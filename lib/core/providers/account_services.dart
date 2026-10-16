import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../preview/local_preview_profile.dart';
import '../preview/preview_auth_state.dart';
import '../preview/settings_preview_session.dart';
import '../theme/appearance_controller.dart';
import '../../features/profile_settings/presentation/verification/verification_state.dart';
import 'reactive_builder.dart';

final profileServiceProvider = Provider<LocalPreviewProfile>(
  (ref) => LocalPreviewProfile.instance,
);
final verificationServiceProvider = Provider<VerificationSession>(
  (ref) => VerificationSession.instance,
);
final settingsServiceProvider = Provider<SettingsPreviewSession>(
  (ref) => SettingsPreviewSession.instance,
);
final appearanceControllerProvider = Provider<AppearanceController>(
  (ref) => AppearanceController.instance,
);

class ProfileView {
  ProfileView(LocalPreviewProfile p)
    : fullName = p.fullName,
      email = p.email,
      generation = p.generation;
  final String fullName, email;
  final int generation;
}

class VerificationView {
  VerificationView(VerificationSession s)
    : submitted = s.basicSubmitted,
      generation = s.generation,
      advancedSubmitted = s.advancedSubmitted;
  final bool submitted, advancedSubmitted;
  final int generation;
}

class AuthView {
  const AuthView(this.unlocked, this.biometrics, this.paymentBiometrics);
  final bool unlocked, biometrics, paymentBiometrics;
}

final profileProvider = Provider<ProfileView>((ref) {
  final p = ref.watch(profileServiceProvider);
  ref.watch(listenableRevisionProvider(p));
  return ProfileView(p);
});
final verificationViewProvider = Provider<VerificationView>((ref) {
  final p = ref.watch(verificationServiceProvider);
  ref.watch(listenableRevisionProvider(p));
  return VerificationView(p);
});
final authViewProvider = Provider<AuthView>((ref) {
  for (final listenable in [
    PreviewAuthState.unlocked,
    PreviewAuthState.biometricsEnabled,
    PreviewAuthState.paymentBiometricsEnabled,
  ]) {
    ref.watch(listenableRevisionProvider(listenable));
  }
  return AuthView(
    PreviewAuthState.unlocked.value,
    PreviewAuthState.biometricsEnabled.value,
    PreviewAuthState.paymentBiometricsEnabled.value,
  );
});
final appearanceModeProvider = Provider<ThemeMode>((ref) {
  final p = ref.watch(appearanceControllerProvider);
  ref.watch(listenableRevisionProvider(p));
  return p.mode;
});
final settingsRevisionProvider = Provider<int>(
  (ref) =>
      ref.watch(listenableRevisionProvider(ref.watch(settingsServiceProvider))),
);
