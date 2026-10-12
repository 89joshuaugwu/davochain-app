import 'support/fake_verification_media.dart';
import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/verification/advanced_verification_flow.dart';
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
  void basic() {
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
  }

  void identity() {
    basic();
    session.chooseDocument('International passport');
    session.addIdentitySide(front: true);
    session.addFace();
    session.verifyIdentity();
  }

  Future<void> mount(WidgetTester tester,
          {Future<bool> Function()? verifyIdentity,
          Future<bool> Function()? verifyAddress}) =>
      tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: AdvancedVerificationFlowScreen(
              verifyIdentity: verifyIdentity, verifyAddress: verifyAddress)));
  Future<void> tap(WidgetTester tester, String label) async {
    final target = label == 'Upload Document'
        ? find.widgetWithText(InkWell, label).first
        : find.text(label).first;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('Basic completion gates direct Advanced navigation',
      (tester) async {
    await mount(tester);
    expect(find.text('Complete basic verification first'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });
  testWidgets('ID upload resumes at selfie without losing optional back',
      (tester) async {
    basic();
    session.chooseDocument('National ID card');
    session.addIdentitySide(front: true);
    await mount(tester);
    expect(find.text('Take a selfie'), findsOneWidget);
    expect(session.faceAdded, isFalse);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('ID Front'), findsOneWidget);
    expect(find.text('Upload ID Back'), findsOneWidget);
    expect(session.identityFrontAdded, isTrue);
    expect(tester.takeException(), isNull);
  });
  test('Changing ID clears identity approval and full verification', () {
    identity();
    session.chooseAddressDocument('Utility bill');
    session.addAddressDocument();
    session.submitAdvanced();
    session.chooseDocument('National ID card');
    expect(session.identityFrontAdded, isFalse);
    expect(session.faceAdded, isFalse);
    expect(session.identityVerified, isFalse);
    expect(session.addressVerified, isFalse);
    expect(session.advancedSubmitted, isFalse);
  });
  testWidgets('failed address verification retains document and allows retry',
      (tester) async {
    identity();
    await mount(tester, verifyAddress: () async => false);
    await tap(tester, 'Address Verification');
    await tap(tester, 'Continue');
    await tap(tester, 'Upload Document');
    await tap(tester, 'Continue');
    await tap(tester, 'Continue');
    expect(
        find.textContaining('Could not verify your address'), findsOneWidget);
    expect(session.addressDocumentAdded, isTrue);
    expect(session.addressVerified, isFalse);
    expect(session.advancedSubmitted, isFalse);
  });
  testWidgets('back cancels matching and ignores a late successful response',
      (tester) async {
    basic();
    session.chooseDocument('National ID card');
    session.addIdentitySide(front: true);
    final response = Completer<bool>();
    await mount(tester, verifyIdentity: () => response.future);
    await tap(tester, 'Start live face detection');
    await tester.tap(find.text('Submit photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(session.identityVerified, isFalse);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    response.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Review your photo'), findsOneWidget);
    expect(session.identityVerified, isFalse);
    expect(session.faceAdded, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('address details can be edited without losing the uploaded file',
      (tester) async {
    identity();
    await mount(tester);
    await tap(tester, 'Address Verification');
    await tap(tester, 'Continue');
    await tap(tester, 'Upload Document');
    await tap(tester, 'Continue');
    await tap(tester, 'Edit');
    await tester.enterText(find.byType(TextField), '24 Marina Road');
    await tester.pump();
    await tap(tester, 'Save address');
    expect(find.textContaining('24 Marina Road'), findsOneWidget);
    expect(session.profileDraft['address'], '24 Marina Road');
    expect(session.addressDocumentAdded, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      '320px with large text and reduced motion keeps actions reachable',
      (tester) async {
    basic();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: true),
            child: child!),
        home: const AdvancedVerificationFlowScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start'));
    expect(find.text('Start').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
