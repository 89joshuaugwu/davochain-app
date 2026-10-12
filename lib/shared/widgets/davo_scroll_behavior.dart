import '../motion/davo_motion_policy.dart';
import 'davo_toast.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DavoScrollBehavior extends MaterialScrollBehavior {
  const DavoScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      axisDirectionToAxis(details.direction) == Axis.vertical
          ? DavoEdgeResponse(child: child)
          : child;
}

/// A tiny expansion stays inside a clipped, clamped viewport: no blank gap.
class DavoEdgeResponse extends StatefulWidget {
  const DavoEdgeResponse({super.key, required this.child});
  final Widget child;
  @override
  State<DavoEdgeResponse> createState() => _EdgeResponseState();
}

class _EdgeResponseState extends State<DavoEdgeResponse>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));
  bool top = true;
  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NotificationListener<
          ScrollNotification>(
      onNotification: (notification) {
        if (DavoMotionPolicy.reduce(context) || notification.depth != 0) {
          return false;
        }
        if (notification is OverscrollNotification &&
            notification.dragDetails != null &&
            notification.metrics.axis == Axis.vertical) {
          top = notification.overscroll < 0;
          motion.stop();
          motion.value =
              (motion.value + notification.overscroll.abs() / 300).clamp(0, 1);
        } else if (notification is ScrollEndNotification) {
          unawaited(motion.animateTo(0, curve: Curves.easeOutCubic));
        }
        return false;
      },
      child: AnimatedBuilder(
          animation: motion,
          child: widget.child,
          builder: (context, child) => ClipRect(
              child: Transform.scale(
                  scaleY: 1 + motion.value * .008,
                  alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
                  child: child))));
}

class DavoFloatingRefresh extends StatefulWidget {
  const DavoFloatingRefresh(
      {super.key, required this.child, required this.onRefresh});
  final Widget child;
  final Future<void> Function() onRefresh;
  @override
  State<DavoFloatingRefresh> createState() => _FloatingRefreshState();
}

class _FloatingRefreshState extends State<DavoFloatingRefresh>
    with TickerProviderStateMixin {
  late final spinner = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final edge = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));
  bool edgeTop = true;
  double pull = 0;
  bool busy = false;
  @override
  void dispose() {
    spinner.dispose();
    edge.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (busy) return;
    spinner.value = (pull / 100) % 1;
    setState(() {
      busy = true;
      pull = 0;
    });
    if (!DavoMotionPolicy.reduce(context)) spinner.repeat();
    try {
      await widget.onRefresh();
    } catch (_) {
      if (mounted) showDavoToast(context, 'Could not refresh. Try again.');
    } finally {
      if (mounted) {
        spinner.stop();
        setState(() => busy = false);
      }
    }
  }

  void _drag(double delta) {
    if (!busy) {
      _edge(delta);
      setState(() => pull = (pull + delta).clamp(0, 100));
    }
  }

  void _edge(double delta) {
    if (DavoMotionPolicy.reduce(context) || busy) return;
    edgeTop = delta > 0;
    edge.stop();
    edge.value = (edge.value + delta.abs() / 300).clamp(0, 1);
  }

  void _release() {
    unawaited(edge.animateTo(0, curve: Curves.easeOutCubic));
    if (pull >= 60 && !busy) {
      unawaited(_refresh());
    } else if (mounted && !busy) {
      setState(() => pull = 0);
    }
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth == 0 &&
                notification is OverscrollNotification &&
                notification.dragDetails != null) {
              if (notification.overscroll < 0) {
                _drag(-notification.overscroll);
              } else {
                _edge(-notification.overscroll);
              }
            }
            if (notification is ScrollEndNotification &&
                notification.depth == 0) {
              _release();
            }
            return false;
          },
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) => _drag(details.delta.dy),
              onVerticalDragEnd: (_) => _release(),
              onVerticalDragCancel: () {
                unawaited(edge.animateTo(0, curve: Curves.easeOutCubic));
                if (!busy) setState(() => pull = 0);
              },
              child: Stack(clipBehavior: Clip.hardEdge, children: [
                AnimatedBuilder(
                    animation: edge,
                    child: widget.child,
                    builder: (context, child) => ClipRect(
                        child: Transform.scale(
                            scaleY: 1 + edge.value * .008,
                            alignment: edgeTop
                                ? Alignment.topCenter
                                : Alignment.bottomCenter,
                            child: child))),
                if (busy || pull > 8)
                  AnimatedPositioned(
                      duration: DavoMotionPolicy.reduce(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      top: MediaQuery.paddingOf(context).top +
                          8 +
                          (busy ? 0 : pull / 10),
                      left: 0,
                      right: 0,
                      child: Center(
                          child: Semantics(
                              container: true,
                              label: busy
                                  ? 'Refreshing dashboard'
                                  : pull >= 60
                                      ? 'Release to refresh dashboard'
                                      : 'Pull to refresh dashboard',
                              liveRegion: busy,
                              child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      color: DavoColors.of(context).surface,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0x22000000),
                                            offset: Offset(0, 2),
                                            blurRadius: 8)
                                      ]),
                                  child: AnimatedBuilder(
                                      animation: spinner,
                                      builder: (context, child) =>
                                          Transform.rotate(
                                              angle:
                                                  (busy
                                                          ? spinner.value
                                                          : pull / 100) *
                                                      6.283185,
                                              child: const Icon(
                                                  Icons.refresh_rounded,
                                                  color: AppColors.primary,
                                                  size: 28)))))))
              ])));
}
