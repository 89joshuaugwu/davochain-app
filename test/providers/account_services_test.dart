import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:davochain/core/providers/account_services.dart';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/appearance_controller.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'sign-out clears account providers and preserves device appearance',
    () async {
      LocalPreviewProfile.instance.register(
        name: 'New Account',
        email: 'new@example.com',
        phone: '+234 8012345678',
      );
      final appearance = AppearanceController(
        read: () async => 'dark',
        write: (_) async {},
      );
      await appearance.restore();
      final c = ProviderContainer(
        overrides: [appearanceControllerProvider.overrideWithValue(appearance)],
      );
      addTearDown(c.dispose);
      final profileSub = c.listen(profileProvider, (_, _) {});
      addTearDown(profileSub.close);
      expect(c.read(profileProvider).fullName, 'New Account');
      final generation = WalletAccountState.instance.generation;
      await LocalPreviewProfile.instance.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(WalletAccountState.instance.generation, greaterThan(generation));
      expect(c.read(authViewProvider).unlocked, isFalse);
      expect(c.read(verificationViewProvider).submitted, isFalse);
      expect(c.read(appearanceModeProvider), ThemeMode.dark);
      expect(VerificationSession.instance.profileDraft, isEmpty);
    },
  );
}
