import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'davo_motion_policy.dart';
import 'davo_motion_spec.dart';
import '../widgets/davo_success_mark.dart';
import 'davo_working_indicator.dart';

/// A finite acknowledgement of an already accepted verification result.
/// It does not hold the Continue action or perform verification.
class DavoVerificationMark extends StatefulWidget {
  const DavoVerificationMark({super.key});
  @override
  State<DavoVerificationMark> createState() => _VerificationMarkState();
}

class _VerificationMarkState extends State<DavoVerificationMark>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion;
  bool _reduced = false;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = DavoMotionPolicy.reduce(context);
    if (_reduced) {
      _motion.value = 1;
    } else if (_foreground && !_motion.isAnimating && !_motion.isCompleted) {
      _motion.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && !_reduced && !_motion.isCompleted) {
      _motion.forward();
    } else {
      _motion.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Verification complete',
    image: true,
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: 148,
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, _) {
              final ms = _motion.value * 2600;
              if (ms < 1600) {
                return DavoWorkingArtwork(
                  kind: DavoWorkingKind.operation,
                  progress: ms / 800,
                  color: AppColors.primary,
                );
              }
              // Begin at the gathered seal, then draw the inset and check once.
              final progress =
                  240 / 1120 +
                  (1 - 240 / 1120) * ((ms - 1600) / 1000).clamp(0.0, 1.0);
              return DavoSuccessMark(
                kind: DavoOutcomeKind.completed,
                progress: progress,
              );
            },
          ),
        ),
      ),
    ),
  );
}
