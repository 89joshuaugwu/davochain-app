import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davochain_logo_lockup.dart';
import 'onboarding_screen.dart';

class BrandSplashScreen extends StatefulWidget {
  const BrandSplashScreen({super.key});

  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
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

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    final curve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    );
    _scale = Tween<double>(begin: .82, end: 1).animate(curve);
    _opacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, .65, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, .16),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    ));

    _introController.forward();
    _timer = Timer(const Duration(milliseconds: 1900), _openOnboarding);
  }

  void _openOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: const OnboardingScreen(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(.035, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _introController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashGlow(),
          Positioned.fill(
            top: null,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .22,
              child: const CustomPaint(painter: _CryptoLinePainter()),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_introController, _ambientController]),
              builder: (context, child) {
                final ambient = reduceMotion
                    ? 0.0
                    : math.sin(_ambientController.value * math.pi) * 4;
                return Transform.translate(
                  offset: Offset(0, ambient),
                  child: FadeTransition(
                    opacity: _opacity,
                    child: SlideTransition(
                      position: _slide,
                      child: ScaleTransition(
                        scale: _scale,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: const DavochainLogoLockup(
                logoColor: Colors.white,
                textColor: Colors.white,
                logoWidth: 56,
                fontSize: 39,
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
          center: const Alignment(0, .05),
          radius: .42,
          colors: [
            Colors.white.withValues(alpha: .13),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _CryptoLinePainter extends CustomPainter {
  const _CryptoLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;

    final faint = Paint()
      ..color = Colors.white.withValues(alpha: .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final baseY = size.height * .78;
    for (var i = -1; i < 5; i++) {
      final x = i * size.width * .24;
      final path = Path()
        ..moveTo(x, baseY)
        ..lineTo(x + size.width * .12, size.height * .48)
        ..lineTo(x + size.width * .24, baseY)
        ..lineTo(x + size.width * .12, size.height * 1.08)
        ..close();
      canvas.drawPath(path, i.isEven ? paint : faint);
    }

    final circleRadius = size.width * .075;
    canvas.drawCircle(Offset(size.width * .12, size.height * .62), circleRadius, paint);
    canvas.drawCircle(Offset(size.width * .86, size.height * .58), circleRadius, faint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
