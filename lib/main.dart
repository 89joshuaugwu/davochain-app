import 'features/wallets/local_account_persistence.dart';
import 'features/wallets/local_ledger_store.dart';
import 'shared/receipts/transaction_repository.dart';
import 'core/preview/local_preview_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'app.dart';
import 'core/theme/appearance_controller.dart';
import 'features/profile_settings/verification_media/verification_media_gateway.dart';
import 'features/gift_cards/gift_evidence_cache.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // No verification capture is enabled until prior-process copies reconcile.
  // Startup remains usable if storage is busy; the capture gateway retries and
  // blocks new sensitive writes until reconciliation succeeds.
  try {
    await initializeVerificationCache();
  } catch (_) {
    debugPrint('Verification cache cleanup pending.');
  }
  try {
    await GiftEvidenceCache.reconcileDeviceStartup();
  } catch (_) {
    debugPrint('Gift evidence cache cleanup pending.');
  }
  final imagePicker = ImagePickerPlatform.instance;
  if (imagePicker is ImagePickerAndroid) {
    imagePicker.useAndroidPhotoPicker = true;
  }
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  await AppearanceController.instance.restore();
  try {
    final persistence = LocalAccountPersistence(
      await LocalLedgerStore.open(),
      LocalTransactionRepository.instance,
      LocalPreviewProfile.instance,
    );
    await persistence.initialize();
    LocalAccountPersistence.instance = persistence;
  } catch (_) {
    debugPrint('Account storage could not be restored.');
  }

  runApp(DavochainApp(firstFrameReady: binding.waitUntilFirstFrameRasterized));
}
