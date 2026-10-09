import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/shared/widgets/davo_result_screen.dart';
import 'package:davochain/shared/widgets/davo_success_mark.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';

ReceiptRecord update(ReceiptStatus status) => ReceiptRecord(
    id: 'accepted-order',
    reference: 'provider-reference',
    type: 'Purchase',
    status: status,
    occurredAt:
        DateTime.utc(2026, 10, 9, status == ReceiptStatus.pending ? 9 : 10),
    amount: '0.01 BTC',
    preview: false,
    fields: const []);

void main() {
  tearDown(ReceiptActivity.reset);
  for (final entry in <String, IconData>{
    'Purchase': Icons.add_circle_outline,
    'Transfer': Icons.north_east,
    'External Transfer': Icons.north_east
  }.entries) {
    testWidgets('${entry.key} details show the correct money direction',
        (tester) async {
      final record = ReceiptRecord(
          id: 'direction',
          reference: 'ref',
          type: entry.key,
          status: ReceiptStatus.completed,
          occurredAt: DateTime(2026, 10, 9),
          amount: '0.01 BTC',
          fields: const []);
      await tester.pumpWidget(
          MaterialApp(home: TransactionRecordDetailsScreen(record: record)));
      expect(find.byIcon(entry.value), findsOneWidget);
    });
  }
  testWidgets(
      'normal sell outcome uses the same computed proceeds as its record',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TransactionSuccessScreen(
            kind: TxKind.sell, target: 'NGN', amount: .03)));
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(find.byWidgetPredicate((widget) =>
        widget is Text &&
        widget.textSpan
                ?.toPlainText()
                .startsWith('You have successfully sold') ==
            true));
    expect(text.textSpan!.toPlainText(), contains('₦720,000.00'));
    expect(text.textSpan!.toPlainText(), isNot(contains('731,540.00')));
  });
  test('failed purchase event describes failure instead of waiting', () {
    final record = buildBuyReceiptRecord(
        const BuyCryptoOrder(
            asset: BuyCryptoAsset.bitcoin,
            wallet: BuyFundingWallet.ngn,
            ngnAmount: 240000),
        status: ReceiptStatus.failed);
    expect(record.events.single.description.toLowerCase(), contains('failed'));
    expect(record.events.single.description, isNot(contains('awaiting')));
  });
  for (final buy in [true, false]) {
    for (final status in ReceiptStatus.values) {
      testWidgets(
          '${buy ? 'buy' : 'crypto'} outcome honors accepted $status and amount',
          (tester) async {
        final record = update(status);
        await tester.pumpWidget(MaterialApp(
            home: buy
                ? BuySuccessScreen(
                    order: const BuyCryptoOrder(
                        asset: BuyCryptoAsset.bitcoin,
                        wallet: BuyFundingWallet.ngn,
                        ngnAmount: 720000),
                    record: record)
                : TransactionSuccessScreen(
                    kind: TxKind.external,
                    target: 'address',
                    amount: .03,
                    record: record)));
        await tester.pumpAndSettle();
        final result =
            tester.widget<DavoResultScreen>(find.byType(DavoResultScreen));
        if (status == ReceiptStatus.failed) {
          expect(result.mark, isNotNull);
          expect(result.title.toLowerCase(), contains('failed'));
        } else {
          expect(
              result.kind,
              status == ReceiptStatus.completed
                  ? DavoOutcomeKind.completed
                  : DavoOutcomeKind.submitted);
        }
        expect(result.message, contains('0.01 BTC'));
        expect(result.message, isNot(contains('0.03 BTC')));
      });
    }
  }
  for (final buy in [true, false]) {
    testWidgets(
        '${buy ? 'buy' : 'crypto'} details reflect accepted record updates',
        (tester) async {
      Widget page(ReceiptRecord record) => buy
          ? BuyTransactionDetailsScreen(
              key: const ValueKey('details'),
              order: const BuyCryptoOrder(
                  asset: BuyCryptoAsset.bitcoin,
                  wallet: BuyFundingWallet.ngn,
                  ngnAmount: 240000),
              record: record)
          : TransactionDetailsScreen(
              key: const ValueKey('details'),
              kind: TxKind.external,
              target: 'address',
              amount: .01,
              record: record);
      await tester
          .pumpWidget(MaterialApp(home: page(update(ReceiptStatus.pending))));
      await tester.pumpAndSettle();
      await tester
          .pumpWidget(MaterialApp(home: page(update(ReceiptStatus.completed))));
      await tester.pumpAndSettle();
      final details = tester.widget<TransactionRecordDetailsScreen>(
          find.byType(TransactionRecordDetailsScreen));
      expect(details.record.status, ReceiptStatus.completed);
      expect(details.record.occurredAt.hour, 10);
    });
  }
}
