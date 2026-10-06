import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _index = 0;
  int _direction = 1;
  late final AnimationController _floatController;

  static const _pages = <_OnboardingData>[
    _OnboardingData(
      imagePath: 'assets/images/onboarding/trade_crypto.png',
      title: 'Trade Crypto, Your Way',
      body: 'Buy, sell and swap crypto with a simple and secure experience.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding/digital_assets.png',
      title: 'Simple. Fast. Secure.',
      body: 'Everything you need to trade digital assets, all in one place.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding/gift_cards.png',
      title: 'Turn Gift Cards Into Cash',
      body: 'Trade your gift cards at competitive rates and get paid with ease.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _setIndex(int index) {
    if (index < 0 || index >= _pages.length || index == _index) return;
    setState(() {
      _direction = index > _index ? 1 : -1;
      _index = index;
    });
  }

  void _next() => _setIndex(_index + 1);
  void _previous() => _setIndex(_index - 1);

  @override
  Widget build(BuildContext context) {
    final data = _pages[_index];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _OnboardingBackdrop()),
          SafeArea(
            top: false,
            bottom: false,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -180) {
                  _next();
                } else if (velocity > 180) {
                  _previous();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final height = constraints.maxHeight;
                    final width = constraints.maxWidth;
                    final topPadding = MediaQuery.paddingOf(context).top;
                    final artSize = math.min(width, math.min(332.0, height * .395));
                    final contentTop = math.max(topPadding + 114, height * .205);

                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          top: contentTop,
                          left: 0,
                          right: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: artSize,
                                width: double.infinity,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : const Duration(milliseconds: 560),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    transitionBuilder: (child, animation) {
                                      final begin = Offset(_direction * .12, 0);
                                      final slide = Tween<Offset>(begin: begin, end: Offset.zero)
                                          .animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ));
                                      final scale = Tween<double>(begin: .965, end: 1)
                                          .animate(animation);
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: slide,
                                          child: ScaleTransition(scale: scale, child: child),
                                        ),
                                      );
                                    },
                                    child: _FloatingArt(
                                      key: ValueKey(data.imagePath),
                                      imagePath: data.imagePath,
                                      size: artSize,
                                      controller: _floatController,
                                      reduceMotion: reduceMotion,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: _index == 2 ? 12 : 42),
                              _ProgressDots(index: _index),
                              const SizedBox(height: 12),
                              AnimatedSwitcher(
                                duration: reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 360),
                                transitionBuilder: (child, animation) {
                                  final slide = Tween<Offset>(
                                    begin: Offset(0, _direction > 0 ? .12 : -.08),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ));
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(position: slide, child: child),
                                  );
                                },
                                child: Column(
                                  key: ValueKey('${data.title}-${data.body}'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.title,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      data.body,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              AnimatedSwitcher(
                                duration: reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 320),
                                child: _index < 2
                                    ? _OnboardingPrimaryButton(
                                        key: const ValueKey('next'),
                                        label: 'Next',
                                        onPressed: _next,
                                      )
                                    : Column(
                                        key: const ValueKey('final-actions'),
                                        children: [
                                          _OnboardingPrimaryButton(
                                            label: 'Create Account',
                                            onPressed: () => Navigator.of(context)
                                                .pushNamed(AppRoutes.signup),
                                          ),
                                          const SizedBox(height: 16),
                                          _OnboardingSecondaryButton(
                                            label: 'Login',
                                            onPressed: () => Navigator.of(context)
                                                .pushNamed(AppRoutes.login),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                        if (_index < 2)
                          Positioned(
                            top: math.max(topPadding + 18.0, 56.0),
                            right: 0,
                            child: TextButton(
                              onPressed: () => _setIndex(2),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingArt extends StatelessWidget {
  const _FloatingArt({
    super.key,
    required this.imagePath,
    required this.size,
    required this.controller,
    required this.reduceMotion,
  });

  final String imagePath;
  final double size;
  final AnimationController controller;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final wave = math.sin(controller.value * math.pi);
        final dy = reduceMotion ? 0.0 : wave * 5.5;
        final scale = reduceMotion ? 1.0 : 1 + wave * .006;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (dot) {
        final active = dot == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(right: dot == 2 ? 0 : 4),
          width: active ? 25 : 10,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : index == 2
                    ? AppColors.muted
                    : AppColors.mutedSoft,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _OnboardingPrimaryButton extends StatelessWidget {
  const _OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.offWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OnboardingSecondaryButton extends StatelessWidget {
  const _OnboardingSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySoft,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, -1),
          end: Alignment(0, .52),
          colors: [
            AppColors.primary,
            Color(0xFF7EA7FC),
            Color(0xFFE8EFFF),
            Colors.white,
          ],
          stops: [0, .22, .48, .66],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.body,
  });

  final String imagePath;
  final String title;
  final String body;
}
