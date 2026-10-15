part of '../dashboard_screen.dart';

class _Entrance extends StatelessWidget {
  const _Entrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => Entrance(
        delay: Duration(milliseconds: (index.clamp(0, 3)) * 40),
        duration: const Duration(milliseconds: 280),
        offset: const Offset(0, .025),
        child: child,
      );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: LocalPreviewProfile.instance,
        builder: (context, _) => Row(
              children: [
                InkWell(
                  onTap: () => startProfileSettingsFlow(context),
                  customBorder: const CircleBorder(),
                  child: Semantics(
                      label: 'Open profile',
                      button: true,
                      child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                              child: LocalProfileAvatar(
                                  size: 40, showBadge: false)))),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome,',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: DavoColors.of(context).muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocalPreviewProfile.instance.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).body,
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.of(context)
                      .push(_davoRoute(const ReferralDashboardScreen())),
                  borderRadius: BorderRadius.circular(1000),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: DavoColors.of(context).isDark
                          ? DavoColors.of(context).primarySoft
                          : const Color(0x80D0DEFD),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: Row(
                      children: [
                        DavoActionIcon(DavoActionGlyph.gift,
                            color: DavoColors.of(context).link, size: 20),
                        if (MediaQuery.textScalerOf(context).scale(14) <=
                            18) ...[
                          const SizedBox(width: 4),
                          Text('Earn \$5',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  color: DavoColors.of(context).link)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DavoNotificationButton(
                    onTap: () => openNotificationCenter(context)),
              ],
            ));
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(
      {this.compact = false,
      required this.visible,
      required this.onVisibilityToggle,
      required this.onDeposit,
      required this.onWithdraw});
  final bool visible;
  final bool compact;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    final stackActions = MediaQuery.sizeOf(context).width /
            (MediaQuery.textScalerOf(context).scale(14) / 14) <
        280;
    final balance = visible
        ? WalletAccountState.instance.ngnBalanceLabel
        : '\u20a6\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022';
    return Container(
      height: largeText
          ? null
          : (compact ? 156.0 : 168.0) +
              (MediaQuery.textScalerOf(context).scale(14) / 14 - 1)
                      .clamp(0, 3) *
                  70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
      child: Stack(children: [
        Positioned(
            right: 0,
            bottom: 18,
            width: 268,
            height: 104,
            child: Image.asset('assets/figma_exact/balance_wave.png',
                fit: BoxFit.fill, filterQuality: FilterQuality.high)),
        Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(18, 12, 18, 12)
                : const EdgeInsets.fromLTRB(24, 16, 24, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Semantics(
                  label:
                      'Available Balance: ${visible ? balance : 'hidden'}. ${visible ? 'Hide' : 'Show'} balance',
                  button: true,
                  toggled: visible,
                  excludeSemantics: true,
                  child: InkWell(
                      onTap: onVisibilityToggle,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Flexible(
                                    child: Text('Available Balance',
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 10,
                                            color: Colors.white))),
                                const SizedBox(width: 5),
                                DavoActionIcon(
                                    visible
                                        ? DavoActionGlyph.visible
                                        : DavoActionGlyph.hidden,
                                    color: Colors.white,
                                    size: 14)
                              ]),
                              const SizedBox(height: 4),
                              FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(balance,
                                      key: ValueKey(visible),
                                      style: const TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.2))),
                              const SizedBox(height: 2),
                              Text(visible ? 'NGN wallet' : 'Balance hidden',
                                  style: const TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 14,
                                      color: Colors.white)),
                            ])),
                      ]))),
              if (largeText) const SizedBox(height: 16) else const Spacer(),
              Flex(
                  direction: stackActions ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: stackActions
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        flex: 1,
                        fit: stackActions ? FlexFit.loose : FlexFit.tight,
                        child: _BalanceActionButton(
                            compact: compact,
                            light: true,
                            glyph: DavoActionGlyph.deposit,
                            label: 'Deposit',
                            onTap: onDeposit)),
                    const SizedBox(width: 16, height: 8),
                    Flexible(
                        flex: 1,
                        fit: stackActions ? FlexFit.loose : FlexFit.tight,
                        child: _BalanceActionButton(
                            compact: compact,
                            light: false,
                            glyph: DavoActionGlyph.withdraw,
                            label: 'Withdraw',
                            onTap: onWithdraw)),
                  ]),
            ])),
      ]),
    );
  }
}

class _BalanceActionButton extends StatelessWidget {
  const _BalanceActionButton({
    this.compact = false,
    required this.light,
    required this.glyph,
    required this.label,
    required this.onTap,
  });

