import 'support/fake_biometric_gateway.dart';
import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/features/auth/presentation/fingerprint_setup_screen.dart';
import 'package:davochain/features/auth/presentation/returning_unlock_screen.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    BiometricGateway.instance = FakeBiometricGateway(accept: false);
    PreviewAuthState.biometricsEnabled.value = false;
    PreviewAuthState.unlocked.value = false;
  });
  tearDown(() {
    BiometricGateway.instance = DeviceBiometricGateway();
    PreviewAuthState.biometricsEnabled.value = false;
  });
  testWidgets('unsuccessful device confirmation cannot enable biometrics',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FingerprintSetupScreen()));
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Not now'));
    await tester.ensureVisible(
        find.widgetWithText(DavoPrimaryButton, 'Enable fingerprint'));
    await tester
        .tap(find.widgetWithText(DavoPrimaryButton, 'Enable fingerprint'));
    await tester.pumpAndSettle();
    expect(PreviewAuthState.biometricsEnabled.value, isFalse);
    expect((BiometricGateway.instance as FakeBiometricGateway).calls, 1);
  });
  testWidgets('failed returning biometrics keeps password and PIN fallback',
      (tester) async {
    PreviewAuthState.biometricsEnabled.value = true;
    await tester.pumpWidget(const MaterialApp(home: ReturningUnlockScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use fingerprint'));
    await tester.pumpAndSettle();
    expect(PreviewAuthState.unlocked.value, isFalse);
    expect(find.byType(ReturningUnlockScreen), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
    expect((BiometricGateway.instance as FakeBiometricGateway).calls, 1);
  });
}
