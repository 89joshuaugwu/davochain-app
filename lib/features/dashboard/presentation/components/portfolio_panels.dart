part of '../dashboard_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WalletAccountState.instance.addListener(_walletChanged);
  }

  void _walletChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WalletAccountState.instance.removeListener(_walletChanged);
    super.dispose();
  }

  bool _visible = true;

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.portfolio, builder: _buildPortfolio);
  Widget _buildPortfolio(BuildContext context) {
    return Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Portfolio',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: DavoColors.of(context).ink)),
                        Text('Your wallet holdings',
                            style: TextStyle(
                                fontSize: 12,
                                color: DavoColors.of(context).body)),
                      ],
                    ),
                  ),
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
                      onTap: () => Navigator.of(context).push(_davoRoute<void>(
                          PortfolioPerformanceScreen(
                              initialValueVisible: _visible)))),
                ],
              ),
              const SizedBox(height: 16),
              _PortfolioValueCard(visible: _visible),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 16),
                      child: Material(
                        color: DavoColors.of(context).border,
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
                                    color: DavoColors.of(context).body),
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
              Text('Your Assets',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DavoColors.of(context).ink)),
              const SizedBox(height: 9),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    _PortfolioAssetTile(
                        asset: CryptoAsset.bitcoin,
                        amount:
                            '${WalletAccountState.instance.snapshot.available('BTC').decimal} BTC',
                        value: WalletAccountState.instance.balanceLabel('BTC'),
                        change: '+4.21%'),
                    const SizedBox(height: 8),
                    _PortfolioAssetTile(
                        asset: CryptoAsset.ethereum,
                        amount:
                            '${WalletAccountState.instance.snapshot.available('ETH').decimal} ETH',
                        value: WalletAccountState.instance.balanceLabel('ETH'),
                        change: '+2.18%'),
                    const SizedBox(height: 8),
                    _PortfolioAssetTile(
                        asset: CryptoAsset.solana,
                        amount:
                            '${WalletAccountState.instance.snapshot.available('SOL').decimal} SOL',
                        value: WalletAccountState.instance.balanceLabel('SOL'),
                        change: '+4.21%'),
                    const SizedBox(height: 8),
                    _PortfolioAssetTile(
                        asset: CryptoAsset.tether,
                        amount:
                            '${WalletAccountState.instance.snapshot.available('USDT').decimal} USDT',
                        value: WalletAccountState.instance.balanceLabel('USDT'),
                        change: '+2.18%'),
                    const SizedBox(height: 8),
                    _PortfolioAssetTile(
                        asset: CryptoAsset.usdCoin,
                        amount:
                            '${WalletAccountState.instance.snapshot.available('USDC').decimal} USDC',
                        value: WalletAccountState.instance.balanceLabel('USDC'),
                        change: '\u2014'),
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
  const _RoundIconButton(
      {required this.icon, required this.tooltip, this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
            backgroundColor: DavoColors.of(context).primarySoft,
            minimumSize: const Size(48, 48)),
        icon: Icon(icon,
            size: 20,
            applyTextScaling: false,
            color: DavoColors.of(context).link),
      );
}

class _PortfolioValueCard extends StatelessWidget {
  const _PortfolioValueCard({required this.visible});
  final bool visible;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Portfolio Value',
              style: TextStyle(fontSize: 12, color: Colors.white)),
          const SizedBox(height: 12),
          Text(
              visible
                  ? WalletAccountState.instance.portfolioBalanceLabel
                  : '\u20a6\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Portfolio valuation',
              style: TextStyle(fontSize: 13, color: Colors.white)),
        ]),
      );
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: WalletAccountState.instance,
      builder: (context, _) => _content(context));
  Widget _content(BuildContext context) {
    final state = WalletAccountState.instance;
    final assets = state.snapshot.assets
        .where((asset) => asset != 'NGN' && asset != 'NGD')
        .toList();
    final total = state.snapshot.portfolioMinorUnits;
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius: BorderRadius.circular(12)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Asset Allocation',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DavoColors.of(context).ink)),
          const SizedBox(height: 12),
          ...assets.map((asset) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Text(asset)),
                Text(total == 0
                    ? '0.0%'
                    : '${(state.snapshot.valuationMinorUnits(asset) * 100 / total).toStringAsFixed(1)}%'),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(state.balanceLabel(asset),
                        textAlign: TextAlign.right)),
              ]))),
        ]));
  }
}

class _PortfolioAssetTile extends StatelessWidget {
  const _PortfolioAssetTile(
      {required this.asset,
      required this.amount,
      required this.value,
      required this.change});

  final CryptoAsset asset;
  final String amount;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: DavoColors.of(context).surface,
          borderRadius: BorderRadius.circular(6)),
      child: _AssetRow(
          asset: asset,
          amount: amount,
          value: value,
          change: change,
          chevron: true),
    );
  }
}

// --- Deposit flow --------------------------------------------------------------

enum CryptoAsset {
  bitcoin('Bitcoin', 'BTC', '₿', Color(0xFFF7931A)),
  ethereum('Ethereum', 'ETH', '◆', Color(0xFF627EEA)),
  solana('Solana', 'SOL', '≋', AppColors.ink),
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
    if (asset == CryptoAsset.solana) return SolanaIcon(size: size);
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(_assetPath,
          fit: BoxFit.contain, filterQuality: FilterQuality.high),
    );
  }
}