  final bool light;
  final bool compact;
  final DavoActionGlyph glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: light ? DavoColors.of(context).fieldFill : const Color(0xFF104DCE),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DavoActionIcon(glyph,
                      size: 20,
                      color:
                          light ? DavoColors.of(context).link : Colors.white),
                  const SizedBox(width: 12),
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: light
                                  ? DavoColors.of(context).link
                                  : Colors.white,
                            ),
                          ))),
                ],
              )),
        ),
      ),
    );
  }
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 50 : 58),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: DavoColors.of(context).primarySoft,
        border: Border.all(color: const Color(0xFF6292FA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(
            'Complete basic verification',
            style: TextStyle(
                fontFamily: 'Sora',
                fontSize: compact ? 14 : 16,
                color: DavoColors.of(context).link,
                letterSpacing: -.16),
          )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'Basic',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions(
      {required this.onBuy,
      required this.onSell,
      required this.onGift,
      required this.onHistory,
      this.compact = false});
  final bool compact;

  final VoidCallback onBuy;
  final VoidCallback onSell;
  final VoidCallback onGift;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _QuickAction(
                compact: compact,
                label: 'Buy Crypto',
                glyph: DavoActionGlyph.buy,
                bg: DavoColors.of(context).warningSurface,
                fg: const Color(0xFFFD9915),
                onTap: onBuy)),
        const SizedBox(width: 16),
        Expanded(
            child: _QuickAction(
                compact: compact,
                label: 'Sell Crypto',
                glyph: DavoActionGlyph.sell,
                bg: DavoColors.of(context).elevated,
                fg: DavoColors.of(context).success,
                onTap: onSell)),
        const SizedBox(width: 16),
        Expanded(
            child: _QuickAction(
                compact: compact,
                label: 'Gift Card',
                glyph: DavoActionGlyph.giftAction,
                bg: const Color(0xFFE9DEFD),
                fg: const Color(0xFF8247E5),
                onTap: onGift)),
        const SizedBox(width: 16),
        Expanded(
            child: _QuickAction(
                compact: compact,
                label: 'History',
                glyph: DavoActionGlyph.history,
                bg: DavoColors.of(context).primarySoft,
                fg: AppColors.primary,
                onTap: onHistory)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    this.compact = false,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    required this.glyph,
  });

  final String label;
  final bool compact;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final DavoActionGlyph glyph;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DavoColors.of(context).surface,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: compact ? 72 : 81),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 32 : 36,
                    height: compact ? 32 : 36,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: bg, shape: BoxShape.circle),
                    child: DavoActionIcon(glyph, color: fg, size: 22),
                  ),
                  SizedBox(height: compact ? 4 : 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: DavoColors.of(context).ink),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatefulWidget {
  const _PromoBanner({this.compact = false});
  final bool compact;
  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner>
    with WidgetsBindingObserver {
  final _pages = PageController(initialPage: 300);
  Timer? _timer;
  int _page = 0;
  bool _paused = false;
  bool _active = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (_paused || !_active || DavoMotionPolicy.reduce(context)) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted ||
          !_pages.hasClients ||
          !TickerMode.valuesOf(context).enabled ||
          !(ModalRoute.of(context)?.isCurrent ?? true) ||
          _pages.position.isScrollingNotifier.value) {
        return;
      }
      _pages.animateToPage((_pages.page ?? 300).round() + 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pages.dispose();
    super.dispose();
  }

  void _open(int slide) {
    if (slide == 0) {
      startSellCryptoFlow(context);
      return;
    }
    Navigator.of(context).push(_davoRoute<void>(slide == 1
        ? const PortfolioScreen()
        : const ReferralDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(14) > 18;
    return Column(children: [
      SizedBox(
          height: large
              ? 120 + MediaQuery.textScalerOf(context).scale(180)
              : widget.compact
                  ? 152
                  : 160,
          child: Listener(
              onPointerDown: (_) => _schedule(),
              child: PageView.builder(
                  controller: _pages,
                  onPageChanged: (index) => setState(() => _page = index % 3),
                  itemBuilder: (context, index) {
                    final slide = index % 3;
                    final content = slide == 0
                        ? _TradingPromoSlide(compact: widget.compact)
                        : _FeaturePromoSlide(
                            portfolio: slide == 1, compact: widget.compact);
                    return Semantics(
                        label: 'Featured ${slide + 1} of 3',
                        button: true,
                        child: InkWell(
                            onTap: () => _open(slide),
                            borderRadius: BorderRadius.circular(12),
                            child: large
                                ? SingleChildScrollView(child: content)
                                : content));
                  }))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < 3; i++)
          IconButton(
              tooltip: 'Show featured banner ${i + 1}',
              onPressed: () {
                _schedule();
                final current = (_pages.page ?? 300).round();
                final target = current - current % 3 + i;
                if (DavoMotionPolicy.reduce(context)) {
                  _pages.jumpToPage(target);
                } else {
                  _pages.animateToPage(target,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic);
                }
              },
              icon: Container(
                  width: _page == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: _page == i
                          ? DavoColors.of(context).link
                          : DavoColors.of(context)
                              .bodyMuted
                              .withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(4)))),
        if (!DavoMotionPolicy.reduce(context))
          IconButton(
              tooltip:
                  _paused ? 'Play featured banners' : 'Pause featured banners',
              onPressed: () {
                setState(() => _paused = !_paused);
                _schedule();
              },
              icon: Icon(
                  _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 16)),
      ]),
    ]);
  }
}

