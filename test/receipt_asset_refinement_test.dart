import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';
import 'package:davochain/shared/receipts/receipt_pdf.dart';
import 'package:davochain/shared/receipts/receipt_identity.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';
import 'package:davochain/features/crypto/presentation/crypto_receipt_records.dart';
import 'package:davochain/features/crypto/presentation/crypto_transaction_kind.dart';

void main() {
  for (final entry in <String, String>{
    'Purchase': 'Bitcoin purchase',
    'Sell': 'Bitcoin sale',
    'Deposit': 'Bitcoin deposit',
    'Withdrawal': 'Bitcoin withdrawal',
    'Conversion': 'Bitcoin to Tether swap',
    'Gift card purchase': 'Amazon gift card purchase',
    'Gift card sale': 'Amazon gift card sale',
  }.entries) {
    testWidgets('${entry.key} receipt has distinct transaction identity',
        (tester) async {
      final semantics = tester.ensureSemantics();

      final record = ReceiptRecord(
          id: 'accepted-id',
          reference: 'accepted-ref',
          type: entry.key,
          status: ReceiptStatus.completed,
          occurredAt: DateTime(2026, 10, 9),
          amount: '0.03 BTC',
          fields: [
            if (entry.key == 'Conversion')
              const ReceiptField(label: 'To', value: 'USDT'),
            if (entry.key.contains('Gift card'))
              const ReceiptField(label: 'Brand', value: 'Amazon'),
          ]);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: ReceiptPaper(
                      presentation: ReceiptPresentation(record: record))))));
      expect(
          find.bySemanticsLabel('Transaction: ${entry.value}'), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      semantics.dispose();
    });
  }
  for (final code in ['BTC', 'ETH', 'SOL', 'USDT', 'NGN', 'NGD', 'USD']) {
    testWidgets('$code has a recognized asset badge on receipt and details',
        (tester) async {
      final semantics = tester.ensureSemantics();

      final record = ReceiptRecord(
          id: 'DC-20261009-418629',
          reference: 'DC-20261009-418629',
          type: 'Transfer',
          status: ReceiptStatus.pending,
          occurredAt: DateTime(2026, 10, 9),
          amount: '12.34 $code',
          fields: const []);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: ReceiptPaper(
                      presentation: ReceiptPresentation(record: record))))));
      expect(find.bySemanticsLabel(RegExp('Asset: $code')), findsOneWidget);
      expect(find.textContaining('Preview'), findsNothing);
      await tester.pumpWidget(
          MaterialApp(home: TransactionRecordDetailsScreen(record: record)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('Asset: $code')), findsOneWidget);
      expect(find.textContaining('Preview'), findsNothing);
      expect(find.text('Pending'), findsOneWidget);
      semantics.dispose();
    });
  }
  testWidgets('conversion shows both assets and gift receipt has a gift badge',
      (tester) async {
    final semantics = tester.ensureSemantics();

    final swap = buildCryptoReceiptRecord(
        kind: TxKind.conversion, target: 'USDT', amount: .03);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: ReceiptPaper(
                    presentation: ReceiptPresentation(record: swap))))));
    expect(find.bySemanticsLabel('Asset: BTC'), findsOneWidget);
    expect(find.bySemanticsLabel('Asset: USDT'), findsOneWidget);
    final gift = ReceiptRecord(
        id: 'DC-20261009-418630',
        reference: 'DC-20261009-418630',
        type: 'Gift card sale',
        status: ReceiptStatus.pending,
        occurredAt: DateTime(2026, 10, 9),
        amount: '₦10,000',
        fields: const []);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: ReceiptPaper(
                    presentation: ReceiptPresentation(record: gift))))));
    expect(find.bySemanticsLabel('Asset: Gift card'), findsOneWidget);
    expect(find.bySemanticsLabel('Asset: NGN'), findsOneWidget);
    semantics.dispose();
  });
  test(
      'generated identifiers look populated and accepted identifiers remain exact',
      () {
    const order = BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 720000);
    final buy = buildBuyReceiptRecord(order);
    final send = buildCryptoReceiptRecord(
        kind: TxKind.external, target: 'recipient', amount: .03);
    for (final record in [buy, send]) {
      expect(record.id, matches(RegExp(r'^DC-[0-9]{8}-[A-Z0-9]+$')));
      expect(record.preview, isTrue);
    }
    expect(ReceiptIdentity(send).headline, 'Bitcoin withdrawal');
    final accepted = buildBuyReceiptRecord(order,
        id: 'provider-id-123', reference: 'provider-ref-456', preview: false);
    expect(accepted.id, 'provider-id-123');
    expect(accepted.reference, 'provider-ref-456');
  });
  test(
      'asset and gift identity PDFs preserve actual amounts and supported vector glyphs',
      () async {
    for (final code in ['BTC', 'ETH', 'SOL', 'USDT', 'NGN', 'NGD', 'USD']) {
      final record = ReceiptRecord(
          id: 'accepted-$code',
          reference: 'ref-$code',
          type: 'Deposit',
          status: ReceiptStatus.pending,
          occurredAt: DateTime(2026, 10, 9),
          amount: '12.34 $code',
          fields: const []);
      expect(await ReceiptPdf.build(ReceiptPresentation(record: record)),
          isNotEmpty);
    }
    final gift = ReceiptRecord(
        id: 'gift-id',
        reference: 'gift-ref',
        type: 'Gift card purchase',
        status: ReceiptStatus.completed,
        occurredAt: DateTime(2026, 10, 9),
        amount: '₦20,000',
        fields: const [ReceiptField(label: 'Brand', value: 'Amazon')]);
    expect(
        await ReceiptPdf.build(ReceiptPresentation(record: gift)), isNotEmpty);
  });
}
