
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../transactions/presentation/transaction_history_screen.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart' show Entrance;
import '../../../core/navigation/app_page_route.dart';
import '../../../core/preview/preview_account_state.dart';
import '../../buy_crypto/presentation/buy_crypto_flow.dart';
import '../../crypto/presentation/crypto_full_flow.dart';
import '../../gift_cards/presentation/gift_card_flow.dart';
import '../../profile_settings/presentation/profile_settings_flow.dart';

const _dashboardAssetRoot = 'assets/images/dashboard';

class DavochainDashboardScreen extends StatefulWidget {
  const DavochainDashboardScreen({super.key});

  @override
  State<DavochainDashboardScreen> createState() => _DavochainDashboardScreenState();
}

class _DavochainDashboardScreenState extends State<DavochainDashboardScreen> {
  int _navIndex = 0;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: PreviewAccountState.setupComplete,
          builder: (context, setupComplete, _) => LayoutBuilder(
            builder: (context, constraints) {
              final gap = constraints.maxHeight < 790 ? 12.0 : 16.0;
              final header = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Entrance(index: 0, child: _DashboardHeader()),
                  SizedBox(height: gap),
                  _Entrance(index: 1, child: _BalanceCard(
                    visible: _balanceVisible,
                    onVisibilityToggle: () => setState(() => _balanceVisible = !_balanceVisible),
                    onDeposit: _openWalletSelector,
                    onWithdraw: () => startWithdrawFlow(context),
                  )),
                  SizedBox(height: gap),
                  if (!setupComplete) ...[
                    _Entrance(index: 2, child: InkWell(
                      onTap: () => Navigator.of(context).push(_davoRoute(const KycTierOverviewScreen())),
                      borderRadius: BorderRadius.circular(8),
                      child: const _SetupBanner(),
                    )),
                    SizedBox(height: gap),
                  ],
                  _Entrance(index: 3, child: _QuickActions(
                    onBuy: () => startBuyCryptoFlow(context),
                    onSell: () => startSellCryptoFlow(context),
                    onGift: () => startGiftCardFlow(context),
                    onHistory: () => Navigator.of(context).push(_davoRoute(const TransactionHistoryScreen())),
                  )),
                  SizedBox(height: gap),
                  const _Entrance(index: 4, child: _PromoBanner()),
                  SizedBox(height: gap),
                  _assetsHeading(),
                  const SizedBox(height: 8),
                ],
              );
              // Retain readable, reachable content on short phones or with enlarged text.
              final needsFullScroll = constraints.maxHeight < 760 || MediaQuery.textScalerOf(context).scale(14) > 18;
              if (needsFullScroll) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(children: [header, const SizedBox(height: 240, child: _DashboardAssetCard())]),
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(children: [header, const Expanded(child: _DashboardAssetCard())]),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onChanged: (index) {
          if (index == 0) return;
          if (index == 2) {
            HapticFeedback.selectionClick();
            setState(() => _navIndex = index);
            startGiftCardFlow(context).whenComplete(() {
              if (mounted) setState(() => _navIndex = 0);
            });
            return;
          }
          if (index == 3) {
            HapticFeedback.selectionClick();
            setState(() => _navIndex = index);
            startProfileSettingsFlow(context).whenComplete(() {
              if (mounted) setState(() => _navIndex = 0);
            });
            return;
          }
          setState(() => _navIndex = index);
          HapticFeedback.selectionClick();
          Navigator.of(context).push(_davoRoute(const PortfolioScreen())).whenComplete(() {
            if (mounted) setState(() => _navIndex = 0);
          });
        },
      ),
    );
  }

  Widget _assetsHeading() => SizedBox(
    height: 40,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Assets', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
      TextButton(
        onPressed: () => Navigator.of(context).push(_davoRoute(const PortfolioScreen())),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('View Portfolio'), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 14)]),
      ),
    ]),
  );

  Future<void> _openWalletSelector() async {
    final selected = await showModalBottomSheet<_WalletOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (_) => _WalletSelectorSheet(onAddCrypto: _openCurrencySelector),
    );
    if (!mounted || selected == null) return;
    if (selected.isFiat) {
      Navigator.of(context).push(_davoRoute(const NairaDepositScreen()));
    } else {
      Navigator.of(context).push(_davoRoute(CryptoDepositScreen(asset: selected.asset!)));
    }
  }

  Future<_WalletOption?> _openCurrencySelector() async {
    final asset = await showModalBottomSheet<CryptoAsset>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (_) => const _CurrencySelectorSheet(),
    );
    if (!mounted || asset == null) return null;
    Navigator.of(context).push(_davoRoute(CryptoDepositScreen(asset: asset)));
    return null;
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => Entrance(
        delay: Duration(milliseconds: index * 45),
        offset: const Offset(0, .025),
        child: child,
      );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => startProfileSettingsFlow(context),
          customBorder: const CircleBorder(),
          child: ClipOval(
            child: Image.asset(
              'assets/figma_exact/profile.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF8D8D8D)),
            ),
            SizedBox(height: 2),
            Text(
              'Callie',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
          ],
        )),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => Navigator.of(context).push(_davoRoute(const ReferralDashboardScreen())),
          borderRadius: BorderRadius.circular(1000),
          child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: const Color(0x80D0DEFD),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Row(
            children: [
              Image.asset('assets/figma_exact/earn_gift.png', width: 20, height: 20, fit: BoxFit.contain),
              const SizedBox(width: 4),
              const Text('Earn \$5', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.primary)),
            ],
          ),
        ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => openNotificationCenter(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: Color(0x80D0DEFD), shape: BoxShape.circle),
            child: Center(child: Image.asset('assets/figma_exact/notification.png', width: 21, height: 21, fit: BoxFit.contain)),
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.visible,
    required this.onVisibilityToggle,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final bool visible;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            width: 268,
            height: 94,
            child: Image.asset(
              'assets/figma_exact/balance_wave.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onVisibilityToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Color(0xFFEEF0F5)),
                      ),
                      const SizedBox(width: 4),
                      Opacity(
                        opacity: visible ? 1 : .55,
                        child: Image.asset('assets/figma_exact/eye.png', width: 10, height: 10, fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(
                    visible ? '₦1,284,500.35' : '₦••••••••',
                    key: ValueKey(visible),
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  )),
                ),
                const SizedBox(height: 2),
                Text(
                  visible ? '≈ \$842.31 USD' : '≈ ••••• USD',
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: Colors.white),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _BalanceActionButton(
                        light: true,
                        assetPath: 'assets/figma_exact/deposit_plus.png',
                        label: 'Deposit',
                        onTap: onDeposit,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _BalanceActionButton(
                        light: false,
                        assetPath: 'assets/figma_exact/withdraw.png',
                        label: 'Withdraw',
                        onTap: onWithdraw,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceActionButton extends StatelessWidget {
  const _BalanceActionButton({
    required this.light,
    this.assetPath,
    required this.label,
    required this.onTap,
  }) : icon = null;

  final bool light;
  final IconData? icon;
  final String? assetPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: light ? const Color(0xFFF5F6F9) : const Color(0xFF104DCE),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (assetPath != null)
                Image.asset(assetPath!, width: 20, height: 20, fit: BoxFit.contain)
              else
                Icon(icon, size: 19, color: light ? AppColors.primary : Colors.white),
              const SizedBox(width: 12),
              Flexible(child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: light ? AppColors.primary : Colors.white,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FE),
        border: Border.all(color: const Color(0xFF6292FA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(child: Text(
            'Finish setting up your account',
            maxLines: 2,
            style: TextStyle(fontFamily: 'Sora', fontSize: 16, color: AppColors.primary, letterSpacing: -.16),
          )),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 15,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
            child: const Text(
              '1/4',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onBuy, required this.onSell, required this.onGift, required this.onHistory});

  final VoidCallback onBuy;
  final VoidCallback onSell;
  final VoidCallback onGift;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickAction(label: 'Buy Crypto', assetPath: 'assets/figma_exact/buy_action.png', bg: const Color(0xFFFEE5CB), fg: const Color(0xFFFD9915), onTap: onBuy)),
        const SizedBox(width: 16),
        Expanded(child: _QuickAction(label: 'Sell Crypto', assetPath: 'assets/figma_exact/sell_action.png', bg: const Color(0xFFDBF8E8), fg: const Color(0xFF20C55D), onTap: onSell)),
        const SizedBox(width: 16),
        Expanded(child: _QuickAction(label: 'Gift Card', assetPath: 'assets/figma_exact/gift_action.png', bg: const Color(0xFFE9DEFD), fg: const Color(0xFF8247E5), onTap: onGift)),
        const SizedBox(width: 16),
        Expanded(child: _QuickAction(label: 'History', assetPath: 'assets/figma_exact/history_action.png', bg: const Color(0xFFD8E9FE), fg: AppColors.primary, onTap: onHistory)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.assetPath,
  }) : icon = null, iconData = null;

  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final String? icon;
  final IconData? iconData;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 81,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: assetPath != null
                    ? Padding(
                        padding: const EdgeInsets.all(3),
                        child: Image.asset(assetPath!, color: label == 'Buy Crypto' ? fg : null, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                      )
                    : iconData != null
                        ? Icon(iconData, color: fg, size: 21)
                        : Text(icon!, style: TextStyle(fontFamily: 'Sora', fontSize: 23, fontWeight: FontWeight.w700, color: fg)),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 121,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF4FE), Color(0xFFBDD2FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            bottom: 0,
            width: 137,
            height: 87,
            child: Image.asset(
              'assets/figma_exact/promo_crypto.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const Positioned(
            left: 16,
            top: 10,
            width: 174,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn your Crypto and\nGift Cards into cash\ninstantly',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.primary),
                ),
                SizedBox(height: 5),
                Text(
                  'Trade top crypto and gift card at good rates with fast payment.',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.25, color: Color(0xFF424242)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(100)),
              alignment: Alignment.center,
              child: const Text(
                'Fast • Secure • Reliable',
                style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAssetCard extends StatelessWidget {
  const _DashboardAssetCard();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: ColoredBox(
      color: Colors.white,
      child: ListView(
        key: const ValueKey('dashboard-assets'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: const [
          _AssetRow(key: ValueKey('dashboard-asset-BTC'), rowHeight: 56, asset: CryptoAsset.bitcoin, amount: '0.0086 BTC', value: '₦580,200.00', change: '+4.21%'),
          Divider(height: 1, color: Color(0xFFF0F1F4)),
          _AssetRow(key: ValueKey('dashboard-asset-ETH'), rowHeight: 56, asset: CryptoAsset.ethereum, amount: '0.102 ETH', value: '₦342,100.00', change: '+2.18%'),
          Divider(height: 1, color: Color(0xFFF0F1F4)),
          _AssetRow(key: ValueKey('dashboard-asset-USDT'), rowHeight: 56, asset: CryptoAsset.tether, amount: '250.00 USDT', value: '₦250,000.00', change: '0.00%'),
          Divider(height: 1, color: Color(0xFFF0F1F4)),
          _AssetRow(key: ValueKey('dashboard-asset-USDC'), rowHeight: 56, asset: CryptoAsset.usdCoin, amount: '112.20 USDC', value: '₦112,200.35', change: '+0.01%'),
        ],
      ),
    ),
  );
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({super.key, this.rowHeight = 62, required this.asset, required this.amount, required this.value, required this.change, this.chevron = false});

  final double rowHeight;
  final CryptoAsset asset;
  final String amount;
  final String value;
  final String change;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final positive = change.startsWith('+');
    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          _CryptoIcon(asset: asset, size: 37),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(asset.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink))),
                    if (chevron) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE8ECFC), borderRadius: BorderRadius.circular(2)),
                        child: Text(asset.symbol, style: const TextStyle(fontFamily: 'Sora', fontSize: 9, color: Colors.black)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF424242))),
              ],
            ),
          ),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: positive ? const Color(0xFFF3FAF5) : const Color(0xFFE8ECFC),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: positive ? const Color(0xFF20C55D) : const Color(0xFF434656)),
                ),
              ),
            ],
          )),
          if (chevron) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.chevron_right_rounded, color: Color(0xFF8D8D8D))),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F2F2))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(index: 0, current: index, assetPath: 'assets/figma_exact/nav_home_full.svg', label: 'Home', onTap: onChanged),
              _NavItem(index: 1, current: index, assetPath: 'assets/figma_exact/nav_trade_full.svg', label: 'Trade', onTap: onChanged),
              _NavItem(index: 2, current: index, assetPath: 'assets/figma_exact/nav_gift_full.svg', label: 'Gift Cards', onTap: onChanged),
              _NavItem(index: 3, current: index, assetPath: 'assets/figma_exact/nav_settings_full.svg', label: 'Settings', onTap: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.index, required this.current, required this.assetPath, required this.label, required this.onTap});

  final int index;
  final int current;
  final String assetPath;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    final color = active ? AppColors.primary : const Color(0xFF686868);
    return InkResponse(
      onTap: () => onTap(index),
      radius: 28,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: ColorFiltered(
                key: ValueKey(active),
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: SvgPicture.asset(assetPath, width: 24, height: 24, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 10, letterSpacing: .55, color: color)),
          ],
        ),
      ),
    );
  }
}

