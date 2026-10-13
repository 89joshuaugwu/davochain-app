import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/shared/motion/davo_refresh_artwork.dart';
import 'package:davochain/shared/motion/davo_outcome_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('brand assembly and orbit render at refresh size in both themes',
      (tester) async {
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: RepaintBoundary(
                    key: boundaryKey,
                    child: SizedBox(
                        width: 288,
                        height: 192,
                        child: Column(children: [
                          for (final dark in [false, true])
                            Container(
                                color: dark
                                    ? const Color(0xff111827)
                                    : Colors.white,
                                height: 96,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (final assembly in [.15, .55, 1.0])
                                        Container(
                                            decoration: BoxDecoration(
                                                color: dark
                                                    ? const Color(0xff202b40)
                                                    : Colors.white,
                                                shape: BoxShape.circle),
                                            child: DavoRefreshArtwork(
                                                assembly: assembly,
                                                orbit: .2,
                                                active: assembly == 1)),
                                    ])),
                        ])))))));
    await tester.runAsync(() => precacheImage(
        const AssetImage('assets/images/brand/davochain_logo.png'),
        tester.element(find.byType(DavoRefreshArtwork).first)));
    await tester.pump();
    expect(find.byType(DavoBrandAssembly), findsNWidgets(6));
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_DAVO_REFRESH')) {
      await tester.runAsync(() async {
        final image = await (boundaryKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 3);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('../tmp/davo-refresh-artwork.png')
            .writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
