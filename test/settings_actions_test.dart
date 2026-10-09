import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/features/profile_settings/presentation/settings_action_flows.dart';
import 'package:davochain/shared/widgets/bank_details_share_button.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';

void main() {
  tearDown(SettingsPreviewSession.instance.reset);
  test(
      'redemption updates points once, and rejects overdrafts and duplicate results',
      () {
    final session = SettingsPreviewSession.instance;
    final redemption = RewardRedemption(
        reference: 'PREVIEW-1',
        points: 15,
        creditKobo: 75,
        createdAt: DateTime(2026, 10, 9));
    expect(session.acceptRedemption(redemption), isTrue);
    expect(session.availablePoints, 0);
    expect(session.rewardCreditKobo, 75);
    expect(session.acceptRedemption(redemption), isFalse);
    expect(session.rewardCreditKobo, 75);
  });
  testWidgets(
      'bank selection leads to number entry and review, then updates linked accounts',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const LinkedAccountsScreen()));
    await tester.tap(find.text('Add Account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'kuda');
    await tester.pump();
    await tester.tap(find.text('Kuda Bank'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1234567890');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review account'));
    await tester.pumpAndSettle();
    expect(find.text('Review bank account'), findsOneWidget);
    await tester.tap(find.text('Link account'));
    await tester.pumpAndSettle();
    expect(find.text('Bank account linked'), findsOneWidget);
    await tester.tap(find.text('Back to linked accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Kuda Bank'), findsOneWidget);
    expect(
        SettingsPreviewSession.instance.banks
            .any((b) => b.number == '1234567890'),
        isTrue);
  });
  testWidgets('password form rejects mismatch and never stores secret values',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const ChangePasswordScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'OldPass1');
    await tester.enterText(find.byType(TextField).at(1), 'NewPass2');
    await tester.enterText(find.byType(TextField).at(2), 'wrong');
    await tester.pump();
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .enabled,
        isFalse);
    await tester.enterText(find.byType(TextField).at(2), 'NewPass2');
    await tester.pump();
    await tester.ensureVisible(find.text('Change your password'));
    await tester.tap(find.text('Change your password'));
    await tester.pumpAndSettle();
    expect(find.text('Password changed'), findsOneWidget);
    expect(find.text('NewPass2'), findsNothing);
    expect(SettingsPreviewSession.instance.passwordChanged, isTrue);
  });
  testWidgets(
      'support submission gets a pending preview reference and retains request',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const EmailSupportScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'Deposit question');
    await tester.enterText(find.byType(TextField).at(2),
        'I would like to check my deposit status.');
    await tester.pump();
    await tester.ensureVisible(find.text('Submit request'));
    await tester.tap(find.text('Submit request'));
    await tester.pumpAndSettle();
    expect(find.text('Request submitted'), findsOneWidget);
    expect(find.textContaining('PREVIEW-SUPPORT'), findsOneWidget);
    expect(SettingsPreviewSession.instance.tickets.length, 1);
  });
  testWidgets(
      'deletion requires explicit confirmation, shows pending then signs out once',
      (tester) async {
    var exits = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: DeleteAccountScreen(onSignOut: () => exits++)));
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .enabled,
        isFalse);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('Request account deletion'));
    await tester.tap(find.text('Request account deletion'));
    await tester.pumpAndSettle();
    expect(find.text('Deletion requested'), findsOneWidget);
    expect(exits, 0);
    await tester.tap(find.text('Back to login'));
    await tester.tap(find.text('Back to login'));
    expect(exits, 1);
  });
  testWidgets(
      'bank sharing opens native composer with displayed details, not a success toast',
      (tester) async {
    MethodCall? call;
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (value) async {
      call = value;
      return 'dev.fluttercommunity.plus/share/dismissed';
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
            body:
                BankDetailsShareButton(details: BankDepositDetails.preview))));
    await tester.tap(find.text('Share Details'));
    await tester.pumpAndSettle();
    expect(call!.method, 'share');
    expect(call!.arguments['text'], contains('542100896436'));
    expect(call!.arguments['text'], contains('Paystack-Titan'));
    expect(find.text('Bank details are ready to share.'), findsNothing);
  });
}
