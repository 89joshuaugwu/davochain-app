import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/features/profile_settings/verification_media/face_oval_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('face shape has wider forehead than chin and stays within its frame',
      () {
    const size = Size(358, 380);
    final r = faceGuideOval(size);
    final path = faceGuidePath(size);
    expect(path.contains(Offset(r.left + r.width * .12, r.top + r.height * .3)),
        isTrue);
    expect(
        path.contains(Offset(r.left + r.width * .12, r.top + r.height * .88)),
        isFalse);
    expect(path.contains(r.center), isTrue);
    expect(path.getBounds().left, greaterThan(0));
    expect(path.getBounds().bottom, lessThan(size.height));
  });
  testWidgets('perimeter progress exposes hold percent without a countdown',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
            width: 358,
            height: 380,
            child: FaceOvalOverlay(ready: true, progress: .6))));
    expect(
        find.bySemanticsLabel('Face position hold progress'), findsOneWidget);
    expect(find.text('5'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  test('oval remains centered with a face proportion across phone layouts', () {
    for (final size in [
      const Size(358, 380),
      const Size(288, 260),
      const Size(500, 300)
    ]) {
      final oval = faceGuideOval(size);
      expect((oval.center - size.center(Offset.zero)).distance, lessThan(.001));
      expect(oval.width / oval.height, closeTo(.74, .001));
      expect(oval.left, greaterThan(0));
      expect(oval.bottom, lessThan(size.height));
    }
  });
  testWidgets('outside blur excludes the face oval and ignores gestures',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
            width: 358, height: 380, child: FaceOvalOverlay(ready: false))));
    final clipper = tester.widget<ClipPath>(find.byType(ClipPath)).clipper!;
    final path = clipper.getClip(const Size(358, 380));
    expect(path.contains(const Offset(179, 190)), isFalse);
    expect(path.contains(const Offset(5, 5)), isTrue);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('capture oval overlay on the supplied photo', (tester) async {
    tester.view.physicalSize = const Size(390, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: RepaintBoundary(
            key: key,
            child: Center(
                child: SizedBox(
                    width: 358,
                    height: 380,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(fit: StackFit.expand, children: [
                          Image.asset(
                              'assets/figma_exact/verification_901d8.png',
                              fit: BoxFit.cover),
                          const FaceOvalOverlay(ready: true, progress: .65),
                        ])))))));
    await tester.runAsync(() => precacheImage(
        const AssetImage('assets/figma_exact/verification_901d8.png'),
        key.currentContext!));
    await tester.pump();
    await tester.runAsync(() async {
      final image = await (key.currentContext!.findRenderObject()!
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('../tmp/face-oval-overlay-review.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }, skip: !const bool.fromEnvironment('CAPTURE_FACE_OVAL'));
}
