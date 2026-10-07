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
      duration: const Duration(milliseconds: 780),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    _timer?.cancel();
    if (reduceMotion) {
      _intro.stop();
      _intro.value = 1;
    } else {
      _intro.forward();
    }
    _timer = Timer(
      Duration(milliseconds: reduceMotion ? 250 : 1200),
      _openOnboarding,
    );
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
            Duration(milliseconds: _reduceMotion == true ? 0 : 280),
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
    final intro = _intro.drive(CurveTween(curve: Curves.easeOutCubic));
    final logoCurve = _intro.drive(
        CurveTween(curve: const Interval(.12, 1, curve: Curves.easeOutCubic)));

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Exact Figma composition: cobalt field, wide oval behind the lockup,
          // and oversized outlined crypto artwork bleeding off the bottom edge.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _intro,
              builder: (context, child) {
                if (reduceMotion) return child!;
                return Transform.scale(
                  scale: 1.035 - (intro.value * .035),
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - intro.value)),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/figma/splash_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -.006),
            child: AnimatedBuilder(
              animation: _intro,
              builder: (context, child) {
                return Opacity(
                  opacity: intro.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset:
                        Offset(0, reduceMotion ? 0 : 10 * (1 - intro.value)),
                    child: Transform.scale(
                      scale: reduceMotion ? 1 : .96 + (.04 * logoCurve.value),
                      child: child,
                    ),
                  ),
                );
              },
              child: _WhiteDavochainLockup(
                maxWidth: math.min(size.width - 30, 360),
              ),
            ),
          ),
        ],
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
