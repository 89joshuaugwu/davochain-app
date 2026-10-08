import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AuthJourneyMethod { password, fingerprint }

/// A finite local sign-in transition. Credential validation remains the caller's
/// responsibility; this widget owns only motion and cancels it on disposal.
class DavoAuthJourney extends StatefulWidget {
  const DavoAuthJourney(
      {super.key,
      required this.child,
      required this.method,
      required this.onComplete});
  final Widget child;
  final AuthJourneyMethod? method;
  final VoidCallback onComplete;
  @override
  State<DavoAuthJourney> createState() => _DavoAuthJourneyState();
}

class _DavoAuthJourneyState extends State<DavoAuthJourney>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  bool _reduced = false;
  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            mounted &&
            widget.method != null) {
          widget.onComplete();
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(DavoAuthJourney oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.method != oldWidget.method) {
      if (widget.method == null) {
        _motion.reset();
      } else {
        _motion.duration = Duration(milliseconds: _reduced ? 400 : 1000);
        _motion.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        AbsorbPointer(absorbing: widget.method != null, child: widget.child),
        if (widget.method != null)
          Positioned.fill(
            child: AnimatedBuilder(
                animation: _motion,
                builder: (context, _) {
                  final progress = _motion.value;
                  final complete = progress >= .55;
                  final fingerprint =
                      widget.method == AuthJourneyMethod.fingerprint;
                  final fade =
                      _reduced ? 1.0 : ((1 - progress) / .16).clamp(0.0, 1.0);
                  return Semantics(
                      liveRegion: true,
                      label: complete
                          ? 'Signed in'
                          : fingerprint
                              ? 'Unlocking with fingerprint'
                              : 'Signing in',
                      child: ColoredBox(
                        color: Colors.white.withValues(alpha: .97),
                        child: Center(
                            child: Opacity(
                                opacity: fade,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                          width: 96,
                                          height: 96,
                                          child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                if (fingerprint && !complete)
                                                  Transform.scale(
                                                      scale: _reduced
                                                          ? 1
                                                          : 1 +
                                                              .08 *
                                                                  math.sin(
                                                                      progress *
                                                                          math
                                                                              .pi *
                                                                          4),
                                                      child: SizedBox(
                                                          width: 92,
                                                          height: 92,
                                                          child: CircularProgressIndicator(
                                                              key: const ValueKey(
                                                                  'fingerprint-auth-ring'),
                                                              value: _reduced
                                                                  ? .65
                                                                  : (progress /
                                                                          .55)
                                                                      .clamp(
                                                                          0.0,
                                                                          1.0),
                                                              strokeWidth: 2,
                                                              color: AppColors
                                                                  .primary,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primarySoft))),
                                                Container(
                                                    width: 72,
                                                    height: 72,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                AppColors
                                                                    .primarySoft,
                                                            shape: BoxShape
                                                                .circle),
                                                    child: Icon(
                                                        complete
                                                            ? Icons
                                                                .check_rounded
                                                            : fingerprint
                                                                ? Icons
                                                                    .fingerprint_rounded
                                                                : Icons
                                                                    .lock_outline_rounded,
                                                        key: ValueKey(complete
                                                            ? 'auth-completion-check'
                                                            : fingerprint
                                                                ? 'fingerprint-auth-icon'
                                                                : 'password-auth-icon'),
                                                        size: 38,
                                                        color:
                                                            AppColors.primary)),
                                              ])),
                                      const SizedBox(height: 20),
                                      Text(
                                          complete
                                              ? 'Welcome back'
                                              : fingerprint
                                                  ? 'Unlocking'
                                                  : 'Signing in',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink)),
                                      const SizedBox(height: 16),
                                      if (!fingerprint && !complete)
                                        Row(
                                            key: const ValueKey(
                                                'password-auth-dots'),
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(
                                                3,
                                                (i) => Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 4),
                                                    child: Opacity(
                                                        opacity: _reduced
                                                            ? 1
                                                            : .35 +
                                                                .65 *
                                                                    ((math.sin(progress * math.pi * 6 - i) +
                                                                            1) /
                                                                        2),
                                                        child: const SizedBox(
                                                            width: 6,
                                                            height: 6,
                                                            child: DecoratedBox(
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.primary,
                                                                    shape: BoxShape.circle))))))),
                                    ]))),
                      ));
                }),
          ),
      ]);
}
