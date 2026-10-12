import 'package:davochain/features/profile_settings/presentation/verification/verification_components.dart';
import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(session.reset);
  tearDown(session.reset);
  Widget app(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

  for (final method in BasicIdentityMethod.values) {
    testWidgets('${method.shortLabel} commits only after a successful response',
        (tester) async {
      session.completeProfile();
      final response = Completer<bool>();
      await tester.pumpWidget(app(BasicIdentityNumberScreen(
          method: method, verify: (_, __) => response.future)));
      await tester.enterText(find.byType(TextField), '12345678901');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Verifying your ${method.shortLabel}'), findsOneWidget);
      expect(session.canStartAdvanced, isFalse);
      response.complete(true);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(session.basicVerified, isTrue);
      expect(find.text('Basic Verifications Completed'), findsOneWidget);
      expect(find.text('Pending review'), findsNothing);
    });
  }
  testWidgets(
      'failed verification retains input for retry and does not unlock Advanced',
      (tester) async {
    session.completeProfile();
    await tester.pumpWidget(app(BasicIdentityNumberScreen(
        method: BasicIdentityMethod.bvn, verify: (_, __) async => false)));
    await tester.enterText(find.byType(TextField), '12345678901');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(session.canStartAdvanced, isFalse);
    expect(find.textContaining('Could not verify'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '12345678901');
  });
  for (final reset in [false, true]) {
    testWidgets(
        'late response cannot verify a ${reset ? 'reset' : 'disposed'} session',
        (tester) async {
      session.completeProfile();
      final response = Completer<bool>();
      await tester.pumpWidget(app(BasicIdentityNumberScreen(
          method: BasicIdentityMethod.nin,
          verify: (_, __) => response.future)));
      await tester.enterText(find.byType(TextField), '12345678901');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      if (reset) {
        session.reset();
      } else {
        await tester.pumpWidget(const SizedBox());
      }
      response.complete(true);
      await tester.pump();
      expect(session.basicVerified, isFalse);
      expect(session.canStartAdvanced, isFalse);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Overview exposes Basic and gates Advanced', (tester) async {
    await tester.pumpWidget(app(const VerificationOverviewScreen()));
    expect(find.text('Basic Verification'), findsOneWidget);
    expect(find.text('Advanced Verification'), findsOneWidget);
    final advanced = tester.widget<VerificationChoiceRow>(
        find.widgetWithText(VerificationChoiceRow, 'Advanced Verification'));
    expect(advanced.onTap, isNull);
    await tester.tap(find.text('Basic Verification'));
    await tester.pumpAndSettle();
    expect(find.byType(BasicVerificationIntroScreen), findsOneWidget);
    expect(find.text('What you need'), findsOneWidget);
    expect(find.byType(CompleteProfileV12Screen), findsNothing);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteProfileV12Screen), findsOneWidget);
  });
  testWidgets(
      'Either identity choice filters to eleven digits and submits without face',
      (tester) async {
    session.completeProfile();
    await tester.pumpWidget(app(const BasicIdentityChoiceScreen()));
    await tester.tap(find.text('BVN Verification'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(BasicIdentityNumberScreen), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(find.text('What you need'), findsNothing);
    expect(find.text('Your BVN'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123a4567890123');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '12345678901');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Verifying your BVN'), findsOneWidget);
    expect(session.basicSubmitted, isFalse);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Basic Verifications Completed'), findsOneWidget);
    expect(find.text('Pending review'), findsNothing);
    expect(session.identifierLastFour, '8901');
    expect(session.faceAdded, isFalse);
  });
  testWidgets('Personal draft resumes and middle name is optional',
      (tester) async {
    session
        .saveProfile({'first': 'Ada', 'last': 'Okafor', 'dob': '1998-05-12'});
    await tester.pumpWidget(app(const CompleteProfileV12Screen()));
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Middle name (optional)'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteProfileContactV12Screen), findsOneWidget);
  });
}
