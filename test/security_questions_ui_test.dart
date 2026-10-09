import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/security_questions/security_questions_service.dart';
import 'package:davochain/features/security_questions/presentation/security_questions_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester, Widget screen) =>
      tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
  Future<void> tap(WidgetTester tester, String label) async {
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> complete(WidgetTester tester, int index, {int? preset}) async {
    await tap(tester, 'Choose a question');
    await tap(tester, securityQuestionPresets[preset ?? index]);
    await tester.enterText(
        find.byKey(const Key('security-answer')), 'private answer $index');
    await tap(tester, index == 2 ? 'Review questions' : 'Next question');
  }

  testWidgets('three guided questions activate only after explicit save',
      (tester) async {
    final service = SecurityQuestionsService();
    await open(tester, SecurityQuestionsSettingsScreen(service: service));
    await tap(tester, 'Set up questions');
    await complete(tester, 0);
    expect(service.enabled, isFalse);
    await tap(tester, 'Choose a question');
    final selected = tester.widget<ListTile>(
        find.widgetWithText(ListTile, securityQuestionPresets[0]));
    expect(selected.enabled, isFalse);
    await tap(tester, securityQuestionPresets[1]);
    await tester.enterText(
        find.byKey(const Key('security-answer')), 'private answer 1');
    await tap(tester, 'Next question');
    await complete(tester, 2);
    expect(find.text('private answer 0'), findsNothing);
    expect(service.enabled, isFalse);
    await tap(tester, 'Save questions');
    expect(service.enabled, isTrue);
    expect(find.text('Security questions saved'), findsOneWidget);
  });
  testWidgets('challenge never completes from partial or wrong answers',
      (tester) async {
    final service = SecurityQuestionsService();
    await service.saveInitial([
      for (var i = 0; i < 3; i++)
        QuestionAnswer(securityQuestionPresets[i], 'answer $i')
    ]);
    var verified = 0;
    await open(
        tester,
        SecurityQuestionsChallengeScreen(
            service: service, onVerified: () => verified++));
    for (var i = 0; i < 3; i++) {
      final field = find.byKey(Key('challenge-answer-$i'));
      expect(tester.widget<TextField>(field).obscureText, isTrue);
      await tester.enterText(field, 'wrong');
    }
    await tap(tester, 'Verify answers');
    expect(verified, 0);
    expect(find.textContaining('Answers did not match'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.enterText(
          find.byKey(Key('challenge-answer-$i')), 'answer $i');
    }
    await tap(tester, 'Verify answers');
    expect(verified, 1);
  });
  testWidgets(
      'recovery back after code preserves old questions and does not unlock',
      (tester) async {
    final service = SecurityQuestionsService();
    await service.saveInitial([
      for (var i = 0; i < 3; i++)
        QuestionAnswer(securityQuestionPresets[i], 'answer $i')
    ]);
    var verified = 0;
    await open(
        tester,
        SecurityQuestionsChallengeScreen(
            service: service, onVerified: () => verified++));
    await tap(tester, 'Forgot your answers?');
    await tap(tester, 'Request preview code');
    final code =
        tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    expect(find.textContaining('no email sent'), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('security-reset-code')), 'wrong');
    await tap(tester, 'Verify code');
    expect(find.text('Verify before replacing questions'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('security-reset-code')), code);
    await tap(tester, 'Verify code');
    expect(find.text('Question 1 of 3'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Answer your security questions'), findsOneWidget);
    expect(service.questions, securityQuestionPresets.take(3).toList());
    expect(verified, 0);
  });
  testWidgets('standalone challenge back returns to primary screen',
      (tester) async {
    final service = SecurityQuestionsService();
    await service.saveInitial([
      for (var i = 0; i < 3; i++)
        QuestionAnswer(securityQuestionPresets[i], 'answer $i')
    ]);
    await open(
        tester,
        Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SecurityQuestionsChallengeScreen(
                                service: service, onVerified: () {}))),
                    child: const Text('Primary unlock')))));
    await tap(tester, 'Primary unlock');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Primary unlock'), findsOneWidget);
    expect(find.text('Answer your security questions'), findsNothing);
  });
  testWidgets('recovery replaces all questions and restarts verification',
      (tester) async {
    final service = SecurityQuestionsService();
    await service.saveInitial([
      for (var i = 0; i < 3; i++)
        QuestionAnswer(securityQuestionPresets[i], 'answer $i')
    ]);
    var verified = 0;
    await open(
        tester,
        SecurityQuestionsChallengeScreen(
            service: service, onVerified: () => verified++));
    await tap(tester, 'Forgot your answers?');
    await tap(tester, 'Request preview code');
    final code =
        tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    await tester.enterText(find.byKey(const Key('security-reset-code')), code);
    await tap(tester, 'Verify code');
    for (var i = 0; i < 3; i++) {
      await complete(tester, i, preset: i + 3);
    }
    expect(await service.verifyAnswers(['answer 0', 'answer 1', 'answer 2']),
        isTrue);
    await tap(tester, 'Save questions');
    expect(verified, 0);
    expect(service.questions, securityQuestionPresets.skip(3).toList());
    await tap(tester, 'Return to verification');
    expect(verified, 0);
    for (var i = 0; i < 3; i++) {
      final field = find.byKey(Key('challenge-answer-$i'));
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      await tester.enterText(field, 'private answer $i');
    }
    await tap(tester, 'Verify answers');
    expect(verified, 1);
  });
  testWidgets('custom duplicate disabled and back retains draft',
      (tester) async {
    final service = SecurityQuestionsService();
    await open(tester, SecurityQuestionsSettingsScreen(service: service));
    await tap(tester, 'Set up questions');
    await complete(tester, 0);
    await tap(tester, 'Choose a question');
    await tap(tester, 'Write my own question');
    await tester.enterText(find.widgetWithText(TextField, 'Your own question'),
        '  ${securityQuestionPresets[0].toUpperCase()}  ');
    await tester.enterText(
        find.byKey(const Key('security-answer')), 'custom draft');
    await tester.pumpAndSettle();
    expect(find.textContaining('already selected'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Next question'))
            .onPressed,
        isNull);
    await tester.enterText(find.widgetWithText(TextField, 'Your own question'),
        'What is my private memory?');
    await tap(tester, 'Next question');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('security-answer')))
            .controller!
            .text,
        'custom draft');
    expect(find.text('What is my private memory?'), findsOneWidget);
    expect(service.enabled, isFalse);
  });
  testWidgets('short Unicode answer cannot advance setup', (tester) async {
    await open(tester, SecurityQuestionsSettingsScreen(service: SecurityQuestionsService()));
    await tap(tester, 'Set up questions');
    await tap(tester, 'Choose a question');
    await tap(tester, securityQuestionPresets[0]);
    await tester.enterText(find.byKey(const Key('security-answer')), '😀a');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Next question')).onPressed, isNull);
  });
  testWidgets('small dark screen supports large text and keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
            data: const MediaQueryData(
                size: Size(320, 640),
                textScaler: TextScaler.linear(2),
                viewInsets: EdgeInsets.only(bottom: 240),
                disableAnimations: true),
            child: SecurityQuestionsSettingsScreen(
                service: SecurityQuestionsService()))));
    await tap(tester, 'Set up questions');
    await complete(tester, 0);
    expect(tester.takeException(), isNull);
  });
}
