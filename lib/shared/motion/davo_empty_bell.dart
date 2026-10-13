import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'davo_motion_policy.dart';

/// Two quiet floating gestures, separated by a rest, then settles into place.
class DavoEmptyBell extends StatefulWidget {
  const DavoEmptyBell({super.key, required this.asset});
  final String asset;
  @override
  State<DavoEmptyBell> createState() => _DavoEmptyBellState();
}

class _DavoEmptyBellState extends State<DavoEmptyBell>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4400));
  bool foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  void sync() {
    if (DavoMotionPolicy.reduce(context)) {
      controller.stop();
      controller.value = 1;
    } else if (foreground && controller.value < 1) {
      controller.forward();
    } else {
      controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
  Widget build(BuildContext context) => ExcludeSemantics(
      child: RepaintBoundary(
          child: AnimatedBuilder(
              animation: controller,
              child: Image.asset(widget.asset,
                  width: 230, height: 150, fit: BoxFit.contain),
              builder: (context, child) {
                final t = controller.value;
                final p = t < .34
                    ? t / .34
                    : t >= .56 && t < .90
                        ? (t - .56) / .34
                        : 0.0;
                final lift = math.pow(math.sin(p * math.pi), 2).toDouble();
                return Transform.translate(
                    offset: Offset(0, -5 * lift),
                    child: Transform.rotate(
                        angle: .045 * math.sin(p * math.pi * 2) * lift,
                        alignment: const Alignment(0, -.3),
                        child: child));
              })));
}
