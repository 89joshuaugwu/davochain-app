part of '../dashboard_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _visible = true;
  String _assetQuery = '';

  @override
  Widget build(BuildContext context) => AccountConsumer(
    builder: (context, ref) {
      ref.watch(currentWalletProvider);
      return DavoRefreshRegion(
        target: DavoRefreshTarget.portfolio,
        builder: _buildPortfolio,
      );
    },
  );
  Widget _buildPortfolio(BuildContext context) {
    final searchHeight =
        24 +
        (MediaQuery.textScalerOf(context).scale(20) + 28).clamp(52.0, 120.0);
    final minimumListHeight =
        (MediaQuery.sizeOf(context).height -
                MediaQuery.paddingOf(context).vertical -
                MediaQuery.viewInsetsOf(context).bottom -
                searchHeight)
            .clamp(0.0, double.infinity);
    return Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final heading = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Portfolio',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: DavoColors.of(context).ink,
                              ),
                            ),
                            Text(
                              'Your wallet holdings',
                              style: TextStyle(
                                fontSize: 12,
                                color: DavoColors.of(context).body,
                              ),
                            ),
                          ],
                        );
                        final separateHeading =
                            constraints.maxWidth /
                                (MediaQuery.textScalerOf(context).scale(18) /
                                    18) <
                            260;
                        final controls = Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 7),
                            if (separateHeading)
                              const Spacer()
                            else
                              Expanded(child: heading),
                            _RoundIconButton(
                              icon: _visible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              tooltip: _visible
                                  ? 'Hide portfolio balance'
                                  : 'Show portfolio balance',
                              onTap: () => setState(() => _visible = !_visible),
                            ),
                            const SizedBox(width: 4),
                            _RoundIconButton(
                              tooltip: 'Portfolio performance',
                              icon: Icons.show_chart_rounded,
                              onTap: () => Navigator.of(context).push(
                                _davoRoute<void>(
                                  PortfolioPerformanceScreen(
                                    initialValueVisible: _visible,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                        return separateHeading
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  controls,
                                  const SizedBox(height: 8),
                                  heading,
                                ],
                              )
                            : controls;
                      },
                    ),
                    const SizedBox(height: 16),
                    _PortfolioValueCard(visible: _visible),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 2 ? 0 : 16,
                            ),
                            child: Material(
                              color: DavoColors.of(context).primarySoft,
                              borderRadius: BorderRadius.circular(6),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    _davoRoute<void>(
                                      index == 0
                                          ? const BuyAmountScreen(
                                              initialOrder: BuyCryptoOrder(
                                                asset: BuyCryptoAsset.bitcoin,
                                                wallet: BuyFundingWallet.ngn,
                                                ngnAmount: 0,
                                              ),
                                            )
                                          : TradeAmountScreen(
                                              mode: index == 1
                                                  ? TradeMode.sell
                                                  : TradeMode.convert,
                                              asset: BuyCryptoAsset.bitcoin,
                                            ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Text(
                                      ['Buy', 'Sell', 'Swap'][index],
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: DavoColors.of(context).body,
                                      ),
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
                    _visible
                        ? const _AllocationCard()
                        : const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Allocation hidden'),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Assets',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PortfolioSearchHeader(
                height: searchHeight,
                child: Material(
                  color: DavoColors.of(context).canvas,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      key: const ValueKey('portfolio-asset-search'),
                      decoration: const InputDecoration(
                        hintText: 'Search assets',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (value) => setState(() => _assetQuery = value),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumListHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Builder(
                    builder: (context) {
                      final wallet = WalletAccountState.instance;
                      final assets = orderedCryptoAssets(
                        wallet.snapshot,
                        query: _assetQuery,
                      );
                      if (assets.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 32,
                                color: DavoColors.of(context).link,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No matching assets',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try a different name or symbol.',
                                style: TextStyle(
                                  color: DavoColors.of(context).bodyMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final asset in assets)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _PortfolioHoldingTile(
                                asset: asset,
                                visible: _visible,
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
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onTap,
    style: IconButton.styleFrom(
      backgroundColor: DavoColors.of(context).primarySoft,
      minimumSize: const Size(48, 48),
    ),
    icon: icon == Icons.visibility_outlined
        ? SvgPicture.asset(
            'assets/figma_exact/davo_eye.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              DavoColors.of(context).link,
              BlendMode.srcIn,
            ),
          )
        : icon == Icons.show_chart_rounded
        ? SvgPicture.asset(
            'assets/figma_exact/davo_performance.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              DavoColors.of(context).link,
              BlendMode.srcIn,
            ),
          )
        : Icon(
            icon,
            size: 20,
            applyTextScaling: false,
            color: DavoColors.of(context).link,
          ),
  );
}

class _PortfolioValueCard extends StatefulWidget {
  const _PortfolioValueCard({required this.visible});
  final bool visible;
  @override
  State<_PortfolioValueCard> createState() => _PortfolioValueCardState();
}

class _PortfolioValueCardState extends State<_PortfolioValueCard> {
  bool _updating = false;
  bool _updated = false;

  Future<void> _refresh() async {
    if (_updating) return;
    setState(() {
      _updating = true;
      _updated = false;
    });
    try {
      await DavoRefreshScope.refresh(context, DavoRefreshTarget.portfolio);
      if (mounted) setState(() => _updated = true);
    } catch (_) {
      if (mounted) {
        showDavoToast(context, 'Could not refresh. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = WalletAccountState.instance;
    final valuation = WalletValuation.forPortfolio(
      wallet.snapshot,
      quote: wallet.activeQuote,
    );
    final canRefresh =
        context.dependOnInheritedWidgetOfExactType<DavoRefreshScope>() != null;
    final status = _updating
        ? 'Updating'
        : _updated
        ? 'Updated'
        : 'Live Sync';
    return DavoBlueBalanceCard(
      label: 'Total Portfolio Value',
      artBottom: -21,
      amount: !widget.visible
          ? '\u2022\u2022\u2022\u2022'
          : !valuation.available
          ? 'Value unavailable'
          : valuation.usdLabel?.replaceFirst('\u2248 ', '') ??
                valuation.nairaLabel,
      caption: !widget.visible
          ? 'Balance hidden'
          : !valuation.available
          ? 'A price is unavailable. Pull down to refresh.'
          : valuation.usdLabel == null
          ? 'USD estimate unavailable'
          : '\u2248 ${valuation.nairaLabel}',
      trailing: WalletAccountState.instance.simulationEnabled
          ? null
          : canRefresh
          ? Semantics(
              liveRegion: true,
              child: Tooltip(
                message: 'Refresh portfolio',
                child: TextButton(
                  onPressed: _updating ? null : _refresh,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor: AppColors.primary,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, size: 12),
                        const SizedBox(width: 3),
                        Text(status, style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(
              height: 48,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 5, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Live Sync',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard();
  static const colors = [
    Color(0xFFF7931A),
    Color(0xFF647CEA),
    Color(0xFF009D98),
    Color(0xFF22C55E),
    Color(0xFF2775CA),
  ];
  static const names = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'SOL': 'Solana',
    'USDT': 'Tether',
    'USDC': 'USD Coin',
    'XRP': 'XRP',
    'ADA': 'Cardano',
    'DOGE': 'Dogecoin',
    'LTC': 'Litecoin',
    'BNB': 'BNB',
  };
  @override
  Widget build(BuildContext context) => DavoListenableBuilder(
    listenable: WalletAccountState.instance,
    builder: (context, _) {
      final state = WalletAccountState.instance;
      final assets = state.snapshot.assets
          .where(
            (asset) =>
                asset != 'NGN' &&
                asset != 'NGD' &&
                (!state.simulationEnabled ||
                    state.snapshot.available(asset).atomicUnits > BigInt.zero),
          )
          .toList();
      final valuation = WalletValuation.forPortfolio(
        state.snapshot,
        quote: state.activeQuote,
      );
      if (!valuation.available) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Allocation unavailable until prices refresh.'),
        );
      }
      final total = valuation.nairaMinorUnits;
      final large = MediaQuery.textScalerOf(context).scale(12) > 18;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DavoColors.of(context).surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Asset Allocation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DavoColors.of(context).ink,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DavoColors.of(context).primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${assets.length} Coins',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(assets.length, (index) {
                      final value = state.snapshot.valuationMinorUnits(
                        assets[index],
                      );
                      return value <= 0
                          ? const SizedBox()
                          : Expanded(
                              flex: value,
                              child: ColoredBox(
                                color: colors[index % colors.length],
                              ),
                            );
                    }),
                  ),
                ),
              ),
            if (assets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Your allocation will appear when you hold crypto.',
                  style: TextStyle(color: DavoColors.of(context).bodyMuted),
                ),
              ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(assets.length, (index) {
                  final asset = assets[index];
                  final value = state.snapshot.valuationMinorUnits(asset);
                  final percentage = total == 0
                      ? '0.0%'
                      : '${(value * 100 / total).toStringAsFixed(1)}%';
                  return SizedBox(
                    width: large
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 10) / 2,
                    child: Semantics(
                      label: '${names[asset] ?? asset}, $percentage',
                      excludeSemantics: true,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DavoColors.of(context).primarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    names[asset] ?? asset,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    percentage,
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --- Deposit flow --------------------------------------------------------------

enum CryptoAsset {
  bitcoin('Bitcoin', 'BTC', '₿', Color(0xFFF7931A)),
  ethereum('Ethereum', 'ETH', '◆', Color(0xFF627EEA)),
  solana('Solana', 'SOL', '≋', AppColors.ink),
  usdCoin('USD Coin', 'USDC', r'$', Color(0xFF2775CA)),
  tether('Tether', 'USDT', '₮', Color(0xFF009393)),
  xrp('XRP', 'XRP', '', Color(0xFF23292F)),
  cardano('Cardano', 'ADA', '', Color(0xFF0033AD)),
  dogecoin('Dogecoin', 'DOGE', '', Color(0xFFC2A633)),
  litecoin('Litecoin', 'LTC', '', Color(0xFF345D9D)),
  bnb('BNB', 'BNB', '', Color(0xFFF3BA2F));

  const CryptoAsset(this.name, this.symbol, this.glyph, this.color);
  final String name;
  final String symbol;
  final String glyph;
  final Color color;
}

class _CryptoIcon extends StatelessWidget {
  const _CryptoIcon({required this.asset, this.size = 37});
  final CryptoAsset asset;
  final double size;
  @override
  Widget build(BuildContext context) => BuyAssetIcon(
    asset: BuyCryptoAsset.values.firstWhere((a) => a.symbol == asset.symbol),
    size: size,
  );
}

class _PortfolioHoldingTile extends StatelessWidget {
  const _PortfolioHoldingTile({
    required this.asset,
    required this.visible,
    this.compact = false,
  });
  final BuyCryptoAsset asset;
  final bool visible;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final wallet = WalletAccountState.instance;
    return Material(
      color: DavoColors.of(context).surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: compact
              ? const EdgeInsets.symmetric(vertical: 4)
              : const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < (compact ? 230 : 300) ||
                  MediaQuery.textScalerOf(context).scale(14) > 19;
              final name = Row(
                children: [
                  BuyAssetIcon(asset: asset, size: 37),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          maxLines: compact && !stacked ? 1 : null,
                          overflow: compact && !stacked
                              ? TextOverflow.ellipsis
                              : null,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          visible
                              ? '${wallet.snapshot.assets.contains(asset.symbol) ? wallet.snapshot.available(asset.symbol).decimal : '0'} ${asset.symbol}'
                              : 'Hidden',
                          style: TextStyle(
                            fontSize: 12,
                            color: DavoColors.of(context).bodyMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final values = _AssetValue(
                asset: asset,
                visible: visible,
                compact: compact,
              );
              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        name,
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerRight, child: values),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: name),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: values,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    );
            },
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            AppPageRoute<void>(
              builder: (_) => CryptoDepositScreen(
                asset: CryptoAsset.values.firstWhere(
                  (a) => a.symbol == asset.symbol,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One USD valuation beside the crypto quantity; cash branding stays on cash.
class _AssetValue extends StatelessWidget {
  const _AssetValue({
    required this.asset,
    required this.visible,
    this.compact = false,
  });
  final BuyCryptoAsset asset;
  final bool visible;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final wallet = WalletAccountState.instance;
    final quoted =
        wallet.snapshot.assets.contains(asset.symbol) &&
        wallet.snapshot.priceMinorUnits(asset.symbol) != null;
    final value = quoted
        ? WalletValuation.forAsset(
            wallet.snapshot,
            asset.symbol,
            quote: wallet.activeQuote,
          )
        : null;
    final usd = value?.usdLabel?.replaceFirst('\u2248 ', '');
    return Text(
      !visible ? 'Hidden' : usd ?? 'Value unavailable',
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}

class _PortfolioSearchHeader extends SliverPersistentHeaderDelegate {
  _PortfolioSearchHeader({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: height, child: child);
  @override
  bool shouldRebuild(covariant _PortfolioSearchHeader oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}
