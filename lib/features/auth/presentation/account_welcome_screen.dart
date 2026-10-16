import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../../shared/widgets/auth_widgets.dart';

/// A single, finite finale for first account setup. It never authorizes an
/// account or navigates from a timer; its caller owns the accepted setup state.
class AccountWelcomeScreen extends StatefulWidget {
  const AccountWelcomeScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  State<AccountWelcomeScreen> createState() => _AccountWelcomeScreenState();
}

class _AccountWelcomeScreenState extends State<AccountWelcomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _scene;
  bool _exploring = false;
  bool _reduced = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _scene = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = DavoMotionPolicy.reduce(context);
    if (_reduced) {
      _scene.value = 1;
    } else if (_foreground && !_scene.isAnimating && !_scene.isCompleted) {
      _scene.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      if (!_reduced && !_scene.isCompleted) _scene.forward();
    } else {
      _scene.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scene.dispose();
    super.dispose();
  }

  void _explore() {
    if (_exploring) return;
    _exploring = true;
    widget.onExplore();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'Davochain',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, constraints.maxHeight - 48),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _scene,
                              builder: (context, _) => Transform.translate(
                                offset: Offset(
                                  0,
                                  8 *
                                      (1 -
                                          Curves.easeOutCubic.transform(
                                            _scene.value,
                                          )),
                                ),
                                child: const _WelcomeIllustration(),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Welcome to Davochain',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 28,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'One place for your wallets, crypto and gift cards.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                height: 1.6,
                                color: colors.body,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final item in const <(IconData, String)>[
                                  (
                                    Icons.account_balance_wallet_outlined,
                                    'Wallets',
                                  ),
                                  (Icons.swap_horiz_rounded, 'Crypto'),
                                  (Icons.card_giftcard_rounded, 'Gift cards'),
                                ])
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(
                                          item.$1,
                                          color: colors.link,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.$2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 12,
                                            color: colors.body,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: colors.bodyMuted,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Transaction PIN created',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 12,
                                      color: colors.bodyMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: DavoPrimaryButton(
                  label: 'Explore Davochain',
                  onPressed: _explore,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wallet-shaped brand composition, without invented balances or account data.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: 280,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primarySoft,
              ),
            ),
            Transform.rotate(
              angle: -.09,
              child: Container(
                width: 208,
                height: 140,
                decoration: BoxDecoration(
                  color: colors.link.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Container(
              width: 208,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/brand/davochain_logo.png',
                    width: 92,
                    height: 80,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: 8,
              child: _tile(context, Icons.swap_horiz_rounded),
            ),
            Positioned(
              left: 14,
              bottom: 6,
              child: _tile(context, Icons.card_giftcard_rounded),
            ),
            Positioned(
              right: 30,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.divider),
                ),
                child: Icon(Icons.check_rounded, color: colors.link, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon) {
    final colors = DavoColors.of(context);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider),
      ),
      child: Icon(icon, color: colors.link, size: 28),
    );
  }
}
