part of '../dashboard_screen.dart';

class _WalletOption {
  const _WalletOption(
      {required this.name,
      required this.symbol,
      required this.balance,
      required this.subBalance,
      this.asset,
      this.isFiat = false});

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

  static final options = [
    const _WalletOption(
        name: 'Davochain Naira',
        symbol: 'NGD',
        balance: '100.50 USD',
        subBalance: '135,000.00 ₦',
        isFiat: true),
    const _WalletOption(
        name: 'Bitcoin',
        symbol: 'BTC',
        balance: '0.00 USD',
        subBalance: '0.00000000 BTC',
        asset: CryptoAsset.bitcoin),
    const _WalletOption(
        name: 'Ethereum',
        symbol: 'ETH',
        balance: '0.00 USD',
        subBalance: '0.00000000 ETH',
        asset: CryptoAsset.ethereum),
    const _WalletOption(
        name: 'Solana',
        symbol: 'SOL',
        balance: '0.00 USD',
        subBalance: '0.00000000 SOL',
        asset: CryptoAsset.solana),
    const _WalletOption(
        name: 'Tether',
        symbol: 'USDT',
        balance: '0.00 USD',
        subBalance: '0.000000 USDT',
        asset: CryptoAsset.tether),
  ];

  @override
  Widget build(BuildContext context) {
    return _DavoSheet(
      title: 'Select Wallet',
      refreshTarget: DavoRefreshTarget.walletBalances,
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
              decoration: BoxDecoration(
                  color: DavoColors.of(context).primarySoft,
                  shape: BoxShape.circle),
              child: Image.asset('assets/figma_exact/plus_circle.png',
                  width: 24, height: 24),
            ),
            title: const Text('Add crypto asset',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
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
        constraints: const BoxConstraints(minHeight: 63),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: DavoColors.of(context).divider, width: .4))),
        child: Row(
          children: [
            if (option.isFiat)
              Image.asset('assets/images/brand/naira_coin.png',
                  width: 37, height: 37, fit: BoxFit.contain)
            else
              _CryptoIcon(asset: option.asset!, size: 37),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.name,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          color: DavoColors.of(context).ink)),
                  const SizedBox(height: 2),
                  Text(option.symbol,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: DavoColors.of(context).body)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(WalletAccountState.instance.balanceLabel(option.symbol),
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        color: DavoColors.of(context).body)),
                const SizedBox(height: 2),
                Text(
                    '${WalletAccountState.instance.snapshot.available(option.symbol).decimal} ${option.symbol}',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        color: DavoColors.of(context).bodyMuted)),
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
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: DavoColors.of(context).divider, width: .4))),
              child: Row(
                children: [
                  _CryptoIcon(asset: asset, size: 37),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asset.name,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                color: DavoColors.of(context).ink)),
                        const SizedBox(height: 2),
                        Text(asset.symbol,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                color: DavoColors.of(context).body)),
                      ],
                    ),
                  ),
                  Image.asset('assets/figma_exact/chevron_right.png',
                      color: DavoColors.of(context).ink, width: 16, height: 16),
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
  const _DavoSheet(
      {required this.title,
      required this.child,
      required this.heightFactor,
      this.refreshTarget});

  final String title;
  final Widget child;
  final double heightFactor;
  final DavoRefreshTarget? refreshTarget;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        decoration: BoxDecoration(
          color: DavoColors.of(context).canvas,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                    width: 85,
                    height: 4,
                    decoration: BoxDecoration(
                        color: DavoColors.of(context).bodyMuted,
                        borderRadius: BorderRadius.circular(100))),
                const SizedBox(height: 11),
                DavoSheetHeader(title: title),
                Expanded(
                    child: refreshTarget == null
                        ? SingleChildScrollView(child: child)
                        : DavoRefreshRegion(
                            target: refreshTarget!,
                            builder: (context) => SingleChildScrollView(
                                physics: const ClampingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                child: child))),
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
      backgroundColor: DavoColors.of(context).surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Row(
            children: [
              Expanded(
                  child: _FooterButton(
                label: 'Share or save',
                background: DavoColors.of(context).border,
                foreground: DavoColors.of(context).body,
                fontWeight: FontWeight.w400,
                onTap: () => _openShareSheet(context),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _FooterButton(
                label: 'Copy Address',
                background: AppColors.primary,
                foreground: DavoColors.of(context).border,
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
              _SimpleAppBar(
                  title: 'Deposit', onBack: () => Navigator.pop(context)),
              DepositActivityBanner(currency: asset.symbol),
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
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: DavoColors.of(context).fieldFill,
                                        width: 1)),
                                child: Image.asset(_qrAsset,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.none),
                              ),
                            ),
                            Positioned(
                              left: 105,
                              top: 118,
                              width: 48,
                              height: 48,
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
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
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).fieldFill,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deposit Address',
                                style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14,
                                    height: 1.35,
                                    color: DavoColors.of(context).bodyMuted)),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(_address,
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 16,
                                            height: 1.35,
                                            color:
                                                DavoColors.of(context).ink))),
                                const SizedBox(width: 18),
                                InkWell(
                                  onTap: () => _copy(context, _address),
                                  child: Image.asset(
                                      'assets/figma_exact/deposit_btc_copy_exact.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.high),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DepositMetaRow(
                          label: 'Minimum Deposit Amount',
                          value: asset == CryptoAsset.bitcoin
                              ? '0.00001 BTC'
                              : '0.001 ${asset.symbol}'),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(
                          label: 'Route Deposits To', value: 'Crypto wallet'),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(
                          label: 'Deposit Arrival', value: '1 confirmations'),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(
                          label: 'Withdrawal Unlocked',
                          value: '2 confirmations'),
                      const SizedBox(height: 22),
                      InkWell(
                        onTap: () =>
                            setState(() => _guidelinesOpen = !_guidelinesOpen),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 13,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Please review these guidelines before making a deposit.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 10,
                                      color: DavoColors.of(context).body),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _guidelinesOpen ? .5 : 0,
                                duration: const Duration(milliseconds: 220),
                                child: Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: DavoColors.of(context).body),
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

  Future<void> _copy(BuildContext context, String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (!context.mounted) return;
      showDavoToast(context, 'Address copied. Check it before sending funds.');
    } on PlatformException {
      if (context.mounted) {
        showDavoToast(context, 'Could not copy address. Please try again.');
      }
    }
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16))),
        child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SharePreview(asset: asset, address: _address),
                          const SizedBox(width: 24),
                          const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Share',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                Text(
                                    'Share your wallet address or save it for later.',
                                    style:
                                        TextStyle(fontSize: 12, height: 1.4)),
                              ])),
                        ]),
                    const SizedBox(height: 20),
                    Wrap(spacing: 20, runSpacing: 16, children: [
                      const _ShareAction(
                          assetPath:
                              'assets/figma_exact/share_download_native_exact.png',
                          label: 'Download',
                          color: AppColors.primary),
                      _ShareAction(
                          assetPath:
                              'assets/figma_exact/share_x_native_exact.png',
                          label: 'X',
                          color: DavoColors.of(context).ink),
                      const _ShareAction(
                          assetPath:
                              'assets/figma_exact/share_telegram_native_exact.png',
                          label: 'Telegram',
                          color: Color(0xFF29A9EA)),
                      _ShareAction(
                          assetPath:
                              'assets/figma_exact/share_more_native_exact.png',
                          label: 'More',
                          color: DavoColors.of(context).border),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    height: 1.3,
                    color: DavoColors.of(context).bodyMuted))),
        Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    height: 1.3,
                    color: DavoColors.of(context).ink))),
      ],
    );
  }
}

