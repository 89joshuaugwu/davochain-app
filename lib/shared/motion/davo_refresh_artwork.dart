import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'davo_outcome_artwork.dart';

/// The pull assembles the actual brand mark. Only the outer arc rotates.
class DavoRefreshArtwork extends StatelessWidget {
  const DavoRefreshArtwork(
      {super.key,
      required this.assembly,
      required this.orbit,
      required this.active,
      this.reducedMotion = false});
  final double assembly, orbit;
  final bool active, reducedMotion;

  @override
  Widget build(BuildContext context) {
    final gather = reducedMotion
        ? 1.0
        : Curves.easeOutCubic.transform(assembly.clamp(0.0, 1.0));
    final breathe = active && !reducedMotion
        ? 1 + .035 * (1 - math.cos(orbit * math.pi * 2)) / 2
        : 1.0;
    return RepaintBoundary(
        child: SizedBox.square(
            dimension: 48,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(
                  child: CustomPaint(
                      painter: DavoRefreshOrbitPainter(
                          orbit: reducedMotion ? 0 : orbit,
                          visibility: gather))),
              Transform.scale(
                  scale: breathe,
                  child: SizedBox(
                      width: 23,
                      height: 23 * 201 / 285,
                      child: DavoBrandAssembly(progress: gather))),
            ])));
  }
}

class DavoRefreshOrbitPainter extends CustomPainter {
  const DavoRefreshOrbitPainter(
      {required this.orbit, required this.visibility});
  final double orbit, visibility;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .35;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius,
        pen..color = AppColors.primary.withValues(alpha: .09 * visibility));
    final start = -math.pi / 2 + orbit * math.pi * 2;
    final sweep = math.pi * 1.22 * visibility;
    for (var segment = 0; segment < 40; segment++) {
      final strength = (segment + 1) / 40;
      canvas.drawArc(
          rect,
          start + sweep * segment / 40,
          sweep / 40,
          false,
          pen
            ..color = AppColors.primary
                .withValues(alpha: (.12 + .88 * strength) * visibility));
    }
    if (visibility > .01) {
      final end = start + sweep;
      canvas.drawCircle(center + Offset(math.cos(end), math.sin(end)) * radius,
          2, Paint()..color = AppColors.primary.withValues(alpha: visibility));
    }
  }

  @override
  bool shouldRepaint(DavoRefreshOrbitPainter old) =>
      old.orbit != orbit || old.visibility != visibility;
}
