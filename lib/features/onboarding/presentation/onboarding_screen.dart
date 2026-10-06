import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  late final AnimationController _floatController;
  int _index = 0;

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
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _goTo(_index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _OnboardingBackdrop()),
          PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                index: index,
                activeIndex: _index,
                floatController: _floatController,
                reduceMotion: reduceMotion,
                onNext: _next,
                onCreateAccount: _showStub,
                onLogin: _showStub,
              );
            },
          ),
          if (_index < _pages.length - 1)
            Positioned(
              top: math.max(MediaQuery.paddingOf(context).top + 18, 56),
              right: 16,
              child: TextButton(
                onPressed: () => _goTo(_pages.length - 1),
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
          // Keeps visual proportions stable on very tall displays without
          // forcing fixed Figma coordinates.
          if (size.height > 940)
            const Positioned(bottom: 0, left: 0, right: 0, child: SizedBox(height: 1)),
        ],
      ),
    );
  }

  void _showStub() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentication screens are the next Davochain build milestone.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.activeIndex,
    required this.floatController,
    required this.reduceMotion,
    required this.onNext,
    required this.onCreateAccount,
    required this.onLogin,
  });

  final _OnboardingData data;
  final int index;
  final int activeIndex;
  final AnimationController floatController;
  final bool reduceMotion;
  final VoidCallback onNext;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  bool get isLast => index == 2;
  bool get isActive => activeIndex == index;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(.88, 1.18);
    final top = math.max(MediaQuery.paddingOf(context).top + 112, height * .205);

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: top,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      width: math.min(width - 32, 332 * scale),
                      height: math.min(332 * scale, height * .395),
                      child: AnimatedBuilder(
                        animation: floatController,
                        builder: (context, child) {
                          final phase = floatController.value * math.pi;
                          final dy = reduceMotion ? 0.0 : math.sin(phase) * 6;
                          final scaleValue = reduceMotion ? 1.0 : 1 + math.sin(phase) * .008;
                          return AnimatedOpacity(
                            opacity: isActive ? 1 : .9,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(0, dy),
                              child: Transform.scale(scale: scaleValue, child: child),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'onboarding-art-$index',
                          child: Image.asset(
                            data.imagePath,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isLast ? 7 : 43),
                  _ProgressDots(activeIndex: activeIndex),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, .12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      data.title,
                      key: ValueKey('${data.title}-$isActive'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(data.body, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 40),
                  if (!isLast)
                    _PrimaryButton(label: 'Next', onPressed: onNext)
                  else ...[
                    _PrimaryButton(label: 'Create Account', onPressed: onCreateAccount),
                    const SizedBox(height: 16),
                    _SecondaryButton(label: 'Login', onPressed: onLogin),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          width: active ? 25 : 10,
          height: 7,
          margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : (activeIndex == 2 ? AppColors.muted : AppColors.mutedSoft),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

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
    return DecoratedBox(
      decoration: const BoxDecoration(
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