// --- Portfolio ----------------------------------------------------------------

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _tradeTab = 0;
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Portfolio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF131B2E))),
                        Text('Real-time valuation', style: TextStyle(fontSize: 12, color: Color(0xFF434656))),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    assetPath: 'assets/figma_exact/eye.png',
                    onTap: () => setState(() => _visible = !_visible),
                  ),
                  const SizedBox(width: 4),
                  const _RoundIconButton(icon: Icons.show_chart_rounded),
                ],
              ),
              const SizedBox(height: 16),
              _PortfolioValueCard(visible: _visible),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) {
                  final active = _tradeTab == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 16),
                      child: Material(
                        color: active ? AppColors.primary : const Color(0xFFEEF0F5),
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          onTap: () {
                            if (index == 0) {
                              startBuyCryptoFlow(context);
                              return;
                            }
                            if (index == 1) {
                              startSellCryptoFlow(context);
                              return;
                            }
                            startConvertCryptoFlow(context);
                            setState(() => _tradeTab = index);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                ['Buy', 'Sell', 'Swap'][index],
                                style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : const Color(0xFF424242)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const _AllocationCard(),
              const SizedBox(height: 24),
              const Text('Your Assets', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
              const SizedBox(height: 9),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: const Column(
                  children: [
                    _PortfolioAssetTile(asset: CryptoAsset.bitcoin, amount: '0.0086 BTC', value: '₦580,200.00', change: '+4.21%'),
                    SizedBox(height: 8),
                    _PortfolioAssetTile(asset: CryptoAsset.ethereum, amount: '0.102 ETH', value: '₦342,100.00', change: '+2.18%'),
                    SizedBox(height: 8),
                    _PortfolioAssetTile(asset: CryptoAsset.solana, amount: '0.74 SOL', value: '₦112,200.00', change: '+4.21%'),
                    SizedBox(height: 8),
                    _PortfolioAssetTile(asset: CryptoAsset.tether, amount: '250.00 USDT', value: '₦250,000.00', change: '+2.18%'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({this.icon, this.assetPath, this.onTap}) : assert(icon != null || assetPath != null);

  final IconData? icon;
  final String? assetPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: Color(0xFFE8ECFC), shape: BoxShape.circle),
        child: assetPath != null
            ? Center(
                child: Image.asset(
                  assetPath!,
                  width: 18,
                  height: 18,
                  color: AppColors.primary,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              )
            : Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

class _PortfolioValueCard extends StatelessWidget {
  const _PortfolioValueCard({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            width: 268,
            height: 94,
            child: Image.asset(
              'assets/figma_exact/balance_wave.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          const Positioned(
            right: 12,
            top: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(999))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  children: [
                    DecoratedBox(decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: SizedBox(width: 6, height: 6)),
                    SizedBox(width: 4),
                    Text('Live Sync', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Portfolio Value', style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Color(0xFFEEF0F5))),
                const SizedBox(height: 8),
                Text(
                  visible ? '₦1,284,500.35' : '₦••••••••',
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(visible ? '≈ \$842.31 USD' : '≈ ••••• USD', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Asset Allocation', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEAEDFF), borderRadius: BorderRadius.circular(100)),
                child: const Text('4 Coins', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF424242))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: const Row(
              children: [
                Expanded(flex: 452, child: SizedBox(height: 12, child: ColoredBox(color: Color(0xFFF7931A)))),
                Expanded(flex: 266, child: SizedBox(height: 12, child: ColoredBox(color: Color(0xFF627EEA)))),
                Expanded(flex: 195, child: SizedBox(height: 12, child: ColoredBox(color: Color(0xFF50AF95)))),
                Expanded(flex: 87, child: SizedBox(height: 12, child: ColoredBox(color: Color(0xFF20C55D)))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _AllocationTile(name: 'Bitcoin', percent: '45.2%', value: '₦580.2k', color: Color(0xFFF7931A))),
                      SizedBox(width: 16),
                      Expanded(child: _AllocationTile(name: 'Ethereum', percent: '26.6%', value: '₦342.1k', color: Color(0xFF627EEA))),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _AllocationTile(name: 'Tether', percent: '19.5%', value: '₦250.0k', color: Color(0xFF50AF95))),
                      SizedBox(width: 16),
                      Expanded(child: _AllocationTile(name: 'Solana', percent: '8.7%', value: '₦112.2k', color: Color(0xFF20C55D))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationTile extends StatelessWidget {
  const _AllocationTile({required this.name, required this.percent, required this.value, required this.color});

  final String name;
  final String percent;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEAF1F9), borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF131B2E))),
                Text(percent, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: Color(0xFF424242))),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _PortfolioAssetTile extends StatelessWidget {
  const _PortfolioAssetTile({required this.asset, required this.amount, required this.value, required this.change});

  final CryptoAsset asset;
  final String amount;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: _AssetRow(asset: asset, amount: amount, value: value, change: change, chevron: true),
    );
  }
}

// --- Deposit flow --------------------------------------------------------------

enum CryptoAsset {
  bitcoin('Bitcoin', 'BTC', '₿', Color(0xFFF7931A)),
  ethereum('Ethereum', 'ETH', '◆', Color(0xFF627EEA)),
  solana('Solana', 'SOL', '≋', Color(0xFF090909)),
  usdCoin('USD Coin', 'USDC', r'$', Color(0xFF2775CA)),
  tether('Tether', 'USDT', '₮', Color(0xFF009393));

  const CryptoAsset(this.name, this.symbol, this.glyph, this.color);
  final String name;
  final String symbol;
  final String glyph;
  final Color color;
}

String _depositQrAsset(CryptoAsset asset) => switch (asset) {
      CryptoAsset.bitcoin => '$_dashboardAssetRoot/btc_qr.png',
      CryptoAsset.ethereum => '$_dashboardAssetRoot/eth_qr.png',
      CryptoAsset.solana => '$_dashboardAssetRoot/sol_qr.png',
      CryptoAsset.usdCoin => '$_dashboardAssetRoot/usdc_qr.png',
      CryptoAsset.tether => '$_dashboardAssetRoot/usdt_qr.png',
    };

class _CryptoIcon extends StatelessWidget {
  const _CryptoIcon({required this.asset, this.size = 37});

  final CryptoAsset asset;
  final double size;

  String get _assetPath => switch (asset) {
        CryptoAsset.bitcoin => 'assets/figma_exact/btc.png',
        CryptoAsset.ethereum => 'assets/figma_exact/eth.png',
        CryptoAsset.solana => 'assets/figma_exact/sol.png',
        CryptoAsset.tether => 'assets/figma_exact/usdt.png',
        CryptoAsset.usdCoin => 'assets/figma_exact/usdc.png',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(_assetPath, fit: BoxFit.contain, filterQuality: FilterQuality.high),
    );
  }
}

class _WalletOption {
  const _WalletOption({required this.name, required this.symbol, required this.balance, required this.subBalance, this.asset, this.isFiat = false});

  final String name;
  final String symbol;
  final String balance;
  final String subBalance;
  final CryptoAsset? asset;
  final bool isFiat;
}

class _WalletSelectorSheet extends StatelessWidget {
  const _WalletSelectorSheet({required this.onAddCrypto});

  final Future<_WalletOption?> Function() onAddCrypto;

  static const options = [
    _WalletOption(name: 'Davochain Naira', symbol: 'NGD', balance: '100.50 USD', subBalance: '135,000.00 ₦', isFiat: true),
    _WalletOption(name: 'Bitcoin', symbol: 'BTC', balance: '0.00 USD', subBalance: '0.00000000 BTC', asset: CryptoAsset.bitcoin),
    _WalletOption(name: 'Ethereum', symbol: 'ETH', balance: '0.00 USD', subBalance: '0.00000000 ETH', asset: CryptoAsset.ethereum),
    _WalletOption(name: 'Solana', symbol: 'SOL', balance: '0.00 USD', subBalance: '0.00000000 SOL', asset: CryptoAsset.solana),
    _WalletOption(name: 'Tether', symbol: 'USDT', balance: '0.00 USD', subBalance: '0.000000 USDT', asset: CryptoAsset.tether),
  ];

  @override
  Widget build(BuildContext context) {
    return _DavoSheet(
      title: 'Select Wallet',
      heightFactor: .57,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () async {
              Navigator.pop(context);
              await onAddCrypto();
            },
            leading: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: Color(0xFFD8E9FE), shape: BoxShape.circle),
              child: Image.asset('assets/figma_exact/plus_circle.png', width: 24, height: 24),
            ),
            title: const Text('Add crypto asset', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          ...options.map((option) => _WalletTile(option: option)),
        ],
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  const _WalletTile({required this.option});

  final _WalletOption option;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, option),
      child: Container(
        height: 63,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEBEDF3), width: .4))),
        child: Row(
          children: [
            if (option.isFiat)
              Image.asset('assets/images/brand/naira_coin.png', width: 37, height: 37, fit: BoxFit.contain)
            else
              _CryptoIcon(asset: option.asset!, size: 37),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(option.symbol, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF424242))),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(option.balance, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: Color(0xFF424242))),
                const SizedBox(height: 2),
                Text(option.subBalance, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: Color(0xFF686868))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySelectorSheet extends StatelessWidget {
  const _CurrencySelectorSheet();

  @override
  Widget build(BuildContext context) {
    return _DavoSheet(
      title: 'Select Currency to Add',
      heightFactor: .57,
      child: Column(
        children: CryptoAsset.values.map((asset) {
          return InkWell(
            onTap: () => Navigator.pop(context, asset),
            child: Container(
              height: 63,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEBEDF3), width: .4))),
              child: Row(
                children: [
                  _CryptoIcon(asset: asset, size: 37),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asset.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.ink)),
                        const SizedBox(height: 2),
                        Text(asset.symbol, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF424242))),
                      ],
                    ),
                  ),
                  Image.asset('assets/figma_exact/chevron_right.png', width: 16, height: 16),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DavoSheet extends StatelessWidget {
  const _DavoSheet({required this.title, required this.child, required this.heightFactor});

  final String title;
  final Widget child;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(width: 85, height: 4, decoration: BoxDecoration(color: const Color(0xFF686868), borderRadius: BorderRadius.circular(100))),
                const SizedBox(height: 11),
                Row(
                  children: [
                    const SizedBox(width: 32),
                    Expanded(child: Center(child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: Colors.black)))),
                    InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: SizedBox(width: 40, height: 40, child: Center(child: Image.asset('assets/figma_exact/buy_close.png', width: 24, height: 24)))),
                  ],
                ),
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CryptoDepositScreen extends StatefulWidget {
  const CryptoDepositScreen({super.key, required this.asset});

  final CryptoAsset asset;

  @override
  State<CryptoDepositScreen> createState() => _CryptoDepositScreenState();
}

