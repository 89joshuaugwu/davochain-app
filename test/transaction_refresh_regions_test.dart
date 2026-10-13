import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/shared/widgets/davo_refresh_region.dart';
import 'package:davochain/shared/widgets/davo_result_screen.dart';
import 'package:davochain/shared/widgets/davo_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(ReceiptActivity.reset);
  tearDown(ReceiptActivity.reset);

  testWidgets('nonfinancial results do not opt into transaction refresh',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const DavoResultScreen(
        title: 'Password updated',
        message: 'Your password has been changed.',
        actions: Text('Done'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(DavoRefreshRegion), findsNothing);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const DavoResultScreen(
        title: 'Transaction pending',
        message: 'Your request is processing.',
        actions: Text('Done'),
        refreshRecordId: 'accepted-transaction-1',
      ),
    ));
    await tester.pumpAndSettle();
    final region = tester.widget<DavoRefreshRegion>(
      find.byType(DavoRefreshRegion),
    );
    expect(region.target, DavoRefreshTarget.transaction);
    expect(region.recordId, 'accepted-transaction-1');
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('pull refresh preserves pending facts and expanded details',
      (tester) async {
    final record = ReceiptRecord(
      id: 'accepted-pending-1',
      reference: 'provider-reference-1',
      type: 'Withdrawal',
      status: ReceiptStatus.pending,
      occurredAt: DateTime(2026, 10, 13),
      amount: '0.01 BTC',
      preview: false,
      fields: const [
        ReceiptField(label: 'Network', value: 'Bitcoin'),
      ],
    );
    ReceiptActivity.accept(record);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      scrollBehavior: const DavoScrollBehavior(),
      home: TransactionRecordDetailsScreen(record: record),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();
    expect(find.text('Less details'), findsOneWidget);

    final before = tester.getRect(find.text('0.01 BTC'));
    await tester.drag(find.byType(ListView), const Offset(0, 160));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getRect(find.text('0.01 BTC')), before);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(ReceiptActivity.records.value, hasLength(1));
    expect(ReceiptActivity.resolve(record), same(record));
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Less details'), findsOneWidget);
    expect(find.byKey(const Key('receipt-details-slide')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
