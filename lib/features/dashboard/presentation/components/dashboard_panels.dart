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
    return DavoListenableBuilder(
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
                              Text(
                                  visible
                                      ? WalletAccountState.instance.snapshot
                                              .usdEquivalentLabel(
                                                  WalletAccountState.instance
                                                      .ngnAvailableMinorUnits) ??
                                          'NGN wallet'
                                      : 'Balance hidden',
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
                bg: const Color(0xFFD9F8E9),
                fg: const Color(0xFF0BB56B),
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
                    child: glyph == DavoActionGlyph.buy
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                color: Color(0xFFFF9B0B),
                                shape: BoxShape.circle),
                            child: const Center(
                                child: DavoActionIcon(DavoActionGlyph.buy,
                                    color: Colors.white, size: 24)))
                        : DavoActionIcon(glyph, color: fg, size: 22),
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
    if (!_active || DavoMotionPolicy.reduce(context)) return;
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
    return SizedBox(
        key: const ValueKey('dashboard-feature-carousel'),
        height: large
            ? 120 + MediaQuery.textScalerOf(context).scale(180)
            : widget.compact
                ? 106
                : 121,
        child: Stack(children: [
          Positioned.fill(
              child: Listener(
                  onPointerDown: (_) => _schedule(),
                  child: PageView.builder(
                      controller: _pages,
                      onPageChanged: (index) =>
                          setState(() => _page = index % 3),
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
          Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: IgnorePointer(
                  child: Center(
                      child: Semantics(
                          label: 'Featured banner ${_page + 1} of 3',
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .94),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var i = 0; i < 3; i++)
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: Container(
                                              width: _page == i ? 14 : 4,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                  color: _page == i
                                                      ? AppColors.primary
                                                      : const Color(0xFFA7B5D3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3)))),
                                  ])))))),
        ]));
  }
}

class _FeaturePromoSlide extends StatelessWidget {
  const _FeaturePromoSlide({required this.portfolio, required this.compact});
  final bool portfolio, compact;
  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(14) > 18;
    final ink = portfolio ? Colors.white : const Color(0xFF152A56);
    final copy = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              portfolio
                  ? 'Your portfolio,\nat a glance'
                  : 'Refer & Earn \u20a65,000',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: ink)),
          const SizedBox(height: 5),
          Text(
              portfolio
                  ? 'Track your holdings and allocation in one place.'
                  : 'Get \u20a6500 for every friend who trades.',
              style: TextStyle(
                  fontSize: 10,
                  height: 1.3,
                  color: portfolio
                      ? const Color(0xFFE1E9FF)
                      : const Color(0xFF304467))),
          const SizedBox(height: 6),
          Text(portfolio ? 'View portfolio \u2192' : 'Invite a friend \u2192',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: ink)),
        ]);
    final art = portfolio
        ? SizedBox(
            width: 92,
            height: 80,
            child: Stack(children: [
              Positioned(
                  left: 4,
                  top: 0,
                  child: Transform.rotate(
                      angle: -.13,
                      child: Container(
                          width: 73,
                          height: 52,
                          decoration: BoxDecoration(
                              color: const Color(0xFFB8CBFF),
                              borderRadius: BorderRadius.circular(9))))),
              Positioned(
                  left: 0,
                  top: 11,
                  child: Container(
                      width: 84,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: SvgPicture.asset(
                          'assets/figma_exact/davo_wallet.svg',
                          width: 52,
                          height: 52,
                          colorFilter: const ColorFilter.mode(
                              Color(0xFF1F4FBC), BlendMode.srcIn)))),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: Image.asset('assets/figma_exact/btc.png',
                      width: 35,
                      height: 35,
                      filterQuality: FilterQuality.high)),
            ]))
        : const DavoCelebrationEmoji();
    return Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: portfolio
                    ? const [Color(0xFF112650), Color(0xFF2357BA)]
                    : const [Color(0xFFFFF6E4), Color(0xFFFFE5AB)])),
        child: large
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                copy,
                const SizedBox(height: 16),
                Center(child: art)
              ])
            : Row(children: [
                Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                        builder: (context, space) => FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child:
                                SizedBox(width: space.maxWidth, child: copy)))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: Center(child: art))
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
                ...BuyCryptoAsset.values.where((asset) =>
                    !['BTC', 'ETH', 'SOL', 'USDT', 'USDC'].contains(asset.symbol) &&
                    WalletAccountState.instance.snapshot.assets.contains(asset.symbol) &&
                    WalletAccountState.instance.snapshot.available(asset.symbol).atomicUnits > BigInt.zero)
                    .map((asset) => _PortfolioHoldingTile(asset: asset, visible: true)),
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
      required this.change});

  final double rowHeight;
  final CryptoAsset asset;
  final String amount;
  final String value;
  final String change;
  bool get chevron => false;

  @override
  Widget build(BuildContext context) {
    final displayChange =
        WalletAccountState.instance.simulationEnabled ? '' : change;
    final positive = displayChange.startsWith('+');
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
                if (displayChange.isNotEmpty)
                  Text(displayChange,
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
              if (displayChange.isNotEmpty) const SizedBox(height: 2),
              if (displayChange.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: positive
                        ? DavoColors.of(context).elevated
                        : DavoColors.of(context).primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    displayChange,
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
