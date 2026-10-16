import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/notification_detail_screen.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:davochain/shared/widgets/davo_refresh_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('requested data pages dispatch their own read-only resource', (
    tester,
  ) async {
    final requests = <DavoRefreshRequest>[];
    for (final entry in <(Widget, DavoRefreshTarget)>[
      (const PortfolioScreen(), DavoRefreshTarget.portfolio),
      (const TransactionHistoryScreen(), DavoRefreshTarget.transactionHistory),
      (const NotificationCenterScreen(), DavoRefreshTarget.notifications),
      (const ProfileSettingsScreen(), DavoRefreshTarget.settings),
      (const GiftCardHomeScreen(), DavoRefreshTarget.giftCardCatalogue),
    ]) {
      await tester.pumpWidget(
        DavoRefreshScope(
          onRefresh: (request) async {
            requests.add(request);
          },
          child: MaterialApp(theme: AppTheme.light, home: entry.$1),
        ),
      );
      await tester.pumpAndSettle();
      final region = find.byType(DavoRefreshRegion);
      expect(tester.widget<DavoRefreshRegion>(region).target, entry.$2);
      await tester.dragFrom(
        tester.getTopLeft(region) + const Offset(100, 130),
        const Offset(0, 170),
      );
      await tester.pumpAndSettle();
      expect(requests.last.target, entry.$2);
      expect(requests.last.recordId, isNull);
      expect(tester.takeException(), isNull);
    }
    expect(requests, hasLength(5));
  });

  testWidgets(
    'transaction refresh fetches the same ID and publishes later confirmation',
    (tester) async {
      final pending = ReceiptRecord(
        id: 'server-accepted-1',
        reference: 'bank-reference-1',
        type: 'Withdrawal',
        status: ReceiptStatus.pending,
        preview: false,
        occurredAt: DateTime.utc(2026, 10, 13),
        amount: '1000.00 NGN',
        fields: const [],
      );
      ReceiptActivity.accept(pending);
      DavoRefreshRequest? request;
      await tester.pumpWidget(
        DavoRefreshScope(
          onRefresh: (read) async {
            request = read;
            ReceiptActivity.accept(pending.withStatus(ReceiptStatus.completed));
          },
          child: MaterialApp(
            theme: AppTheme.light,
            home: TransactionRecordDetailsScreen(record: pending),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 170));
      await tester.pumpAndSettle();
      expect(request!.target, DavoRefreshTarget.transaction);
      expect(request!.recordId, pending.id);
      expect(ReceiptActivity.records.value, hasLength(1));
      expect(ReceiptActivity.resolve(pending).status, ReceiptStatus.completed);
      expect(find.text('Completed'), findsNWidgets(2));
      expect(find.text('1000.00 NGN'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      ReceiptActivity.reset();
    },
  );

  testWidgets(
    'notification detail has category, message, read status and relevant action',
    (tester) async {
      PreviewAccountState.notificationInbox.reset(
        records: previewNotifications,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const NotificationCenterScreen(),
        ),
      );
      await tester.tap(find.text('Deposit Received'));
      await tester.pumpAndSettle();
      expect(find.byType(DavoNotificationDetailScreen), findsOneWidget);
      expect(find.text('Received'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
      expect(
        find.text(
          'Your monthly salary of \$4,250.00 has been received in your account.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('View transaction history'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionHistoryScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
