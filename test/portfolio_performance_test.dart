import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/portfolio_performance.dart';
import 'package:davochain/features/dashboard/presentation/portfolio_performance_screen.dart';
import 'package:davochain/shared/widgets/davo_refresh_region.dart';
import 'package:davochain/shared/widgets/davo_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 13, 12);
  PortfolioPerformanceSnapshot history() => PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 128450035),
        history: [
          PortfolioValuePoint(
              timestamp: now.subtract(const Duration(days: 400)),
              valueKobo: 100000000),
          PortfolioValuePoint(
              timestamp: now.subtract(const Duration(days: 20)),
              valueKobo: 110000000),
          PortfolioValuePoint(
              timestamp: now.subtract(const Duration(hours: 12)),
              valueKobo: 120000000),
        ],
        performance: const {
          PortfolioPerformancePeriod.all:
              PortfolioAdjustedPerformance(changeKobo: 2500, percent: .02)
        },
      );

  Future<void> show(WidgetTester tester,
      {PortfolioPerformanceController? controller,
      bool visible = true,
      PortfolioPerformanceLoader? loader,
      double scale = 1,
      DavoRefreshDelegate? onRefresh}) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: DavoRefreshScope(
            onRefresh: onRefresh ?? (_) async {},
            child: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: PortfolioPerformanceScreen(
                    controller: controller,
                    loader: loader,
                    initialValueVisible: visible)))));
    await tester.pump();
  }

  test('periods filter chronological data and preserve exact current kobo', () {
    final snapshot = history();
    expect(snapshot.pointsFor(PortfolioPerformancePeriod.day).length, 2);
    expect(snapshot.pointsFor(PortfolioPerformancePeriod.month).length, 3);
    expect(snapshot.pointsFor(PortfolioPerformancePeriod.year).length, 3);
    expect(snapshot.pointsFor(PortfolioPerformancePeriod.all).length, 4);
    expect(snapshot.pointsFor(PortfolioPerformancePeriod.all).last.valueKobo,
        128450035);
    expect(formatPortfolioNaira(128450035), '₦1,284,500.35');
    expect(formatPortfolioNaira(-1), '−₦0.01');
    expect(
        () => snapshot.history.add(snapshot.current), throwsUnsupportedError);
  });

  test('cash deposits cannot imply investment returns', () {
    final snapshot = history();
    expect(snapshot.performance[PortfolioPerformancePeriod.day], isNull);
    expect(
        snapshot.performance[PortfolioPerformancePeriod.all]!.changeKobo, 2500);
    expect(
        snapshot.pointsFor(PortfolioPerformancePeriod.day).last.valueKobo -
            snapshot.pointsFor(PortfolioPerformancePeriod.day).first.valueKobo,
        8450035);
  });

  testWidgets('initial snapshot has current point and neutral history state',
      (tester) async {
    await show(tester);
    expect(find.text('₦1,824,588.00'), findsOneWidget);
    expect(find.text('Your first valuation'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.byKey(const ValueKey('portfolio-chart')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('period changes and chart gestures inspect real valuations',
      (tester) async {
    final controller = PortfolioPerformanceController(history());
    addTearDown(controller.dispose);
    await show(tester, controller: controller);
    final chart = find.byKey(const ValueKey('portfolio-chart'));
    await tester.tapAt(tester.getTopLeft(chart) + const Offset(14, 60));
    await tester.pump();
    expect(find.text('₦1,100,000.00'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('portfolio-period-1D')));
    await tester.pump();
    expect(
        tester
            .widget<ChoiceChip>(
                find.byKey(const ValueKey('portfolio-period-1D')))
            .selected,
        isTrue);
    await tester.tapAt(tester.getTopLeft(chart) + const Offset(14, 60));
    await tester.pump();
    expect(find.text('₦1,200,000.00'), findsOneWidget);
    await tester.dragFrom(tester.getTopLeft(chart) + const Offset(14, 60),
        Offset(tester.getSize(chart).width - 28, 0));
    await tester.pump();
    expect(find.text('₦1,284,500.35'), findsOneWidget);
  });

  testWidgets('incoming snapshots update screen and reset selected point',
      (tester) async {
    final controller = PortfolioPerformanceController(history());
    addTearDown(controller.dispose);
    await show(tester, controller: controller);
    await tester.tapAt(
        tester.getTopLeft(find.byKey(const ValueKey('portfolio-chart'))) +
            const Offset(14, 60));
    controller.value = PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 500));
    await tester.pump();
    expect(find.text('₦5.00'), findsOneWidget);
    expect(find.text('Latest valuation'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    // Supplied controllers remain owned by their account/repository.
    controller.value = history();
  });

  testWidgets(
      'refresh delegates the selected range and receives repository state',
      (tester) async {
    final controller = PortfolioPerformanceController(history());
    addTearDown(controller.dispose);
    DavoRefreshRequest? request;
    await show(tester, controller: controller, onRefresh: (incoming) async {
      request = incoming;
      controller.value = PortfolioPerformanceSnapshot(
          current: PortfolioValuePoint(timestamp: now, valueKobo: 999));
    });
    await tester.tap(find.byKey(const ValueKey('portfolio-period-1W')));
    await tester.pump();
    await tester
        .widget<DavoFloatingRefresh>(find.byType(DavoFloatingRefresh))
        .onRefresh();
    await tester.pump();
    expect(request!.target, DavoRefreshTarget.portfolioPerformance);
    expect(request!.period, '1W');
    expect(find.text('₦9.99'), findsOneWidget);
  });

  testWidgets(
      'investment returns are only shown for their server-supplied period',
      (tester) async {
    final controller = PortfolioPerformanceController(history());
    addTearDown(controller.dispose);
    await show(tester, controller: controller);
    expect(find.textContaining('0.02%'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('portfolio-period-All')));
    await tester.pump();
    expect(find.text('+₦25.00 (+0.02%)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('portfolio-period-1D')));
    await tester.pump();
    expect(find.textContaining('0.02%'), findsNothing);
    expect(find.text('Includes deposits and withdrawals.'), findsOneWidget);
  });

  testWidgets('hidden mode conceals every value including chart semantics',
      (tester) async {
    final controller = PortfolioPerformanceController(history());
    addTearDown(controller.dispose);
    final semantics = tester.ensureSemantics();
    await show(tester, controller: controller, visible: false);
    expect(find.textContaining('₦'), findsNothing);
    expect(find.byKey(const ValueKey('portfolio-chart')), findsNothing);
    expect(find.byType(Slider), findsNothing);
    await tester.tap(find.byTooltip('Show portfolio values'));
    await tester.pump();
    expect(find.text('₦1,284,500.35'), findsOneWidget);
    semantics.dispose();
  });
  testWidgets('compact large text and dark theme scroll without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: PortfolioPerformanceScreen())));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('stale loader results cannot replace a newer period',
      (tester) async {
    final controller = PortfolioPerformanceController(history());
    addTearDown(controller.dispose);
    final day = Completer<PortfolioPerformanceSnapshot>();
    final all = Completer<PortfolioPerformanceSnapshot>();
    await show(tester,
        controller: controller,
        loader: (period) => period == PortfolioPerformancePeriod.month
            ? Future.value(history())
            : period == PortfolioPerformancePeriod.day
                ? day.future
                : all.future);
    await tester.tap(find.byKey(const ValueKey('portfolio-period-1D')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('portfolio-period-All')));
    all.complete(PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 100)));
    await tester.pump();
    day.complete(PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 200)));
    await tester.pump();
    expect(controller.value.current.valueKobo, 100);
  });
}
