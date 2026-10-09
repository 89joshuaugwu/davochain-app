import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

class BrandSplashScreen extends StatefulWidget {
  const BrandSplashScreen(
      {super.key, this.firstFrameReady, this.destinationBuilder});

  /// Supplied by the engine entry point so startup cannot consume the reveal.
  final Future<void>? firstFrameReady;

  /// Overrides the destination only for an explicitly opened returning preview.
  final WidgetBuilder? destinationBuilder;
  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _intro;
  Timer? _staticHold;
  bool? _reduceMotion;
  bool _ready = false;
  bool _navigating = false;
  bool _foreground = true;

  static const _systemStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.primary,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2900),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _reduceMotion == false) {
          _openOnboarding();
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Layout can happen while Android still covers Flutter. Wait until that
      // frame has actually reached the renderer before spending the animation.
      await widget.firstFrameReady;
      if (!mounted) return;
      _ready = true;
      _continueIntroduction();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduced) return;
    _reduceMotion = reduced;
    _staticHold?.cancel();
    if (reduced) {
      _intro.stop();
      _intro.value = 1;
    }
    if (_ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _continueIntroduction();
      });
    }
  }

  void _continueIntroduction() {
    if (!_foreground || _navigating) return;
    if (_reduceMotion == true) {
      _staticHold?.cancel();
      _staticHold = Timer(const Duration(milliseconds: 700), _openOnboarding);
    } else {
      _intro.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _ready) {
      _continueIntroduction();
    } else {
      _intro.stop();
      _staticHold?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _staticHold?.cancel();
    _intro.dispose();
    super.dispose();
  }

  void _openOnboarding() {
    if (!mounted || !_foreground || _navigating) return;
    _navigating = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      settings: RouteSettings(
          name: widget.destinationBuilder == null
              ? '/onboarding'
              : '/returning-preview'),
      transitionDuration:
          Duration(milliseconds: _reduceMotion == true ? 0 : 320),
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (routeContext, animation, secondaryAnimation) =>
          widget.destinationBuilder?.call(routeContext) ??
          const OnboardingScreen(),
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          _reduceMotion == true
              ? child
              : FadeTransition(
                  opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
                  child: child,
                ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    const lockupScale = .94;
    final labelWidth = math.min(size.width - 118, 268.0) * lockupScale;
    final markAndGap = 70 * lockupScale;
    final lockupWidth = labelWidth + markAndGap;
    final finalLeft = (size.width - lockupWidth) / 2;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemStyle,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Semantics(
            label: 'Davochain',
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                  animation: _intro,
                  builder: (context, child) {
                    double phase(double start, double end,
                            [Curve curve = Curves.easeOutCubic]) =>
                        reduced
                            ? 1
                            : curve.transform(
                                ((_intro.value - start) / (end - start))
                                    .clamp(0.0, 1.0));
                    final upper = phase(.04, .25, Curves.easeOutBack);
                    final lower = phase(.10, .30, Curves.easeOutBack);
                    final move = phase(.29, .55);
                    final name = phase(.35, .63);
                    final currencies = phase(.48, .79);
                    final markWidth = 90 - (90 - 58 * lockupScale) * move;
                    const lockupLift = 24.0;
                    final centerY =
                        size.height * (.50 + .055 * move) - lockupLift;
                    final markLeft = (size.width - markWidth) / 2 * (1 - move) +
                        finalLeft * move;
                    return Stack(clipBehavior: Clip.hardEdge, children: [
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Transform.translate(
                              offset: Offset(0, (1 - currencies) * 130),
                              child: Opacity(
                                  opacity: currencies,
                                  child: const RepaintBoundary(
                                      child: ClipRect(
                                          key: ValueKey(
                                              'welcome-currencies'),
                                          child: _CurrencyFooter()))))),
                      Positioned(
                          left: finalLeft + markAndGap,
                          top: size.height * .555 - 30 - lockupLift,
                          width: labelWidth,
                          height: 60,
                          child: Opacity(
                              opacity: name,
                              child: ClipRect(
                                  clipper: _NameReveal(name),
                                  child: const FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: Text('Davochain',
                                          style: TextStyle(
                                              fontFamily: 'Sora',
                                              fontSize: 40 * lockupScale,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1,
                                              letterSpacing: .4)))))),
                      Positioned(
                          left: markLeft,
                          top: centerY - markWidth * 201 / 285 / 2,
                          width: markWidth,
                          height: markWidth * 201 / 285,
                          child: _AssemblingMark(upper: upper, lower: lower)),
                    ]);
                  }),
            )),
      ),
    );
  }
}

/// Original Figma vectors, with the source frame's bottom crop preserved.
class _CurrencyFooter extends StatelessWidget {
  const _CurrencyFooter();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 390;
          Widget currency(String name, double left, double top, double width,
                  double height) =>
              Positioned(
                left: left * scale,
                top: top * scale,
                width: width * scale,
                height: height * scale,
                child: SvgPicture.asset('assets/images/brand/splash_$name.svg'),
              );
          return SizedBox(
            height: 133 * scale,
            child: Stack(clipBehavior: Clip.hardEdge, children: [
              currency('dollar', -6, 0, 117.181, 197),
              currency('naira', 111, 2, 173.042, 198),
              currency('bitcoin', 288, 2, 123.509, 176),
            ]),
          );
        },
      );
}

/// Clips the supplied transparent logo into its three original parts. The brand
/// asset is preserved; no approximate replacement paths are drawn.
class _AssemblingMark extends StatelessWidget {
  const _AssemblingMark({required this.upper, required this.lower});
  final double upper, lower;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final scale = constraints.maxWidth / 285;
        Widget part(String name, Rect region, double progress, Offset origin) =>
            Transform.translate(
                key: ValueKey('welcome-$name'),
                offset: origin * (1 - progress),
                child: Opacity(
                    opacity: progress.clamp(0.0, 1.0),
                    child: ClipRect(
                        clipper: _LogoPartClipper(region),
                        child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minWidth: 391 * scale,
                            maxWidth: 391 * scale,
                            minHeight: 329 * scale,
                            maxHeight: 329 * scale,
                            child: Transform.translate(
                                offset: Offset(-43 * scale, -69 * scale),
                                child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                    child: Image.asset(
                                        'assets/images/brand/davochain_logo.png',
                                        fit: BoxFit.fill)))))));
        return Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
              child: part(
                  'dot', const Rect.fromLTRB(0, .58, .29, 1), 1, Offset.zero)),
          Positioned.fill(
              child: part('upper', const Rect.fromLTRB(0, 0, 1, .46), upper,
                  const Offset(42, -24))),
          Positioned.fill(
              child: part('lower', const Rect.fromLTRB(.30, .54, 1, 1), lower,
                  const Offset(-38, 26))),
        ]);
      });
}

class _LogoPartClipper extends CustomClipper<Rect> {
  const _LogoPartClipper(this.region);
  final Rect region;
  @override
  Rect getClip(Size size) => Rect.fromLTRB(
      region.left * size.width,
      region.top * size.height,
      region.right * size.width,
      region.bottom * size.height);
  @override
  bool shouldReclip(_LogoPartClipper oldClipper) => oldClipper.region != region;
}

class _NameReveal extends CustomClipper<Rect> {
  const _NameReveal(this.progress);
  final double progress;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * progress, size.height);
  @override
  bool shouldReclip(_NameReveal oldClipper) => oldClipper.progress != progress;
}
