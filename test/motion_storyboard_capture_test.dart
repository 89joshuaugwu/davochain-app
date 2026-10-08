import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import '../tool/motion_gallery.dart';

void main() {
  testWidgets('export deterministic storyboard PNG checkpoints',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final loader = FontLoader('Sora')
        ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf'));
      await loader.load();
    });
    final frames = <String, List<int>>{
      'C': [0, 240, 440, 660, 880, 1120],
      'S': [0, 200, 420, 600, 760, 900],
      'P': [0, 140, 340, 520, 680, 840, 1000],
      'F': [0, 120, 320, 480, 640, 800, 960],
      'W': [0, 300, 600, 900, 1200],
      'K': [0, 100, 190, 280],
      'H': [0, 80, 160, 280]
    };
    final directory = Directory('../tmp/motion-storyboards')
      ..createSync(recursive: true);
    for (final entry in frames.entries) {
      for (final blue
          in entry.key == 'P' || entry.key == 'F' ? [false, true] : [false]) {
        for (final ms in entry.value) {
          final key = GlobalKey();
          await tester.pumpWidget(MaterialApp(
              theme: AppTheme.light,
              home: RepaintBoundary(
                  key: key,
                  child: MotionReferenceScene(
                      scene: entry.key,
                      progress: ms / entry.value.last,
                      blue: blue))));
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image = await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
                    '${directory.path}/${entry.key}-${blue ? 'blue' : 'white'}-$ms.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    }
  }, skip: !const bool.fromEnvironment('CAPTURE_MOTION'));
}
