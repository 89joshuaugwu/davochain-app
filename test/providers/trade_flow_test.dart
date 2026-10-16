import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/wallets/quote_repository.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';

void main() {
  setUp(() => WalletAccountState.instance.startSimulation(empty: false));
  tearDown(() => WalletAccountState.instance.reset());
  test(
    'review locks exact quantity and rejects a changed or expired quote',
    () {
      final wallet = WalletAccountState.instance;
      final old = QuoteSnapshot.offline();
      wallet.updateQuotes(old);
      final order = const BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 10000,
      ).freezeQuote();
      final quantity = order.exactCryptoAmount.toString();
      final next = QuoteSnapshot(
        id: 'new-price',
        asOf: DateTime.now(),
        pricesMinorUnits: {
          ...old.pricesMinorUnits,
          'BTC': old.pricesMinorUnits['BTC']! * 2,
        },
        usdNgnMinorUnits: old.usdNgnMinorUnits,
      );
      wallet.updateQuotes(next);
      expect(order.exactCryptoAmount.toString(), quantity);
      expect(order.quoteCurrent, isFalse);
      expect(
        order.copyWith(ngnAmount: 10000).exactCryptoAmount.toString(),
        quantity,
      );
      final fresh = order
          .copyWith(asset: BuyCryptoAsset.ethereum)
          .freezeQuote();
      expect(fresh.quoteCurrent, isTrue);
    },
  );
  test(
    'a reviewed buy cannot authorize a different account at the same quote',
    () {
      final wallet = WalletAccountState.instance;
      final order = const BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 10000,
      ).freezeQuote();
      wallet.startSimulation(empty: false);
      expect(order.quoteCurrent, isFalse);
    },
  );
}
