import 'package:davochain/features/profile_settings/presentation/verification/advanced_verification_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(session.reset);
  void basic() {
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
  }

  Future<void> mount(WidgetTester tester) => tester.pumpWidget(
        const MaterialApp(home: AdvancedVerificationFlowScreen()),
      );
  testWidgets('basic submission gates direct navigation', (tester) async {
    await mount(tester);
    expect(find.text('Complete basic verification first'), findsOneWidget);
    expect(find.text('Take a face photo'), findsNothing);
  });
  testWidgets('face is first and progress resumes at documents',
      (tester) async {
    basic();
    await mount(tester);
    expect(find.text('Take a face photo'), findsOneWidget);
    expect(find.text('Choose your identity document'), findsNothing);
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use photo'));
    await tester.pumpAndSettle();
    expect(session.faceAdded, isTrue);
    await tester.pumpWidget(const SizedBox());
    await mount(tester);
    expect(find.text('Choose your identity document'), findsOneWidget);
  });
  test('changing ID resets sides, passport requires only biodata page', () {
    basic();
    session.addFace();
    session.chooseDocument('National ID');
    session.addIdentitySide(front: true);
    session.addIdentitySide(front: false);
    session.chooseDocument('International passport');
    expect(session.identityBackAdded, isFalse);
    expect(session.identityFrontAdded, isFalse);
    session.addIdentitySide(front: true);
    expect(session.identityDocumentsAdded, isTrue);
    expect(() => session.submitAdvanced(), throwsStateError);
    expect(session.advancedSubmitted, isFalse);
    session.chooseAddressDocument('Utility bill');
    session.addAddressDocument();
    session.submitAdvanced();
    expect(session.advancedSubmitted, isTrue);
  });
  testWidgets('submitted outcome remains pending review', (tester) async {
    basic();
    session.addFace();
    session.chooseDocument('International passport');
    session.addIdentitySide(front: true);
    session.chooseAddressDocument('Utility bill');
    session.addAddressDocument();
    session.submitAdvanced();
    await mount(tester);
    expect(find.text('Pending review'), findsOneWidget);
    expect(find.text('Advanced verification submitted'), findsOneWidget);
    expect(find.textContaining('approved'), findsNothing);
  });
  testWidgets('documents and address gate review, back preserves the chosen ID',
      (tester) async {
    basic();
    session.addFace();
    await mount(tester);
    Future<void> tap(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    DavoPrimaryButton primary() =>
        tester.widget(find.byType(DavoPrimaryButton));
    expect(primary().enabled, isFalse);
    await tap('National ID');
    await tap('Front of document');
    expect(primary().enabled, isFalse);
    await tap('Back of document');
    expect(primary().enabled, isTrue);
    await tap('International passport');
    expect(session.identityBackAdded, isFalse);
    expect(primary().enabled, isFalse);
    expect(find.text('Back of document'), findsNothing);
    await tap('Biodata page');
    await tap('Continue');
    expect(find.text('Add proof of address'), findsOneWidget);
    expect(primary().enabled, isFalse);
    await tap('Utility bill');
    expect(primary().enabled, isFalse);
    await tap('Proof of address');
    expect(primary().enabled, isTrue);
    expect(session.advancedSubmitted, isFalse);
    await tap('Previous step');
    expect(session.identityDocumentType, 'International passport');
    expect(session.identityFrontAdded, isTrue);
    await tap('Continue');
    await tap('Review details');
    expect(find.text('Review and submit'), findsOneWidget);
    expect(session.advancedSubmitted, isFalse);
    await tap('Submit for review');
    expect(session.advancedSubmitted, isTrue);
    expect(find.text('Pending review'), findsOneWidget);
  });
  testWidgets('explicit return exits to overview and preserves progress',
      (tester) async {
    basic();
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return Scaffold(
          body: TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const AdvancedVerificationFlowScreen(),
        )),
        child: const Text('Overview'),
      ));
    })));
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to overview'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(session.faceAdded, isTrue);
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your identity document'), findsOneWidget);
  });
  testWidgets('320px with large text and reduced motion stays scrollable',
      (tester) async {
    basic();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const AdvancedVerificationFlowScreen(),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
