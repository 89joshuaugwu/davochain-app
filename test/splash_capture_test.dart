import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/onboarding/presentation/brand_splash_screen.dart';

void main() {
  testWidgets('capture final splash composition at phone sizes',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
    });
    final directory = Directory('../tmp/splash-refinement-review')
      ..createSync(recursive: true);
    for (final size in [
      const Size(320, 640),
      const Size(390, 844),
      const Size(414, 896)
    ]) {
      tester.view.physicalSize = size;
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: RepaintBoundary(key: key, child: const BrandSplashScreen()),
      ));
      await tester.pump();
      await tester.runAsync(() => precacheImage(
          const AssetImage('assets/images/brand/davochain_logo.png'),
          key.currentContext!));
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.runAsync(() async {
        final image = await (key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('${directory.path}/splash-${size.width.toInt()}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  }, skip: !const bool.fromEnvironment('CAPTURE_SPLASH'));
}