class _FeaturePromoSlide extends StatelessWidget {
  const _FeaturePromoSlide({required this.portfolio, required this.compact});
  final bool portfolio, compact;
  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(14) > 18;
    final text = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              portfolio
                  ? 'Your crypto.\nOne clear view.'
                  : 'Refer & Earn \u20a65,000',
              style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  color: portfolio ? const Color(0xFF183D65) : Colors.white,
                  height: 1.3)),
          const SizedBox(height: 6),
          Text(
              portfolio
                  ? 'See your holdings, allocation and portfolio value.'
                  : 'Get \u20a6500 for every friend who trades',
              style: TextStyle(
                  fontSize: 10,
                  height: 1.35,
                  color: portfolio ? const Color(0xFF294B62) : Colors.white)),
          const SizedBox(height: 6),
          Text(portfolio ? 'View portfolio \u2192' : 'Invite a friend \u2192',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: portfolio ? const Color(0xFF183D65) : Colors.white)),
        ]);
    final art = portfolio
        ? Stack(alignment: Alignment.center, children: [
            Image.asset('assets/figma_exact/eth.png',
                width: 56, height: 56, filterQuality: FilterQuality.high),
            Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset('assets/figma_exact/btc.png',
                    width: 64, height: 64, filterQuality: FilterQuality.high)),
          ])
        : SvgPicture.asset('assets/figma_exact/referral_party.svg',
            width: 86, height: 86);
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: portfolio ? const Color(0xFFDDF4EF) : AppColors.primary),
        child: large
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                text,
                const SizedBox(height: 16),
                SizedBox(height: 100, width: 120, child: art)
              ])
            : Row(children: [
                Expanded(flex: 3, child: text),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: SizedBox(height: 90, child: art))
              ]));
  }
}

class _TradingPromoSlide extends StatelessWidget {
  const _TradingPromoSlide({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(14) > 18;
    final copy =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Turn your Crypto and\nGift Cards into cash\ninstantly',
          style: TextStyle(
              fontFamily: 'Sora',
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: DavoColors.of(context).link)),
      const SizedBox(height: 5),
      Text('Trade top crypto and gift card at good rates with fast payment.',
          style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              height: 1.25,
              color: DavoColors.of(context).body)),
    ]);
    final artwork = Image.asset('assets/figma_exact/promo_crypto.png',
        key: const ValueKey('dashboard-coins-and-cards'),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true);
    return Container(
        key: const ValueKey('dashboard-promo'),
        height: large ? null : (compact ? 106 : 121),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: DavoColors.of(context).primarySoft,
            gradient: Theme.of(context).brightness == Brightness.light
                ? const LinearGradient(
                    colors: [Color(0xFFE9F0FF), Color(0xFFD2E1FF)])
                : null,
            borderRadius: BorderRadius.circular(12)),
        child: large
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                copy,
                const SizedBox(height: 8),
                Center(child: SizedBox(height: 130, child: artwork))
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                        builder: (context, space) => FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child:
                                SizedBox(width: space.maxWidth, child: copy)))),
                const SizedBox(width: 6),
                Expanded(
                    flex: 2,
                    child: SizedBox(
                        height: compact ? 90 : 105,
                        child: Column(children: [
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Text(
                                      'Fast \u2022 Secure \u2022 Reliable',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)))),
                          const SizedBox(height: 2),
                          Expanded(
                              child: OverflowBox(
                                  maxWidth: compact ? 136 : 156,
                                  maxHeight: compact ? 136 : 156,
                                  child: SizedBox(
                                      width: compact ? 136 : 156,
                                      height: compact ? 136 : 156,
                                      child: artwork))),
                        ])))
              ]));
  }
}

