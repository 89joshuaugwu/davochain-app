import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single, finite confirmation accent. Present only after the caller has
/// established the outcome; this widget does not establish transaction status.
class DavoSuccessMark extends StatefulWidget {
  const DavoSuccessMark({
    super.key,
    this.size = 148,
    this.semanticLabel = 'Success',
  }) : assert(size > 0);

  final double size;
  final String semanticLabel;

  @override
  State<DavoSuccessMark> createState() => _DavoSuccessMarkState();
}

class _DavoSuccessMarkState extends State<DavoSuccessMark>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (reduceMotion) {
      _started = true;
      _controller?.stop();
      _controller?.value = 1;
    } else if (!_started) {
      _started = true;
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 850),
      )..forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint(double progress) => CustomPaint(
          size: Size.square(widget.size),
          painter: _SuccessPainter(progress),
        );

    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: _controller == null
              ? paint(1)
              : AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) => paint(_controller!.value),
                ),
        ),
      ),
    );
  }
}

class _SuccessPainter extends CustomPainter {
  const _SuccessPainter(this.progress);

  final double progress;
  static const _blue = Color(0xFF135CF7);

  double _phase(double start, double end) =>
      ((progress - start) / (end - start)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 148);
    const center = Offset(74, 74);
    final arrival = Curves.easeOutCubic.transform(_phase(0, .5));
    final halo = Curves.easeOutCubic.transform(_phase(0, .8));
    final accentOpacity = math.sin(math.pi * _phase(.08, .9));

    canvas.drawCircle(
        center, 57, Paint()..color = _blue.withValues(alpha: .08));
    if (progress < 1) {
      canvas.drawCircle(
        center,
        52 + 17 * halo,
        Paint()
          ..color = _blue.withValues(alpha: .12 * (1 - halo))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      for (final angle in [-math.pi / 3, math.pi / 7, math.pi * .82]) {
        final radius = 61 + 7 * halo;
        final point =
            center + Offset(math.cos(angle), math.sin(angle)) * radius;
        canvas.drawCircle(
          point,
          1.8,
          Paint()..color = _blue.withValues(alpha: .55 * accentOpacity),
        );
      }
    }

    canvas.drawCircle(center, 43 + 2 * arrival, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      45,
      Paint()
        ..color = _blue.withValues(alpha: .12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 45),
      -math.pi / 2,
      2 * math.pi * Curves.easeOutCubic.transform(_phase(0, .65)),
      false,
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5,
    );

    final check = Path()
      ..moveTo(55, 74)
      ..lineTo(68, 87)
      ..lineTo(94, 61);
    final metric = check.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(
        0,
        metric.length * Curves.easeOutCubic.transform(_phase(.25, .85)),
      ),
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SuccessPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
