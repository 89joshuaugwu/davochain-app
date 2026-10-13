import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'support/preview_receipt_fixture.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/shared/widgets/davo_success_mark.dart';
import 'package:davochain/shared/widgets/davo_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  receiptTestWidgets(
      'new preview trades share pending facts and complete on an open receipt',
      (tester) async {
    for (final kind in TxKind.values) {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: TransactionSuccessScreen(
              kind: kind, target: 'bc1qexample', amount: .03)));
      await tester.pumpAndSettle();
      expect(tester.widget<DavoResultScreen>(find.byType(DavoResultScreen)).kind,
          DavoOutcomeKind.submitted);
      final id = ReceiptActivity.records.value.first.id;
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Completed'), findsNothing);
      await tester.tap(find.textContaining('Share').first);
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsWidgets);
      await tester.pump(const Duration(seconds: 20));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Pending'), findsNothing);
      expect(ReceiptActivity.records.value.first.id, id);
      await tester.pumpWidget(const SizedBox());
      ReceiptActivity.reset();
    }
  });
  receiptTestWidgets(
      'preview gift sale completes while historical deposits retain accepted facts',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const GiftCardSellSubmittedScreen()));
    await tester.pumpAndSettle();
    expect(tester.widget<DavoSuccessMark>(find.byType(DavoSuccessMark)).kind,
        DavoOutcomeKind.submitted);
    await tester.pump(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    expect(find.text('Current Trade Status: Completed'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DepositStatusScreen(success: true)));
    expect(
        tester
            .widget<TransactionRecordDetailsScreen>(
                find.byType(TransactionRecordDetailsScreen))
            .record
            .status,
        ReceiptStatus.completed);
    expect(find.byType(DavoSuccessMark), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const DepositStatusScreen(success: false)));
    expect(find.byType(DavoSuccessMark), findsNothing);
    expect(find.text('Pending'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });
}
