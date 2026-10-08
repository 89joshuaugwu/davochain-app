import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/theme/appearance_controller.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  await AppearanceController.instance.restore();
  runApp(DavochainApp(firstFrameReady: binding.waitUntilFirstFrameRasterized));
}
