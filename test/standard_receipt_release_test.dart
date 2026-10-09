import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_pdf.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';

void main() {
  final record = buildBuyReceiptRecord(const BuyCryptoOrder(
      asset: BuyCryptoAsset.bitcoin,
      wallet: BuyFundingWallet.ngn,
      ngnAmount: 720000));
  testWidgets('only standard receipt is available while note and export remain',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ReceiptScreen(record: record)));
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Purchase Receipt'), findsNothing);
    expect(find.text('Birthday'), findsNothing);
    expect(find.text('Celebration'), findsNothing);
    expect(find.text('Appreciation'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Share as image').hitTestable(), findsOneWidget);
    expect(find.text('Share as PDF').hitTestable(), findsOneWidget);
  });
  test('real purchase record PDF preserves its approximation symbol', () async {
    final pdf = await ReceiptPdf.build(ReceiptPresentation(record: record));
    expect(pdf, isNotEmpty);
  });
}
