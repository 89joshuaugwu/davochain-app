import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'davo_motion_spec.dart';

class DavoOutcomeArtwork extends StatelessWidget {
  const DavoOutcomeArtwork(
      {super.key, required this.kind, required this.progress, this.size = 148});
  final DavoOutcomeKind kind;
  final double progress, size;
  @override
  Widget build(BuildContext context) {
    final frame = DavoOutcomeFrame(kind, progress);
    return RepaintBoundary(
        child: SizedBox.square(
            dimension: size,
            child: FittedBox(
                child: SizedBox.square(
                    dimension: 148,
                    child: Stack(children: [
                      if (frame.completed && frame.ms < 440)
                        Positioned(
                            left: 45,
                            top: 74 - 58 * 201 / 285 / 2,
                            width: 58,
                            height: 58 * 201 / 285,
                            child: Opacity(
                                opacity: 1 - frame.p(240, 440),
                                child: _BrandAssembly(frame: frame))),
                      Positioned.fill(
                          child: CustomPaint(
                              painter: DavoOutcomePainter(kind, progress))),
                    ])))));
  }
}

class _BrandAssembly extends StatelessWidget {
  const _BrandAssembly({required this.frame});
  final DavoOutcomeFrame frame;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final scale = constraints.maxWidth / 285;
        Widget part(Rect region, Offset offset, double opacity) => Positioned.fill(
            child: Transform.translate(
                offset: offset,
                child: Opacity(
                    opacity: opacity,
                    child: ClipRect(
                        clipper: _BrandClip(region),
                        child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minWidth: 391 * scale,
                            maxWidth: 391 * scale,
                            minHeight: 329 * scale,
                            maxHeight: 329 * scale,
                            child: Transform.translate(
                                offset: Offset(-43 * scale, -69 * scale),
                                child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                        AppColors.primary, BlendMode.srcIn),
                                    child: Image.asset(
                                        'assets/images/brand/davochain_logo.png',
                                        fit: BoxFit.fill))))))));
        final gather = frame.p(0, 240);
        return Stack(clipBehavior: Clip.none, children: [
          part(const Rect.fromLTRB(0, .58, .29, 1), Offset.zero,
              frame.p(0, 120)),
          part(const Rect.fromLTRB(0, 0, 1, .46),
              const Offset(14, -10) * (1 - gather), 1),
          part(const Rect.fromLTRB(.30, .54, 1, 1),
              const Offset(-12, 10) * (1 - gather), 1)
        ]);
      });
}

class _BrandClip extends CustomClipper<Rect> {
  const _BrandClip(this.rect);
  final Rect rect;
  @override
  Rect getClip(Size s) => Rect.fromLTRB(rect.left * s.width,
      rect.top * s.height, rect.right * s.width, rect.bottom * s.height);
  @override
  bool shouldReclip(_BrandClip old) => old.rect != rect;
}

class DavoOutcomePainter extends CustomPainter {
  const DavoOutcomePainter(this.kind, this.progress);
  final DavoOutcomeKind kind;
  final double progress;
  void path(Canvas c, Path p, double value, Paint paint) {
    if (value <= 0) return;
    for (final metric in p.computeMetrics()) {
      c.drawPath(metric.extractPath(0, metric.length * value), paint);
    }
  }

  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.scale(size.width / 148, size.height / 148);
    final f = DavoOutcomeFrame(kind, progress);
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (!f.completed && f.ms < 420) {
      final opacity = f.p(0, 200) * (1 - f.p(200, 420));
      c.save();
      c.translate(0, -10 * (1 - f.p(0, 200)) + 10 * f.p(200, 420));
      stroke.color = AppColors.primary.withValues(alpha: opacity);
      c.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTRB(56, 42, 92, 86), const Radius.circular(4)),
          stroke);
      stroke.strokeWidth = 2;
      c.drawLine(const Offset(63, 57), const Offset(85, 57), stroke);
      c.drawLine(const Offset(63, 65), const Offset(80, 65), stroke);
      c.restore();
    }
    c.drawCircle(const Offset(74, 74), f.discRadius,
        Paint()..color = AppColors.primary.withValues(alpha: f.discOpacity));
    if (f.insetRadius > 0) {
      c.drawCircle(
          const Offset(74, 74), f.insetRadius, Paint()..color = Colors.white);
    }
    stroke
      ..color = AppColors.primary
      ..strokeWidth = f.completed ? 6.5 : 2.5;
    if (f.completed) {
      path(
          c,
          Path()
            ..moveTo(62, 74)
            ..lineTo(71, 83)
            ..lineTo(88, 66),
          f.check,
          stroke);
    } else {
      if (f.clock > 0) {
        c.drawCircle(const Offset(74, 74), 13,
            stroke..color = AppColors.primary.withValues(alpha: f.clock));
      }
      stroke.color = AppColors.primary;
      path(
          c,
          Path()
            ..moveTo(74, 65)
            ..lineTo(74, 74)
            ..lineTo(80, 78),
          f.hands,
          stroke);
    }
    c.restore();
  }

  @override
  bool shouldRepaint(DavoOutcomePainter old) =>
      old.progress != progress || old.kind != kind;
}
