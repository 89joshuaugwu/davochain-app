import 'package:davochain/core/navigation/app_routes.dart';
import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/features/auth/presentation/returning_unlock_screen.dart';
import 'package:davochain/shared/widgets/davo_auth_journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> login(WidgetTester tester, {bool reduced = false}) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!),
        routes: {
          AppRoutes.dashboard: (_) => const Scaffold(body: Text('Destination'))
        },
        home: const LoginScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.pump();
    await tester.tap(find.text('Login'));
    await tester.pump();
  }

  testWidgets('password journey progresses dots to check then routes once',
      (tester) async {
    await login(tester);
    expect(find.byKey(const ValueKey('password-auth-dots')), findsOneWidget);
    expect(find.byKey(const ValueKey('fingerprint-auth-ridges')), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('auth-completion-check')), findsOneWidget);
    expect(find.text('Destination'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Destination'), findsOneWidget);
    expect(Navigator.of(tester.element(find.text('Destination'))).canPop(),
        isFalse);
  });
  testWidgets('invalid email stays in form without completion feedback',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const LoginScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'invalid');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.pump();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-completion-check')), findsNothing);
    expect(find.byKey(const ValueKey('password-auth-dots')), findsNothing);
  });
  testWidgets('fingerprint journey uses its ring and finite completion',
      (tester) async {
    PreviewAuthState.biometricsEnabled.value = true;
    PreviewAuthState.unlocked.value = false;
    addTearDown(() {
      PreviewAuthState.biometricsEnabled.value = false;
      PreviewAuthState.unlocked.value = false;
    });
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const ReturningUnlockScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use fingerprint'));
    await tester.pump();
    expect(find.byKey(const ValueKey('fingerprint-auth-ridges')), findsOneWidget);
    expect(find.byKey(const ValueKey('password-auth-dots')), findsNothing);
    expect(PreviewAuthState.unlocked.value, isFalse);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('auth-completion-check')), findsOneWidget);
    // Dispose before navigation: no late completion may unlock the local state.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(PreviewAuthState.unlocked.value, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion uses a static shortcut and cancellation is safe',
      (tester) async {
    await login(tester, reduced: true);
    expect(find.byKey(const ValueKey('auth-completion-check')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('auth-completion-check')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Destination'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await login(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'returning password shares password journey and blocks other actions',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const ReturningUnlockScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'password');
    await tester.pump();
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    expect(tester.widget<DavoAuthJourney>(find.byType(DavoAuthJourney)).method,
        AuthJourneyMethod.password);
    expect(find.byKey(const ValueKey('password-auth-dots')), findsOneWidget);
    expect(
        tester
            .widget<AbsorbPointer>(find
                .descendant(
                    of: find.byType(DavoAuthJourney),
                    matching: find.byType(AbsorbPointer))
                .first)
            .absorbing,
        isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
