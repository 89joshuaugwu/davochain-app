import 'support/fake_verification_media.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/verification/advanced_verification_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => VerificationMediaGateway.instance = FakeVerificationMedia());
  tearDown(() =>
      VerificationMediaGateway.instance = DeviceVerificationMediaGateway());
  final session = VerificationSession.instance;
  setUp(session.reset);
  tearDown(session.reset);
  testWidgets('Basic method starts with shared identity requirements',
      (tester) async {
    session.completeProfile();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const BasicIdentityChoiceScreen()));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('BVN Verification'), findsOneWidget);
    expect(find.text('What you need'), findsOneWidget);
    expect(find.text('Your registered phone number'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '12345678901');
    await tester.pump();
    expect(find.byKey(const Key('identity-number-complete')), findsOneWidget);
  });
  testWidgets(
      'Advanced completes ID before face then separately verifies address',
      (tester) async {
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.bvn, '12345678901');
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const AdvancedVerificationFlowScreen()));
    Future<void> tap(String text) async {
      final target = text == 'Upload Document'
          ? find.widgetWithText(InkWell, text).first
          : find.text(text).first;
      await tester.ensureVisible(target);
      final loading = text == 'Submit photo' ||
          (text == 'Continue' &&
              find.text('Address Details').evaluate().isNotEmpty);
      await tester.tap(target);
      if (loading) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
      } else {
        await tester.pumpAndSettle();
      }
    }

    await tap('Start');
    await tap('ID Verification');
    await tap('Start');
    await tap('Upload ID Front');
    await tap('Continue');
    expect(find.text('Take a selfie'), findsOneWidget);
    expect(session.faceAdded, isFalse);
    await tap('Start live face detection');
    await tap('Submit photo');
    expect(find.text('Matching your identity'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Verifications Completed'), findsOneWidget);
    expect(session.advancedSubmitted, isFalse);
    await tap('Continue to Address Verification');
    await tap('Address Verification');
    await tap('Continue');
    await tap('Upload Document');
    await tap('Continue');
    expect(find.text('Address Details'), findsOneWidget);
    await tap('Continue');
    expect(find.text('Verifying your Address'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Your Account is Fully Verified'), findsOneWidget);
    expect(session.advancedSubmitted, isTrue);
    expect(find.text('Pending review'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
