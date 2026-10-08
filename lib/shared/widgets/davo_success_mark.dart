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
        duration: const Duration(milliseconds: 800),
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
    final gather = Curves.easeOutCubic.transform(_phase(0, .32));
    final fill = Curves.easeOutCubic.transform(_phase(.12, .48));
    final inner = Curves.easeOutCubic.transform(_phase(.32, .62));

    // The outer disc establishes the mark before the inset and check arrive.
    // A single gathering ring disappears into the disc, then the final rests.
    if (progress < .48) {
      canvas.drawCircle(
          center,
          67 - 10 * gather,
          Paint()
            ..color = _blue.withValues(alpha: .15 * (1 - fill))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
    canvas.drawCircle(center, 53 + 4 * fill,
        Paint()..color = _blue.withValues(alpha: .18 + .82 * fill));
    if (inner > 0) {
      canvas.drawCircle(center, 24 * inner,
          Paint()..color = Colors.white.withValues(alpha: inner));
    }

    final check = Path()
      ..moveTo(62, 74)
      ..lineTo(71, 83)
      ..lineTo(88, 66);
    final metric = check.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(
        0,
        metric.length * Curves.easeOutCubic.transform(_phase(.52, .88)),
      ),
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SuccessPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
