part of 'crypto_full_flow.dart';

class TransactionProgressScreen extends StatefulWidget {
  const TransactionProgressScreen({
    super.key,
    required this.kind,
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
    this.network,
    this.fee,
    this.operation,
  });
  final TxKind kind;
  final String target;
  final Object amount;
  final BuyCryptoAsset asset;
  final Future<PreviewTransactionOutcome>? operation;
  final String? network;
  final Object? fee;
  @override
  State<TransactionProgressScreen> createState() =>
      _TransactionProgressScreenState();
}

class _TransactionProgressScreenState extends State<TransactionProgressScreen> {
  bool failed = false;
  final int _accountGeneration = WalletAccountState.instance.generation;
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    try {
      final accepted = await (widget.operation ??
          PreviewTransactionOperation.transfer(
            external: widget.kind == TxKind.external,
          ));
      if (!mounted ||
          _accountGeneration != WalletAccountState.instance.generation ||
          ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      if (accepted == PreviewTransactionOutcome.failed) {
        setState(() => failed = true);
        return;
      }
      Navigator.pushReplacement(
        context,
        AppPageRoute<void>(
          builder: (_) => TransactionSuccessScreen(
            kind: widget.kind,
            outcomeKind: accepted == PreviewTransactionOutcome.submitted
                ? DavoOutcomeKind.submitted
                : DavoOutcomeKind.completed,
            target: widget.target,
            amount: widget.amount,
            asset: widget.asset,
            network: widget.network,
            fee: widget.fee,
          ),
        ),
      );
    } catch (_) {
      if (mounted &&
          _accountGeneration == WalletAccountState.instance.generation &&
          ModalRoute.of(context)?.isCurrent != false) {
        setState(() => failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transfer =
        widget.kind == TxKind.internal || widget.kind == TxKind.external;
    final title = transfer
        ? 'Sending ${formatGroupedAmount(formatCryptoQuantity(widget.amount))} ${widget.asset.symbol}'
        : widget.kind == TxKind.sell
            ? 'Selling ${formatGroupedAmount(formatCryptoQuantity(widget.amount))} ${widget.asset.symbol}'
            : 'Converting';
    final sub = switch (widget.kind) {
      TxKind.internal => 'to ${widget.target}',
      TxKind.external => 'to ${_short(widget.target)}',
      _ => '',
    };
    final subColor = widget.kind == TxKind.external
        ? DavoColors.of(context).bodyMuted
        : DavoColors.of(context).body;
    return _FigmaFullScaffold(
      child: Column(
        children: [
          _TopBar(
            title: transfer ? 'Crypto Withdraw Mode' : '',
            onBack: () => Navigator.pop(context),
            height: 32,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 47),
          failed
              ? Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: DavoColors.of(context).danger,
                )
              : const DavoWorkingIndicator(),
          const SizedBox(height: 16),
          SizedBox(
            height: 22,
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
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 19,
              child: Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  color: subColor,
                ),
              ),
            ),
          ],
          SizedBox(height: sub.isNotEmpty ? 8 : 8),
          Text(
            failed
                ? 'Could not complete this transaction. Go back to try again.'
                : widget.kind == TxKind.conversion || widget.kind == TxKind.sell
                    ? failed
                        ? 'Could not complete this transaction. Go back to try again.'
                        : 'Please wait while we process your transaction'
                    : 'Please wait while we process your transaction',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              height: 1.35,
              color: DavoColors.of(context).body,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionSuccessScreen extends StatefulWidget {
  const TransactionSuccessScreen({
    super.key,
    required this.kind,
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
    this.record,
    this.network,
    this.fee,
    this.outcomeKind = DavoOutcomeKind.completed,
  });
  final TxKind kind;
  final String target;
  final Object amount;
  final BuyCryptoAsset asset;
  final DavoOutcomeKind outcomeKind;
  final ReceiptRecord? record;
  final String? network;
  final Object? fee;
  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen>
    with ReceiptActivityObserver<TransactionSuccessScreen> {
  TxKind get kind => widget.kind;
  String get target => widget.target;
  Object get amount => widget.amount;
  BuyCryptoAsset get asset => widget.asset;
  DavoOutcomeKind get outcomeKind => record.status == ReceiptStatus.pending
      ? DavoOutcomeKind.submitted
      : DavoOutcomeKind.completed;
  late final ReceiptRecord _fallback = buildCryptoReceiptRecord(
    kind: kind,
    target: target,
    amount: amount,
    asset: asset,
    network: widget.network,
    fee: widget.fee,
    status: widget.outcomeKind == DavoOutcomeKind.submitted
        ? ReceiptStatus.pending
        : ReceiptStatus.completed,
  );
  ReceiptRecord get record =>
      ReceiptActivity.resolve(widget.record ?? _fallback);
  @override
  void initState() {
    super.initState();
    if (widget.record == null) {
      ReceiptActivity.submitPreview(record);
    } else {
      ReceiptActivity.accept(record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transfer = kind == TxKind.internal || kind == TxKind.external;
    return DavoResultScreen(
      onExit: () => finishDavoTransaction(context, tab: transfer ? 0 : 1),
      eventKey: '${record.id}-${record.status.name}',
      refreshRecordId: record.id,
      kind: outcomeKind,
      mark: record.status == ReceiptStatus.failed
          ? const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB42318),
              size: 100,
            )
          : null,
      title: record.status == ReceiptStatus.failed
          ? '${record.type} failed'
          : outcomeKind == DavoOutcomeKind.submitted
              ? '${record.type} submitted'
              : transfer
                  ? 'Transfer successful'
                  : kind == TxKind.sell
                      ? 'Sale successful'
                      : 'Conversion successful',
      message:
          '${record.type} ${record.status.label.toLowerCase()}: ${record.amount}.',
      details: record.status == ReceiptStatus.failed || widget.record != null
          ? null
          : outcomeKind == DavoOutcomeKind.submitted
              ? Text(
                  transfer
                      ? 'Your transfer has been submitted. Its status will update after confirmation.'
                      : kind == TxKind.sell
                          ? 'Your sale has been submitted. Its status will update after confirmation.'
                          : 'Your conversion has been submitted. Its status will update after confirmation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    height: 1.35,
                    color: DavoColors.of(context).body,
                  ),
                )
              : _TransactionSuccessMessage(
                  kind: kind,
                  target: target,
                  amount: amount,
                  asset: asset,
                ),
      appBar: AppBar(
        backgroundColor: DavoColors.of(context).surface,
        leading: IconButton(
            tooltip: transfer ? 'Back to wallet' : 'Back to trade',
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                finishDavoTransaction(context, tab: transfer ? 0 : 1)),
        title: transfer
            ? const Text(
                'Crypto withdrawal',
                style: TextStyle(fontFamily: 'Sora', fontSize: 16),
              )
            : null,
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Button(
            label: 'View Details',
            onTap: () => Navigator.push(
              context,
              AppPageRoute<void>(
                builder: (_) => TransactionDetailsScreen(
                  pending: outcomeKind == DavoOutcomeKind.submitted,
                  kind: kind,
                  target: target,
                  amount: amount,
                  asset: asset,
                  record: record,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Secondary(
            label: transfer
                ? 'Send another transfer'
                : kind == TxKind.sell
                    ? 'Sell more crypto'
                    : 'Convert more crypto',
            onTap: () => finishDavoTransaction(context,
                tab: transfer ? 0 : 1,
                start: transfer
                    ? null
                    : (_) => TradeAmountScreen(
                        mode: kind == TxKind.sell
                            ? TradeMode.sell
                            : TradeMode.convert,
                        asset: asset)),
          ),
        ],
      ),
    );
  }
}

class _TransactionSuccessMessage extends StatelessWidget {
  const _TransactionSuccessMessage({
    required this.kind,
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
  });
  final TxKind kind;
  final String target;
  final Object amount;
  final BuyCryptoAsset asset;

  @override
  Widget build(BuildContext context) {
    final muted = DavoColors.of(context).bodyMuted;
    final ink = DavoColors.of(context).ink;
    final base = TextStyle(
      fontFamily: 'Sora',
      fontSize: 14,
      height: 1.35,
      color: muted,
    );
    final dark = TextStyle(
      fontFamily: 'Sora',
      fontSize: 14,
      height: 1.35,
      color: ink,
    );
    final strong = TextStyle(
      fontFamily: 'Sora',
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: ink,
    );
    final amountText = '${formatCryptoQuantity(amount)} ${asset.symbol}';
    final spans = switch (kind) {
      TxKind.internal => <InlineSpan>[
          TextSpan(text: 'You have sent', style: base),
          TextSpan(text: ' $amountText ', style: dark),
          TextSpan(text: 'to', style: base),
          TextSpan(text: ' $target', style: dark),
        ],
      TxKind.external => <InlineSpan>[
          TextSpan(text: 'You have sent ', style: base),
          TextSpan(text: amountText, style: strong),
          TextSpan(text: ' to ', style: base),
          TextSpan(text: _short(target), style: strong),
        ],
      TxKind.conversion => <InlineSpan>[
          TextSpan(text: 'You have successfully converted  ', style: base),
          TextSpan(text: amountText, style: strong),
          TextSpan(text: ' to ', style: base),
          TextSpan(
            text:
                '${formatCryptoQuantity((ExactDecimal.from(amount) * asset.ngnPrice).divide((BuyCryptoAsset.values.where((a) => a.symbol == target || a.name == target).firstOrNull ?? BuyCryptoAsset.tether).ngnPrice, rounding: DecimalRounding.floor))} $target',
            style: strong,
          ),
        ],
      TxKind.sell => <InlineSpan>[
          TextSpan(text: 'You have successfully sold ', style: base),
          TextSpan(text: '$amountText ', style: strong),
          TextSpan(text: 'for ', style: base),
          TextSpan(
            text:
                '₦${formatGroupedAmount((ExactDecimal.from(amount) * asset.ngnPrice).toFixed(2))}',
            style: strong,
          ),
        ],
    };
    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
  }
}

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.kind,
    required this.target,
    required this.amount,
    this.receipt = false,
    this.pending = false,
    this.asset = BuyCryptoAsset.bitcoin,
    this.record,
  });
  final TxKind kind;
  final String target;
  final Object amount;
  final bool receipt, pending;
  final BuyCryptoAsset asset;
  final ReceiptRecord? record;
  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late final ReceiptRecord _fallback = buildCryptoReceiptRecord(
    kind: widget.kind,
    target: widget.target,
    amount: widget.amount,
    asset: widget.asset,
    status: widget.pending ? ReceiptStatus.pending : ReceiptStatus.completed,
  );
  ReceiptRecord get record =>
      ReceiptActivity.resolve(widget.record ?? _fallback);
  @override
  Widget build(BuildContext context) => widget.receipt
      ? ReceiptScreen(record: record)
      : TransactionRecordDetailsScreen(
          record: record,
          onDone: () => finishDavoTransaction(context,
              tab:
                  widget.kind == TxKind.sell || widget.kind == TxKind.conversion
                      ? 1
                      : 0),
          receiptBuilder: (_) => TransactionDetailsScreen(
            kind: widget.kind,
            target: widget.target,
            amount: widget.amount,
            asset: widget.asset,
            pending: widget.pending,
            record: record,
            receipt: true,
          ),
        );
}
