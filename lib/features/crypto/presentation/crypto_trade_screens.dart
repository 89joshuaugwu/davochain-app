part of 'crypto_full_flow.dart';

class TradeAmountScreen extends StatefulWidget {
  const TradeAmountScreen(
      {super.key,
      required this.mode,
      required this.asset,
      this.onBack,
      this.onModeSelected});
  final VoidCallback? onBack;
  final void Function(int, BuyCryptoAsset)? onModeSelected;
  final TradeMode mode;
  final BuyCryptoAsset asset;
  @override
  State<TradeAmountScreen> createState() => _TradeAmountScreenState();
}

class _TradeAmountScreenState extends State<TradeAmountScreen> {
  final amount = TextEditingController();
  late BuyCryptoAsset sourceAsset;
  late BuyCryptoAsset destinationAsset;
  late final int _accountGeneration;
  void _walletChanged() {
    if (!mounted) return;
    if (_accountGeneration != WalletAccountState.instance.generation) {
      amount.clear();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _accountGeneration = WalletAccountState.instance.generation;
    WalletAccountState.instance.addListener(_walletChanged);
    sourceAsset = widget.asset;
    destinationAsset = sourceAsset == BuyCryptoAsset.tether
        ? BuyCryptoAsset.bitcoin
        : BuyCryptoAsset.tether;
  }

  Future<void> _selectAsset({required bool source}) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<BuyCryptoAsset>(
        context: context,
        sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
                MediaQuery.accessibleNavigationOf(context))
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200)),
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const BuyCryptoAssetSheet());
    if (!mounted || picked == null) return;
    setState(() {
      if (source) {
        if (picked == destinationAsset) destinationAsset = sourceAsset;
        sourceAsset = picked;
      } else {
        if (picked == sourceAsset) sourceAsset = destinationAsset;
        destinationAsset = picked;
      }
    });
  }

  void _swapAssets() {
    FocusScope.of(context).unfocus();
    final received = (enteredAmount * sourceAsset.ngnPrice).divide(
        destinationAsset.ngnPrice,
        scale: WalletAccountState.instance.snapshot
            .available(destinationAsset.symbol)
            .decimals,
        rounding: DecimalRounding.floor);
    setState(() {
      final previous = sourceAsset;
      sourceAsset = destinationAsset;
      destinationAsset = previous;
      if (amount.text.isNotEmpty) {
        amount.text = formatGroupedAmount(received
            .toFixed(
                WalletAccountState.instance.snapshot
                    .available(sourceAsset.symbol)
                    .decimals,
                rounding: DecimalRounding.floor)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), ''));
        amount.selection = TextSelection.collapsed(offset: amount.text.length);
      }
    });
  }

  @override
  void dispose() {
    WalletAccountState.instance.removeListener(_walletChanged);
    amount.dispose();
    super.dispose();
  }

  bool get convert => widget.mode == TradeMode.convert;
  ExactDecimal get balance =>
      ExactDecimal.parse(WalletAccountState.instance.snapshot
          .available(sourceAsset.symbol)
          .decimal);
  ExactDecimal get enteredAmount => _parseExactAmount(amount.text);

  void _switchMode(TradeMode mode) {
    FocusScope.of(context).unfocus();
    if (widget.onModeSelected != null) {
      widget.onModeSelected!(mode == TradeMode.sell ? 1 : 2, sourceAsset);
      return;
    }
    Navigator.pushReplacement(
        context,
        AppPageRoute<void>(
            builder: (_) => TradeAmountScreen(mode: mode, asset: sourceAsset)));
  }

  void _pickPercent(String label) {
    final available =
        WalletAccountState.instance.snapshot.available(sourceAsset.symbol);
    final percent = label == 'Max' ? 100 : int.parse(label.replaceAll('%', ''));
    amount.text = formatGroupedAmount(
        CryptoTradeAmounts.percentage(available, percent).toString());
    amount.selection = TextSelection.collapsed(offset: amount.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final n = enteredAmount;
    final positiveProceeds = _positiveTradeProceeds(
        n, sourceAsset, convert ? destinationAsset : null);
    final active = positiveProceeds &&
        _accountGeneration == WalletAccountState.instance.generation &&
        CryptoTradeAmounts.canSpend(
            WalletAccountState.instance.snapshot.available(sourceAsset.symbol),
            n);
    final ngn = n * sourceAsset.ngnPrice;
    return TradeFormLayout(
      header: _ExactCryptoTradeHeader(
          title: convert ? 'Swap' : 'Sell',
          onBack: widget.onBack ?? () => Navigator.pop(context)),
      tabs: _Tabs(
          active: convert ? 2 : 1,
          onBuy: () {
            FocusScope.of(context).unfocus();
            if (widget.onModeSelected != null) {
              widget.onModeSelected!(0, sourceAsset);
              return;
            }
            Navigator.pushReplacement(
                context,
                AppPageRoute<void>(
                    builder: (_) => BuyAmountScreen(
                        initialOrder: BuyCryptoOrder(
                            asset: sourceAsset,
                            wallet: BuyFundingWallet.ngd,
                            ngnAmount: 0))));
          },
          onSell: () {
            if (convert) _switchMode(TradeMode.sell);
          },
          onConvert: () {
            if (!convert) _switchMode(TradeMode.convert);
          }),
      content: Column(children: [
        if (convert) ...[
          InkWell(
              onTap: () => _selectAsset(source: true),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Text(
                                '${formatGroupedAmount(_tradeQuantity(n))} ${sourceAsset.symbol}',
                                style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary),
                      ]))),
          Text(
              '\u2248 ${formatGroupedAmount((ngn.divide(ExactDecimal.parse('1463.08'))).toFixed(2))} USD',
              style: TextStyle(
                  fontSize: 13, color: DavoColors.of(context).bodyMuted)),
          const SizedBox(height: 24),
          _ExactSwapBox(
              from: true,
              onSelect: () => _selectAsset(source: true),
              asset: sourceAsset,
              balance: balance,
              value: n,
              controller: amount,
              onChanged: () => setState(() {})),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton(
                  onPressed: _swapAssets,
                  tooltip: 'Swap assets',
                  style: IconButton.styleFrom(
                      backgroundColor: DavoColors.of(context).primarySoft,
                      foregroundColor: DavoColors.of(context).link),
                  icon: const Icon(Icons.swap_vert_rounded, size: 28))),
          _ExactSwapBox(
              from: false,
              onSelect: () => _selectAsset(source: false),
              asset: destinationAsset,
              balance: WalletAccountState.instance.snapshot
                  .available(destinationAsset.symbol)
                  .decimal,
              value: ngn.divide(destinationAsset.ngnPrice,
                  scale: WalletAccountState.instance.snapshot
                      .available(destinationAsset.symbol)
                      .decimals,
                  rounding: DecimalRounding.floor)),
          const SizedBox(height: 16),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Estimated fee: Free',
                  style: TextStyle(
                      fontSize: 12, color: DavoColors.of(context).bodyMuted))),
        ] else ...[
          _AssetBalance(asset: sourceAsset),
          const SizedBox(height: 24),
          _Amount(
              controller: amount,
              suffix: sourceAsset.symbol,
              onChanged: () => setState(() {})),
          const SizedBox(height: 20),
          Text('\u2248 \u20a6${formatGroupedAmount(ngn.toFixed(2))}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DavoColors.of(context).ink)),
        ],
        const SizedBox(height: 12),
        Text(
            convert
                ? '1 ${sourceAsset.symbol} \u2248 \u20a6${formatGroupedAmount(sourceAsset.ngnPrice.toFixed(2))}'
                : '1 ${sourceAsset.symbol} \u2248 (\u20a6${formatGroupedAmount(sourceAsset.ngnPrice.toFixed(2))})',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: DavoColors.of(context).bodyMuted)),
        const SizedBox(height: 24),
        Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['10%', '25%', '50%', '75%', 'Max']
                .map((v) => _Percent(label: v, onTap: () => _pickPercent(v)))
                .toList()),
        if (!n.isZero && !positiveProceeds)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Enter a larger amount.',
                  style: TextStyle(color: DavoColors.of(context).danger))),
        if (n.compareTo(balance) > 0)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Amount exceeds your available balance.',
                  style: TextStyle(color: DavoColors.of(context).danger))),
      ]),
      action: _Button(
          label: convert ? 'Review' : 'Continue',
          enabled: active,
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
                context,
                AppPageRoute<void>(
                    builder: (_) => TradeReviewScreen(
                        kind: convert ? TxKind.conversion : TxKind.sell,
                        amount: n,
                        sourceAsset: sourceAsset,
                        destinationAsset: destinationAsset)));
          }),
    );
  }
}

