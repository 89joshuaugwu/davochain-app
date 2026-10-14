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
                              const Text('Available Balance',
                                  style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 10,
                                      color: Colors.white)),
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
                        SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                                child: DavoActionIcon(
                                    visible
                                        ? DavoActionGlyph.visible
                                        : DavoActionGlyph.hidden,
                                    color: Colors.white,
                                    size: 20))),
                      ]))),
              if (largeText) const SizedBox(height: 16) else const Spacer(),
              Row(children: [
                Expanded(
                    child: _BalanceActionButton(
                        compact: compact,
                        light: true,
                        glyph: DavoActionGlyph.deposit,
                        label: 'Deposit',
                        onTap: onDeposit)),
                const SizedBox(width: 16),
                Expanded(
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
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DavoActionIcon(glyph,
                  size: 20,
                  color: light ? DavoColors.of(context).link : Colors.white),
              const SizedBox(width: 12),
              Flexible(
                  child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: light ? DavoColors.of(context).link : Colors.white,
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
            maxLines: 2,
            style: TextStyle(
                fontFamily: 'Sora',
                fontSize: compact ? 14 : 16,
                color: DavoColors.of(context).link,
                letterSpacing: -.16),
          )),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 18,
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
                glyph: DavoActionGlyph.gift,
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.textScalerOf(context).scale(14) > 18) {
      return Container(
        key: const ValueKey('dashboard-promo'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DavoColors.of(context).primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Turn your Crypto and\nGift Cards into cash\ninstantly',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: DavoColors.of(context).link)),
            const SizedBox(height: 8),
            Text(
                'Trade top crypto and gift card at good rates with fast payment.',
                style: TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    color: DavoColors.of(context).body)),
          ],
        ),
      );
    }
    return Container(
      key: const ValueKey('dashboard-promo'),
      height: compact ? 106 : 121,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: DavoColors.of(context).primarySoft,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            bottom: 0,
            width: compact ? 120 : 137,
            height: compact ? 78 : 87,
            child: Image.asset(
              'assets/figma_exact/promo_crypto.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: compact ? 12 : 16,
            top: compact ? 6 : 10,
            width: 174,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn your Crypto and\nGift Cards into cash\ninstantly',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: DavoColors.of(context).link),
                ),
                const SizedBox(height: 5),
                Text(
                  'Trade top crypto and gift card at good rates with fast payment.',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      height: 1.25,
                      color: DavoColors.of(context).body),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              height: compact ? 22 : 24,
              padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100)),
              alignment: Alignment.center,
              child: const Text(
                'Fast • Secure • Reliable',
                style: TextStyle(
                    fontFamily: 'Sora', fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
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
