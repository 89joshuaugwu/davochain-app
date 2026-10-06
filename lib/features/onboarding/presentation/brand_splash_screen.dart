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
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _ambient;
  Timer? _timer;

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
      duration: const Duration(milliseconds: 900),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(milliseconds: 1900), _openOnboarding);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _openOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: '/onboarding'),
        transitionDuration: const Duration(milliseconds: 560),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, animation, __) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
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
    final intro = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    final logoCurve = CurvedAnimation(
      parent: _intro,
      curve: const Interval(.16, 1, curve: Curves.easeOutBack),
    );

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
              animation: Listenable.merge([_intro, _ambient]),
              builder: (context, child) {
                final float = reduceMotion
                    ? 0.0
                    : math.sin(_ambient.value * math.pi) * 1.6;
                return Opacity(
                  opacity: intro.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - intro.value) + float),
                    child: Transform.scale(
                      scale: reduceMotion ? 1 : .88 + (.12 * logoCurve.value),
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
