import 'package:davochain/features/dashboard/portfolio_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/portfolio_performance_screen.dart';

void main() {
  test('immutable snapshot reuses sorted period projection between inspections',
      () {
    final now = DateTime.utc(2026, 10, 14);
    final snapshot = PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 500),
        history: [
          PortfolioValuePoint(
              timestamp: now.subtract(const Duration(days: 2)), valueKobo: 100),
          PortfolioValuePoint(
              timestamp: now.subtract(const Duration(hours: 1)),
              valueKobo: 200),
          PortfolioValuePoint(timestamp: now, valueKobo: 300),
        ]);
    final day = snapshot.pointsFor(PortfolioPerformancePeriod.day);
    expect(day.map((point) => point.valueKobo), [200, 500]);
    expect(identical(day, snapshot.pointsFor(PortfolioPerformancePeriod.day)),
        isTrue);
    expect(() => day.clear(), throwsUnsupportedError);
    expect(snapshot.pointsFor(PortfolioPerformancePeriod.all).length, 3);
    expect(identical(day, snapshot.pointsFor(PortfolioPerformancePeriod.all)),
        isFalse);
    final replacement = PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 700));
    expect(
        replacement.pointsFor(PortfolioPerformancePeriod.day).single.valueKobo,
        700);
  });
  testWidgets(
      'unchanged chart painter skips repaint but new selection repaints',
      (tester) async {
    final now = DateTime.utc(2026, 10, 14);
    final controller = PortfolioPerformanceController(
        PortfolioPerformanceSnapshot(
            current: PortfolioValuePoint(timestamp: now, valueKobo: 500),
            history: [
          PortfolioValuePoint(
              timestamp: now.subtract(const Duration(hours: 1)), valueKobo: 100)
        ]));
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: PortfolioPerformanceScreen(controller: controller)));
    await tester.pumpAndSettle();
    final chart = find.byKey(const ValueKey('portfolio-chart'));
    final paint =
        find.descendant(of: chart, matching: find.byType(CustomPaint)).first;
    final dynamic before = tester.widget<CustomPaint>(paint).painter!;
    expect(before.shouldRepaint(before), isFalse);
    await tester.tapAt(tester.getTopLeft(chart) + const Offset(14, 50));
    await tester.pump();
    final dynamic after = tester.widget<CustomPaint>(paint).painter!;
    expect(after.shouldRepaint(before), isTrue);
    expect(tester.takeException(), isNull);
  });
}
