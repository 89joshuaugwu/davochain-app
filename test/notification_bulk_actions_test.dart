import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/features/notifications/device_notification_gateway.dart';
import 'package:davochain/features/notifications/notification_delivery_controller.dart';
import 'package:davochain/features/notifications/notification_events.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';

const messages = [
  InboxNotification(
    id: 'a:one',
    title: 'First message',
    body: 'Deposit',
    time: '',
    day: '',
    category: 1,
    kind: NotificationKind.deposit,
    status: 'Completed',
  ),
  InboxNotification(
    id: 'a:two',
    title: 'Second message',
    body: 'Security',
    time: '',
    day: '',
    category: 2,
  ),
];

class HeldPostPhone extends DeviceNotificationGateway {
  final gate = Completer<void>();
  final posting = Completer<void>();
  int posts = 0, voices = 0;
  final active = <int>{};
  @override
  Future<bool> enabled({String? channel}) async => true;
  @override
  Future<void> show(DeviceNotificationRequest request) async {
    posts++;
    posting.complete();
    await gate.future;
    active.add(request.id);
  }

  @override
  Future<bool> speakDeposit() async {
    voices++;
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    active.remove(id);
  }
}

void main() {
  test(
    'bulk reads invalidate stale responses and clearing preserves consumed events across restart',
    () {
      final inbox = NotificationInbox(records: const []);
      final events = NotificationEventCoordinator(inbox: inbox)
        ..activate('a', 1);
      events.welcome('a', 1, firstName: 'Ada');
      final token = inbox.capturePublicationToken();
      inbox.markAllRead();
      expect(inbox.unreadCount, 0);
      expect(inbox.publish(messages, token: token), isFalse);
      inbox.clearAll();
      final saved = events.exportState();
      events.restoreState('a', 2, saved);
      expect(events.welcome('a', 2, firstName: 'Ada'), isFalse);
      expect(inbox.snapshot, isEmpty);
      inbox.dispose();
    },
  );
  test(
    'clearing during a pending native post cancels the alert and prevents voice or replay',
    () async {
      final phone = HeldPostPhone();
      final delivery = NotificationDeliveryController(
        phone: phone,
        voiceEnabled: () => true,
        save: (_) async {},
      );
      await delivery.activate('a', 1);
      final post = delivery.deliver(
        [messages.first],
        account: 'a',
        generation: 1,
      );
      await phone.posting.future;
      final cleared = delivery.acknowledgeMany([messages.first.id]);
      phone.gate.complete();
      await post;
      await cleared;
      expect(phone.active, isEmpty);
      expect(phone.voices, 0);
      await delivery.deliver([messages.first], account: 'a', generation: 1);
      expect(phone.posts, 1);
    },
  );
  testWidgets(
    'notification menu reads all categories and confirms before clearing',
    (tester) async {
      final inbox = PreviewAccountState.notificationInbox
        ..reset(records: messages);
      addTearDown(() => inbox.reset(records: const []));
      await tester.pumpWidget(
        const MaterialApp(home: NotificationCenterScreen()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Security'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Notification actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark all as read'));
      await tester.pumpAndSettle();
      expect(inbox.unreadCount, 0);
      expect(inbox.snapshot.every((item) => item.isRead), isTrue);
      Future<void> clear() async {
        await tester.tap(find.byTooltip('Notification actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear notifications'));
        await tester.pumpAndSettle();
      }

      await clear();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(inbox.snapshot.length, 2);
      await clear();
      await tester.tap(find.widgetWithText(TextButton, 'Clear notifications'));
      await tester.pumpAndSettle();
      expect(inbox.snapshot, isEmpty);
      expect(find.text('You are all caught up'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('confirmation from an earlier account cannot clear a new inbox', (
    tester,
  ) async {
    final inbox = PreviewAccountState.notificationInbox
      ..reset(records: messages);
    addTearDown(() => inbox.reset(records: const []));
    await tester.pumpWidget(
      const MaterialApp(home: NotificationCenterScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notification actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear notifications'));
    await tester.pumpAndSettle();
    inbox.reset(records: [messages.last]);
    await tester.tap(find.widgetWithText(TextButton, 'Clear notifications'));
    await tester.pumpAndSettle();
    expect(inbox.snapshot.length, 1);
  });
}
