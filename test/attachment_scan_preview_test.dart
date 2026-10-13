import 'package:davochain/features/profile_settings/verification_media/attachment_scan_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget preview({bool reduced = false}) => MaterialApp(
      home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const IntrinsicHeight(
              child: Row(children: [
            Expanded(
                child: AttachmentScanPreview(
                    key: ValueKey('same-attachment'),
                    child: SizedBox(
                        height: 120, child: ColoredBox(color: Colors.white))))
          ]))));
  testWidgets('preview scans twice then retains completion through rebuilds',
      (tester) async {
    await tester.pumpWidget(preview());
    await tester.pump();
    Rect shade() => tester
        .widgetList<ClipRect>(find.byType(ClipRect))
        .firstWhere((widget) => widget.clipper != null)
        .clipper!
        .getClip(const Size(100, 120));
    await tester.pump(const Duration(milliseconds: 400));
    expect(shade().top, closeTo(60, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(shade().top, closeTo(0, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(shade().top, closeTo(60, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
        tester
            .widgetList<ClipRect>(find.byType(ClipRect))
            .where((widget) => widget.clipper != null),
        isEmpty);
    await tester.pumpWidget(preview());
    expect(
        tester
            .widgetList<ClipRect>(find.byType(ClipRect))
            .where((widget) => widget.clipper != null),
        isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion shows the unchanged preview immediately',
      (tester) async {
    await tester.pumpWidget(preview(reduced: true));
    expect(find.byType(ColoredBox), findsWidgets);
    expect(
        tester
            .widgetList<ClipRect>(find.byType(ClipRect))
            .where((widget) => widget.clipper != null),
        isEmpty);
    expect(tester.takeException(), isNull);
  });
}