class _CryptoDepositScreenState extends State<CryptoDepositScreen> {
  bool _guidelinesOpen = false;
  OverlayEntry? _copyToastEntry;

  @override
  void dispose() {
    _copyToastEntry?.remove();
    _copyToastEntry = null;
    super.dispose();
  }

  CryptoAsset get asset => widget.asset;

  String get _address => switch (asset) {
        CryptoAsset.bitcoin => '1HGJSYUXGfgy2tdoE4rVQEqouRpBQaAA6zLZ',
        CryptoAsset.ethereum => '0x5C9f7Bf9C8e7A66C31E0D4d9bA2769D3431A92F2',
        CryptoAsset.solana => '5fCqVJmSc9M9Vh2eYw9rN3XX7oVA5EeMdwL7jDqkGzLQ',
        CryptoAsset.usdCoin => '0xE1A9bA33f04C4A12925D4207D0A19cC3B4c84021',
        CryptoAsset.tether => '0x4C55D181b91A6d5fE8B54B925C61D9dC06cE28B4',
      };

  String get _qrAsset => _depositQrAsset(asset);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Row(
            children: [
              Expanded(child: _FooterButton(
                label: 'Share or save',
                background: const Color(0xFFEEF0F5),
                foreground: const Color(0xFF424242),
                fontWeight: FontWeight.w400,
                onTap: () => _openShareSheet(context),
              )),
              const SizedBox(width: 16),
              Expanded(child: _FooterButton(
                label: 'Copy Address',
                background: AppColors.primary,
                foreground: const Color(0xFFEEF0F5),
                fontWeight: FontWeight.w600,
                onTap: () => _copy(context, _address),
              )),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            children: [
              _SimpleAppBar(title: 'Deposit', titleLeft: 128, onBack: () => Navigator.pop(context)),
              const SizedBox(height: 23),
              Expanded(
                child: SingleChildScrollView(

                  child: Column(
                    children: [
                      SizedBox(
                        width: 257,
                        height: 283,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 5,
                              top: 5,
                              width: 247,
                              height: 273,
                              child: Container(
                                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF5F6F9), width: 1)),
                                child: Image.asset(_qrAsset, fit: BoxFit.fill, filterQuality: FilterQuality.none),
                              ),
                            ),
                            Positioned(
                              left: 105,
                              top: 118,
                              width: 48,
                              height: 48,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: _CryptoIcon(asset: asset, size: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 91,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        decoration: BoxDecoration(color: const Color(0xFFF5F6F9), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 19, child: Text('Deposit Address', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF686868)))),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(_address, maxLines: 2, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: AppColors.ink))),
                                const SizedBox(width: 18),
                                InkWell(
                                  onTap: () => _copy(context, _address),
                                  child: Image.asset('assets/figma_exact/deposit_btc_copy_exact.png', width: 24, height: 24, fit: BoxFit.fill, filterQuality: FilterQuality.high),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DepositMetaRow(label: 'Minimum Deposit Amount', value: asset == CryptoAsset.bitcoin ? '0.00001 BTC' : '0.001 ${asset.symbol}'),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(label: 'Route Deposits To', value: 'Crypto wallet'),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(label: 'Deposit Arrival', value: '1 confirmations'),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(label: 'Withdrawal Unlocked', value: '2 confirmations'),
                      const SizedBox(height: 22),
                      InkWell(
                        onTap: () => setState(() => _guidelinesOpen = !_guidelinesOpen),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 13,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Please review these guidelines before making a deposit.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Color(0xFF424242)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _guidelinesOpen ? .5 : 0,
                                duration: const Duration(milliseconds: 220),
                                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF424242)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: _guidelinesOpen
                            ? const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: _Guidelines(),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.selectionClick();

    // Figma node 7319:55296 defines the toast itself (265 x 98, 8 px
    // radius, 16 px padding), but it is stored beside the Deposit frame
    // rather than as a positioned overlay. Keep the component pixel-exact
    // and place feedback below the status bar.
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _copyToastEntry?.remove();
    _copyToastEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.paddingOf(overlayContext).top;
        return Positioned(
          left: 0,
          right: 0,
          top: topInset + 12,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 265,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Copied Successfully. Please check when pasting to avoid malicious tampering',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.375,
                      color: Color(0xFFF8F9FB),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    _copyToastEntry = entry;
    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (_copyToastEntry == entry) {
        entry.remove();
        _copyToastEntry = null;
      }
    });
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: .40),
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: SafeArea(top: false, child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SharePreview(asset: asset, address: _address),
              const SizedBox(width: 24),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Share your wallet address or save it for later.', style: TextStyle(fontSize: 12, height: 1.4)),
              ])),
            ]),
            const SizedBox(height: 20),
            const Wrap(spacing: 20, runSpacing: 16, children: [
              _ShareAction(assetPath: 'assets/figma_exact/share_download_native_exact.png', label: 'Download', color: AppColors.primary),
              _ShareAction(assetPath: 'assets/figma_exact/share_x_native_exact.png', label: 'X', color: Color(0xFF1C1C1C)),
              _ShareAction(assetPath: 'assets/figma_exact/share_telegram_native_exact.png', label: 'Telegram', color: Color(0xFF29A9EA)),
              _ShareAction(assetPath: 'assets/figma_exact/share_more_native_exact.png', label: 'More', color: Color(0xFFEEF0F5)),
            ]),
          ]),
        )),
      ),
    );
  }

}

