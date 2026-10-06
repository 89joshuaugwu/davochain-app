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
      duration: const Duration(milliseconds: 760),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(milliseconds: 1650), _openOnboarding);
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
        transitionDuration: const Duration(milliseconds: 620),
        pageBuilder: (_, animation, __) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.012, end: 1).animate(curved),
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
    final introCurve = CurvedAnimation(parent: _intro, curve: Curves.easeOutBack);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashGlow(),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1.18,
              child: Opacity(
                opacity: .86,
                child: Image.asset(
                  'assets/images/brand/native_splash_branding.png',
                  height: MediaQuery.sizeOf(context).height * .205,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _ambient]),
              builder: (context, child) {
                final wave = math.sin(_ambient.value * math.pi);
                final dy = reduceMotion ? 0.0 : wave * 4;
                final scale = reduceMotion ? 1.0 : .88 + introCurve.value * .12;
                return Opacity(
                  opacity: Curves.easeOut.transform(_intro.value.clamp(0.0, 1.0).toDouble()),
                  child: Transform.translate(
                    offset: Offset(0, dy + (1 - _intro.value) * 14),
                    child: Transform.scale(scale: scale, child: child),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/brand/native_splash_lockup.png',
                width: math.min(MediaQuery.sizeOf(context).width * .69, 300.0),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashGlow extends StatelessWidget {
  const _SplashGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -.02),
          radius: .48,
          colors: [
            Colors.white.withOpacity(.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
