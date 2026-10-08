import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/shared/widgets/davo_success_mark.dart';
import 'package:davochain/shared/widgets/davo_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'confirmed trades use check, external submission remains pending through receipt',
      (tester) async {
    for (final kind in TxKind.values) {
      final outcome = kind == TxKind.external
          ? DavoOutcomeKind.submitted
          : DavoOutcomeKind.completed;
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: TransactionSuccessScreen(
              kind: kind,
              target: 'bc1qexample',
              amount: .03,
              outcomeKind: outcome)));
      await tester.pumpAndSettle();
      expect(
          tester.widget<DavoResultScreen>(find.byType(DavoResultScreen)).kind,
          outcome);
      if (outcome == DavoOutcomeKind.submitted) {
        expect(find.text('Withdrawal submitted'), findsOneWidget);
        await tester.tap(find.text('View Details'));
        await tester.pumpAndSettle();
        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('Completed'), findsNothing);
        await tester.tap(find.textContaining('Share').first);
        await tester.pumpAndSettle();
        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('Completed'), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets(
      'submitted gift sale and historical deposits do not imply approval',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const GiftCardSellSubmittedScreen()));
    await tester.pumpAndSettle();
    expect(tester.widget<DavoSuccessMark>(find.byType(DavoSuccessMark)).kind,
        DavoOutcomeKind.submitted);
    await tester.pump(const Duration(minutes: 1));
    expect(find.text('Current Trade Status: Pending'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DepositStatusScreen(success: true)));
    expect(
        tester.widget<DavoSuccessMark>(find.byType(DavoSuccessMark)).progress,
        1);
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
