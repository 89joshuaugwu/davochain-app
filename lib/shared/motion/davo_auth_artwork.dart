import 'package:flutter/material.dart';
import 'davo_motion_spec.dart';

/// Deterministic authentication artwork; credentials remain caller-owned.
class DavoAuthArtwork extends StatelessWidget {
  const DavoAuthArtwork(
      {super.key,
      required this.fingerprint,
      required this.progress,
      required this.color});
  final bool fingerprint;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: SizedBox.square(
          dimension: 112,
          child: CustomPaint(
              painter: DavoAuthPainter(fingerprint, progress, color))));
}

class DavoAuthPainter extends CustomPainter {
  const DavoAuthPainter(this.fingerprint, this.progress, this.color);
  final bool fingerprint;
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 112, size.height / 112);
    final ms = progress * (fingerprint ? 960 : 1000);
    double phase(double a, double b) => DavoMotionSpec.phase(ms, a, b);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = fingerprint ? 2.5 : 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void draw(Path path, double value, double opacity) {
      pen.color = color.withValues(alpha: opacity.clamp(0, 1));
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * value), pen);
      }
    }

    if (fingerprint) {
      final paths = [
        Path()
          ..moveTo(28, 58)
          ..cubicTo(28, 18, 84, 18, 84, 58),
        Path()
          ..moveTo(35, 63)
          ..cubicTo(35, 29, 77, 29, 77, 60)
          ..cubicTo(77, 76, 70, 86, 63, 91),
        Path()
          ..moveTo(42, 68)
          ..cubicTo(42, 43, 70, 41, 70, 61)
          ..cubicTo(70, 75, 65, 81, 58, 86),
        Path()
          ..moveTo(49, 72)
          ..cubicTo(49, 51, 63, 49, 63, 62)
          ..cubicTo(63, 72, 58, 78, 52, 82),
        Path()
          ..moveTo(56, 60)
          ..cubicTo(56, 72, 50, 82, 43, 88),
      ];
      for (var i = 0; i < paths.length; i++) {
        draw(paths[i], 1, .18 * (1 - phase(480, 640)));
        draw(paths[i], phase(120 + i * 40, 320 + i * 40), 1 - phase(480, 640));
      }
    } else {
      for (final x in [35.0, 49.0, 63.0, 77.0]) {
        canvas.drawCircle(
            Offset(x + (56 - x) * phase(140, 340), 56 + 8 * phase(140, 340)),
            3,
            Paint()
              ..color = color.withValues(
                  alpha: phase(0, 140) * (1 - phase(140, 340))));
      }
      pen.color =
          color.withValues(alpha: phase(220, 360) * (1 - phase(520, 680)));
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTRB(38, 50, 74, 78), const Radius.circular(6)),
          pen);
      draw(
          Path()
            ..moveTo(45, 50)
            ..lineTo(45, 41)
            ..cubicTo(45, 26, 67, 26, 67, 41)
            ..lineTo(67, 50),
          phase(300, 520),
          1 - phase(520, 680));
    }
    pen.strokeWidth = 4;
    draw(
        Path()
          ..moveTo(40, 56)
          ..lineTo(51, 67)
          ..lineTo(73, 45),
        phase(fingerprint ? 500 : 520, fingerprint ? 700 : 680),
        1);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DavoAuthPainter old) =>
      old.fingerprint != fingerprint ||
      old.progress != progress ||
      old.color != color;
}
