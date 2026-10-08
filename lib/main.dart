import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  runApp(DavochainApp(firstFrameReady: binding.waitUntilFirstFrameRasterized));
}
