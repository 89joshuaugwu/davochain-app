import 'package:flutter/material.dart';
import 'davo_motion_policy.dart';
import 'davo_motion_spec.dart';

/// Sequential outgoing/incoming content with one focusable form at a time.
class DavoStepTransition extends StatefulWidget {
  const DavoStepTransition(
      {super.key, required this.child, this.backwards = false});
  final Widget child;
  final bool backwards;
  @override
  State<DavoStepTransition> createState() => _StepState();
}

class _StepState extends State<DavoStepTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  Widget? outgoing;
  bool reduced = false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280), value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = DavoMotionPolicy.reduce(context);
    if (reduced) {
      outgoing = null;
      controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(DavoStepTransition old) {
    super.didUpdateWidget(old);
    if (old.child.key != widget.child.key) {
      outgoing = reduced ? null : old.child;
      controller.forward(from: reduced ? 1 : 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final ms = controller.value * 280;
        final leaving = outgoing != null && ms < 100;
        final opacity = leaving
            ? 1 - DavoMotionSpec.phase(ms, 0, 100)
            : DavoMotionSpec.phase(ms, 100, 280, DavoMotionSpec.settle);
        final y = (leaving ? -4 * (1 - opacity) : 8 * (1 - opacity)) *
            (widget.backwards ? -1 : 1);
        final child = Opacity(
            opacity: opacity,
            child: Transform.translate(
                offset: Offset(0, y),
                child: leaving ? outgoing! : widget.child));
        return leaving
            ? ExcludeFocus(
                child: ExcludeSemantics(child: IgnorePointer(child: child)))
            : child;
      });
}
