import 'package:davochain/core/money/money.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decimal parsing retains exact atomic units and rejects excess precision', () {
    expect(AssetAmount.parse('0.00000001', 'BTC', 8).atomicUnits, BigInt.one);
    expect(AssetAmount.parse('12345678901234567890.35', 'NGN', 2).atomicUnits,
        BigInt.parse('1234567890123456789035'));
    for (final invalid in ['NaN', 'Infinity', '-1', '0.000000001', '1e3', '1,23']) {
      expect(() => AssetAmount.parse(invalid, 'BTC', 8), throwsFormatException);
    }
  });
  test('funding wallet and account share available balance and formatted value', () {
    final state = WalletAccountState.instance;
    expect(BuyFundingWallet.ngn.balance, state.ngnAvailableMinorUnits / 100);
    expect(BuyFundingWallet.ngn.formattedBalance, state.ngnBalanceLabel);
    expect(state.snapshot.available('BTC').decimal, '0.0086');
    expect(state.snapshot.valuationMinorUnits('BTC'), 20640000);
  });
  test('old-account snapshot cannot restore state after a reset', () {
    final state = WalletAccountState.instance;
    final generation = state.generation;
    final old = state.snapshot;
    state.reset();
    expect(state.publish(old, generation: generation), isFalse);
  });
}
