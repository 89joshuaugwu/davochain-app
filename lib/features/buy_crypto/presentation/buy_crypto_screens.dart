import '../../../core/providers/reactive_builder.dart';
import '../../../shared/receipts/transaction_commands.dart';
import '../../../core/navigation/transaction_navigation.dart';
import '../../../shared/widgets/trade_amount_card.dart';
import '../../../core/money/exact_decimal.dart';
import '../../wallets/wallet_repository.dart';
import 'buy_amount_controller.dart';
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

import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import 'buy_crypto_models.dart';
import 'buy_crypto_widgets.dart';
import 'buy_receipt_screen.dart';

class BuyAmountScreen extends StatefulWidget {
  const BuyAmountScreen({
    super.key,
    required this.initialOrder,
    this.onBack,
    this.onModeSelected,
  });
  final void Function(int, BuyCryptoAsset)? onModeSelected;
  final VoidCallback? onBack;
  final BuyCryptoOrder initialOrder;

  @override
  State<BuyAmountScreen> createState() => _BuyAmountScreenState();
}

class _BuyAmountScreenState extends State<BuyAmountScreen> {
  late final BuyAmountController _flow;
  BuyCryptoOrder get _order => _flow.order;
  TextEditingController get _amountController => _flow.input;
  void _flowChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _flow = BuyAmountController(widget.initialOrder)..addListener(_flowChanged);
  }

  @override
  void dispose() {
    _flow.removeListener(_flowChanged);
    _flow.dispose();
    super.dispose();
  }

  ExactDecimal get _amount => _flow.amount;
  bool get _canContinue => _flow.canContinue;

  Future<void> _changeAsset() async {
    FocusScope.of(context).unfocus();
    final asset = await showModalBottomSheet<BuyCryptoAsset>(
      context: context,
      sheetAnimationStyle:
          (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const BuyCryptoAssetSheet(),
    );
    if (!mounted || asset == null) return;
    _flow.selectAsset(asset);
  }

  Future<void> _changeWallet() async {
    final wallet = await showModalBottomSheet<BuyFundingWallet>(
      context: context,
      sheetAnimationStyle:
          (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const BuyFundingWalletSheet(),
    );
    if (!mounted || wallet == null) return;
    _flow.selectWallet(wallet);
  }

  @override
  Widget build(BuildContext context) {
    return TradeFormLayout(
      header: _ExactTradeHeader(
        title: 'Buy',
        onBack: widget.onBack ?? () => Navigator.pop(context),
      ),
      tabs: _ModeToggle(
        asset: _order.asset,
        onModeSelected: widget.onModeSelected,
      ),
      content: Column(
        children: [
          TradeAmountCard(
            label: 'You pay',
            selector: TradeCurrencySelector(
              icon: Image.asset(_order.wallet.iconAsset, width: 32, height: 32),
              name: _order.wallet.name,
              symbol: _order.wallet.symbol,
              onTap: _changeWallet,
            ),
            controller: _amountController,
            onChanged: () => setState(() {}),
            footer: 'Available: ${_order.wallet.formattedBalance}',
          ),
          const SizedBox(height: 16),
          TradeAmountCard(
            label: 'You receive',
            selector: TradeCurrencySelector(
              icon: BuyAssetIcon(asset: _order.asset, size: 32),
              name: _order.asset.name,
              symbol: _order.asset.symbol,
              onTap: _changeAsset,
            ),
            value:
                '${_order.copyWith(ngnAmount: _amount).formattedCryptoAmount} ${_order.asset.symbol}',
            footer: _order.formattedExchangeRate,
          ),
          const SizedBox(height: 20),
          TradePercentageButtons(
            key: ValueKey(_order.wallet),
            controller: _amountController,
            onPick: _flow.pickPercentage,
          ),
          if (_amount.compareTo(_order.wallet.exactBalance) > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Amount exceeds your selected wallet balance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                color: DavoColors.of(context).danger,
              ),
            ),
          ],
        ],
      ),
      action: _PrimaryButton(
        label: 'Continue',
        enabled: _canContinue,
        onPressed: () {
          FocusScope.of(context).unfocus();
          final order = _order.copyWith(ngnAmount: _amount).freezeQuote();
          Navigator.of(context).push<void>(
            AppPageRoute<void>(builder: (_) => BuyReviewScreen(order: order)),
          );
        },
      ),
    );
  }
}

