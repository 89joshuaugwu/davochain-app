import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Rect faceGuideOval(Size size) {
  final height = math.min(size.height * .84, size.width / .74 * .78);
  return Rect.fromCenter(
      center: size.center(Offset.zero), width: height * .74, height: height);
}

/// Rounded forehead and cheeks flow into a broad, softly rounded jaw.
Path faceGuidePath(Size size) {
  final r = faceGuideOval(size);
  final x = r.left, y = r.top, w = r.width, h = r.height;
  return Path()
    ..moveTo(x + w * .5, y)
    ..cubicTo(x + w * .78, y, x + w, y + h * .16, x + w, y + h * .38)
    ..cubicTo(x + w, y + h * .70, x + w * .80, y + h, x + w * .5, y + h)
    ..cubicTo(x + w * .20, y + h, x, y + h * .70, x, y + h * .38)
    ..cubicTo(x, y + h * .16, x + w * .22, y, x + w * .5, y)
    ..close();
}

/// Only the surroundings are filtered; aligned hold progress fills the ticks.
class FaceOvalOverlay extends StatelessWidget {
  const FaceOvalOverlay({super.key, required this.ready, this.progress = 0});
  final bool ready;
  final double progress;
  @override
  Widget build(BuildContext context) => IgnorePointer(
          child: Stack(fit: StackFit.expand, children: [
        ClipPath(
            clipper: const _OutsideOval(),
            child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: const ColoredBox(color: Color(0x55000000)))),
        Semantics(
            label: 'Face position hold progress',
            value: '${(progress.clamp(0, 1) * 100).round()} percent',
            child: CustomPaint(painter: _OvalBorder(ready, progress))),
      ]));
}

class _OutsideOval extends CustomClipper<Path> {
  const _OutsideOval();
  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addPath(faceGuidePath(size), Offset.zero);
  @override
  bool shouldReclip(_OutsideOval oldClipper) => false;
}

class _OvalBorder extends CustomPainter {
  const _OvalBorder(this.ready, this.progress);
  final bool ready;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final path = faceGuidePath(size);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: .35));
    final metric = path.computeMetrics().first;
    const count = 100;
    final filled = (progress.clamp(0, 1) * count).floor();
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final tangent = metric.getTangentForOffset(metric.length * i / count)!;
      final normal = Offset(tangent.vector.dy, -tangent.vector.dx);
      paint.color = i < filled
          ? const Color(0xFF15976F)
          : ready
              ? Colors.white
              : Colors.white.withValues(alpha: .65);
      canvas.drawLine(
          tangent.position + normal * 4, tangent.position + normal * 10, paint);
    }
  }

  @override
  bool shouldRepaint(_OvalBorder oldDelegate) =>
      ready != oldDelegate.ready || progress != oldDelegate.progress;
}
