import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/receipts/receipt_activity.dart';
import '../../../shared/receipts/transaction_record_details_screen.dart';
import 'buy_receipt_records.dart';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../core/preview/preview_transaction_operation.dart';
import '../../../shared/motion/davo_working_indicator.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../../../shared/widgets/trade_form_layout.dart';
import '../../crypto/presentation/crypto_full_flow.dart';
import '../../../shared/widgets/transaction_pin_entry.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import 'buy_crypto_models.dart';
import 'buy_crypto_widgets.dart';
import 'buy_receipt_screen.dart';

class BuyAmountScreen extends StatefulWidget {
  const BuyAmountScreen({super.key, required this.initialOrder});
  final BuyCryptoOrder initialOrder;

  @override
  State<BuyAmountScreen> createState() => _BuyAmountScreenState();
}

class _BuyAmountScreenState extends State<BuyAmountScreen> {
  late BuyCryptoOrder _order;
  late final TextEditingController _amountController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _amountController = TextEditingController();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double get _amount {
    final normalized =
        _amountController.text.replaceAll(',', '').replaceAll('₦', '').trim();
    return parseAmount(normalized);
  }

  bool get _canContinue => _amount > 0 && _amount <= _order.wallet.balance;

  void _setAmount(double value) {
    HapticFeedback.selectionClick();
    final safe = value.clamp(0.0, _order.wallet.balance).toDouble();
    _amountController.text = _formatEditable(safe);
    _amountController.selection =
        TextSelection.collapsed(offset: _amountController.text.length);
    setState(() {});
  }

  Future<void> _changeAsset() async {
    final asset = await showModalBottomSheet<BuyCryptoAsset>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const BuyCryptoAssetSheet(),
    );
    if (!mounted || asset == null) return;
    setState(() => _order = _order.copyWith(asset: asset));
  }

  Future<void> _changeWallet() async {
    final wallet = await showModalBottomSheet<BuyFundingWallet>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const BuyFundingWalletSheet(),
    );
    if (!mounted || wallet == null) return;
    final shouldClamp = _amount > wallet.balance;
    if (shouldClamp) {
      _amountController.text = _formatEditable(wallet.balance);
      _amountController.selection =
          TextSelection.collapsed(offset: _amountController.text.length);
    }
    setState(() => _order = _order.copyWith(wallet: wallet));
  }

  @override
  Widget build(BuildContext context) {
    final crypto = _amount / _order.asset.ngnPerUnit;
    return TradeFormLayout(
      header:
          _ExactTradeHeader(title: 'Buy', onBack: () => Navigator.pop(context)),
      tabs: _ModeToggle(asset: _order.asset),
      content: Column(children: [
        InkWell(
          onTap: _changeWallet,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              _WalletBadge(wallet: _order.wallet),
              const SizedBox(height: 12),
              Text(
                '${_order.wallet.symbol} Balance',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: DavoColors.of(context).body),
              ),
              const SizedBox(height: 4),
              Text(
                _order.wallet.formattedBalance,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: DavoColors.of(context).ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.primary
                    : DavoColors.of(context).divider,
                width: _focusNode.hasFocus ? 1.2 : 1),
            borderRadius: BorderRadius.circular(4),
          ),
          height: 77,
          child: Row(
            children: [
              if (_amountController.text.isNotEmpty)
                Text('₦',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).ink)),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [GroupedAmountInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: DavoColors.of(context).ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).ink),
                  ),
                ),
              ),
              Text(_order.wallet.symbol,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      height: 1.35,
                      color: DavoColors.of(context).body)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: _changeAsset,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('≈',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      height: 1.2,
                      color: DavoColors.of(context).bodyMuted)),
              const SizedBox(width: 4),
              Text(
                '${formatGroupedAmount(crypto.toStringAsFixed(5))} ${_order.asset.symbol}',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: DavoColors.of(context).body),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('1 ${_order.asset.symbol}',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: DavoColors.of(context).ink)),
            const SizedBox(width: 12),
            Text('≈',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: DavoColors.of(context).bodyMuted)),
            const SizedBox(width: 4),
            Text('(₦${_formatNgn(_order.asset.ngnPerUnit)})',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    height: 1.35,
                    color: DavoColors.of(context).bodyMuted)),
          ],
        ),
        const SizedBox(height: 24),
        _PercentageButtons(balance: _order.wallet.balance, onPick: _setAmount),
        if (_amount > _order.wallet.balance) ...[
          const SizedBox(height: 16),
          Text('Amount exceeds your selected wallet balance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: DavoColors.of(context).danger)),
        ],
      ]),
      action: _PrimaryButton(
        label: 'Continue',
        enabled: _canContinue,
        onPressed: () {
          FocusScope.of(context).unfocus();
          final order = _order.copyWith(ngnAmount: _amount);
          Navigator.of(context).push<void>(AppPageRoute<void>(
              builder: (_) => BuyReviewScreen(order: order)));
        },
      ),
    );
  }
}

