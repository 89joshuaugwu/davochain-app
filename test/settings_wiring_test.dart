import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';

void main() {
  tearDown(SettingsPreviewSession.instance.reset);
  testWidgets(
      'linked bank is selectable in the themed withdrawal payment sheet',
      (tester) async {
    SettingsPreviewSession.instance.acceptBank(const LinkedBank(
        bank: 'Kuda Bank', number: '1234567890', name: 'Preview user'));
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const NairaWithdrawScreen()));
    await tester.ensureVisible(find.text('Select a payment method'));
    await tester.tap(find.text('Select a payment method'));
    await tester.pumpAndSettle();
    final panel = find.ancestor(
        of: find.text('Preview accounts'), matching: find.byType(Material));
    expect(
        panel.evaluate().any((element) {
          return (element.widget as Material).color == DavoColors.dark.canvas;
        }),
        isTrue);
    await tester.scrollUntilVisible(find.text('Kuda Bank - 1234567890'), 100,
        scrollable: find.descendant(
            of: find.byType(ListView), matching: find.byType(Scrollable)));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Kuda Bank - 1234567890'));
    await tester.pumpAndSettle();
    expect(find.text('Kuda Bank'), findsOneWidget);
    expect(find.text('Preview accounts'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'account information deletion reaches login and clears the navigation stack',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const AccountInformationScreen()));
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Request account deletion'));
    await tester.pumpAndSettle();
    expect(find.text('Deletion requested'), findsOneWidget);
    await tester.tap(find.text('Back to login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(SettingsPreviewSession.instance.deletionRequest, isNull);
    final context = tester.element(find.byType(LoginScreen));
    expect(Navigator.of(context).canPop(), isFalse);
  });
}
