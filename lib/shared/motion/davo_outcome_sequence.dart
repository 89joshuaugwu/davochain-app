import 'package:flutter/material.dart';
import 'davo_motion_policy.dart';
import 'davo_motion_spec.dart';

class DavoOutcomeSequence extends StatefulWidget {
  const DavoOutcomeSequence(
      {super.key,
      this.eventKey,
      this.play = true,
      required this.kind,
      this.tempo = DavoOutcomeTempo.regular,
      this.builder,
      this.sceneBuilder})
      : assert(builder != null || sceneBuilder != null);
  final Object? eventKey;
  final bool play;
  final DavoOutcomeKind kind;
  final DavoOutcomeTempo tempo;
  final Widget Function(BuildContext, double)? builder;
  final Widget Function(BuildContext, Animation<double>)? sceneBuilder;
  @override
  State<DavoOutcomeSequence> createState() => _SequenceState();
}

class _SequenceState extends State<DavoOutcomeSequence>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController controller;
  bool started = false, reduced = false, foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    controller = AnimationController(
        vsync: this,
        duration: DavoMotionSpec.outcomeDuration(widget.kind, widget.tempo));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = DavoMotionPolicy.reduce(context);
    if (reduced || !widget.play) {
      started = true;
      controller.value = 1;
    } else if (!started) {
      started = true;
      if (foreground) controller.forward();
    }
  }

  @override
  void didUpdateWidget(DavoOutcomeSequence oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.duration =
        DavoMotionSpec.outcomeDuration(widget.kind, widget.tempo);
    if (oldWidget.eventKey != widget.eventKey) {
      controller.value = reduced || !widget.play ? 1 : 0;
      if (!reduced && widget.play && foreground) controller.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (!foreground) {
      controller.stop();
    } else if (!reduced && widget.play && controller.value < 1) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sceneBuilder != null) {
      return widget.sceneBuilder!(context, controller);
    }
    if (reduced || controller.value == 1) return widget.builder!(context, 1);
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) =>
            widget.builder!(context, controller.value));
  }
}