class BuyReviewScreen extends StatelessWidget {
  const BuyReviewScreen({super.key, required this.order});
  final BuyCryptoOrder order;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).offWhite,
        bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: _PrimaryButton(
                    label: 'Confirm',
                    enabled: true,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push<void>(AppPageRoute<void>(
                          builder: (_) => BuyPinScreen(order: order)));
                    }))),
        body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(children: [
                  SizedBox(
                      height: 40,
                      child: _ExactTradeHeader(
                          title: 'Buy', onBack: () => Navigator.pop(context))),
                  const SizedBox(height: 20),
                  _ReviewExchangeCards(order: order),
                  const SizedBox(height: 24),
                  _ExactReviewSummary(rows: [
                    (
                      'Exchange Rate',
                      '1 USDT \u2248 \u20a6${_formatNgn(BuyCryptoOrder.usdtNgnRate)}',
                      false
                    ),
                    ('Network Fee', 'Free', true),
                    (
                      'Total you Pay',
                      '\u20a6${_formatNgn(order.ngnAmount)}',
                      false
                    ),
                  ]),
                ]))),
      );
}

class BuyPinScreen extends StatelessWidget {
  const BuyPinScreen({super.key, required this.order});
  final BuyCryptoOrder order;
  @override
  Widget build(BuildContext context) =>
      TransactionPinEntryScreen(onConfirm: () {
        Navigator.of(context).pushReplacement<void, void>(AppPageRoute<void>(
            builder: (_) => BuyProgressScreen(order: order)));
      });
}

class BuyProgressScreen extends StatefulWidget {
  const BuyProgressScreen({super.key, required this.order, this.operation});
  final BuyCryptoOrder order;
  final Future<PreviewTransactionOutcome>? operation;

  @override
  State<BuyProgressScreen> createState() => _BuyProgressScreenState();
}

class _BuyProgressScreenState extends State<BuyProgressScreen> {
  bool failed = false;
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    try {
      final accepted =
          await (widget.operation ?? PreviewTransactionOperation.buy());
      if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
      if (accepted == PreviewTransactionOutcome.failed) {
        setState(() => failed = true);
        return;
      }
      Navigator.of(context).pushReplacement<void, void>(
        AppPageRoute<void>(
            builder: (_) => accepted == PreviewTransactionOutcome.submitted
                ? DavoResultScreen(
                    kind: DavoOutcomeKind.submitted,
                    title: 'Purchase submitted',
                    message:
                        'Pending confirmation. Your purchase status will update after processing.',
                    actions: FilledButton(
                        onPressed: () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                        child: const Text('Done')))
                : BuySuccessScreen(order: widget.order)),
      );
    } catch (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent != false) {
        setState(() => failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      appBar: AppBar(
          backgroundColor: DavoColors.of(context).canvas,
          surfaceTintColor: Colors.transparent),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Column(children: [
                if (failed)
                  Icon(Icons.error_outline_rounded,
                      size: 56, color: DavoColors.of(context).danger)
                else
                  const DavoWorkingIndicator(),
                const SizedBox(height: 16),
                Text(
                    'Buying ${formatGroupedAmount(widget.order.cryptoAmount.toStringAsFixed(5))} ${widget.order.asset.symbol}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).ink)),
                const SizedBox(height: 8),
                Text(
                    failed
                        ? 'Could not complete this transaction. Go back to try again.'
                        : 'Please wait while we process your transaction',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: DavoColors.of(context).body)),
              ]))));
}