class TradeReviewScreen extends StatelessWidget {
  const TradeReviewScreen(
      {super.key,
      required this.kind,
      required this.amount,
      this.sourceAsset = BuyCryptoAsset.bitcoin,
      this.destinationAsset = BuyCryptoAsset.tether});
  final TxKind kind;
  final Object amount;
  final BuyCryptoAsset sourceAsset, destinationAsset;

  Widget _reviewAsset(BuildContext context, String label, BuyCryptoAsset asset,
          String value, String secondary) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: DavoColors.of(context).bodyMuted)),
          const SizedBox(height: 12),
          Row(children: [
            BuyAssetIcon(asset: asset, size: 32),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(secondary,
                      style: TextStyle(
                          fontSize: 12,
                          color: DavoColors.of(context).bodyMuted)),
                ])),
            Text(asset.symbol,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final conv = kind == TxKind.conversion;
    final ngn = ExactDecimal.from(amount) * sourceAsset.ngnPrice;
    final received = ngn.divide(destinationAsset.ngnPrice,
        scale: WalletAccountState.instance.snapshot
            .available(destinationAsset.symbol)
            .decimals,
        rounding: DecimalRounding.floor);
    final receivedText = formatGroupedAmount(formatCryptoQuantity(received));
    final usdText = formatGroupedAmount(
        (ngn.divide(ExactDecimal.parse('1463.08'))).toFixed(2));
    final rate =
        '1 ${destinationAsset.symbol} \u2248 ${formatGroupedAmount((destinationAsset.ngnPrice.divide(sourceAsset.ngnPrice)).toFixed(8))} ${sourceAsset.symbol}';
    return Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _Button(
                  label: conv ? 'Confirm conversion' : 'Confirm',
                  enabled: _positiveTradeProceeds(ExactDecimal.from(amount),
                      sourceAsset, conv ? destinationAsset : null),
                  onTap: () => Navigator.pushReplacement(
                      context,
                      AppPageRoute<void>(
                          builder: (_) => TransactionProgressScreen(
                              kind: kind,
                              target: conv ? destinationAsset.symbol : 'NGN',
                              amount: amount,
                              asset: sourceAsset)))))),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(children: [
                SizedBox(
                    height: 48,
                    child: _ExactCryptoTradeHeader(
                        title: conv ? 'Review Conversion' : 'Sell',
                        onBack: () => Navigator.pop(context))),
                const SizedBox(height: 24),
                _reviewAsset(
                    context,
                    conv ? 'You are converting' : 'You are Selling',
                    sourceAsset,
                    formatGroupedAmount(formatCryptoQuantity(amount)),
                    '\$$usdText'),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).primarySoft,
                            shape: BoxShape.circle),
                        child: Icon(
                            conv
                                ? Icons.swap_vert_rounded
                                : Icons.arrow_downward_rounded,
                            size: 22,
                            color: AppColors.primary))),
                if (conv)
                  _reviewAsset(context, 'To (You will receive)',
                      destinationAsset, receivedText, '\$$usdText')
                else
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: DavoColors.of(context).surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('To (You will receive)',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DavoColors.of(context).bodyMuted)),
                            const SizedBox(height: 12),
                            Row(children: [
                              Image.asset('$_f/buy_nigeria.png',
                                  width: 32, height: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        '\u20a6${formatGroupedAmount(ngn.toFixed(2))}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Nigerian Naira',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: DavoColors.of(context)
                                                .bodyMuted)),
                                  ])),
                            ]),
                          ])),
                const SizedBox(height: 24),
                _ExactTradeSummary(conversion: conv, rows: [
                  (
                    'Exchange Rate',
                    conv
                        ? rate
                        : '1 ${sourceAsset.symbol} \u2248 \u20a6${formatGroupedAmount(sourceAsset.ngnPrice.toFixed(2))}',
                    false
                  ),
                  ('Network Fee', 'Free', true),
                  (
                    conv ? 'Total Amount' : 'Total Received',
                    conv
                        ? '$receivedText ${destinationAsset.symbol}\n\$$usdText'
                        : '\u20a6${formatGroupedAmount(ngn.toFixed(2))}',
                    false
                  ),
                ]),
              ]))),
    );
  }
}