class _Guidelines extends StatelessWidget {
  const _Guidelines();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        'Use supported wallet addresses only\n'
        'Deposits sent via smart contracts may not be credited. Please send funds from a standard wallet address.\n\n'
        'Airdrops not supported\n'
        'Davochain does not support airdrops or mining rewards. Do not use your Davochain deposit address for such activities.\n\n'
        'Avoid high-risk platforms\n'
        'Do not send funds from unverified or high-risk platforms to ensure the safety of your account.',
        style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 10,
            height: 1.28,
            color: DavoColors.of(context).bodyMuted),
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
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFB3B3B3), width: 1),
          borderRadius: BorderRadius.circular(4)),
      child: Stack(
        children: [
          Positioned(
              left: 9.6,
              top: 8.2,
              child: Text('Deposit ${asset.symbol}',
                  style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 3.21,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Colors.black))),
          Positioned(
              left: 17.5,
              top: 17.4,
              width: 49.5,
              height: 54.7,
              child: Image.asset(_depositQrAsset(asset),
                  fit: BoxFit.contain, filterQuality: FilterQuality.none)),
          Positioned(
            left: 37.6,
            top: 40.1,
            child: Container(
              width: 9.6,
              height: 9.6,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: _CryptoIcon(asset: asset, size: 8),
            ),
          ),
          const Positioned(
              left: 9.6,
              top: 76.7,
              child: Text('Network',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 2.81,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Color(0xFF686868)))),
          Positioned(
              left: 9.6,
              top: 82.3,
              width: 65.3,
              child: Text('${asset.name} (${asset.symbol})',
                  maxLines: 1,
                  style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 3.21,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Colors.black))),
          const Positioned(
              left: 9.6,
              top: 89.5,
              child: Text('Deposit Address',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 2.81,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Color(0xFF686868)))),
          Positioned(
              left: 9.6,
              top: 95.1,
              width: 65.3,
              height: 8,
              child: Text(address,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 3.21,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: AppColors.ink))),
          Positioned(
            left: 29.8,
            top: 110,
            width: 42,
            height: 8,
            child: Row(children: [
              Image.asset('assets/images/brand/davochain_logo.png',
                  width: 5, height: 5, fit: BoxFit.contain),
              const SizedBox(width: 1),
              const Text('Davochain',
                  style: TextStyle(
                      fontSize: 3.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
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
            child: Image.asset(assetPath,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 10,
                  height: 1.3,
                  color: DavoColors.of(context).body)),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton(
      {required this.label,
      required this.background,
      required this.foreground,
      required this.onTap,
      this.fontWeight = FontWeight.w600});

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
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: fontWeight,
                      color: foreground))),
        ),
      ),
    );
  }
}

