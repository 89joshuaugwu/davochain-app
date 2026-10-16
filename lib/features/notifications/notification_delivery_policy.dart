import 'notification_inbox.dart';
import 'device_notification_gateway.dart';

String notificationChannel(InboxNotification item) => switch (item.kind) {
  NotificationKind.security => 'davo_security_v1',
  NotificationKind.verification ||
  NotificationKind.welcome => 'davo_account_v1',
  _ => item.category == 1 ? 'davo_transactions_v1' : 'davo_updates_v1',
};

bool phoneEligible(InboxNotification item) =>
    !item.isRead &&
    item.kind != NotificationKind.welcome &&
    !(item.status == 'Pending' || item.status == 'Submitted') &&
    item.category != 3;

DeviceNotificationRequest phonePresentation(
  InboxNotification item, {
  required int id,
  required String account,
  bool showDetails = false,
  bool foreground = false,
}) => DeviceNotificationRequest(
  id: id,
  eventId: item.id,
  accountId: account,
  title: item.title,
  body: showDetails && item.category == 1
      ? item.body
      : switch (item.kind) {
          NotificationKind.deposit =>
            'Your wallet has an update. Open Davochain for details.',
          NotificationKind.security =>
            'Review this security update in Davochain.',
          NotificationKind.verification =>
            'Open Davochain to view your verification update.',
          _ => 'Open Davochain to view this update.',
        },
  channel: notificationChannel(item),
  occurredAt: item.createdAt,
  silent: foreground && item.kind != NotificationKind.security,
);
