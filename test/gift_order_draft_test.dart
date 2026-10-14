import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/gift_cards/gift_card_repository.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_receipt_records.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('review pricing uses selected catalog terms', (tester) async {
    const chosen = GiftCatalogProduct(skuId: 'amazon-us-ecode-900', brandName: 'Amazon',
      country: 'United States', cardType: GiftCardType.eCode, category: 'shopping', rateNaira: 900);
    await tester.pumpWidget(const MaterialApp(home: GiftCardBuyReviewScreen(
      brand: GiftCardBrand(name: 'Amazon', asset: 'assets/figma_exact/amazon.png'), amount: 50, quantity: 2,
      draft: GiftOrderDraft(product: chosen, denomination: 50, quantity: 2))));
    expect(find.text('₦90,000'), findsWidgets);
    expect(find.text('₦900/\$1'), findsOneWidget);
    expect(find.text('United States Amazon, E-code (50 above)'), findsOneWidget);
  });
  const product = GiftCatalogProduct(skuId: 'amazon-us-ecode', brandName: 'Amazon',
    country: 'United States', cardType: GiftCardType.eCode, category: 'shopping');
  test('receipt retains selected SKU and recipient instead of legacy defaults', () {
    const draft = GiftOrderDraft(product: product, denomination: 50, quantity: 2,
      delivery: GiftDelivery(forMe: false, instant: false, email: 'gift@example.com', phone: '+2348012345678'));
    final receipt = giftCardPreviewReceipt(sell: false, occurredAt: DateTime.utc(2026),
      id: 'test', country: 'France', cardType: 'Physical', draft: draft);
    final fields = {for (final field in receipt.fields) field.label: field.value};
    expect(fields['Country'], 'United States');
    expect(fields['Card type'], 'E-code');
    expect(fields['Quantity'], '2');
    expect(fields['Email'], 'gift@example.com');
    expect(fields['Phone'], '+2348012345678');
    expect(fields['Delivery recipient'], 'Send Gift');
    expect(fields['Delivery method'], 'Email Delivery');
  });
  test('edited delivery invalidates the accepted quote', () {
    final now = DateTime.utc(2026, 10, 14);
    const draft = GiftOrderDraft(product: product, denomination: 50,
      delivery: GiftDelivery(forMe: false, instant: false, email: 'first@example.com'));
    final quote = GiftOrderQuote(id: 'provider-quote', draft: draft,
      expiresAt: now.add(const Duration(minutes: 1)), costMinorUnits: 4325000, catalogVersion: 'v1');
    final edited = draft.withDelivery(const GiftDelivery(forMe: false, instant: false,
      email: 'other@example.com'));
    expect(quote.matches(edited, now: now), isFalse);
    expect(quote.matches(draft, now: now), isTrue);
    expect(quote.matches(draft, now: now.add(const Duration(minutes: 2))), isFalse);
  });
}
