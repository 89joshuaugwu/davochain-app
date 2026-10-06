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
      duration: const Duration(milliseconds: 680),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
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
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, animation, __) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.008, end: 1).animate(curved),
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
    final introCurve = CurvedAnimation(parent: _intro, curve: Curves.easeOutBack);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Exact Figma splash background recovered from the source artwork:
          // cobalt field, central shadow and outlined crypto forms at the edge.
          Positioned.fill(
            child: Image.asset(
              'assets/images/figma/splash_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
          ),
          Align(
            alignment: const Alignment(0, -.015),
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _ambient]),
              builder: (context, child) {
                final pulse = reduceMotion ? 0.0 : math.sin(_ambient.value * math.pi) * 1.5;
                return Opacity(
                  opacity: Curves.easeOut.transform(_intro.value.clamp(0.0, 1.0)),
                  child: Transform.translate(
                    offset: Offset(0, (1 - _intro.value) * 12 + pulse),
                    child: Transform.scale(
                      scale: reduceMotion ? 1 : .9 + introCurve.value * .1,
                      child: child,
                    ),
                  ),
                );
              },
              child: _WhiteDavochainLockup(
                width: math.min(size.width * .72, 305.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteDavochainLockup extends StatelessWidget {
  const _WhiteDavochainLockup({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/brand/davochain_logo.png',
                width: 60,
                height: 40,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Davochain',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: .42,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
