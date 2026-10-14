import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/gift_cards/gift_order_draft.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_receipt_records.dart';

void main() {
  test('buy quantities resolve to supported atomic units without rounding up',
      () {
    const order = BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: '10000');
    expect(order.exactCryptoAmount.toString(), '0.00041666');
    const dust = BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: '0.01');
    expect(dust.exactCryptoAmount.isZero, isTrue);
  });
  test('buy preserves exact input above binary float integer precision', () {
    final order = const BuyCryptoOrder(
        asset: BuyCryptoAsset.tether,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: '9007199254740993.01');
    expect(order.exactNgnAmount.toFixed(2), '9007199254740993.01');
  });
  test('gift cost multiplies denomination and quantity before rounding kobos',
      () {
    final draft = const GiftOrderDraft(
        product: GiftCatalogProduct(
            skuId: 'a',
            brandName: 'Amazon',
            country: 'France',
            cardType: GiftCardType.eCode,
            category: 'shopping'),
        denomination: '50.01',
        quantity: 3);
    expect(draft.costMinorUnits, 12977595);
    final receipt = giftCardPreviewReceipt(
        sell: false, occurredAt: DateTime(2026), id: 'exact', draft: draft);
    expect(receipt.amount, '₦129,775.95');
    expect(receipt.fields.firstWhere((f) => f.label == 'Card Value').value,
        '\$150.03');
  });
}