class _DepositMetaRow extends StatelessWidget {
  const _DepositMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: Color(0xFF686868))),
          Text(value, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _Guidelines extends StatelessWidget {
  const _Guidelines();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Text(
        'Use supported wallet addresses only\n'
        'Deposits sent via smart contracts may not be credited. Please send funds from a standard wallet address.\n\n'
        'Airdrops not supported\n'
        'Davochain does not support airdrops or mining rewards. Do not use your Davochain deposit address for such activities.\n\n'
        'Avoid high-risk platforms\n'
        'Do not send funds from unverified or high-risk platforms to ensure the safety of your account.',
        style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.28, color: Color(0xFF686868)),
      ),
    );
  }
}

class _SharePreview extends StatelessWidget {
  const _SharePreview({required this.asset, required this.address});

  final CryptoAsset asset;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84.6,
      height: 124.4,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFB3B3B3), width: 1), borderRadius: BorderRadius.circular(4)),
      child: Stack(
        children: [
          Positioned(left: 9.6, top: 8.2, child: Text('Deposit ${asset.symbol}', style: const TextStyle(fontFamily: 'Sora', fontSize: 3.21, fontWeight: FontWeight.w500, height: 1.25, color: Colors.black))),
          Positioned(left: 17.5, top: 17.4, width: 49.5, height: 54.7, child: Image.asset(_depositQrAsset(asset), fit: BoxFit.contain, filterQuality: FilterQuality.none)),
          Positioned(
            left: 37.6,
            top: 40.1,
            child: Container(
              width: 9.6,
              height: 9.6,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: _CryptoIcon(asset: asset, size: 8),
            ),
          ),
          const Positioned(left: 9.6, top: 76.7, child: Text('Network', style: TextStyle(fontFamily: 'Sora', fontSize: 2.81, fontWeight: FontWeight.w500, height: 1.25, color: Color(0xFF686868)))),
          Positioned(left: 9.6, top: 82.3, width: 65.3, child: Text('${asset.name} (${asset.symbol})', maxLines: 1, style: const TextStyle(fontFamily: 'Sora', fontSize: 3.21, fontWeight: FontWeight.w500, height: 1.25, color: Colors.black))),
          const Positioned(left: 9.6, top: 89.5, child: Text('Deposit Address', style: TextStyle(fontFamily: 'Sora', fontSize: 2.81, fontWeight: FontWeight.w500, height: 1.25, color: Color(0xFF686868)))),
          Positioned(left: 9.6, top: 95.1, width: 65.3, height: 8, child: Text(address, maxLines: 2, overflow: TextOverflow.clip, style: const TextStyle(fontFamily: 'Sora', fontSize: 3.21, fontWeight: FontWeight.w500, height: 1.25, color: AppColors.ink))),
          Positioned(
            left: 29.8,
            top: 110,
            width: 42,
            height: 8,
            child: Row(children: [
              Image.asset('assets/images/brand/davochain_logo.png', width: 5, height: 5, fit: BoxFit.contain),
              const SizedBox(width: 1),
              const Text('Davochain', style: TextStyle(fontSize: 3.3, fontWeight: FontWeight.w700, color: AppColors.ink)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({
    required this.assetPath,
    required this.label,
    required this.color,
  });

  final String assetPath;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.fill, filterQuality: FilterQuality.high),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: Color(0xFF424242))),
      ],
    ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.label, required this.background, required this.foreground, required this.onTap, this.fontWeight = FontWeight.w600});

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 48,
          child: Center(child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: fontWeight, color: foreground))),
        ),
      ),
    );
  }
}

