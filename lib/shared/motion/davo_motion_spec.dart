import 'package:flutter/material.dart';

enum DavoOutcomeKind { completed, submitted }

enum DavoOutcomeTempo { regular, compact }

enum DavoWorkingKind { operation, reviewPending }

enum AuthJourneyState { idle, working, accepted, failed }

abstract final class DavoMotionSpec {
  static const settle = Cubic(.22, 1, .36, 1);
  static const standard = Cubic(.4, 0, .2, 1);
  static const exit = Cubic(.4, 0, 1, 1);
  static double rejectionOffset(double progress) {
    const times = [0.0, 40.0, 80.0, 120.0, 160.0, 220.0];
    const offsets = [0.0, -4.0, 4.0, -3.0, 3.0, 0.0];
    final ms = progress.clamp(0.0, 1.0) * 220;
    for (var i = 1; i < times.length; i++) {
      if (ms <= times[i]) {
        return offsets[i - 1] +
            (offsets[i] - offsets[i - 1]) * phase(ms, times[i - 1], times[i]);
      }
    }
    return 0;
  }

  static Duration outcomeDuration(
          DavoOutcomeKind kind, DavoOutcomeTempo tempo) =>
      Duration(
          milliseconds: kind == DavoOutcomeKind.submitted
              ? 900
              : tempo == DavoOutcomeTempo.compact
                  ? 680
                  : 1120);
  static double phase(double elapsedMs, double startMs, double endMs,
          [Curve curve = Curves.linear]) =>
      curve.transform(
          ((elapsedMs - startMs) / (endMs - startMs)).clamp(0.0, 1.0));
}

class DavoOutcomeFrame {
  DavoOutcomeFrame(this.kind, double progress)
      : ms = progress.clamp(0.0, 1.0) *
            (kind == DavoOutcomeKind.completed ? 1120 : 900);
  final DavoOutcomeKind kind;
  final double ms;
  bool get completed => kind == DavoOutcomeKind.completed;
  double p(double a, double b, [Curve curve = DavoMotionSpec.settle]) =>
      DavoMotionSpec.phase(ms, a, b, curve);
  double get discOpacity => completed ? p(240, 360) : p(200, 420);
  double get discRadius => 20 + 37 * (completed ? p(240, 560) : p(200, 420));
  double get insetRadius => 24 * (completed ? p(420, 660) : p(380, 600));
  double get check => completed ? p(640, 880, Curves.linear) : 0;
  double get clock => completed ? 0 : p(520, 640);
  double get hands => completed ? 0 : p(560, 760, Curves.linear);
  double get heading => completed ? p(580, 800) : p(460, 680);
  double get details => completed ? p(720, 940) : p(600, 800);
}
