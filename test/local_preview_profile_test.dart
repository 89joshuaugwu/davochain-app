import 'package:davochain/features/notifications/notification_inbox.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/shared/widgets/local_profile_avatar.dart';
import 'package:davochain/features/auth/presentation/returning_unlock_screen.dart';

void main() {
  final profile = LocalPreviewProfile.instance;
  final verification = VerificationSession.instance;
  setUp(() {
    profile.loginSample();
    PreviewAccountState.readNotifications.clear();
  });
  tearDown(() => profile.loginSample());
  test(
    'registration clears sample identity and Basic submission applies identity only on success',
    () {
      profile.register(
        name: 'Ada Obi',
        email: 'ada@example.com',
        phone: '+234 8012345678',
      );
      expect(profile.fullName, 'Ada Obi');
      expect(profile.email, 'ada@example.com');
      expect(profile.sampleAvatar, isFalse);
      expect(profile.photo, isNull);
      expect(profile.dateOfBirth, isEmpty);
      expect(profile.username, isEmpty);
      verification.saveProfile({
        'first': 'Ada',
        'middle': 'Mary',
        'last': 'Okafor',
        'dob': '2000-01-02',
        'address': '10 Lagos Road',
        'phone': '8098765432',
      });
      expect(profile.fullName, 'Ada Obi');
      verification.completeProfile();
      verification.submitBasic(BasicIdentityMethod.nin, '12345678901');
      expect(profile.fullName, 'Ada Mary Okafor');
      expect(profile.phone, '+234 8098765432');
      expect(profile.dateOfBirth, '2000-01-02');
      expect(profile.address, '10 Lagos Road');
      expect(profile.email, 'ada@example.com');
      profile.setPhoto(Uint8List.fromList([1, 2, 3]));
      profile.setUsername('ada_obi');
      expect(profile.username, 'ada_obi');
      expect(verification.profileDraft['username'], 'ada_obi');
      profile.loginSample();
      expect(profile.photo, isNull);
      expect(profile.sampleAvatar, isTrue);
      expect(profile.fullName, 'Vincent Chukwu');
      expect(profile.username, 'Admiral');
      expect(verification.basicVerified, isFalse);
    },
  );
  testWidgets('avatar reacts to each verification tier', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: LocalProfileAvatar()),
      ),
    );
    expect(
      find.byKey(const ValueKey('profile-verification-level-0')),
      findsOneWidget,
    );
    verification.completeProfile();
    verification.submitBasic(BasicIdentityMethod.bvn, '12345678901');
    await tester.pump();
    expect(
      find.byKey(const ValueKey('profile-verification-level-1')),
      findsOneWidget,
    );
    verification.chooseDocument('National ID');
    verification.addIdentitySide(front: true);
    verification.addFace();
    verification.verifyIdentity();
    verification.chooseAddressDocument('Utility Bill');
    verification.addAddressDocument();
    verification.submitAdvanced();
    await tester.pump();
    expect(
      find.byKey(const ValueKey('profile-verification-level-2')),
      findsOneWidget,
    );
  });
  testWidgets('locked signup and ambassador headers use the local identity', (
    tester,
  ) async {
    profile.register(
      name: 'Ada Obi',
      email: 'ada@example.com',
      phone: '+234 8012345678',
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ReturningUnlockScreen()),
    );
    expect(find.text('Welcome back, Ada'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AmbassadorDashboardScreen(),
      ),
    );
    expect(find.text('Hi, Ada'), findsOneWidget);
    expect(find.byType(LocalProfileAvatar), findsOneWidget);
    expect(find.text('Hi, Callie'), findsNothing);
  });
  testWidgets('notifications filter and open a read detail', (tester) async {
    PreviewAccountState.notificationInbox.reset(records: previewNotifications);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const NotificationCenterScreen(),
      ),
    );
    await tester.tap(find.text('Security'));
    await tester.pump();
    expect(find.text('New Login Detected'), findsOneWidget);
    expect(find.text('Deposit Received'), findsNothing);
    await tester.tap(find.text('Rewards'));
    await tester.pump();
    expect(find.text('No rewards notifications yet'), findsOneWidget);
    await tester.tap(find.text('Transactions'));
    await tester.pump();
    await tester.tap(find.text('Deposit Received'));
    await tester.pumpAndSettle();
    expect(PreviewAccountState.readNotifications, contains('Deposit Received'));
    expect(
      find.text(
        'Your monthly salary of \$4,250.00 has been received in your account.',
      ),
      findsOneWidget,
    );
  });
  testWidgets(
    'notification channel changes persist when the screen is reopened',
    (tester) async {
      Widget app() => MaterialApp(
        theme: AppTheme.light,
        home: const NotificationChannelScreen(type: 0),
      );
      await tester.pumpWidget(app());
      final push = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Push Notification',
      );
      await tester.tap(push);
      await tester.pump();
      expect(PreviewAccountState.notificationChannels[0][0], isFalse);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app());
      expect(tester.widget<Semantics>(push).properties.toggled, isFalse);
    },
  );
}