class BuySuccessScreen extends StatefulWidget {
  const BuySuccessScreen({super.key, required this.order, this.record});
  final BuyCryptoOrder order;
  final ReceiptRecord? record;
  @override
  State<BuySuccessScreen> createState() => _BuySuccessScreenState();
}

class _BuySuccessScreenState extends State<BuySuccessScreen> {
  BuyCryptoOrder get order => widget.order;
  late final ReceiptRecord _fallback = buildBuyReceiptRecord(order);
  ReceiptRecord get record => widget.record ?? _fallback;
  @override
  void initState() {
    super.initState();
    ReceiptActivity.accept(record);
  }

  @override
  Widget build(BuildContext context) => DavoResultScreen(
        title: switch (record.status) {
          ReceiptStatus.completed => 'Purchase successful',
          ReceiptStatus.pending => 'Purchase submitted',
          ReceiptStatus.failed => 'Purchase failed',
        },
        kind: record.status == ReceiptStatus.pending
            ? DavoOutcomeKind.submitted
            : DavoOutcomeKind.completed,
        mark: record.status == ReceiptStatus.failed
            ? const Icon(Icons.error_outline_rounded,
                color: Color(0xFFB42318), size: 100)
            : null,
        message:
            '${record.status == ReceiptStatus.completed ? 'You bought' : record.status == ReceiptStatus.pending ? 'Purchase awaiting confirmation:' : 'Purchase failed:'} ${record.amount}.${record.preview ? ' Preview only. No funds have been moved.' : ''}',
        appBar: AppBar(
            backgroundColor: DavoColors.of(context).surface,
            leading: IconButton(
              tooltip: 'Back to dashboard',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.dashboard, (route) => false),
            )),
        actions: Column(mainAxisSize: MainAxisSize.min, children: [
          _PrimaryButton(
              label: 'View Details',
              enabled: true,
              onPressed: () => Navigator.of(context).push<void>(
                  AppPageRoute<void>(
                      builder: (_) => BuyTransactionDetailsScreen(
                          order: order, record: record)))),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement<void, void>(
                AppPageRoute<void>(
                    builder: (_) => BuyAmountScreen(
                        initialOrder: order.copyWith(ngnAmount: 0)))),
            style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: DavoColors.of(context).primarySoft,
                foregroundColor: DavoColors.of(context).link,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            child: const Text('Buy more crypto'),
          ),
        ]),
      );
}

class BuyTransactionDetailsScreen extends StatefulWidget {
  const BuyTransactionDetailsScreen(
      {super.key, required this.order, this.record});
  final BuyCryptoOrder order;
  final ReceiptRecord? record;
  @override
  State<BuyTransactionDetailsScreen> createState() =>
      _BuyTransactionDetailsScreenState();
}

class _BuyTransactionDetailsScreenState
    extends State<BuyTransactionDetailsScreen> {
  late final ReceiptRecord _fallback = buildBuyReceiptRecord(widget.order);
  ReceiptRecord get record => widget.record ?? _fallback;
  @override
  Widget build(BuildContext context) => TransactionRecordDetailsScreen(
      record: record,
      onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
      receiptBuilder: (_) => BuyReceiptScreen(
          order: widget.order,
          date: record.occurredAt,
          transactionId: record.id,
          record: record));
}

class _ExactTradeHeader extends StatelessWidget {
  const _ExactTradeHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
            left: 6,
            top: 4,
            width: 32,
            height: 32,
            child: InkResponse(
                onTap: onBack,
                radius: 22,
                child: Image.asset('assets/figma_exact/buy_back.png',
                    color: DavoColors.of(context).ink, width: 32, height: 32)),
          ),
          Positioned.fill(
            child: Center(
              child: Text(title,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: DavoColors.of(context).ink)),
            ),
          ),
        ],
      );
}

