import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';

ReceiptRecord fixture(String id, {bool preview = true,
    ReceiptStatus status = ReceiptStatus.completed}) => ReceiptRecord(
  id: id, reference: 'reference-$id', type: 'Purchase', status: status,
  occurredAt: DateTime(2026, 10, 13), amount: '0.01 BTC', preview: preview,
  fields: const [ReceiptField(label: 'Destination', value: 'Wallet A')]);

void main() {
  tearDown(() { FundingActivity.reset(); ReceiptActivity.reset(); });

  testWidgets('new preview completes once at 20 seconds with identical facts', (tester) async {
    final original = fixture('new');
    final pending = ReceiptActivity.submitPreview(original);
    expect(pending.status, ReceiptStatus.pending);
    await tester.pump(const Duration(seconds: 19));
    expect(ReceiptActivity.resolve(original).status, ReceiptStatus.pending);
    // Reopening/submitting the same identity cannot restart or duplicate it.
    ReceiptActivity.submitPreview(original);
    await tester.pump(const Duration(seconds: 1));
    final completed = ReceiptActivity.resolve(original);
    expect(completed.status, ReceiptStatus.completed);
    expect(completed.id, original.id);
    expect(completed.reference, original.reference);
    expect(completed.occurredAt, original.occurredAt);
    expect(completed.fields, original.fields);
    expect(ReceiptActivity.records.value, hasLength(1));
  });

  testWidgets('reset cancels old timers including reused identity', (tester) async {
    ReceiptActivity.submitPreview(fixture('same'));
    await tester.pump(const Duration(seconds: 10));
    ReceiptActivity.reset();
    final fresh = ReceiptActivity.submitPreview(fixture('same'));
    await tester.pump(const Duration(seconds: 10));
    expect(ReceiptActivity.resolve(fresh).status, ReceiptStatus.pending);
    await tester.pump(const Duration(seconds: 10));
    expect(ReceiptActivity.resolve(fresh).status, ReceiptStatus.completed);
  });

  testWidgets('historical, failed and provider records never auto complete', (tester) async {
    ReceiptActivity.accept(fixture('history', status: ReceiptStatus.pending));
    ReceiptActivity.submitPreview(fixture('failed', status: ReceiptStatus.failed));
    ReceiptActivity.submitPreview(fixture('provider', preview: false, status: ReceiptStatus.pending));
    await tester.pump(const Duration(seconds: 30));
    expect(ReceiptActivity.records.value.map((r) => r.status),
        [ReceiptStatus.pending, ReceiptStatus.failed, ReceiptStatus.pending]);
  });

  testWidgets('a late failure or provider replacement prevents preview completion', (tester) async {
    ReceiptActivity.submitPreview(fixture('late-failure'));
    ReceiptActivity.submitPreview(fixture('provider-replacement'));
    await tester.pump(const Duration(seconds: 10));
    ReceiptActivity.accept(fixture('late-failure', status: ReceiptStatus.failed));
    ReceiptActivity.accept(fixture('provider-replacement',
        preview: false, status: ReceiptStatus.pending));
    await tester.pump(const Duration(seconds: 10));
    expect(ReceiptActivity.resolve(fixture('late-failure')).status,
        ReceiptStatus.failed);
    expect(ReceiptActivity.resolve(fixture('provider-replacement')).status,
        ReceiptStatus.pending);
  });

  for (final receipt in [false, true]) {
    testWidgets('open ${receipt ? 'export receipt' : 'details'} follows shared status', (tester) async {
      final record = ReceiptActivity.submitPreview(fixture('visible'));
      await tester.pumpWidget(MaterialApp(home: receipt
          ? ReceiptScreen(record: record)
          : TransactionRecordDetailsScreen(record: record)));
      expect(find.text('Pending'), findsWidgets);
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Pending'), findsNothing);
      expect(ReceiptActivity.resolve(record).id, 'visible');
    });
  }

  testWidgets('buy result stays mounted and becomes successful', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuySuccessScreen(
      order: BuyCryptoOrder(asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn, ngnAmount: 240000))));
    expect(find.text('Purchase submitted'), findsOneWidget);
    final id = ReceiptActivity.records.value.single.id;
    await tester.pump(const Duration(seconds: 20));
    await tester.pump();
    expect(find.text('Purchase successful'), findsOneWidget);
    expect(ReceiptActivity.records.value.single.id, id);
  });

  testWidgets('funding history has one consistent row and completes by receipt identity', (tester) async {
    FundingActivity.submitPreview(FundingRecord(id: 'withdrawal',
      direction: FundingDirection.withdrawal, status: FundingStatus.pending,
      amount: 45000, currency: 'NGN', destination: 'Bank A',
      occurredAt: DateTime(2026, 10, 13), preview: true));
    await tester.pumpWidget(const MaterialApp(home: TransactionHistoryScreen()));
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Withdrawal submitted'), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
    await tester.pump();
    expect(find.text('Pending'), findsNothing);
    expect(find.text('Withdrawal successful'), findsOneWidget);
    expect(FundingActivity.records.value.single.status, FundingStatus.completed);
    expect(ReceiptActivity.records.value.single.id,
        FundingActivity.records.value.single.id);
  });
}
