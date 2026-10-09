import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/crypto/presentation/crypto_receipt_records.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';

void main() {
  tearDown(ReceiptActivity.reset);
  test('tiny crypto, pending state and accepted references survive adapter',
      () {
    final r = buildCryptoReceiptRecord(
        kind: TxKind.external,
        target: 'recipient-address',
        amount: 0.00000001,
        status: ReceiptStatus.pending,
        id: 'FULL-ID-1234567890',
        reference: 'BANK-REF',
        occurredAt: DateTime.utc(2026, 10, 7, 12),
        network: 'Bitcoin');
    expect(r.amount, '0.00000001 BTC');
    expect(r.id, 'FULL-ID-1234567890');
    expect(r.status, ReceiptStatus.pending);
    expect(
        r.fields.firstWhere((f) => f.label == 'Destination').sensitive, true);
    expect(
        r.events.where((e) => e.state == ReceiptEventState.complete).length, 1);
    expect(
        r.events
            .where((e) => e.state == ReceiptEventState.current)
            .single
            .occurredAt,
        isNull);
  });
  test('buy adapter retains accepted date, wallet and exact order value', () {
    const order = BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 731540);
    final date = DateTime.utc(2026, 10, 7, 10, 30);
    final r =
        buildBuyReceiptRecord(order, occurredAt: date, id: 'ACCEPTED-ORDER');
    expect(r.occurredAt, date);
    expect(r.id, 'ACCEPTED-ORDER');
    expect(r.fields.firstWhere((f) => f.label == 'Amount paid').value,
        '731,540.00 NGN');
  });
  test('activity replaces updates without downgrading completed records', () {
    final done = buildCryptoReceiptRecord(
        kind: TxKind.sell, target: 'NGN', amount: .03, id: 'same');
    final pending = buildCryptoReceiptRecord(
        kind: TxKind.sell,
        target: 'NGN',
        amount: .03,
        id: 'same',
        status: ReceiptStatus.pending);
    ReceiptActivity.accept(pending);
    ReceiptActivity.accept(done);
    ReceiptActivity.accept(pending);
    expect(ReceiptActivity.records.value, hasLength(1));
    expect(
        ReceiptActivity.records.value.single.status, ReceiptStatus.completed);
  });
  testWidgets('history opens buy with the same October seventh record',
      (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: TransactionHistoryScreen()));
    await tester.tap(find.text('Bought Bitcoin'));
    await tester.pumpAndSettle();
    final details = tester.widget<TransactionRecordDetailsScreen>(
        find.byType(TransactionRecordDetailsScreen));
    expect(details.record.occurredAt, DateTime(2026, 10, 7, 10, 30));
    expect(details.record.amount, '0.03 BTC');
    expect(tester.takeException(), isNull);
  });
}
