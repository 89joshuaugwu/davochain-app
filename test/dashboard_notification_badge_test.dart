import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/shared/widgets/davo_notification_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';

void main() {
  setUp(() => LocalPreviewProfile.instance.loginSample());
  tearDown(() => LocalPreviewProfile.instance.loginSample());

  testWidgets('dashboard announces unread count and updates without remount',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light, home: const DavochainDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Notifications, 4 unread'), findsOneWidget);
      PreviewAccountState.readNotifications.add('Deposit Received');
      await tester.pump();
      expect(find.bySemanticsLabel('Notifications, 3 unread'), findsOneWidget);
      PreviewAccountState.readNotifications.addAll(
          ['New Login Detected', 'Transfer Sent', 'Support Ticket Updated']);
      await tester.pump();
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
      expect(find.byKey(const ValueKey('notification-unread-badge')),
          findsNothing);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('opening a notification reduces the mounted dashboard count',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light, home: const DavochainDashboardScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Notifications, 4 unread'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deposit Received'));
      await tester.pumpAndSettle();
      expect(
          PreviewAccountState.readNotifications, contains('Deposit Received'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Notifications, 3 unread'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('dashboard resets unread count after changing preview account',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light, home: const DavochainDashboardScreen()));
      await tester.pumpAndSettle();
      PreviewAccountState.readNotifications.add('Deposit Received');
      await tester.pump();
      expect(find.bySemanticsLabel('Notifications, 3 unread'), findsOneWidget);
      LocalPreviewProfile.instance.loginSample();
      await tester.pump();
      expect(find.bySemanticsLabel('Notifications, 4 unread'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
  for (final (count, label) in [
    (0, ''),
    (1, '1'),
    (9, '9'),
    (10, '9+'),
    (12, '9+')
  ]) {
    testWidgets('bell displays $count unread with full accessible count',
        (tester) async {
      final inbox = NotificationInbox(records: const []);
      addTearDown(inbox.dispose);
      inbox.publish(const [],
          token: inbox.capturePublicationToken(), unreadCount: count);
      var taps = 0;
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                    body: DavoNotificationButton(
                        inbox: inbox, onTap: () => taps++)))));
        final button = find.bySemanticsLabel(
            count == 0 ? 'Notifications' : 'Notifications, $count unread');
        expect(button, findsOneWidget);
        expect(tester.getSize(button), const Size(48, 48));
        expect(
            tester
                .getSemantics(button)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isTrue);
        final badge = find.byKey(const ValueKey('notification-unread-badge'));
        expect(badge, count == 0 ? findsNothing : findsOneWidget);
        if (count > 0) {
          expect(find.text(label), findsOneWidget);
          expect(tester.getSize(badge), const Size(20, 20));
          expect(find.bySemanticsLabel(label), findsNothing);
          final decoration =
              tester.widget<Container>(badge).decoration as BoxDecoration;
          expect(decoration.color!.r, greaterThan(decoration.color!.g));
          expect(
              (Colors.white.computeLuminance() + 0.05) /
                  (decoration.color!.computeLuminance() + 0.05),
              greaterThanOrEqualTo(4.5));
          expect(
              tester.widget<Text>(find.text(label)).style!.color, Colors.white);
        }
        await tester.tap(button);
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }

  test('stable IDs distinguish duplicate titles and keep snapshots immutable',
      () {
    final inbox = NotificationInbox(records: const [
      InboxNotification(
          id: 'a',
          title: 'Same title',
          body: '',
          time: '',
          day: '',
          category: 0),
      InboxNotification(
          id: 'b',
          title: 'Same title',
          body: '',
          time: '',
          day: '',
          category: 0),
    ]);
    addTearDown(inbox.dispose);
    final old = inbox.snapshot;
    var publications = 0;
    inbox.addListener(() => publications++);
    expect(inbox.markRead('a'), isTrue);
    expect(inbox.markRead('a'), isFalse);
    expect(inbox.markRead('unknown'), isFalse);
    expect(inbox.unreadCount, 1);
    expect(inbox.snapshot[1].isRead, isFalse);
    expect(old[0].isRead, isFalse);
    expect(() => old.clear(), throwsUnsupportedError);
    expect(publications, 1);
  });

  test(
      'server aggregate includes unread beyond loaded page and decrements once',
      () {
    final inbox = NotificationInbox();
    addTearDown(inbox.dispose);
    expect(
        inbox.publish(previewNotifications,
            token: inbox.capturePublicationToken(), unreadCount: 12),
        isTrue);
    expect(inbox.unreadCount, 12);
    inbox.markRead('preview-deposit');
    inbox.markRead('preview-deposit');
    expect(inbox.unreadCount, 11);
    inbox.markUnread('preview-deposit');
    expect(inbox.unreadCount, 12);
  });

  test('stale server publication cannot undo a read or cross account reset',
      () {
    final inbox = NotificationInbox();
    addTearDown(inbox.dispose);
    final beforeRead = inbox.capturePublicationToken();
    inbox.markRead('preview-deposit');
    expect(
        inbox.publish(previewNotifications, token: beforeRead, unreadCount: 99),
        isFalse);
    expect(inbox.unreadCount, 3);
    final beforeReset = inbox.capturePublicationToken();
    inbox.reset();
    expect(
        inbox.publish(previewNotifications,
            token: beforeReset, unreadCount: 99),
        isFalse);
    expect(inbox.unreadCount, 4);
    final current = inbox.capturePublicationToken();
    expect(inbox.publish(const [], token: current, unreadCount: 0), isTrue);
    expect(inbox.unreadCount, 0);
    expect(inbox.publish(previewNotifications, token: current, unreadCount: 99),
        isFalse);
  });

  test('publication rejects duplicate IDs and an impossible aggregate', () {
    final inbox = NotificationInbox();
    addTearDown(inbox.dispose);
    expect(
        () => inbox.publish(
            [previewNotifications.first, previewNotifications.first],
            token: inbox.capturePublicationToken()),
        throwsArgumentError);
    expect(
        () => inbox.publish(previewNotifications,
            token: inbox.capturePublicationToken(), unreadCount: 3),
        throwsArgumentError);
    expect(inbox.unreadCount, 4);
  });

  testWidgets(
      'notification center reacts to canonical reads and detaches safely',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const NotificationCenterScreen()));
    PreviewAccountState.notificationInbox.markRead('preview-deposit');
    await tester.pump();
    final title = find.text('Deposit Received');
    final row = find
        .ancestor(of: title, matching: find.byType(Semantics))
        .evaluate()
        .map((element) => element.widget)
        .whereType<Semantics>()
        .where((widget) => widget.properties.label == 'Read notification');
    expect(row, hasLength(1));
    await tester.pumpWidget(const SizedBox());
    PreviewAccountState.notificationInbox.markRead('preview-login');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
