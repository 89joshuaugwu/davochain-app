import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => PreviewAccountState.setupComplete.value = false);
  tearDown(() => PreviewAccountState.setupComplete.value = false);
  testWidgets('three complete assets fit and only assets scroll',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final viewport = find.byKey(const ValueKey('dashboard-assets'));
    expect(viewport, findsOneWidget);
    final visible = tester.getRect(viewport);
    final scrollable = tester.state<ScrollableState>(find.descendant(of: viewport, matching: find.byType(Scrollable)));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    final fourthBefore = tester.getRect(find.byKey(const ValueKey('dashboard-asset-USDC')));
    expect(fourthBefore.bottom, greaterThan(visible.bottom));
    for (final code in ['BTC', 'ETH', 'USDT']) {
      final row = tester.getRect(find.byKey(ValueKey('dashboard-asset-$code')));
      expect(row.top, greaterThanOrEqualTo(visible.top));
      expect(row.bottom, lessThanOrEqualTo(visible.bottom));
    }
    final promo =
        find.text('Turn your Crypto and\nGift Cards into cash\ninstantly');
    final before = tester.getRect(promo);
    await tester.drag(viewport, const Offset(0, -170));
    await tester.pumpAndSettle();
    expect(tester.getRect(promo), before);
    expect(find.text('USD Coin').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'successful preview setup removes banner and reveals all four assets',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(DavochainDashboardScreen));
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const FullyVerifiedV12Screen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Finish setting up your account'), findsNothing);
    final viewport =
        tester.getRect(find.byKey(const ValueKey('dashboard-assets')));
    for (final code in ['BTC', 'ETH', 'USDT', 'USDC']) {
      final row = tester.getRect(find.byKey(ValueKey('dashboard-asset-$code')));
      expect(row.top, greaterThanOrEqualTo(viewport.top));
      expect(row.bottom, lessThanOrEqualTo(viewport.bottom));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('short phone keeps all dashboard controls reachable',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('dashboard-assets')));
    expect(find.byKey(const ValueKey('dashboard-assets')).hitTestable(),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
