import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/shared/motion/davo_refresh_artwork.dart';
import 'package:davochain/shared/widgets/davo_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ReceiptRecord get record => ReceiptRecord(
        id: 'DC-polish-35',
        reference: 'DC-polish-35',
        type: 'Bitcoin purchase',
        status: ReceiptStatus.completed,
        occurredAt: DateTime.utc(2026, 10, 13),
        amount: '0.03 BTC',
        fields: const [
          ReceiptField(label: 'Asset', value: 'Bitcoin'),
          ReceiptField(label: 'Exchange Rate', value: '1 BTC = NGN 24000000')
        ]);

void main() {
  testWidgets(
      'gift referral uses a complete vector icon and opens existing rewards',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GiftCardHomeScreen()));
    expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
    await tester.tap(find.text('Refer'));
    await tester.pumpAndSettle();
    expect(find.byType(ReferralDashboardScreen), findsOneWidget);
    expect(find.text('Referral Program'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'receipt details slide open and closed through intermediate heights',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: TransactionRecordDetailsScreen(record: record)));
    expect(find.text('Transaction ID'), findsNothing);
    await tester.tap(find.text('More details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final partial = tester
        .widget<Align>(find.byKey(const Key('receipt-details-slide')))
        .heightFactor!;
    expect(partial, inExclusiveRange(0.0, 1.0));
    await tester.pumpAndSettle();
    expect(find.text('Transaction ID'), findsOneWidget);
    await tester.ensureVisible(find.text('Less details'));
    await tester.tap(find.text('Less details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Transaction ID'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Transaction ID'), findsNothing);
  });

  testWidgets(
      'sharing body uses eight pixel side margins and keeps paper readable',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ReceiptScreen(record: record)));
    final paper = tester.getRect(find.byType(ReceiptPaper));
    expect(paper.left, 8);
    expect(paper.right, 792);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick refresh completes two whole rotations before hiding',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DavoFloatingRefresh(
                onRefresh: () async {},
                child: const SizedBox.expand(child: Text('Pull here'))))));
    await tester.drag(find.text('Pull here'), const Offset(0, 160));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.byType(DavoRefreshArtwork), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(DavoRefreshArtwork), findsNothing);
  });
}
