import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'davo_motion_policy.dart';
import 'davo_motion_spec.dart';
import 'davo_outcome_artwork.dart';

/// Active work rotates independently of its Future. Review attention runs twice.
class DavoWorkingIndicator extends StatefulWidget {
  const DavoWorkingIndicator(
      {super.key,
      this.size = 150,
      this.active = true,
      this.color = AppColors.primary,
      this.kind = DavoWorkingKind.operation});
  final double size;
  final Color color;
  final bool active;
  final DavoWorkingKind kind;
  @override
  State<DavoWorkingIndicator> createState() => _WorkingState();
}

class _WorkingState extends State<DavoWorkingIndicator>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController controller;
  bool reduced = false, foreground = true, started = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    foreground = WidgetsBinding.instance.lifecycleState == null || WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    controller = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds:
                widget.kind == DavoWorkingKind.operation ? 1200 : 3600));
  }

  void sync() {
    if (reduced || !foreground || !widget.active) {
      controller.stop();
      return;
    }
    if (widget.kind == DavoWorkingKind.operation) {
      if (!controller.isAnimating) controller.repeat();
    } else if (!started) {
      started = true;
      controller.forward();
    } else if (controller.value < 1 && !controller.isAnimating) {
      controller.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = DavoMotionPolicy.reduce(context);
    sync();
  }

  @override
  void didUpdateWidget(DavoWorkingIndicator old) {
    super.didUpdateWidget(old);
    sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
      label: widget.kind == DavoWorkingKind.operation
          ? 'Processing'
          : 'Pending review',
      image: true,
      child: RepaintBoundary(
          child: SizedBox.square(
              dimension: widget.size,
              child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => DavoWorkingArtwork(
                      kind: widget.kind,
                      progress: reduced ? 0 : controller.value,
                      color: widget.color)))));
}

class DavoWorkingArtwork extends StatelessWidget {
  const DavoWorkingArtwork(
      {super.key,
      required this.kind,
      required this.progress,
      this.color = AppColors.primary});
  final DavoWorkingKind kind;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        if (kind == DavoWorkingKind.operation)
          ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: const DavoOutcomeArtwork(
                  kind: DavoOutcomeKind.completed,
                  progress: 240 / 1120,
                  size: 112)),
        CustomPaint(painter: DavoWorkingPainter(kind, progress, color)),
      ]);
}

class DavoWorkingPainter extends CustomPainter {
  const DavoWorkingPainter(this.kind, this.progress, this.color);
  final Color color;
  final DavoWorkingKind kind;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 112, size.height / 112);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    if (kind == DavoWorkingKind.operation) {
      pen.color = color.withValues(alpha: .7);
      canvas.drawArc(const Rect.fromLTWH(22, 22, 68, 68),
          progress * math.pi * 2, math.pi * .4, false, pen);
    } else {
      canvas.drawCircle(const Offset(56, 56), 34, pen);
      canvas.drawPath(
          Path()
            ..moveTo(56, 38)
            ..lineTo(56, 56)
            ..lineTo(68, 64),
          pen);
      canvas.drawCircle(
          const Offset(84, 32),
          4,
          Paint()
            ..color = color.withValues(
                alpha: progress >= 1
                    ? .45
                    : .45 + .55 * (1 - math.cos(progress * math.pi * 4)) / 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DavoWorkingPainter old) =>
      old.progress != progress || old.kind != kind;
}