class _ExactCryptoTradeHeader extends StatelessWidget {
  const _ExactCryptoTradeHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded,
                color: DavoColors.of(context).ink)),
        Expanded(
            child: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    height: 1.35,
                    color: DavoColors.of(context).ink))),
        const SizedBox(width: 48),
      ]);
}

class _ExactSwapBox extends StatelessWidget {
  const _ExactSwapBox(
      {required this.from,
      required this.asset,
      required this.balance,
      required this.value,
      this.controller,
      this.onChanged,
      this.onSelect});
  final bool from;
  final BuyCryptoAsset asset;
  final Object balance, value;
  final TextEditingController? controller;
  final VoidCallback? onChanged;
  final VoidCallback? onSelect;
  @override
  Widget build(BuildContext context) => Focus(
      child: Builder(
          builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: DavoColors.of(context).surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Focus.of(context).hasFocus
                            ? AppColors.primary
                            : DavoColors.of(context).border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(from ? 'From' : 'To',
                          style: TextStyle(
                              fontSize: 12,
                              color: DavoColors.of(context).bodyMuted)),
                      const SizedBox(height: 8),
                      Row(children: [
                        InkWell(
                            onTap: onSelect,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BuyAssetIcon(asset: asset, size: 24),
                                      const SizedBox(width: 8),
                                      Text(asset.symbol,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.primary,
                                          size: 18),
                                    ]))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: from
                                ? TextField(
                                    controller: controller,
                                    onChanged: (_) => onChanged?.call(),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: const [
                                      GroupedAmountInputFormatter()
                                    ],
                                    textAlign: TextAlign.right,
                                    decoration: const DavoInlineInputDecoration(
                                        hintText: '0.00'),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  )
                                : Text(
                                    formatGroupedAmount(
                                        formatCryptoQuantity(value)),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600))),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                          'Available: ${formatGroupedAmount(balance.toString())} ${asset.symbol}',
                          style: TextStyle(
                              fontSize: 12,
                              color: DavoColors.of(context).bodyMuted)),
                    ]),
              )));
}