class _SimpleAppBar extends StatelessWidget {
  const _SimpleAppBar({required this.title, required this.titleLeft, required this.onBack});

  final String title;
  final double titleLeft;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -10,
            top: 15,
            width: 32,
            height: 32,
            child: InkResponse(onTap: onBack, child: Image.asset('assets/figma_exact/deposit_back_exact.png', width: 32, height: 32, fit: BoxFit.fill, filterQuality: FilterQuality.high)),
          ),
          Positioned(
            left: titleLeft,
            top: 20,
            width: 66,
            height: 22,
            child: IgnorePointer(
              child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink)),
            ),
          ),
        ],
      ),
    );
  }
}

class NairaDepositScreen extends StatelessWidget {
  const NairaDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 15, 18),
          child: Column(
            children: [
              _SimpleAppBar(title: 'Deposit', titleLeft: 146, onBack: () => Navigator.pop(context)),
              const SizedBox(height: 34),
              Expanded(
                child: SingleChildScrollView(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 121,
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                        decoration: BoxDecoration(color: const Color(0xFFFEF7EA), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/figma_exact/crypto_info_exact.png', width: 17, height: 17, fit: BoxFit.contain),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 38, child: Text('Faster Transfers: Use Your Own Bank Account', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
                                  SizedBox(height: 4),
                                  Text('For faster processing, transfer funds from your own bank account. Transfers from other accounts may be delayed and require proof of ownership', style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.5, color: Color(0xFF424242))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 223,
                        padding: const EdgeInsets.fromLTRB(17, 19, 16, 20),
                        decoration: BoxDecoration(color: const Color(0xFFF5F6F9), borderRadius: BorderRadius.circular(4)),
                        child: const Column(
                          children: [
                            _BankDetailRow(label: 'Account name', value: 'Ogbonnia Chukwu Vincent (DVC)'),
                            SizedBox(height: 8),
                            _BankDetailRow(label: 'Bank name', value: 'Paystack-Titan'),
                            SizedBox(height: 8),
                            _BankDetailRow(label: 'Account number', value: '542100896436', last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: SizedBox(
                          width: 305,
                          height: 75,
                          child: Text(
                            'Any money sent to this bank account will automatically top up your Davochain (NGD) wallet.\nReceive funds from any local Nigerian bank account directly into your Davochain wallet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF424242)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SizedBox(height: 19, child: Text('Disclaimer', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 70,
                        child: Text(
                          'Funds deposited into your Davochain (NGD) wallet cannot be withdrawn.\nDeposits are only accepted from bank accounts with a name that matches your Davochain NGD account name. Deposits from accounts with different names will be blocked and rejected.',
                          style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.4, color: Color(0xFF424242)),
                        ),
                      ),
                      const SizedBox(height: 66),
                      _FooterButton(
                        label: 'Share Details',
                        background: AppColors.primary,
                        foreground: const Color(0xFFF8F9FB),
                        fontWeight: FontWeight.w400,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bank details are ready to share.'))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankDetailRow extends StatelessWidget {
  const _BankDetailRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF2F3F7), width: .5))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF424242))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied'), behavior: SnackBarBehavior.floating));
            },
            child: Image.asset('assets/figma_exact/deposit_ngd_copy_exact.png', width: 16, height: 16, fit: BoxFit.fill, filterQuality: FilterQuality.high),
          ),
        ],
      ),
    );
  }
}

AppPageRoute<T> _davoRoute<T>(Widget child) {
  return AppPageRoute<T>(builder: (_) => child);
}
