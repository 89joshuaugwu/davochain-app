part of '../dashboard_screen.dart';

class CryptoDepositScreen extends StatefulWidget {
  const CryptoDepositScreen({super.key, required this.asset});

  final CryptoAsset asset;

  @override
  State<CryptoDepositScreen> createState() => _CryptoDepositScreenState();
}

class _CryptoDepositScreenState extends State<CryptoDepositScreen> {
  bool _guidelinesOpen = false;
  bool _addressExpanded = false;

  CryptoAsset get asset => widget.asset;

  SimulationCryptoAddress get _destination =>
      SimulationCryptoAddress.bySymbol[asset.symbol]!;
  String get _address => _destination.address;

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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FooterButton(
                  label: 'Copy Address',
                  background: AppColors.primary,
                  foreground: Colors.white,
                  fontWeight: FontWeight.w600,
                  onTap: () => _copy(context, _address),
                ),
              ),
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
                title: 'Deposit',
                onBack: () => Navigator.pop(context),
              ),
              DepositActivityBanner(currency: asset.symbol),
              SimulationDepositButton(currency: asset.symbol),
              const SizedBox(height: 23),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        '${asset.name} (${asset.symbol})',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: DavoColors.of(context).ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Network: ${_depositNetwork(asset)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          height: 1.5,
                          color: DavoColors.of(context).body,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Test address only. Do not send real funds.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DavoColors.of(context).body,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                    width: 1,
                                  ),
                                ),
                                child: DavoAddressQr(data: _address),
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
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: _CryptoIcon(asset: asset, size: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        key: const ValueKey('compact-deposit-address-card'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DavoColors.of(context).fieldFill,
                          border: Border.all(
                            color: DavoColors.of(context).divider,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${asset.name} address',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: DavoColors.of(context).ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _addressExpanded
                                        ? _address
                                        : '${_address.substring(0, 6)}...${_address.substring(_address.length - 5)}',
                                    key: const ValueKey('deposit-address'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: DavoColors.of(context).bodyMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => setState(
                                () => _addressExpanded = !_addressExpanded,
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              ),
                              child: Text(
                                _addressExpanded ? 'Hide' : 'Show all',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy full address',
                              onPressed: () => _copy(context, _address),
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: DavoColors.of(context).link,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_destination.destinationTag != null) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Destination tag (required)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _destination.destinationTag!,
                            key: const ValueKey('deposit-destination-tag'),
                          ),
                          trailing: IconButton(
                            tooltip: 'Copy destination tag',
                            icon: const Icon(Icons.copy_outlined),
                            onPressed: () =>
                                _copy(context, _destination.destinationTag!),
                          ),
                        ),
                        const Text(
                          'Include this tag with the XRP test address. The address QR does not include the tag.',
                          style: TextStyle(fontSize: 12, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const _DepositMetaRow(
                        label: 'Route Deposits To',
                        value: 'Crypto wallet',
                      ),
                      const SizedBox(height: 12),
                      const _DepositMetaRow(
                        label: 'Receiving mode',
                        value: 'Local testing only',
                      ),
                      const SizedBox(height: 22),
                      InkWell(
                        onTap: () =>
                            setState(() => _guidelinesOpen = !_guidelinesOpen),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
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
                                    color: DavoColors.of(context).body,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _guidelinesOpen ? .5 : 0,
                                duration: const Duration(milliseconds: 220),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: DavoColors.of(context).body,
                                ),
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
      sheetAnimationStyle:
          (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: DavoColors.of(context).surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
                          Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Share your wallet address or save it for later.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    const _ShareAction(
                      assetPath:
                          'assets/figma_exact/share_download_native_exact.png',
                      label: 'Download',
                      color: AppColors.primary,
                    ),
                    _ShareAction(
                      assetPath: 'assets/figma_exact/share_x_native_exact.png',
                      label: 'X',
                      color: DavoColors.of(context).ink,
                    ),
                    const _ShareAction(
                      assetPath:
                          'assets/figma_exact/share_telegram_native_exact.png',
                      label: 'Telegram',
                      color: Color(0xFF29A9EA),
                    ),
                    _ShareAction(
                      assetPath:
                          'assets/figma_exact/share_more_native_exact.png',
                      label: 'More',
                      color: DavoColors.of(context).border,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              height: 1.3,
              color: DavoColors.of(context).bodyMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              height: 1.3,
              color: DavoColors.of(context).ink,
            ),
          ),
        ),
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
          color: DavoColors.of(context).bodyMuted,
        ),
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
    return SizedBox(
      width: 84.6,
      height: 124.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFB3B3B3), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: MediaQuery.withNoTextScaling(
          child: Stack(
            children: [
              Positioned(
                left: 9.6,
                top: 8.2,
                child: Text(
                  'TEST ${asset.symbol}',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 3.21,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                left: 17.5,
                top: 17.4,
                width: 49.5,
                height: 54.7,
                child: DavoAddressQr(data: address),
              ),
              Positioned(
                left: 37.6,
                top: 40.1,
                child: Container(
                  width: 9.6,
                  height: 9.6,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _CryptoIcon(asset: asset, size: 8),
                ),
              ),
              const Positioned(
                left: 9.6,
                top: 76.7,
                child: Text(
                  'Network',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 2.81,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Color(0xFF686868),
                  ),
                ),
              ),
              Positioned(
                left: 9.6,
                top: 82.3,
                width: 65.3,
                child: Text(
                  _depositNetwork(asset),
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 3.21,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Colors.black,
                  ),
                ),
              ),
              const Positioned(
                left: 9.6,
                top: 89.5,
                child: Text(
                  'Deposit Address',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 2.81,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Color(0xFF686868),
                  ),
                ),
              ),
              Positioned(
                left: 9.6,
                top: 95.1,
                width: 65.3,
                height: 8,
                child: Text(
                  '$address${SimulationCryptoAddress.bySymbol[asset.symbol]!.destinationTag == null ? '' : ' / Tag: ${SimulationCryptoAddress.bySymbol[asset.symbol]!.destinationTag}'}',
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 3.21,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Positioned(
                left: 29.8,
                top: 110,
                width: 42,
                height: 8,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/brand/davochain_logo.png',
                      width: 5,
                      height: 5,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 1),
                    const Text(
                      'Davochain',
                      style: TextStyle(
                        fontSize: 3.3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
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
            child: Image.asset(
              assetPath,
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              height: 1.3,
              color: DavoColors.of(context).body,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Center(
            heightFactor: 1,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: fontWeight,
                color: foreground,
              ),
            ),
          ),
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
              child: Image.asset(
                'assets/figma_exact/deposit_back_exact.png',
                color: DavoColors.of(context).ink,
                width: 32,
                height: 32,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Positioned(
            left: 48,
            right: 48,
            top: 15,
            child: IgnorePointer(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: DavoColors.of(context).ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NairaDepositScreen extends StatefulWidget {
  const NairaDepositScreen({super.key});
  @override
  State<NairaDepositScreen> createState() => _NairaDepositScreenState();
}

class _NairaDepositScreenState extends State<NairaDepositScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ReceivingAccountRuntime.ensureCurrent();
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: ReceivingAccountRuntime.controller,
    builder: (context, _) {
      final account = ReceivingAccountRuntime.controller.current;
      final details = account.details;
      final current =
          account.accountId == WalletAccountState.instance.snapshot.accountId &&
          WalletAccountState.instance.simulationEnabled;
      final ready =
          current &&
          account.status == ReceivingAccountStatus.ready &&
          details != null;
      return Scaffold(
        backgroundColor: DavoColors.of(context).canvas,
        appBar: AppBar(title: const Text('Receive Davochain Naira')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const DepositActivityBanner(currency: 'NGN'),
              const SimulationDepositButton(currency: 'NGN'),
              Text(
                'Your receiving account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: DavoColors.of(context).ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Share these details to receive naira into your Davochain Naira wallet. 1 Davochain Naira equals 1 Nigerian naira.',
                style: TextStyle(height: 1.6),
              ),
              const SizedBox(height: 24),
              if (ready) ...[
                if (details.isPreview) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DavoColors.of(context).primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Preview receiving details. This is a test account reference, not a real bank account. Use Add funds to test an accepted deposit.',
                      style: TextStyle(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: DavoColors.of(context).surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _BankDetailRow(
                        label: 'Account name',
                        value: details.accountName,
                      ),
                      _BankDetailRow(
                        label: 'Bank name',
                        value: details.bankName,
                      ),
                      _BankDetailRow(
                        label: details.isPreview
                            ? 'Test account reference'
                            : 'Account number',
                        value: details.accountNumber,
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Receive from your own account or another sender. Accepted funds join the same wallet you use to buy crypto and withdraw to a linked bank account.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: 28),
                BankDetailsShareButton(
                  details: BankDepositDetails(
                    accountName: details.accountName,
                    bankName: details.bankName,
                    accountNumber: details.accountNumber,
                    wallet: 'Davochain Naira',
                    isPreview: details.isPreview,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                Text(
                  current && account.status == ReceivingAccountStatus.creating
                      ? 'Preparing your receiving details...'
                      : current &&
                            account.status == ReceivingAccountStatus.failed
                      ? 'Your receiving details could not be prepared.'
                      : 'Receiving details are not available yet.',
                  style: const TextStyle(height: 1.6),
                ),
                if (current &&
                    account.status == ReceivingAccountStatus.creating)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (current && account.status == ReceivingAccountStatus.failed)
                  TextButton(
                    onPressed: ReceivingAccountRuntime.controller.retry,
                    child: const Text('Try again'),
                  ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _BankDetailRow extends StatelessWidget {
  const _BankDetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

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
                  color: DavoColors.of(context).fieldFill,
                  width: .5,
                ),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    height: 1.25,
                    color: DavoColors.of(context).body,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    height: 1.35,
                    color: DavoColors.of(context).ink,
                  ),
                ),
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
            child: Image.asset(
              'assets/figma_exact/deposit_ngd_copy_exact.png',
              color: DavoColors.of(context).ink,
              width: 16,
              height: 16,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

String _depositNetwork(CryptoAsset asset) =>
    SimulationCryptoAddress.bySymbol[asset.symbol]!.network;
