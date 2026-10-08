import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/shared/widgets/davo_state_picker.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/services.dart';
import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/features/auth/presentation/returning_unlock_screen.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';

Widget app(Widget home) => MaterialApp(theme: AppTheme.light, home: home);
void main() {
  setUp(() {
    VerificationSession.instance.reset();
    PreviewAuthState.biometricsEnabled.value = false;
    PreviewAuthState.unlocked.value = false;
  });
  testWidgets('logout removes profile and previous routes', (tester) async {
    await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const ProfileSettingsScreen())),
            child: const Text('Open profile')))));
    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
        isFalse);
  });
  testWidgets('first KYC tier starts NIN and second starts BVN',
      (tester) async {
    await tester.pumpWidget(app(const KycTierIntroScreen(tier: 1)));
    expect(find.text('Tier 1: NIN Verification'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteProfileV12Screen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app(const KycTierIntroScreen(tier: 2)));
    expect(find.text('Tier 2: BVN Verification'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(BvnEntryV12Screen), findsOneWidget);
  });
  testWidgets('biometrics must be enabled through explicit preview setup',
      (tester) async {
    await tester.pumpWidget(app(const ProfileSettingsScreen()));
    await tester.ensureVisible(find.text('Enable Biometrics'));
    await tester.tap(find.text('Enable Biometrics'));
    await tester.pumpAndSettle();
    expect(find.text('Enable fingerprint'), findsNWidgets(2));
  });
  testWidgets('returning login preview runs splash then offers password unlock',
      (tester) async {
    await tester.pumpWidget(app(const ProfileSettingsScreen()));
    await tester.ensureVisible(find.text('Preview returning login'));
    await tester.tap(find.text('Preview returning login'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back, Vincent'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
    expect(find.text('Use fingerprint'), findsNothing);
  });
  testWidgets(
      'enabled fingerprint preview unlocks without a password and clears stack',
      (tester) async {
    await tester.pumpWidget(app(const ProfileSettingsScreen()));
    final setting = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Biometric unlock');
    expect(tester.widget<Semantics>(setting).properties.toggled, isFalse);
    await tester.ensureVisible(find.text('Enable Biometrics'));
    await tester.tap(find.text('Enable Biometrics'));
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(DavoPrimaryButton, 'Enable fingerprint'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(setting).properties.toggled, isTrue);
    await tester.ensureVisible(find.text('Preview returning login'));
    await tester.tap(find.text('Preview returning login'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byIcon(Icons.fingerprint_rounded)).bottom,
        lessThan(tester.getRect(find.byType(TextField)).top));
    await tester.tap(find.text('Use fingerprint'));
    await tester.pumpAndSettle();
    expect(find.byType(DavochainDashboardScreen), findsOneWidget);
    expect(
        Navigator.of(tester.element(find.byType(DavochainDashboardScreen)))
            .canPop(),
        isFalse);
  });
  testWidgets(
      'biometric preview setting can be disabled and does not reset on profile reopen',
      (tester) async {
    PreviewAuthState.biometricsEnabled.value = true;
    await tester.pumpWidget(app(const ProfileSettingsScreen()));
    await tester.ensureVisible(find.text('Enable Biometrics'));
    await tester.tap(find.text('Enable Biometrics'));
    await tester.pumpAndSettle();
    expect(PreviewAuthState.biometricsEnabled.value, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app(const ProfileSettingsScreen()));
    final setting = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Biometric unlock');
    expect(tester.widget<Semantics>(setting).properties.toggled, isFalse);
  });
  testWidgets(
      'password unlock remains reachable above keyboard on a narrow phone',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    var textScale = 1.4;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!),
        home: const ReturningUnlockScreen()));
    expect(find.text('Use fingerprint'), findsNothing);
    await tester.enterText(find.byType(TextField), 'sample');
    await tester.pump();
    await tester.ensureVisible(find.text('Unlock'));
    expect(tester.takeException(), isNull);
    // The compact keyboard contract belongs to unlock; restore ordinary metrics
    // before verifying the destination, whose layout is checked independently.
    textScale = 1;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetViewInsets();
    await tester.pump();
    await tester.ensureVisible(find.text('Unlock'));
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.byType(DavochainDashboardScreen), findsOneWidget);
  });
  testWidgets(
      'BVN completion advances to tier three and NIN face completion advances to tier two',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const BvnEntryV12Screen()));
    await tester.enterText(find.byType(TextField), '12345678901');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Tier 2 Completed'), findsOneWidget);
    expect(find.text('Continue to Tier 3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app(const FaceReviewV12Screen()));
    await tester.tap(find.text('Submit photo'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Tier 1 Completed'), findsOneWidget);
    expect(find.text('Continue to Tier 2'), findsOneWidget);
  });
  testWidgets(
      'fingerprint sits above password even before setup and cancel returns to settings',
      (tester) async {
    await tester.pumpWidget(app(const ProfileSettingsScreen()));
    await tester.ensureVisible(find.text('Preview returning login'));
    await tester.tap(find.text('Preview returning login'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    final fingerprint = find.byIcon(Icons.fingerprint_rounded);
    expect(fingerprint, findsOneWidget);
    expect(tester.getRect(fingerprint).bottom,
        lessThan(tester.getRect(find.byType(TextField)).top));
    await tester.tap(find.byTooltip('Back to Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSettingsScreen), findsOneWidget);
  });
  testWidgets(
      'reduced motion unlock keeps fingerprint and contrast without a looping reveal',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: const ReturningUnlockScreen()));
    await tester.pumpAndSettle();
    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.descendant(
            of: find.byType(ReturningUnlockScreen),
            matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>)));
    expect(region.value.statusBarIconBrightness, Brightness.light);
    expect(region.value.systemNavigationBarIconBrightness, Brightness.light);
    expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    expect(find.text('Enter your password to unlock your account.'),
        findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('completed contact form offers NIN or BVN without a facial step',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const CompleteProfileContactV12Screen()));
    await tester.enterText(find.byType(TextField).at(0), '08012345678');
    await tester.enterText(find.byType(TextField).at(1), '12 Example Street');
    await tester.tap(find.byType(DavoStatePicker));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Abia').last);
    await tester.tap(find.text('Abia').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(BasicIdentityChoiceScreen), findsOneWidget);
    await tester.tap(find.text('NIN'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '12345678901');
    await tester.pump();
    await tester.tap(find.text('Submit Basic verification'));
    await tester.pumpAndSettle();
    expect(find.byType(BasicVerificationSubmittedScreen), findsOneWidget);
    expect(find.byType(KycSelfieV12Screen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