class _ExactReviewSummary extends StatelessWidget {
  const _ExactReviewSummary({required this.rows});
  final List<(String, String, bool)> rows;
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
                    builder: (context, constraints) => Row(children: [
                          SizedBox(
                              width: constraints.maxWidth * .30,
                              child: Text(rows[i].$1,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          DavoColors.of(context).bodyMuted))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(rows[i].$2,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      color: rows[i].$3
                                          ? DavoColors.of(context).link
                                          : DavoColors.of(context).ink))),
                        ]))),
          ],
        ]),
      );
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.asset});
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: DavoColors.of(context).fieldFill,
            borderRadius: BorderRadius.circular(999)),
        child: Row(
            children: List.generate(
                3,
                (index) => Expanded(
                        child: Material(
                      color: index == 0
                          ? DavoColors.of(context).surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: index == 0
                            ? null
                            : () => Navigator.pushReplacement(
                                context,
                                AppPageRoute<void>(
                                    builder: (_) => TradeAmountScreen(
                                        mode: index == 1
                                            ? TradeMode.sell
                                            : TradeMode.convert,
                                        asset: asset))),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                                child: Text(['Buy', 'Sell', 'Swap'][index],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: index == 0
                                            ? DavoColors.of(context).link
                                            : DavoColors.of(context).body)))),
                      ),
                    )))),
      );
}

class _WalletBadge extends StatelessWidget {
  const _WalletBadge({required this.wallet});
  final BuyFundingWallet wallet;

  @override
  Widget build(BuildContext context) {
    return Image.asset(wallet.iconAsset,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high);
  }
}

class _PercentageButtons extends StatelessWidget {
  const _PercentageButtons({required this.balance, required this.onPick});
  final double balance;
  final ValueChanged<double> onPick;

  @override
  Widget build(BuildContext context) {
    const values = [0.10, 0.25, 0.50, 0.75, 1.0];
    const labels = ['10%', '25%', '50%', '75%', 'Max'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: List.generate(values.length, (index) {
        return InkWell(
          onTap: () => onPick(balance * values[index]),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 48,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DavoColors.of(context).canvas,
              border: Border.all(color: DavoColors.of(context).border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                color: index == 4
                    ? DavoColors.of(context).link
                    : DavoColors.of(context).body,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {required this.label, required this.enabled, required this.onPressed});
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: DavoColors.of(context).primaryDisabled,
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(
              fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ReviewExchangeCards extends StatelessWidget {
  const _ReviewExchangeCards({required this.order});
  final BuyCryptoOrder order;
  Widget _card(BuildContext context, String label, Widget icon, String value,
          String subtitle) =>
      Container(
        width: double.infinity,
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
            icon,
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: DavoColors.of(context).bodyMuted)),
                ]))
          ]),
        ]),
      );
  @override
  Widget build(BuildContext context) => Column(children: [
        _card(context, 'You will pay', _WalletBadge(wallet: order.wallet),
            '\u20a6${_formatNgn(order.ngnAmount)}', order.wallet.name),
        Stack(clipBehavior: Clip.none, children: [
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _card(
                  context,
                  'You will receive',
                  BuyAssetIcon(asset: order.asset, size: 32),
                  '${formatGroupedAmount(order.cryptoAmount.toStringAsFixed(5))} ${order.asset.symbol}',
                  '\u2248 \$${formatGroupedAmount(order.usdAmount.toStringAsFixed(2))} USD')),
          Positioned(
              top: -15,
              left: 0,
              right: 0,
              height: 40,
              child: Center(
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: DavoColors.of(context).primarySoft,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_downward_rounded,
                          size: 22, color: AppColors.primary)))),
        ]),
      ]);
}

String _formatNgn(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final reversed = whole.split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < reversed.length; i += 3) {
    chunks.add(
        reversed.sublist(i, math.min(i + 3, reversed.length)).reversed.join());
  }
  return '${chunks.reversed.join(',')}.${parts[1]}';
}

String _formatEditable(double value) =>
    formatGroupedAmount(value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2));
