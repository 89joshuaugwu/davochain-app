import '../../features/notifications/notification_permission_panel.dart';
import 'package:flutter/material.dart';
import 'davo_action_icon.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../motion/davo_motion_policy.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/buy_crypto/presentation/buy_crypto_screens.dart';
import '../../features/buy_crypto/presentation/buy_crypto_models.dart';
import '../../features/crypto/presentation/crypto_full_flow.dart';
import '../../features/gift_cards/presentation/gift_card_flow.dart';
import '../../features/profile_settings/presentation/profile_settings_flow.dart';

/// Main destinations share one navigation bar. Detail routes cover this shell.
Future<void> selectDavoMainTab(BuildContext context, int index,
    {GiftCardMode? giftMode}) async {
  final scope = context.findAncestorWidgetOfExactType<_MainTabScope>();
  if (scope != null) {
    scope.select(index, giftMode);
    return;
  }
  await Navigator.of(context).push<void>(AppPageRoute<void>(
      builder: (_) => DavoMainShell(initialIndex: index, giftMode: giftMode)));
}

class DavoMainShell extends StatefulWidget {
  const DavoMainShell(
      {super.key, this.initialIndex = 0, this.onRefresh, this.giftMode});
  final int initialIndex;
  final Future<void> Function()? onRefresh;
  final GiftCardMode? giftMode;
  @override
  State<DavoMainShell> createState() => _DavoMainShellState();
}

class _DavoMainShellState extends State<DavoMainShell>
    with SingleTickerProviderStateMixin {
  late int _index;
  final Map<int, Widget> _pages = {};
  late final _transition = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 180), value: 1);
  void _animateSelection() {
    if (DavoMotionPolicy.reduce(context)) {
      _transition.value = 1;
    } else {
      _transition.forward(from: .65);
    }
  }

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialIndex == 0) {
        NotificationInvitation.maybeShow(context);
      }
    });
  }

  void _select(int index) {
    if (_index == index || index < 0 || index > 3) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = index);
    _animateSelection();
  }

  void _selectDestination(int index, GiftCardMode? giftMode) {
    if (giftMode != null) {
      setState(() => _pages[2] = GiftCardHomeScreen(
          key: UniqueKey(), initialMode: giftMode, onBack: () => _select(0)));
    }
    _select(index);
  }

  void _selectTradeMode(int mode, BuyCryptoAsset asset) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _pages[1] = mode == 0
        ? BuyAmountScreen(
            key: const ValueKey('trade-buy'),
            initialOrder: BuyCryptoOrder(
                asset: asset, wallet: BuyFundingWallet.ngn, ngnAmount: 0),
            onBack: () => _select(0),
            onModeSelected: _selectTradeMode)
        : TradeAmountScreen(
            key: ValueKey('trade-$mode'),
            mode: mode == 1 ? TradeMode.sell : TradeMode.convert,
            asset: asset,
            onBack: () => _select(0),
            onModeSelected: _selectTradeMode));
    _animateSelection();
  }

  Widget _page(int index) => _pages.putIfAbsent(
      index,
      () => switch (index) {
            0 => DavoDashboardContent(onRefresh: widget.onRefresh),
            1 => BuyAmountScreen(
                initialOrder: const BuyCryptoOrder(
                    asset: BuyCryptoAsset.bitcoin,
                    wallet: BuyFundingWallet.ngn,
                    ngnAmount: 0),
                onBack: () => _select(0),
                onModeSelected: _selectTradeMode),
            2 => GiftCardHomeScreen(
                initialMode: widget.giftMode ?? GiftCardMode.buy,
                onBack: () => _select(0)),
            _ => ProfileSettingsScreen(onBack: () => _select(0)),
          });
  @override
  Widget build(BuildContext context) {
    _page(_index);
    return _MainTabScope(
        select: _selectDestination,
        child: PopScope(
          canPop: _index == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _select(0);
          },
          child: Scaffold(
            backgroundColor: DavoColors.of(context).canvas,
            body: FadeTransition(
              opacity: _transition,
              child: IndexedStack(
                  index: _index,
                  children: List.generate(
                      4,
                      (index) => TickerMode(
                          enabled: index == _index,
                          child: _pages[index] ?? const SizedBox.shrink()))),
            ),
            bottomNavigationBar:
                DavoMainNavigation(index: _index, onChanged: _select),
          ),
        ));
  }
}

class _MainTabScope extends InheritedWidget {
  const _MainTabScope({required this.select, required super.child});
  final void Function(int, GiftCardMode?) select;
  @override
  bool updateShouldNotify(_MainTabScope oldWidget) => false;
}

class DavoMainNavigation extends StatelessWidget {
  const DavoMainNavigation(
      {super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;
  static const labels = ['Home', 'Trade', 'Gift Cards', 'Settings'];
  static const glyphs = [
    DavoActionGlyph.home,
    DavoActionGlyph.trade,
    DavoActionGlyph.gift,
    DavoActionGlyph.settings
  ];
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            border:
                Border(top: BorderSide(color: DavoColors.of(context).divider))),
        child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72 +
                  (MediaQuery.textScalerOf(context).scale(10) - 10)
                          .clamp(0, 30) *
                      2.8,
              child: Row(
                  children: List.generate(4, (item) {
                final selected = item == index;
                final color = selected
                    ? DavoColors.of(context).link
                    : DavoColors.of(context).bodyMuted;
                return Expanded(
                    child: Semantics(
                  selected: selected,
                  button: true,
                  label: '${labels[item]} tab',
                  excludeSemantics: true,
                  onTap: () => onChanged(item),
                  child: InkWell(
                      key: ValueKey('main-tab-$item'),
                      onTap: () => onChanged(item),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DavoActionIcon(glyphs[item],
                                size: 24, color: color),
                            const SizedBox(height: 5),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(labels[item],
                                        maxLines: 1,
                                        softWrap: false,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 10,
                                            height: 1.1,
                                            fontWeight: FontWeight.w500,
                                            color: color)))),
                          ])),
                ));
              })),
            )),
      );
}
