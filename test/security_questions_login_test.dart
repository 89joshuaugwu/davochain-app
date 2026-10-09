import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/features/auth/presentation/returning_unlock_screen.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/features/security_questions/security_questions_service.dart';
import 'package:davochain/features/security_questions/presentation/security_questions_screens.dart';
import 'package:davochain/shared/widgets/transaction_pin_entry.dart';

void main() {
  setUp(() {
    SecurityQuestionsService.instance.clear();
    PreviewAuthState.unlocked.value = false;
    PreviewAuthState.accountEmail = null;
  });
  tearDown(() {
    SecurityQuestionsService.instance.clear();
    PreviewAuthState.biometricsEnabled.value = false;
  });
  Future<void> enroll() => SecurityQuestionsService.instance.saveInitial(const [
        QuestionAnswer('First question?', 'answer one'),
        QuestionAnswer('Second question?', 'answer two'),
        QuestionAnswer('Third question?', 'answer three')
      ]);
  testWidgets('rapid PIN taps cannot stack multiple unlock routes',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReturningUnlockScreen()));
    final button =
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Use PIN'));
    button.onPressed!();
    button.onPressed!();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TransactionPinEntryScreen), findsNothing);
    expect(find.byType(ReturningUnlockScreen), findsOneWidget);
  });
  testWidgets(
      'fingerprint handoff challenges before unlocking and cancellation returns',
      (tester) async {
    await enroll();
    PreviewAuthState.biometricsEnabled.value = true;
    await tester.pumpWidget(const MaterialApp(home: ReturningUnlockScreen()));
    await tester.tap(find.text('Use fingerprint'));
    await tester.pumpAndSettle();
    expect(find.byType(SecurityQuestionsChallengeScreen), findsOneWidget);
    expect(PreviewAuthState.unlocked.value, false);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ReturningUnlockScreen), findsOneWidget);
    expect(PreviewAuthState.unlocked.value, false);
  });
  testWidgets(
      'password login waits for the selected answer before entering Home',
      (tester) async {
    await enroll();
    await tester.pumpWidget(MaterialApp(home: const LoginScreen(), routes: {
      '/dashboard': (_) => const Scaffold(body: Text('Home destination'))
    }));
    await tester.enterText(find.byType(TextField).at(0), 'review@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'Preview123');
    await tester.pump();
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(SecurityQuestionsChallengeScreen), findsOneWidget);
    expect(find.text('Home destination'), findsNothing);
    final index = SecurityQuestionsService.instance.questions
        .indexWhere((question) => find.text(question).evaluate().isNotEmpty);
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byKey(const Key('challenge-answer-0')),
        ['answer one', 'answer two', 'answer three'][index]);
    await tester.pump();
    await tester.ensureVisible(find.text('Verify answer'));
    await tester.tap(find.text('Verify answer'));
    await tester.pumpAndSettle();
    expect(find.text('Home destination'), findsOneWidget);
    expect(PreviewAuthState.unlocked.value, true);
  });
  testWidgets('PIN unlock enters the same question challenge', (tester) async {
    await enroll();
    await tester.pumpWidget(const MaterialApp(home: ReturningUnlockScreen()));
    await tester.ensureVisible(find.text('Use PIN'));
    await tester.tap(find.text('Use PIN'));
    await tester.pumpAndSettle();
    tester
        .widget<TransactionPinEntryScreen>(
            find.byType(TransactionPinEntryScreen))
        .onConfirm();
    await tester.pumpAndSettle();
    expect(find.byType(SecurityQuestionsChallengeScreen), findsOneWidget);
    expect(PreviewAuthState.unlocked.value, false);
  });
}