class _DashboardAssetCard extends StatelessWidget {
  const _DashboardAssetCard({this.rowHeight = 56});
  final double rowHeight;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: DavoColors.of(context).surface,
          child: ShaderMask(
            key: const ValueKey('dashboard-assets-soft-edge'),
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.white],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, 10)),
            child: ListView(
              key: const ValueKey('dashboard-assets'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _AssetRow(
                    key: const ValueKey('dashboard-asset-BTC'),
                    rowHeight: rowHeight,
                    asset: CryptoAsset.bitcoin,
                    amount:
                        '${WalletAccountState.instance.snapshot.available('BTC').decimal} BTC',
                    value: WalletAccountState.instance.balanceLabel('BTC'),
                    change: '+4.21%'),
                Divider(height: 1, color: DavoColors.of(context).divider),
                _AssetRow(
                    key: const ValueKey('dashboard-asset-ETH'),
                    rowHeight: rowHeight,
                    asset: CryptoAsset.ethereum,
                    amount:
                        '${WalletAccountState.instance.snapshot.available('ETH').decimal} ETH',
                    value: WalletAccountState.instance.balanceLabel('ETH'),
                    change: '+2.18%'),
                Divider(height: 1, color: DavoColors.of(context).divider),
                _AssetRow(
                    key: const ValueKey('dashboard-asset-USDT'),
                    rowHeight: rowHeight,
                    asset: CryptoAsset.tether,
                    amount:
                        '${WalletAccountState.instance.snapshot.available('USDT').decimal} USDT',
                    value: WalletAccountState.instance.balanceLabel('USDT'),
                    change: '0.00%'),
                Divider(height: 1, color: DavoColors.of(context).divider),
                _AssetRow(
                    key: const ValueKey('dashboard-asset-USDC'),
                    rowHeight: rowHeight,
                    asset: CryptoAsset.usdCoin,
                    amount:
                        '${WalletAccountState.instance.snapshot.available('USDC').decimal} USDC',
                    value: WalletAccountState.instance.balanceLabel('USDC'),
                    change: '+0.01%'),
                Divider(height: 1, color: DavoColors.of(context).divider),
                _AssetRow(
                    key: const ValueKey('dashboard-asset-SOL'),
                    rowHeight: rowHeight,
                    asset: CryptoAsset.solana,
                    amount:
                        '${WalletAccountState.instance.snapshot.available('SOL').decimal} SOL',
                    value: WalletAccountState.instance.balanceLabel('SOL'),
                    change: '+4.21%'),
              ],
            ),
          ),
        ),
      );
}

class _AssetRow extends StatelessWidget {
  const _AssetRow(
      {super.key,
      this.rowHeight = 62,
      required this.asset,
      required this.amount,
      required this.value,
      required this.change,
      this.chevron = false});

  final double rowHeight;
  final CryptoAsset asset;
  final String amount;
  final String value;
  final String change;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final positive = change.startsWith('+');
    if (MediaQuery.textScalerOf(context).scale(14) > 18) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CryptoIcon(asset: asset, size: 37),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).ink)),
                Text(amount,
                    style: TextStyle(
                        fontSize: 12, color: DavoColors.of(context).body)),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).ink)),
                Text(change,
                    style: TextStyle(
                        fontSize: 11,
                        color: positive
                            ? DavoColors.of(context).success
                            : DavoColors.of(context).bodyMuted)),
              ],
            )),
          ],
        ),
      );
    }
    return SizedBox(
      height: rowHeight +
          (MediaQuery.textScalerOf(context).scale(14) / 14 - 1).clamp(0, 3) *
              36,
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
                    Flexible(
                        child: Text(asset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: DavoColors.of(context).ink))),
                    if (chevron) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).primarySoft,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(asset.symbol,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 9,
                                color: DavoColors.of(context).ink)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: DavoColors.of(context).body)),
              ],
            ),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DavoColors.of(context).ink)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: positive
                      ? DavoColors.of(context).elevated
                      : DavoColors.of(context).primarySoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: positive
                          ? DavoColors.of(context).success
                          : DavoColors.of(context).body),
                ),
              ),
            ],
          )),
          if (chevron)
            Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.chevron_right_rounded,
                    color: DavoColors.of(context).muted)),
        ],
      ),
    );
  }
}

// --- Portfolio ----------------------------------------------------------------
