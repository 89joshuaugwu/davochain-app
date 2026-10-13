import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BTC review and receipt show the same quantity and asset rate',
      (tester) async {
    const order = BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 10000);
    final receipt = buildBuyReceiptRecord(order);
    expect(receipt.amount, '0.00041667 BTC');
    final rate = receipt.fields
        .firstWhere((field) => field.label == 'Exchange Rate')
        .value;
    await tester
        .pumpWidget(const MaterialApp(home: BuyReviewScreen(order: order)));
    await tester.pumpAndSettle();
    expect(find.text(rate), findsOneWidget);
    expect(find.text(receipt.amount), findsOneWidget);
  });
}
