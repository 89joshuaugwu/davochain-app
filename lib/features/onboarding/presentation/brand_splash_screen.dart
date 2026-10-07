import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

class BrandSplashScreen extends StatefulWidget {
  const BrandSplashScreen({super.key});

  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  Timer? _timer;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    _timer?.cancel();
    // Start the welcome sequence after the first layout, not during startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _reduceMotion != reduceMotion) return;
      if (reduceMotion) {
        _intro.stop();
        _intro.value = 1;
      } else {
        _intro.forward();
      }
      _timer = Timer(
          Duration(milliseconds: reduceMotion ? 1200 : 3200), _openOnboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  void _openOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: '/onboarding'),
        transitionDuration:
            Duration(milliseconds: _reduceMotion == true ? 0 : 450),
        reverseTransitionDuration:
            Duration(milliseconds: _reduceMotion == true ? 0 : 220),
        pageBuilder: (_, animation, __) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          if (_reduceMotion == true) return child;
          final curved = animation.drive(CurveTween(
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.015, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final size = MediaQuery.sizeOf(context);
    double phase(double start, double end) => reduceMotion
        ? 1
        : Curves.easeOutCubic.transform(
            ((_intro.value - start) / (end - start)).clamp(0.0, 1.0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: AnimatedBuilder(
          animation: _intro,
          builder: (context, child) {
            final oval = phase(0, .45);
            final brand = phase(.12, .65);
            final currencies = phase(.32, 1);
            final centerY = size.height * .555;
            return Stack(clipBehavior: Clip.hardEdge, children: [
              Positioned(
                left: size.width * .045,
                right: size.width * .045,
                top: centerY - size.height * .039,
                height: size.height * .078,
                child: Transform.scale(
                  scaleX: .35 + .65 * oval,
                  scaleY: .7 + .3 * oval,
                  child: Opacity(
                      opacity: .25 + .75 * oval,
                      child: const ClipOval(
                        key: ValueKey('welcome-oval'),
                        child: ColoredBox(color: Color(0xFF0750E8)),
                      )),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, (1 - currencies) * 95),
                  child: Opacity(
                      opacity: currencies,
                      child: ClipRect(
                        key: const ValueKey('welcome-currencies'),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: .24,
                          child: SizedBox(
                              width: size.width,
                              height: size.height,
                              child: Image.asset(
                                'assets/images/figma/splash_background.png',
                                fit: BoxFit.fill,
                                excludeFromSemantics: true,
                              )),
                        ),
                      )),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: centerY - 30,
                height: 60,
                child: Opacity(
                    opacity: .15 + .85 * brand,
                    child: Transform.translate(
                      offset: Offset(0, (1 - brand) * 20),
                      child: Transform.scale(
                          scale: .92 + .08 * brand,
                          child: Center(
                            child: _WhiteDavochainLockup(
                                maxWidth: math.min(size.width - 48, 350)),
                          )),
                    )),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _WhiteDavochainLockup extends StatelessWidget {
  const _WhiteDavochainLockup({required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: Image.asset(
              'assets/images/brand/davochain_logo.png',
              width: 61,
              height: 42,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Davochain',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: .4,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
