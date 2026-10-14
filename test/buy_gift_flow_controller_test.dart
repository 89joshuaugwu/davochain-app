import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_amount_controller.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/gift_cards/presentation/gift_flow_controllers.dart';
import 'package:davochain/features/gift_cards/gift_order_draft.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';

void main() {
  tearDown(() => WalletAccountState.instance.reset());
  test('buy max and percentage keep wallet kobos and reset invalidates input',
      () {
    final flow = BuyAmountController(const BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 0));
    flow.pickPercentage(25);
    expect(flow.amount.toFixed(2), '321125.09');
    flow.pickPercentage(100);
    expect(flow.amount.toFixed(2), '1284500.35');
    expect(flow.canContinue, isTrue);
    WalletAccountState.instance.reset();
    expect(flow.canContinue, isFalse);
    flow.dispose();
  });
  test('gift quantity updates exact total and account reset clears selection',
      () {
    final flow = GiftAmountController();
    flow.product = const GiftCatalogProduct(
        skuId: 'a',
        brandName: 'Amazon',
        country: 'France',
        cardType: GiftCardType.eCode,
        category: 'shopping');
    flow.amount.text = '50.01';
    flow.quantity = 3;
    expect(flow.draft!.costMinorUnits, 12977595);
    WalletAccountState.instance.reset();
    expect(flow.ready, isFalse);
    flow.dispose();
  });
  test('delivery controller retains recipient and validates required email',
      () {
    final flow = GiftDeliveryController();
    flow.forMe = false;
    flow.instant = false;
    expect(flow.delivery.validationError, isNotNull);
    flow.email.text = 'gift@example.com';
    flow.phone.text = '+2348012345678';
    expect(flow.delivery.validationError, isNull);
    expect(flow.delivery.email, 'gift@example.com');
    flow.dispose();
  });
}
