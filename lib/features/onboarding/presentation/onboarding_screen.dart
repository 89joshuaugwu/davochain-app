import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/davochain_logo_lockup.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _opening = false;
  static const _pages = [
    _WelcomePage(
        image: 'assets/images/onboarding/trade_crypto.png',
        title: 'Trade Crypto, Your Way',
        body: 'Buy, sell and swap. Your next move starts with Davochain.'),
    _WelcomePage(
        image: 'assets/images/onboarding/gift_cards.png',
        title: 'Simple. Fast. Secure.',
        body:
            'Your digital assets, together. Keep track of your balance and every move you make.'),
    _WelcomePage(
        image: 'assets/images/onboarding/digital_assets.png',
        title: 'Turn Gift Cards Into Cash',
        body:
            'Give your gift cards a fresh start. Choose a card, see the rate and take it from there.'),
  ];
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (page < 0 || page >= _pages.length || !_controller.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic);
    }
  }

  Future<void> _open(String route) async {
    if (_opening) return;
    _opening = true;
    await Navigator.of(context).pushNamed(route);
    if (mounted) _opening = false;
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index > 0) _goTo(_index - 1);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: DavoColors.of(context).surface,
            systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark),
        child: Scaffold(
          backgroundColor: DavoColors.of(context).surface,
          body: DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: const Alignment(0, .45),
              colors: [
                AppColors.primary,
                AppColors.primary,
                DavoColors.of(context).isDark ? const Color(0xFF224581) : const Color(0xFF91B6FF),
                DavoColors.of(context).isDark ? DavoColors.of(context).surface : const Color(0xFFF0F5FF),
                DavoColors.of(context).surface
              ],
              stops: const [0, .16, .42, .8, 1],
            )),
            child: SafeArea(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 12, top: 4),
                child: Row(children: [
                  const Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: DavochainLogoLockup(
                                  logoColor: Colors.white,
                                  logoWidth: 29,
                                  fontSize: 20)))),
                  if (_index == 2) const SizedBox(height: 48, width: 64),
                  if (_index < 2)
                    TextButton(
                      onPressed: () => _goTo(2),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(64, 48)),
                      child: const Text('Skip'),
                    ),
                ]),
              ),
              Expanded(
                  child: PageView.builder(
                key: const ValueKey('welcome-pages'),
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _index = page),
                itemBuilder: (context, page) => _WelcomeContent(
                    data: _pages[page],
                    controller: _controller,
                    index: page,
                    reduced: reduced),
              )),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          _pages.length,
                          (page) => Semantics(
                                label:
                                    'Introduction ${page + 1} of ${_pages.length}',
                                selected: _index == page,
                                button: true,
                                child: InkResponse(
                                    splashFactory:
                                        reduced ? NoSplash.splashFactory : null,
                                    onTap: () => _goTo(page),
                                    radius: 22,
                                    child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Center(
                                          child: AnimatedContainer(
                                            duration: reduced
                                                ? Duration.zero
                                                : const Duration(
                                                    milliseconds: 220),
                                            curve: Curves.easeOutCubic,
                                            width: _index == page ? 28 : 8,
                                            height: 6,
                                            decoration: BoxDecoration(
                                                color: _index == page
                                                    ? AppColors.primary
                                                    : const Color(0xFFD4DDF0),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        ))),
                              ))),
                  DavoPrimaryButton(
                    label: _index == 2 ? 'Create Account' : 'Next',
                    height: math.max(52,
                        MediaQuery.textScalerOf(context).scale(14) * 1.35 + 24),
                    onPressed: _index == 2
                        ? () => _open(AppRoutes.signup)
                        : () => _goTo(_index + 1),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _open(AppRoutes.login),
                        style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48)),
                        child: const Text('Login'),
                      )),
                ]),
              ),
            ])),
          ),
        ),
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent(
      {required this.data,
      required this.controller,
      required this.index,
      required this.reduced});
  final _WelcomePage data;
  final PageController controller;
  final int index;
  final bool reduced;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final artHeight = (constraints.maxHeight * .60).clamp(100.0, 355.0);
      return SingleChildScrollView(
        key: PageStorageKey('welcome-content-$index'),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: artHeight,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        final distance = controller.hasClients &&
                                controller.position.hasContentDimensions
                            ? ((controller.page ?? 0) - index).clamp(-1.0, 1.0)
                            : 0.0;
                        if (reduced) return child!;
                        return Transform.translate(
                            offset: Offset(distance * 36, 0),
                            child: Transform.rotate(
                                angle: distance * .025, child: child));
                      },
                      child: RepaintBoundary(
                          child: Image.asset(data.image,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                              filterQuality: FilterQuality.medium)),
                    )),
                const SizedBox(height: 24),
                Semantics(
                    header: true,
                    child: Text(data.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontSize: 28,
                                height: 1.2,
                                letterSpacing: -.7,
                                color: DavoColors.of(context).ink))),
                const SizedBox(height: 14),
                Text(data.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.55,
                        color: DavoColors.of(context).bodyMuted)),
                const SizedBox(height: 12),
              ]),
        ),
      );
    });
  }
}

class _WelcomePage {
  const _WelcomePage(
      {required this.image, required this.title, required this.body});
  final String image;
  final String title;
  final String body;
}
