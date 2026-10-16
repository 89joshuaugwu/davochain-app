import 'package:davochain/features/wallets/quote_repository.dart';
import 'package:davochain/features/wallets/wallet_valuation.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'naira and USD equivalents use the same dated quote and exact rounding',
    () {
      final state = WalletAccountState()..startSimulation(empty: false);
      state.updateQuotes(QuoteSnapshot.offline());
      final value = WalletValuation.forAsset(
        state.snapshot,
        'BTC',
        quote: state.activeQuote,
      );
      expect(value.nairaMinorUnits, state.snapshot.valuationMinorUnits('BTC'));
      expect(
        value.usdMinorUnits,
        value.nairaMinorUnits * 100 ~/ state.snapshot.usdNgnMinorUnits!,
      );
      expect(value.asOf, state.activeQuote!.asOf);
      expect(
        WalletValuation.forAsset(
          state.snapshot,
          'NGN',
          quote: state.activeQuote,
        ).nairaMinorUnits,
        state.ngnAvailableMinorUnits,
      );
      state.dispose();
    },
  );
  test('mismatched or expired quote hides the USD estimate', () {
    final state = WalletAccountState()..startSimulation(empty: false);
    final base = QuoteSnapshot.offline();
    final mismatched = QuoteSnapshot(
      id: 'other',
      asOf: base.asOf,
      pricesMinorUnits: {...base.pricesMinorUnits, 'BTC': 1},
      usdNgnMinorUnits: base.usdNgnMinorUnits,
    );
    expect(
      WalletValuation.forAsset(
        state.snapshot,
        'BTC',
        quote: mismatched,
      ).usdMinorUnits,
      isNull,
    );
    final expired = QuoteSnapshot(
      id: 'expired',
      asOf: base.asOf,
      expiresAt: DateTime.utc(2020),
      pricesMinorUnits: base.pricesMinorUnits,
      usdNgnMinorUnits: base.usdNgnMinorUnits,
    );
    expect(
      WalletValuation.forAsset(
        state.snapshot,
        'BTC',
        quote: expired,
      ).usdMinorUnits,
      isNull,
    );
    state.dispose();
  });
}
