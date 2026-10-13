import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'app.dart';
import 'core/theme/appearance_controller.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final imagePicker = ImagePickerPlatform.instance;
  if (imagePicker is ImagePickerAndroid) {
    imagePicker.useAndroidPhotoPicker = true;
  }
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  await AppearanceController.instance.restore();
  runApp(DavochainApp(firstFrameReady: binding.waitUntilFirstFrameRasterized));
}
