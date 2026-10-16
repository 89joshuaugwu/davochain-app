import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/notifications/notification_events.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/notification_detail_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PreviewAccountState.notificationInbox.reset(records: const []);
    VerificationSession.instance.reset();
  });
  tearDown(
    () => PreviewAccountState.notificationInbox.reset(records: const []),
  );
  Future<void> show(
    WidgetTester tester, {
    bool dark = false,
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const NotificationCenterScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('gear opens existing notification settings', (tester) async {
    await show(tester);
    await tester.tap(find.byTooltip('Notification settings'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'welcome detail and Get started navigation at large text, dark=$dark',
      (tester) async {
        final events = NotificationEventCoordinator(
          inbox: PreviewAccountState.notificationInbox,
        );
        events.activate('new-account', 1);
        events.welcome('new-account', 1, firstName: 'Ada');
        await show(tester, dark: dark, scale: 1.7);
        await tester.tap(find.text('Welcome to Davochain, Ada'));
        await tester.pumpAndSettle();
        expect(find.byType(DavoNotificationDetailScreen), findsOneWidget);
        expect(find.text('Message'), findsNothing);
        expect(PreviewAccountState.notificationInbox.unreadCount, 0);
        await tester.scrollUntilVisible(
          find.text('Get started'),
          300,
          scrollable: find
              .descendant(
                of: find.byType(DavoNotificationDetailScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        expect(find.byType(BasicVerificationIntroScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'security and transaction filters do not show welcome in unrelated groups',
    (tester) async {
      PreviewAccountState.notificationInbox.insert(
        const InboxNotification(
          id: 'welcome',
          title: 'Welcome to Davochain',
          body: 'Complete your profile.',
          time: 'Just now',
          day: 'Today',
          category: 0,
          kind: NotificationKind.welcome,
        ),
      );
      await show(tester);
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Davochain'), findsNothing);
      expect(
        find.text('Your account security updates will appear here.'),
        findsOneWidget,
      );
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Davochain'), findsOneWidget);
    },
  );
}
