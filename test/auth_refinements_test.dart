import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'package:davochain/features/auth/presentation/create_password_screen.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
    await tester.pumpAndSettle();
  }

  for (final kind in VerificationKind.values) {
    testWidgets('${kind.name} resend waits 30 seconds and resets after resend',
        (tester) async {
      var now = DateTime(2026);
      await open(tester, VerificationScreen(kind: kind, now: () => now));
      final resend = find.ancestor(
          of: find.text('Resend Code'), matching: find.byType(InkWell));
      expect(tester.widget<InkWell>(resend).onTap, isNull);
      expect(find.text('0:30'), findsOneWidget);
      now = now.add(const Duration(seconds: 29));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('0:01'), findsOneWidget);
      expect(tester.widget<InkWell>(resend).onTap, isNull);
      now = now.add(const Duration(seconds: 10));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<InkWell>(resend).onTap, isNotNull);
      await tester.tap(find.text('Resend Code'));
      await tester.pumpAndSettle();
      expect(find.text('0:30'), findsOneWidget);
      expect(tester.widget<InkWell>(resend).onTap, isNull);
      await tester.pumpWidget(const SizedBox());
      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('forgot password cooldown, visible strength and security success',
      (tester) async {
    var now = DateTime(2026);
    await open(tester, ForgotPasswordScreen(now: () => now));
    await tester.enterText(find.byType(TextField), 'user@example.com');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final resend = find.widgetWithText(TextButton, 'Resend Code');
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    expect(find.text('0:30'), findsOneWidget);
    now = now.add(const Duration(seconds: 30));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<TextButton>(resend).onPressed, isNotNull);
    await tester.tap(resend);
    await tester.pumpAndSettle();
    expect(find.text('0:30'), findsOneWidget);
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
    }
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    final password = find.byType(TextField).first;
    for (final entry in <String, String>{
      'abc': 'Low Strength',
      'abcdefgh1': 'Medium Strength',
      'Abcdefgh1': 'Strong Password'
    }.entries) {
      await tester.enterText(password, entry.key);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      final fill = find.byType(AnimatedFractionallySizedBox);
      expect(tester.getSize(fill).height, 8);
      expect(tester.getSize(fill).width, greaterThan(0));
      final box = tester.widget<ColoredBox>(
          find.descendant(of: fill, matching: find.byType(ColoredBox)));
      expect(
          box.color,
          entry.value == 'Low Strength'
              ? AppColors.primary
              : entry.value == 'Medium Strength'
                  ? const Color(0xFF986000)
                  : const Color(0xFF13803D));
    }
    await tester.enterText(find.byType(TextField).last, 'Abcdefgh1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Update Password'));
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
    expect(find.text('Password updated'), findsOneWidget);
    expect(
        find.text(
            'For security, you\u2019ve been signed out of all other devices.'),
        findsOneWidget);
    expect(find.text('Login Now'), findsOneWidget);
    tester.view.physicalSize = const Size(360, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.text('Login Now')).bottom, lessThan(420));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'signup strength fill is visible and transitions through the same colors',
      (tester) async {
    await open(tester, const CreatePasswordScreen());
    await tester.enterText(find.byType(TextField).first, 'abc');
    await tester.pumpAndSettle();
    final fill = find.byType(AnimatedFractionallySizedBox);
    expect(tester.getSize(fill).height, 8);
    expect(tester.getSize(fill).width, greaterThan(0));
    expect(tester.widget<Text>(find.text('Low Strength')).style!.color,
        AppColors.primary);
    await tester.enterText(find.byType(TextField).first, 'abcdefgh1');
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('Medium Strength')).style!.color,
        const Color(0xFF986000));
    await tester.enterText(find.byType(TextField).first, 'Abcdefgh1');
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('Strong Password')).style!.color,
        const Color(0xFF13803D));
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .enabled,
        isFalse);
  });
}
