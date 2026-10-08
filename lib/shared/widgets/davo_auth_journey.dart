import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../motion/davo_auth_artwork.dart';
import '../motion/davo_motion_policy.dart';
import '../motion/davo_working_indicator.dart';
import '../motion/davo_motion_spec.dart';
export '../motion/davo_motion_spec.dart' show AuthJourneyState;

enum AuthJourneyMethod { password, fingerprint }

/// Only accepted caller state starts a success scene. Dispose/cancel invalidates it.
class DavoAuthJourney extends StatefulWidget {
  const DavoAuthJourney(
      {super.key,
      required this.child,
      required this.method,
      required this.onComplete,
      this.state = AuthJourneyState.accepted,
      this.onBlue = false});
  final Widget child;
  final AuthJourneyMethod? method;
  final VoidCallback onComplete;
  final AuthJourneyState state;
  final bool onBlue;
  @override
  State<DavoAuthJourney> createState() => _DavoAuthJourneyState();
}

class _DavoAuthJourneyState extends State<DavoAuthJourney>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion;
  bool _reduced = false, _delivered = false;
  bool _foreground = true;
  bool get _accepted =>
      widget.method != null && widget.state == AuthJourneyState.accepted;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _motion = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() {
        final threshold = _reduced
            ? 1.0
            : widget.method == AuthJourneyMethod.fingerprint
                ? 800 / 960
                : .84;
        if (_motion.value >= threshold &&
            ModalRoute.of(context)?.isCurrent == false) {
          _motion.stop();
          _delivered = true;
          return;
        }
        if (_motion.value >= threshold &&
            mounted &&
            _foreground &&
            _accepted &&
            !_delivered) {
          _delivered = true;
          widget.onComplete();
        }
      });
  }

  void _start() {
    _delivered = false;
    _motion.duration = Duration(
        milliseconds: _reduced
            ? 150
            : widget.method == AuthJourneyMethod.fingerprint
                ? 960
                : 1000);
    _motion.value = 0;
    if (_foreground) _motion.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = DavoMotionPolicy.reduce(context);
    final changed = reduced != _reduced;
    _reduced = reduced;
    if (_accepted &&
        !_delivered &&
        (!_motion.isAnimating && _motion.value == 0 || changed && reduced)) {
      _start();
    }
  }

  @override
  void didUpdateWidget(DavoAuthJourney old) {
    super.didUpdateWidget(old);
    if (widget.method != old.method || widget.state != old.state) {
      _motion.reset();
      _delivered = false;
      if (_accepted) _start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed && _accepted && !_delivered) {
      _motion.forward();
    } else if (state != AppLifecycleState.resumed) {
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
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        AbsorbPointer(
            absorbing: _accepted ||
                widget.method != null &&
                    widget.state == AuthJourneyState.working,
            child: widget.child),
        if (widget.method != null &&
            (widget.state == AuthJourneyState.working || _accepted))
          Positioned.fill(
              child: AnimatedBuilder(
                  animation: _motion,
                  builder: (context, child) => DavoAuthScene(
                      fingerprint:
                          widget.method == AuthJourneyMethod.fingerprint,
                      onBlue: widget.onBlue,
                      working: widget.state == AuthJourneyState.working,
                      progress: _reduced ? 1 : _motion.value,
                      reduced: _reduced))),
      ]);
}

/// Pure scene composition shared by the production overlay and storyboard gallery.
class DavoAuthScene extends StatelessWidget {
  const DavoAuthScene(
      {super.key,
      required this.fingerprint,
      required this.progress,
      this.onBlue = false,
      this.working = false,
      this.reduced = false});
  final bool fingerprint, onBlue, working, reduced;
  final double progress;
  double _labelHeight(BuildContext context, double width, TextStyle style) {
    var height = 60.0;
    for (final label in [
      fingerprint ? 'Unlocking' : 'Signing in',
      'Welcome back'
    ]) {
      final painter = TextPainter(
          text: TextSpan(text: label, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context))
        ..layout(maxWidth: width);
      if (painter.height > height) height = painter.height;
      painter.dispose();
    }
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final ms = progress * (fingerprint ? 960 : 1000);
    final mix = working
        ? 0.0
        : reduced
            ? 1.0
            : DavoMotionSpec.phase(
                ms, fingerprint ? 620 : 580, fingerprint ? 760 : 720);
    final foreground = onBlue ? Colors.white : DavoColors.of(context).link;
    final style = TextStyle(
        fontFamily: 'Sora',
        decoration: TextDecoration.none,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onBlue ? Colors.white : DavoColors.of(context).ink);
    return Material(
        color: onBlue ? AppColors.primary : DavoColors.of(context).surface,
        child: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Semantics(
                        liveRegion: true,
                        label: working
                            ? 'Authenticating'
                            : mix == 1
                                ? 'Signed in'
                                : fingerprint
                                    ? 'Unlocking with fingerprint'
                                    : 'Signing in',
                        child: Opacity(
                            opacity: working || reduced
                                ? 1
                                : DavoMotionSpec.phase(
                                    ms, 0, fingerprint ? 120 : 140),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (working)
                                    DavoWorkingIndicator(
                                        size: 112, color: foreground)
                                  else
                                    DavoAuthArtwork(
                                        key: ValueKey(
                                            ms >= (fingerprint ? 500 : 520)
                                                ? 'auth-completion-check'
                                                : fingerprint
                                                    ? 'fingerprint-auth-ridges'
                                                    : 'password-auth-dots'),
                                        fingerprint: fingerprint,
                                        progress: progress,
                                        color: foreground),
                                  const SizedBox(height: 20),
                                  LayoutBuilder(
                                      builder: (context, constraints) =>
                                          SizedBox(
                                              height: _labelHeight(context,
                                                  constraints.maxWidth, style),
                                              child: Center(
                                                  child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                    if (mix < 1)
                                                      Opacity(
                                                          opacity: 1 - mix,
                                                          child: Text(
                                                              fingerprint
                                                                  ? 'Unlocking'
                                                                  : 'Signing in',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: style)),
                                                    if (mix > 0)
                                                      Opacity(
                                                          opacity: mix,
                                                          child: Text(
                                                              'Welcome back',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: style)),
                                                  ])))),
                                ])))))));
  }
}