class _ExactTradeSummary extends StatelessWidget {
  const _ExactTradeSummary({required this.rows, required this.conversion});
  final List<(String, String, bool)> rows;
  final bool conversion;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                  height: 1,
                  thickness: .5,
                  color: DavoColors.of(context).divider),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: LayoutBuilder(
                    builder: (context, constraints) => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: constraints.maxWidth * .30,
                                  child: Text(rows[i].$1,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: DavoColors.of(context)
                                              .bodyMuted))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(rows[i].$2,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          color: rows[i].$3
                                              ? DavoColors.of(context).link
                                              : DavoColors.of(context).ink,
                                          fontWeight: FontWeight.w500))),
                            ]))),
          ]
        ]),
      );
}

String _tradeQuantity(ExactDecimal amount) {
  final text = amount.toString();
  final fraction = text.split('.');
  return fraction.length == 1 || fraction.last.length < 2
      ? amount.toFixed(2)
      : text;
}

bool _positiveTradeProceeds(
    ExactDecimal quantity, BuyCryptoAsset source, BuyCryptoAsset? destination) {
  if (quantity.isNegative || quantity.isZero) return false;
  final naira = quantity * source.ngnPrice;
  return destination == null
      ? !ExactDecimal.parse(naira.toFixed(2)).isZero
      : !naira
          .divide(destination.ngnPrice,
              scale: WalletAccountState.instance.snapshot
                  .available(destination.symbol)
                  .decimals,
              rounding: DecimalRounding.floor)
          .isZero;
}
