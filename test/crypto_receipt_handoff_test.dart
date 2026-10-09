import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/preview_transaction_operation.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';

void main() {
  tearDown(ReceiptActivity.reset);
  testWidgets(
      'withdrawal acceptance carries network fee and tiny asset amount into details',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: TransactionProgressScreen(
            kind: TxKind.external,
            target: '0xrecipient',
            amount: .000000001,
            asset: BuyCryptoAsset.ethereum,
            network: 'Ethereum',
            fee: .00002,
            operation: Future.value(PreviewTransactionOutcome.submitted))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();
    final record = tester
        .widget<TransactionRecordDetailsScreen>(
            find.byType(TransactionRecordDetailsScreen))
        .record;
    expect(record.amount, '0.000000001 ETH');
    expect(record.fields.firstWhere((f) => f.label == 'Network').value,
        'Ethereum');
    expect(record.fields.firstWhere((f) => f.label == 'Network Fee').value,
        '0.00002 ETH');
  });
}
