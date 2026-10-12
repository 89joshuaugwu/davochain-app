import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

Rect faceGuideOval(Size size) {
  final height = math.min(size.height * .84, size.width / .74 * .78);
  return Rect.fromCenter(center: size.center(Offset.zero),
      width: height * .74, height: height);
}

/// Only the surroundings are filtered; the face inside the oval stays sharp.
class FaceOvalOverlay extends StatelessWidget {
  const FaceOvalOverlay({super.key, required this.ready});
  final bool ready;
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Stack(
      fit: StackFit.expand, children: [
        ClipPath(clipper: const _OutsideOval(), child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: const ColoredBox(color: Color(0x55000000)))),
        CustomPaint(painter: _OvalBorder(ready)),
      ]));
}

class _OutsideOval extends CustomClipper<Path> {
  const _OutsideOval();
  @override Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addOval(faceGuideOval(size));
  @override bool shouldReclip(_OutsideOval oldClipper) => false;
}

class _OvalBorder extends CustomPainter {
  const _OvalBorder(this.ready);
  final bool ready;
  @override void paint(Canvas canvas, Size size) => canvas.drawOval(
      faceGuideOval(size), Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = ready ? AppColors.primary : Colors.white);
  @override bool shouldRepaint(_OvalBorder oldDelegate) => ready != oldDelegate.ready;
}
