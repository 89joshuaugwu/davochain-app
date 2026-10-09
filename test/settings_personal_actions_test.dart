import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/settings_personal_action_flows.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';

class _PasswordGateway extends PreviewSettingsGateway {
  final result = Completer<void>();
  int calls = 0;
  @override
  Future<void> changePassword(String current, String next) {
    calls++;
    return result.future;
  }
}

class _WrongRewardGateway extends PreviewSettingsGateway {
  @override
  Future<RewardRedemption> redeemPoints(int points) async => RewardRedemption(
      reference: 'WRONG', points: 1, creditKobo: 5, createdAt: DateTime(2026));
}

Future<void> _fillPassword(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'OldPass1');
  await tester.enterText(find.byType(TextField).at(1), 'NewPass2');
  await tester.enterText(find.byType(TextField).at(2), 'NewPass2');
  await tester.pump();
}

void main() {
  tearDown(SettingsPreviewSession.instance.reset);
  testWidgets(
      'password busy guards duplicate submissions and failures retain a retry',
      (tester) async {
    final gateway = _PasswordGateway();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: ChangePasswordScreen(gateway: gateway)));
    await _fillPassword(tester);
    final button =
        tester.widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton));
    button.onPressed!();
    button.onPressed!();
    await tester.pump();
    expect(gateway.calls, 1);
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .loading,
        isTrue);
    expect(tester.widget<TextField>(find.byType(TextField).first).enabled,
        isFalse);
    gateway.result.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Please try again'), findsOneWidget);
    expect(SettingsPreviewSession.instance.passwordChanged, isFalse);
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .enabled,
        isTrue);
  });

  testWidgets('a session reset cancels a pending password result',
      (tester) async {
    final gateway = _PasswordGateway();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark, home: ChangePasswordScreen(gateway: gateway)));
    await _fillPassword(tester);
    tester
        .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
        .onPressed!();
    SettingsPreviewSession.instance.reset();
    gateway.result.complete();
    await tester.pumpAndSettle();
    expect(SettingsPreviewSession.instance.passwordChanged, isFalse);
    expect(find.text('Password changed'), findsNothing);
  });

  testWidgets('redeeming requires review and credits 15 points as 75 kobo',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const DavoPointsScreen()));
    await tester.enterText(find.byType(TextField), '15');
    await tester.pump();
    expect(SettingsPreviewSession.instance.availablePoints, 15);
    await tester.tap(find.text('Review redemption'));
    await tester.pumpAndSettle();
    expect(find.text('Preview credit: NGN 0.75'), findsOneWidget);
    expect(SettingsPreviewSession.instance.availablePoints, 15);
    await tester.tap(find.text('Redeem points'));
    await tester.pumpAndSettle();
    expect(find.text('Points redeemed'), findsOneWidget);
    expect(SettingsPreviewSession.instance.availablePoints, 0);
    expect(SettingsPreviewSession.instance.rewardCreditKobo, 75);
    await tester.tap(find.text('Back to points'));
    await tester.pumpAndSettle();
    expect(find.textContaining('15 points redeemed'), findsOneWidget);
  });

  testWidgets('a mismatched gateway redemption cannot debit the balance',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: DavoPointsScreen(gateway: _WrongRewardGateway())));
    await tester.enterText(find.byType(TextField), '15');
    await tester.pump();
    await tester.tap(find.text('Review redemption'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Redeem points'));
    await tester.pumpAndSettle();
    expect(SettingsPreviewSession.instance.availablePoints, 15);
    expect(
        find.textContaining('Please review the amount again'), findsOneWidget);
  });

  testWidgets('saved support requests stay reachable with pending details',
      (tester) async {
    SettingsPreviewSession.instance.acceptTicket(SupportTicket(
        reference: 'PREVIEW-SUPPORT-SAVED',
        subject: 'Saved question',
        message: 'Saved message',
        orderId: 'ORDER-1',
        createdAt: DateTime(2026)));
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const EmailSupportScreen()));
    await tester.ensureVisible(find.text('Saved question'));
    await tester.tap(find.text('Saved question'));
    await tester.pumpAndSettle();
    expect(find.text('Request details'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Order ID: ORDER-1'), findsOneWidget);
    expect(find.byTooltip('Copy reference'), findsOneWidget);
    await tester.tap(find.text('Back to requests'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
  });
}
