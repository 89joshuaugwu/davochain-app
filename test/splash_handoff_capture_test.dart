import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/onboarding/presentation/brand_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('render the splash timeline for the React Native handoff',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
    });
    final ready = Completer<void>();
    final key = GlobalKey();
    final directory = Directory('../tmp/splash-motion-frames')
      ..createSync(recursive: true);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: RepaintBoundary(
        key: key,
        child: BrandSplashScreen(firstFrameReady: ready.future),
      ),
    ));
    await tester.runAsync(() => precacheImage(
        const AssetImage('assets/images/brand/davochain_logo.png'),
        key.currentContext!));
    ready.complete();
    await tester.pump();
    for (var frame = 0; frame < 87; frame++) {
      if (frame > 0) {
        await tester.pump(const Duration(microseconds: 33333));
      }
      await tester.runAsync(() async {
        final image = await (key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('${directory.path}/frame-${frame.toString().padLeft(3, '0')}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  }, skip: !const bool.fromEnvironment('CAPTURE_SPLASH_HANDOFF'));
}
