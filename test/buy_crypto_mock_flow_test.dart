import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';

void main() {
  test('buy crypto mock quote is deterministic and local', () {
    const order = BuyCryptoOrder(
      asset: BuyCryptoAsset.bitcoin,
      wallet: BuyFundingWallet.ngn,
      ngnAmount: 731540,
    );

    expect(order.cryptoAmount, closeTo(0.0304808333, 0.0000001));
    expect(order.usdAmount, closeTo(500.0000, 0.01));
  });

  test('mock wallets expose frontend balances without services', () {
    expect(BuyFundingWallet.ngn.balance, 1731540);
    expect(BuyFundingWallet.ngd.balance, 135000);
  });
}
