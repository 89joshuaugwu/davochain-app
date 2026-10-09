import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/motion/davo_working_indicator.dart';
import 'package:davochain/shared/widgets/davo_success_mark.dart';

void main() {
  setUp(ReceiptActivity.reset);
  Future<void> show(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: child));
    await tester.pump(const Duration(seconds: 2));
  }

  ReceiptRecord terminalRecord(ReceiptStatus status) => ReceiptRecord(
        id: 'terminal-gift-${status.name}',
        reference: 'gift-provider-reference',
        type: 'Gift card trade',
        status: status,
        occurredAt: DateTime.utc(2026, 9, 1, 12),
        amount: '₦12,300',
        preview: false,
        fields: const [],
      );

  for (final sell in [false, true]) {
    testWidgets(
        'failed gift ${sell ? 'sell' : 'buy'} never uses pending or success art',
        (tester) async {
      final record = terminalRecord(ReceiptStatus.failed);
      await show(
          tester,
          sell
              ? GiftCardSellSubmittedScreen(record: record)
              : GiftCardBuySuccessScreen(
                  amount: 10, naira: 12300, record: record));
      expect(find.byType(DavoSuccessMark), findsNothing);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.textContaining('Failed'), findsWidgets);
    });
  }

  for (final status in [ReceiptStatus.completed, ReceiptStatus.failed]) {
    testWidgets('${status.label} gift verification stops pending indicator',
        (tester) async {
      await show(
          tester, GiftCardVerificationScreen(record: terminalRecord(status)));
      expect(find.byType(DavoWorkingIndicator), findsNothing);
      expect(find.text('Verifying your card...'), findsNothing);
      expect(find.text('Card trade ${status.label}'), findsOneWidget);
    });
  }

  testWidgets('buy outcome opens receipt with actual purchase amount',
      (tester) async {
    await show(
        tester, const GiftCardBuySuccessScreen(amount: 75, naira: 64875));
    expect(find.text('Save New Trade'), findsNothing);
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('64,875'), findsWidgets);
    expect(find.textContaining('Preview'), findsNothing);
  });

  testWidgets(
      'sell outcome provides receipt separately from pending verification',
      (tester) async {
    await show(tester, const GiftCardSellSubmittedScreen());
    expect(find.text('View Receipt'), findsOneWidget);
    expect(find.text('Track Verification'), findsOneWidget);
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsWidgets);
    expect(find.textContaining('Preview'), findsNothing);
  });

  testWidgets('submitted sell receipt retains reviewed brand and amount',
      (tester) async {
    await show(
        tester,
        const GiftCardSellReviewScreen(
          brand: GiftCardBrand(
              name: 'Steam', asset: 'assets/figma_exact/steam.png'),
          amount: 80,
          cardType: 'France Steam, E-code (50 above)',
        ));
    await tester.ensureVisible(find.text('I have read and accepted the terms'));
    await tester.tap(find.text('I have read and accepted the terms'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('I confirm this card is valid'));
    await tester.tap(find.text('I confirm this card is valid'));
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('₦69,200'), findsOneWidget);
    expect(find.text('\$500.00'), findsNothing);
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Steam'), findsWidgets);
    expect(find.text('France Steam, E-code (50 above)'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets(
      'buy receipt uses accepted pending record and never duplicates history on rebuild',
      (tester) async {
    final record = ReceiptRecord(
        id: 'accepted-buy-123',
        reference: 'provider-456',
        type: 'Gift card purchase',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.utc(2026, 9, 1, 12),
        amount: '₦12,300',
        preview: false,
        fields: const [ReceiptField(label: 'Quantity', value: '3')]);
    await show(tester,
        GiftCardBuySuccessScreen(amount: 99, naira: 999, record: record));
    expect(find.text('Completed'), findsNothing);
    expect(ReceiptActivity.records.value.single, same(record));
    await show(tester,
        GiftCardBuySuccessScreen(amount: 99, naira: 999, record: record));
    expect(ReceiptActivity.records.value, hasLength(1));
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(tester.widget<ReceiptScreen>(find.byType(ReceiptScreen)).record,
        same(record));
    expect(find.textContaining('Preview'), findsNothing);
    expect(ReceiptActivity.records.value, hasLength(1));
  });

  testWidgets(
      'preview buy keeps date and identifier while returning from receipt',
      (tester) async {
    await show(
        tester,
        const GiftCardBuySuccessScreen(
            amount: 30,
            naira: 25950,
            quantity: 2,
            brand: GiftCardBrand(
                name: 'Steam', asset: 'assets/figma_exact/steam.png')));
    final record = ReceiptActivity.records.value.single;
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(tester.widget<ReceiptScreen>(find.byType(ReceiptScreen)).record,
        same(record));
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Receipt'));
    await tester.pumpAndSettle();
    expect(tester.widget<ReceiptScreen>(find.byType(ReceiptScreen)).record,
        same(record));
    expect(
        record.fields.singleWhere((field) => field.label == 'Quantity').value,
        '2');
    expect(ReceiptActivity.records.value, hasLength(1));
  });
}