class _SimpleAppBar extends StatelessWidget {
  const _SimpleAppBar({required this.title, required this.onBack});

  final String title;
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
            child: InkResponse(
                onTap: onBack,
                child: Image.asset('assets/figma_exact/deposit_back_exact.png',
                    color: DavoColors.of(context).ink,
                    width: 32,
                    height: 32,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high)),
          ),
          Positioned(
            left: 48,
            right: 48,
            top: 15,
            child: IgnorePointer(
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: DavoColors.of(context).ink)),
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
      backgroundColor: DavoColors.of(context).surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 15, 18),
          child: Column(
            children: [
              _SimpleAppBar(
                  title: 'Deposit', onBack: () => Navigator.pop(context)),
              const DepositActivityBanner(currency: 'NGD'),
              const SizedBox(height: 34),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(minHeight: 121),
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).warningSurface,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                                'assets/figma_exact/crypto_info_exact.png',
                                width: 17,
                                height: 17,
                                fit: BoxFit.contain),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      child: Text(
                                          'Faster Transfers: Use Your Own Bank Account',
                                          style: TextStyle(
                                              fontFamily: 'Sora',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.35,
                                              color:
                                                  DavoColors.of(context).ink))),
                                  const SizedBox(height: 4),
                                  Text(
                                      'For faster processing, transfer funds from your own bank account. Transfers from other accounts may be delayed and require proof of ownership',
                                      style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 10,
                                          height: 1.5,
                                          color: DavoColors.of(context).body)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.fromLTRB(17, 19, 16, 20),
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).fieldFill,
                            borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            _BankDetailRow(
                                label: 'Account name',
                                value: BankDepositDetails.preview.accountName),
                            const SizedBox(height: 8),
                            _BankDetailRow(
                                label: 'Bank name',
                                value: BankDepositDetails.preview.bankName),
                            const SizedBox(height: 8),
                            _BankDetailRow(
                                label: 'Account number',
                                value: BankDepositDetails.preview.accountNumber,
                                last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 305,
                          child: Text(
                            'Any money sent to this bank account will automatically top up your Davochain (NGD) wallet.\nReceive funds from any local Nigerian bank account directly into your Davochain wallet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                height: 1.25,
                                color: DavoColors.of(context).body),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                          child: Text('Disclaimer',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  height: 1.35,
                                  color: DavoColors.of(context).ink))),
                      const SizedBox(height: 16),
                      SizedBox(
                        child: Text(
                          '1. Funds deposited into your Davochain (NGD) wallet cannot be withdrawn.\n\n2. Deposits are only accepted from bank accounts with a name that matches your Davochain NGD account name. Deposits from accounts with different names will be blocked and rejected.',
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 10,
                              height: 1.4,
                              color: DavoColors.of(context).body),
                        ),
                      ),
                      const SizedBox(height: 66),
                      const BankDetailsShareButton(
                          details: BankDepositDetails.preview),
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
  const _BankDetailRow(
      {required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: DavoColors.of(context).fieldFill, width: .5))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        height: 1.25,
                        color: DavoColors.of(context).body)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: DavoColors.of(context).ink)),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              try {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) showDavoToast(context, '$label copied');
              } on PlatformException {
                if (context.mounted) {
                  showDavoToast(context, 'Could not copy. Please try again.');
                }
              }
            },
            child: Image.asset('assets/figma_exact/deposit_ngd_copy_exact.png',
                color: DavoColors.of(context).ink,
                width: 16,
                height: 16,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high),
          ),
        ],
      ),
    );
  }
}
