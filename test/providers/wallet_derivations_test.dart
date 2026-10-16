import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:davochain/core/providers/account_scope.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/wallets/quote_repository.dart';
import 'package:davochain/features/dashboard/presentation/portfolio_view_state.dart';

void main() {
  test('portfolio excludes cash and zero allocation stays finite', () {
    final engine = WalletAccountState()..startSimulation(empty: true);
    final container = ProviderContainer(
      overrides: [walletEngineProvider.overrideWithValue(engine)],
    );
    addTearDown(container.dispose);
    final empty = container.read(portfolioViewProvider);
    expect(empty.totalMinorUnits, 0);
    expect(empty.allocation, isEmpty);
    engine.applyEffect(
      'fund',
      engine.effect(credits: {'NGN': '100000', 'BTC': '0.01'}),
      completed: true,
      failed: false,
    );
    final state = PortfolioViewState.fromSnapshot(engine.snapshot);
    expect(state.totalMinorUnits, engine.snapshot.valuationMinorUnits('BTC'));
    expect(state.allocation.single.asset, 'BTC');
    expect(state.allocation.single.percent, 100);
  });
  test(
    'quote reviews expire and streamed prices change valuation without changing quantity',
    () async {
      final engine = WalletAccountState()..startSimulation(empty: true);
      engine.applyEffect(
        'coin',
        engine.effect(credits: {'BTC': '1'}),
        completed: true,
        failed: false,
      );
      final quotes = MutableQuoteSource();
      addTearDown(quotes.dispose);
      final repo = QuoteRepository(quotes);
      final locked = repo.current;
      final quantity = engine.snapshot.available('BTC').atomicUnits;
      final next = QuoteSnapshot(
        id: 'next',
        asOf: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
        pricesMinorUnits: {...locked.pricesMinorUnits, 'BTC': 20000},
        usdNgnMinorUnits: 133004,
      );
      final future = repo.watch().first;
      quotes.publish(next);
      expect((await future).id, 'next');
      engine.updateQuotes(next);
      expect(engine.snapshot.available('BTC').atomicUnits, quantity);
      expect(engine.snapshot.valuationMinorUnits('BTC'), 20000);
      expect(locked.matches(next, DateTime.now()), isFalse);
      expect(
        next.matches(next, DateTime.now().add(const Duration(minutes: 2))),
        isFalse,
      );
      expect(quotes.publish(locked), isFalse);
    },
  );
}
