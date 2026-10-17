import '../../wallets/simulation_crypto_addresses.dart';
import '../../../shared/widgets/davo_address_qr.dart';
import '../../wallets/presentation/wallet_picker_sheet.dart';
import '../../wallets/asset_catalog_projection.dart';
import '../../wallets/wallet_valuation.dart';
import '../../../shared/widgets/davo_naira_amount.dart';
import '../../funding/receiving_account_runtime.dart';
import '../../funding/receiving_account.dart';
import '../../../core/providers/account_scope.dart';
import '../../wallets/wallet_providers.dart';
import '../../../core/providers/reactive_builder.dart';
import '../../wallets/simulation_deposit_button.dart';
import '../../buy_crypto/presentation/buy_crypto_widgets.dart'
    show BuyAssetIcon;
import '../../../shared/widgets/davo_celebration_emoji.dart';
import 'dart:async';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import '../../buy_crypto/presentation/buy_crypto_screens.dart';
import '../../../shared/widgets/davo_blue_balance_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../wallets/wallet_repository.dart';
import '../../../shared/widgets/davo_action_icon.dart';
import '../../../shared/widgets/davo_notification_button.dart';
import 'portfolio_performance_screen.dart';
import '../../../shared/widgets/davo_refresh_region.dart';
import '../../../shared/widgets/davo_scroll_behavior.dart';
import '../../funding/funding_outcomes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/davo_main_shell.dart';
import '../../../shared/widgets/local_profile_avatar.dart';
import '../../../core/preview/local_preview_profile.dart';
import '../../transactions/presentation/transaction_history_screen.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart' show Entrance;
import '../../../shared/widgets/bank_details_share_button.dart';
import '../../../shared/widgets/davo_toast.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/preview/preview_account_state.dart';
import '../../buy_crypto/presentation/buy_crypto_flow.dart';
import '../../crypto/presentation/crypto_full_flow.dart';
import '../../gift_cards/presentation/gift_card_flow.dart';
import '../../profile_settings/presentation/profile_settings_flow.dart';
import '../../profile_settings/presentation/verification/verification_overview_screen.dart';

part 'components/dashboard_panels.dart';
part 'components/portfolio_panels.dart';
part 'components/deposit_screens.dart';

class DavochainDashboardScreen extends StatelessWidget {
  const DavochainDashboardScreen({super.key, this.onRefresh});
  final Future<void> Function()? onRefresh;
  @override
  Widget build(BuildContext context) => DavoMainShell(onRefresh: onRefresh);
}

class DavoDashboardContent extends StatefulWidget {
  const DavoDashboardContent({super.key, this.onRefresh});
  final Future<void> Function()? onRefresh;

  @override
  State<DavoDashboardContent> createState() => _DavochainDashboardScreenState();
}

class _DavochainDashboardScreenState extends State<DavoDashboardContent> {
  bool _balanceVisible = true;
  @override
  Widget build(BuildContext context) => AccountConsumer(
    builder: (context, ref) {
      ref.watch(currentWalletProvider);
      return _buildDashboard(context);
    },
  );
  Widget _buildDashboard(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: DavoColors.of(context).surface,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: DavoColors.of(context).canvas,
        body: DavoFloatingRefresh(
          onRefresh: () async {
            await (widget.onRefresh?.call() ??
                DavoRefreshScope.refresh(context, DavoRefreshTarget.dashboard));
            if (mounted) setState(() {});
          },
          child: SafeArea(
            bottom: false,
            child: DavoValueListenableBuilder<bool>(
              valueListenable: PreviewAccountState.setupComplete,
              builder: (context, setupComplete, _) => LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;
                  final gap = compact
                      ? 6.0
                      : constraints.maxHeight < 790
                      ? 12.0
                      : 16.0;
                  final header = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Entrance(index: 0, child: _DashboardHeader()),
                      SizedBox(height: gap),
                      _Entrance(
                        index: 1,
                        child: _BalanceCard(
                          compact: compact,
                          visible: _balanceVisible,
                          onVisibilityToggle: () => setState(
                            () => _balanceVisible = !_balanceVisible,
                          ),
                          onDeposit: _openWalletSelector,
                          onWithdraw: () => startWithdrawFlow(context),
                        ),
                      ),
                      SizedBox(height: gap),
                      if (!setupComplete) ...[
                        _Entrance(
                          index: 2,
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                              AppPageRoute<void>(
                                settings: const RouteSettings(
                                  name: 'verification',
                                ),
                                builder: (_) =>
                                    const VerificationOverviewScreen(),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: _SetupBanner(compact: compact),
                          ),
                        ),
                        SizedBox(height: gap),
                      ],
                      _Entrance(
                        index: 3,
                        child: _QuickActions(
                          compact: compact,
                          onBuy: () => startBuyCryptoFlow(context),
                          onSell: () => startSellCryptoFlow(context),
                          onGift: () => startGiftCardFlow(context),
                          onHistory: () => Navigator.of(
                            context,
                          ).push(_davoRoute(const TransactionHistoryScreen())),
                        ),
                      ),
                      SizedBox(height: gap),
                      _Entrance(
                        index: 4,
                        child: _PromoBanner(compact: compact),
                      ),
                      SizedBox(height: gap),
                      _assetsHeading(compact: compact),
                      SizedBox(height: compact ? 4 : 8),
                    ],
                  );
                  // Standard phones retain three complete assets below the compact carousel.
                  // Short views and enlarged text keep every control reachable by scrolling.
                  final needsFullScroll =
                      constraints.maxHeight < 660 ||
                      constraints.maxWidth < 350 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18;
                  if (needsFullScroll) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        children: [
                          header,
                          SizedBox(
                            height: setupComplete ? 320 : 240,
                            child: _DashboardAssetCard(
                              rowHeight:
                                  MediaQuery.textScalerOf(context).scale(14) >
                                      18
                                  ? 112
                                  : 72,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, compact ? 12 : 16, 16, 0),
                    child: Column(
                      children: [
                        header,
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, space) {
                              final visibleRows = setupComplete ? 4 : 3;
                              final rowHeight =
                                  ((space.maxHeight - 8) / visibleRows).clamp(
                                    48.0,
                                    72.0,
                                  );
                              final windowHeight = (8 + rowHeight * visibleRows)
                                  .clamp(0.0, space.maxHeight);
                              return Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  height: windowHeight,
                                  child: _DashboardAssetCard(
                                    rowHeight: rowHeight,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _assetsHeading({bool compact = false}) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: compact ? 36 : 40),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Assets',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DavoColors.of(context).ink,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).push(_davoRoute(const PortfolioScreen())),
            style: TextButton.styleFrom(
              foregroundColor: DavoColors.of(context).link,
              textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12),
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text('View Portfolio', textAlign: TextAlign.right),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _openWalletSelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle:
          (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const WalletPickerSheet(),
    );
    if (!mounted || selected == null) return;
    if (selected == 'NGN') {
      Navigator.of(context).push(_davoRoute(const NairaDepositScreen()));
    } else {
      Navigator.of(context).push(
        _davoRoute(
          CryptoDepositScreen(
            asset: CryptoAsset.values.firstWhere(
              (asset) => asset.symbol == selected,
            ),
          ),
        ),
      );
    }
  }
}

AppPageRoute<T> _davoRoute<T>(Widget child) {
  return AppPageRoute<T>(builder: (_) => child);
}
