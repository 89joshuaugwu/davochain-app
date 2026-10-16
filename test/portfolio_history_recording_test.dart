import 'package:davochain/features/dashboard/portfolio_performance.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/dashboard/portfolio_valuation_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unchanged current value still anchors period selection to today', () {
    final wallet = WalletAccountState.instance..startSimulation(empty: true);
    final account = wallet.snapshot.accountId;
    final history = PortfolioValuationHistory.instance;
    history.record(
      account,
      10000,
      DateTime.now().toUtc().subtract(const Duration(days: 40)),
    );
    history.record(
      account,
      0,
      DateTime.now().toUtc().subtract(const Duration(days: 35)),
    );
    final controller = PortfolioPerformanceController();
    expect(
      DateTime.now()
          .toUtc()
          .difference(controller.value.current.timestamp)
          .inSeconds,
      lessThan(2),
    );
    expect(
      controller.value.pointsFor(PortfolioPerformancePeriod.day),
      hasLength(1),
    );
    controller.dispose();
    wallet.reset();
  });
  test(
    'live controller keeps an unchanged observed valuation as one point',
    () {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      final account = wallet.snapshot.accountId;
      PortfolioValuationHistory.instance.record(
        account,
        wallet.snapshot.portfolioMinorUnits,
        DateTime.now().toUtc(),
      );
      final controller = PortfolioPerformanceController();
      expect(
        controller.value.pointsFor(PortfolioPerformancePeriod.all),
        hasLength(1),
      );
      controller.dispose();
      wallet.reset();
    },
  );
  test(
    'actual changes create history; identical refresh does not invent a trend',
    () {
      final history = PortfolioValuationHistory();
      history.record('a', 10000, DateTime.utc(2026, 10, 16, 10));
      history.record('a', 10000, DateTime.utc(2026, 10, 16, 11));
      expect(history.points('a'), hasLength(1));
      history.record('a', 20000, DateTime.utc(2026, 10, 16, 12));
      expect(history.points('a'), hasLength(2));
      final restored = PortfolioValuationHistory()
        ..restore('a', history.export('a'));
      expect(restored.points('a').last.valueKobo, 20000);
      expect(restored.points('b'), isEmpty);
    },
  );
}