class BuyReviewScreen extends StatelessWidget {
  const BuyReviewScreen({super.key, required this.order});
  final BuyCryptoOrder order;
  @override
  Widget build(BuildContext context) => DavoListenableBuilder(
    listenable: WalletAccountState.instance,
    builder: (context, _) => _buildReview(context),
  );
  Widget _buildReview(BuildContext context) => Scaffold(
    backgroundColor: DavoColors.of(context).offWhite,
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: _PrimaryButton(
          label: 'Confirm',
          enabled: order.quoteCurrent,
          onPressed: () {
            if (!order.quoteCurrent) return;
            Navigator.of(context).push<void>(
              AppPageRoute<void>(builder: (_) => BuyPinScreen(order: order)),
            );
          },
        ),
      ),
    ),
    body: SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: _ExactTradeHeader(
                title: 'Buy',
                onBack: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            _ReviewExchangeCards(order: order),
            const SizedBox(height: 24),
            _ExactReviewSummary(
              rows: [
                ('Exchange Rate', order.formattedExchangeRate, false),
                ('Network Fee', 'Free', true),
                (
                  'Total you Pay',
                  '\u20a6${_formatNgn(order.exactNgnAmount)}',
                  false,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class BuyPinScreen extends StatelessWidget {
  const BuyPinScreen({super.key, required this.order});
  final BuyCryptoOrder order;
  @override
  Widget build(BuildContext context) => TransactionPinEntryScreen(
    onConfirm: () {
      if (!order.quoteCurrent) {
        Navigator.pop(context);
        return;
      }
      Navigator.of(context).pushReplacement<void, void>(
        AppPageRoute<void>(builder: (_) => BuyProgressScreen(order: order)),
      );
    },
  );
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
  final int _generation = WalletAccountState.instance.generation;
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    try {
      final accepted =
          await (widget.operation ?? PreviewTransactionOperation.buy());
      if (!mounted ||
          _generation != WalletAccountState.instance.generation ||
          ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      if (accepted == PreviewTransactionOutcome.failed) {
        setState(() => failed = true);
        return;
      }
      Navigator.of(context).pushReplacement<void, void>(
        AppPageRoute<void>(
          builder: (_) => BuySuccessScreen(order: widget.order),
        ),
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
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
        child: Column(
          children: [
            if (failed)
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: DavoColors.of(context).danger,
              )
            else
              const DavoWorkingIndicator(),
            const SizedBox(height: 16),
            Text(
              'Buying ${widget.order.formattedCryptoAmount} ${widget.order.asset.symbol}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: DavoColors.of(context).ink,
              ),
            ),
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
                color: DavoColors.of(context).body,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class BuySuccessScreen extends StatefulWidget {
  const BuySuccessScreen({super.key, required this.order, this.record});
  final BuyCryptoOrder order;
  final ReceiptRecord? record;
  @override
  State<BuySuccessScreen> createState() => _BuySuccessScreenState();
}

class _BuySuccessScreenState extends State<BuySuccessScreen>
    with ReceiptActivityObserver<BuySuccessScreen> {
  BuyCryptoOrder get order => widget.order;
  late final ReceiptRecord _fallback = buildBuyReceiptRecord(order);
  ReceiptRecord get record =>
      ReceiptActivity.resolve(widget.record ?? _fallback);
  @override
  void initState() {
    super.initState();
    if (widget.record == null) {
      submitAccountTransaction(context, record);
    } else {
      ReceiptActivity.accept(record);
    }
  }

  @override
  Widget build(BuildContext context) => DavoResultScreen(
    onExit: () => finishDavoTransaction(context, tab: 1),
    eventKey: '${record.id}-${record.status.name}',
    refreshRecordId: record.id,
    title: switch (record.status) {
      ReceiptStatus.completed => 'Purchase successful',
      ReceiptStatus.pending => 'Purchase submitted',
      ReceiptStatus.failed => 'Purchase failed',
    },
    kind: record.status == ReceiptStatus.pending
        ? DavoOutcomeKind.submitted
        : DavoOutcomeKind.completed,
    mark: record.status == ReceiptStatus.failed
        ? const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 100,
          )
        : null,
    message:
        '${record.status == ReceiptStatus.completed
            ? 'You bought'
            : record.status == ReceiptStatus.pending
            ? 'Purchase awaiting confirmation:'
            : 'Purchase failed:'} ${record.amount}.',
    appBar: AppBar(
      backgroundColor: DavoColors.of(context).surface,
      leading: IconButton(
        tooltip: 'Back to trade',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => finishDavoTransaction(context, tab: 1),
      ),
    ),
    actions: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PrimaryButton(
          label: 'View Details',
          enabled: true,
          onPressed: () => Navigator.of(context).push<void>(
            AppPageRoute<void>(
              builder: (_) =>
                  BuyTransactionDetailsScreen(order: order, record: record),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => finishDavoTransaction(
            context,
            tab: 1,
            start: (_) =>
                BuyAmountScreen(initialOrder: order.copyWith(ngnAmount: 0)),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: DavoColors.of(context).primarySoft,
            foregroundColor: DavoColors.of(context).link,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Buy more crypto'),
        ),
      ],
    ),
  );
}

class BuyTransactionDetailsScreen extends StatefulWidget {
  const BuyTransactionDetailsScreen({
    super.key,
    required this.order,
    this.record,
  });
  final BuyCryptoOrder order;
  final ReceiptRecord? record;
  @override
  State<BuyTransactionDetailsScreen> createState() =>
      _BuyTransactionDetailsScreenState();
}

class _BuyTransactionDetailsScreenState
    extends State<BuyTransactionDetailsScreen> {
  late final ReceiptRecord _fallback = buildBuyReceiptRecord(widget.order);
  ReceiptRecord get record =>
      ReceiptActivity.resolve(widget.record ?? _fallback);
  @override
  Widget build(BuildContext context) => TransactionRecordDetailsScreen(
    record: record,
    onDone: () => finishDavoTransaction(context, tab: 1),
    receiptBuilder: (_) => BuyReceiptScreen(
      order: widget.order,
      date: record.occurredAt,
      transactionId: record.id,
      record: record,
    ),
  );
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
          child: Image.asset(
            'assets/figma_exact/buy_back.png',
            color: DavoColors.of(context).ink,
            width: 32,
            height: 32,
          ),
        ),
      ),
      Positioned.fill(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.35,
              color: DavoColors.of(context).ink,
            ),
          ),
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
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: .5,
              color: DavoColors.of(context).divider,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth * .30,
                    child: Text(
                      rows[i].$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: DavoColors.of(context).bodyMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: rows[i].$3
                            ? DavoColors.of(context).link
                            : DavoColors.of(context).ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.asset, this.onModeSelected});
  final void Function(int, BuyCryptoAsset)? onModeSelected;
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: DavoColors.of(context).fieldFill,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Material(
            color: index == 0 ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: index == 0
                  ? null
                  : () {
                      if (onModeSelected != null) {
                        onModeSelected!(index, asset);
                        return;
                      }
                      Navigator.pushReplacement(
                        context,
                        AppPageRoute<void>(
                          builder: (_) => TradeAmountScreen(
                            mode: index == 1
                                ? TradeMode.sell
                                : TradeMode.convert,
                            asset: asset,
                          ),
                        ),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    ['Buy', 'Sell', 'Swap'][index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: index == 0
                          ? Colors.white
                          : DavoColors.of(context).body,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _WalletBadge extends StatelessWidget {
  const _WalletBadge({required this.wallet});
  final BuyFundingWallet wallet;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      wallet.iconAsset,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });
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
            fontFamily: 'Sora',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ReviewExchangeCards extends StatelessWidget {
  const _ReviewExchangeCards({required this.order});
  final BuyCryptoOrder order;
  Widget _card(
    BuildContext context,
    String label,
    Widget icon,
    String value,
    String subtitle,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DavoColors.of(context).surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DavoColors.of(context).bodyMuted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: DavoColors.of(context).bodyMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _card(
        context,
        'You will pay',
        _WalletBadge(wallet: order.wallet),
        '\u20a6${_formatNgn(order.exactNgnAmount)}',
        order.wallet.name,
      ),
      Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _card(
              context,
              'You will receive',
              BuyAssetIcon(asset: order.asset, size: 32),
              '${order.formattedCryptoAmount} ${order.asset.symbol}',
              '\u2248 \$${formatGroupedAmount(order.exactUsdAmount.toFixed(2))} USD',
            ),
          ),
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

String _formatNgn(ExactDecimal value) => formatGroupedAmount(value.toFixed(2));
