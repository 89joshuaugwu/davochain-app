import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../shared/motion/davo_outcome_artwork.dart';
import '../../../shared/widgets/auth_widgets.dart';

/// A single, finite finale for first account setup. It never authorizes an
/// account or navigates from a timer; its caller owns the accepted setup state.
class AccountWelcomeScreen extends StatefulWidget {
  const AccountWelcomeScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  State<AccountWelcomeScreen> createState() => _AccountWelcomeScreenState();
}

class _AccountWelcomeScreenState extends State<AccountWelcomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _scene;
  bool _exploring = false;
  bool _reduced = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _scene = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = DavoMotionPolicy.reduce(context);
    if (_reduced) {
      _scene.value = 1;
    } else if (_foreground && !_scene.isAnimating && !_scene.isCompleted) {
      _scene.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      if (!_reduced && !_scene.isCompleted) _scene.forward();
    } else {
      _scene.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scene.dispose();
    super.dispose();
  }

  void _explore() {
    if (_exploring) return;
    _exploring = true;
    widget.onExplore();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
              child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text('Davochain',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.ink))),
            Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight:
                                    math.max(0, constraints.maxHeight - 48)),
                            child: Center(
                                child: AnimatedBuilder(
                                    animation: _scene,
                                    builder: (context, _) {
                                      final ms = _scene.value * 2400;
                                      double phase(double start, double end) =>
                                          DavoMotionSpec.phase(ms, start, end,
                                              DavoMotionSpec.settle);
                                      // Let the supplied brand pieces gather for 720 ms, then
                                      // resolve through the exact established completion artwork.
                                      final mark = ms < 720
                                          ? ms / 720 * (240 / 1120)
                                          : 240 / 1120 +
                                              (1 - 240 / 1120) *
                                                  phase(720, 1700);
                                      Widget reveal(Widget child, double start,
                                              double end) =>
                                          Opacity(
                                              opacity: phase(start, end),
                                              child: Transform.translate(
                                                  offset: Offset(
                                                      0,
                                                      12 *
                                                          (1 -
                                                              phase(
                                                                  start, end))),
                                                  child: child));
                                      return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Semantics(
                                                label: 'Account setup complete',
                                                image: true,
                                                child: ExcludeSemantics(
                                                    child: SizedBox.square(
                                                        dimension: 240,
                                                        child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Positioned.fill(
                                                                  child: CustomPaint(
                                                                      painter: _WelcomeRipple(
                                                                          _scene
                                                                              .value,
                                                                          colors
                                                                              .primarySoft))),
                                                              DavoOutcomeArtwork(
                                                                  kind: DavoOutcomeKind
                                                                      .completed,
                                                                  progress: mark
                                                                      .clamp(
                                                                          0, 1),
                                                                  size: 180),
                                                            ])))),
                                            const SizedBox(height: 16),
                                            reveal(
                                                Text('Welcome to Davochain',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 28,
                                                        height: 1.25,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: colors.ink)),
                                                1150,
                                                1750),
                                            const SizedBox(height: 14),
                                            reveal(
                                                Text(
                                                    'Your next chapter starts here.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 14,
                                                        height: 1.5,
                                                        color: colors.body)),
                                                1400,
                                                1950),
                                            const SizedBox(height: 24),
                                            reveal(
                                                Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            colors.primarySoft,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24)),
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .lock_outline_rounded,
                                                              size: 16,
                                                              color:
                                                                  colors.link),
                                                          const SizedBox(
                                                              width: 8),
                                                          Flexible(
                                                              child: Text(
                                                                  'Transaction PIN created',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Sora',
                                                                      fontSize:
                                                                          12,
                                                                      color: colors
                                                                          .link))),
                                                        ])),
                                                1650,
                                                2200),
                                          ]);
                                    })))))),
            Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: DavoPrimaryButton(
                    label: 'Explore Davochain', onPressed: _explore)),
          ])),
        ));
  }
}

/// Two quiet expansion waves carry the seal's reveal, then disappear entirely.
/// No blur, looping particles, shadows, or transformed text rasterization.
class _WelcomeRipple extends CustomPainter {
  const _WelcomeRipple(this.progress, this.color);
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    for (final delay in [0.0, .12]) {
      final p = ((progress - .26 - delay) / .55).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      canvas.drawCircle(
          size.center(Offset.zero),
          54 + 64 * DavoMotionSpec.settle.transform(p),
          Paint()
            ..color = color.withValues(alpha: math.sin(p * math.pi) * .9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_WelcomeRipple oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
