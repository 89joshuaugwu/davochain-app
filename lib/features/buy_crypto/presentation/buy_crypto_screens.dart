import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../../shared/widgets/davo_toast.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../../../shared/widgets/receipt_detail_row.dart';
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .40),
      builder: (_) => const BuyCryptoAssetSheet(),
    );
    if (!mounted || asset == null) return;
    setState(() => _order = _order.copyWith(asset: asset));
  }

  Future<void> _changeWallet() async {
    final wallet = await showModalBottomSheet<BuyFundingWallet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .40),
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
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: AppColors.body),
              ),
              const SizedBox(height: 4),
              Text(
                _order.wallet.formattedBalance,
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.primary
                    : const Color(0xFFEBEDF3),
                width: _focusNode.hasFocus ? 1.2 : 1),
            borderRadius: BorderRadius.circular(4),
          ),
          height: 77,
          child: Row(
            children: [
              if (_amountController.text.isNotEmpty)
                const Text('₦',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [GroupedAmountInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                ),
              ),
              Text(_order.wallet.symbol,
                  style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      height: 1.35,
                      color: AppColors.body)),
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
              const Text('≈',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      height: 1.2,
                      color: AppColors.bodyMuted)),
              const SizedBox(width: 4),
              Text(
                '${formatGroupedAmount(crypto.toStringAsFixed(5))} ${_order.asset.symbol}',
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.body),
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
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.ink)),
            const SizedBox(width: 12),
            const Text('≈',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: AppColors.bodyMuted)),
            const SizedBox(width: 4),
            Text('(₦${_formatNgn(_order.asset.ngnPerUnit)})',
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.bodyMuted)),
          ],
        ),
        const SizedBox(height: 24),
        _PercentageButtons(balance: _order.wallet.balance, onPick: _setAmount),
        if (_amount > _order.wallet.balance) ...[
          const SizedBox(height: 16),
          const Text('Amount exceeds your selected wallet balance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sora', fontSize: 12, color: AppColors.danger)),
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
        backgroundColor: AppColors.offWhite,
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
  const BuyProgressScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  State<BuyProgressScreen> createState() => _BuyProgressScreenState();
}

class _BuyProgressScreenState extends State<BuyProgressScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement<void, void>(
        AppPageRoute<void>(
            builder: (_) => BuySuccessScreen(order: widget.order)),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              top: 16,
              width: 24,
              height: 24,
              child: InkResponse(
                onTap: () => Navigator.pop(context),
                radius: 20,
                child: Image.asset('assets/figma_exact/buy_back.png',
                    width: 24, height: 24),
              ),
            ),
            Positioned(
              left: 120,
              top: 91,
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/figma_exact/dashboard_crypto_gifs__dashbardandcryptgifs_a56b5b485b8874cc26d0b3c667bfc016ba68cf23.gif',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: 34,
              right: 33,
              top: 257,
              height: 22,
              child: Text(
                'Buying ${formatGroupedAmount(widget.order.cryptoAmount.toStringAsFixed(5))} ${widget.order.asset.symbol}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            const Positioned(
              left: 34,
              right: 33,
              top: 287,
              height: 19,
              child: Text(
                'Please wait while we process your Conversion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuySuccessScreen extends StatelessWidget {
  const BuySuccessScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  Widget build(BuildContext context) => DavoResultScreen(
        title: 'Purchase successful',
        message:
            'You bought ${formatGroupedAmount(order.cryptoAmount.toStringAsFixed(4))} ${order.asset.symbol} for \u20A6${_formatNgn(order.ngnAmount)}.',
        appBar: AppBar(
            backgroundColor: Colors.white,
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
                      builder: (_) =>
                          BuyTransactionDetailsScreen(order: order)))),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement<void, void>(
                AppPageRoute<void>(
                    builder: (_) => BuyAmountScreen(
                        initialOrder: order.copyWith(ngnAmount: 0)))),
            style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFFEAF0FB),
                foregroundColor: AppColors.primary,
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

class BuyTransactionDetailsScreen extends StatelessWidget {
  const BuyTransactionDetailsScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final transactionId = '0x3a4f...9c7d';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              _TradeTopBar(
                title: 'Transaction Details',
                onBack: () => Navigator.pop(context),
                compactTitle: true,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        '${formatGroupedAmount(order.cryptoAmount.toStringAsFixed(4))} ${order.asset.symbol}',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 24,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${formatGroupedAmount(order.usdAmount.toStringAsFixed(2))} USD',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.body,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 94,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F9ED),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1BA44D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(15, 22, 15, 22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const _DetailsRow(label: 'To', value: 'Callieweb3'),
                            const _DetailsDivider(),
                            _DetailsRow(
                              label: 'Asset',
                              value:
                                  '${order.asset.name} (${order.asset.symbol})',
                              leading:
                                  BuyAssetIcon(asset: order.asset, size: 24),
                            ),
                            const _DetailsDivider(),
                            _DetailsRow(
                              label: 'Date',
                              value:
                                  '${_month(now.month)} ${now.day}, ${now.year}, ${_two(now.hour)}:${_two(now.minute)}',
                            ),
                            const _DetailsDivider(),
                            const _DetailsRow(
                              label: 'Network Fee',
                              value: 'Free',
                              accent: true,
                            ),
                            const _DetailsDivider(),
                            _DetailsRow(
                              label: 'Transaction ID',
                              value: transactionId,
                              copyable: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _PrimaryButton(
                label: 'Done',
                enabled: true,
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.dashboard,
                  (route) => false,
                ),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(AppPageRoute<void>(
                        builder: (_) => BuyReceiptScreen(
                            order: order,
                            date: now,
                            transactionId: transactionId)));
                  },
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEAF0FB),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Share Receipt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                    width: 32, height: 32)),
          ),
          Positioned.fill(
            child: Center(
              child: Text(title,
                  style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: AppColors.ink)),
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
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: .5, color: Color(0xFFEBEDF3)),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: LayoutBuilder(
                    builder: (context, constraints) => Row(children: [
                          SizedBox(
                              width: constraints.maxWidth * .30,
                              child: Text(rows[i].$1,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.bodyMuted))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(rows[i].$2,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      color: rows[i].$3
                                          ? AppColors.primary
                                          : AppColors.ink))),
                        ]))),
          ],
        ]),
      );
}

class _TradeTopBar extends StatelessWidget {
  const _TradeTopBar(
      {required this.title, required this.onBack, this.compactTitle = false});
  final String title;
  final VoidCallback onBack;
  final bool compactTitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: Image.asset('assets/figma_exact/buy_back.png',
                  width: 24, height: 24),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: compactTitle ? 14 : 20,
              height: 1.35,
              fontWeight: compactTitle ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.asset});
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: const Color(0xFFF3F3F9),
            borderRadius: BorderRadius.circular(999)),
        child: Row(
            children: List.generate(
                3,
                (index) => Expanded(
                        child: Material(
                      color: index == 0 ? Colors.white : Colors.transparent,
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
                                child: Text(['Buy', 'Sell', 'Convert'][index],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: index == 0
                                            ? AppColors.primary
                                            : AppColors.body)))),
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
              color: const Color(0xFFF8F9FB),
              border: Border.all(color: const Color(0xFFEEF0F5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                color: index == 4 ? AppColors.primary : AppColors.body,
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
          disabledBackgroundColor: AppColors.primaryDisabled,
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
  Widget _card(String label, Widget icon, String value, String subtitle) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
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
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.bodyMuted)),
                ]))
          ]),
        ]),
      );
  @override
  Widget build(BuildContext context) => Column(children: [
        _card('You will pay', _WalletBadge(wallet: order.wallet),
            '\u20a6${_formatNgn(order.ngnAmount)}', order.wallet.name),
        Stack(clipBehavior: Clip.none, children: [
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _card(
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
                      decoration: const BoxDecoration(
                          color: Color(0xFFF4F7FF), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_downward_rounded,
                          size: 22, color: AppColors.primary)))),
        ]),
      ]);
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.leading,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool copyable;
  final Widget? leading;
  final bool accent;

  @override
  Widget build(BuildContext context) => ReceiptDetailRow(
        label: label,
        value: value,
        copyable: copyable,
        leading: leading,
        valueColor: accent ? AppColors.primary : AppColors.ink,
        onCopy: () {
          HapticFeedback.selectionClick();
          showDavoToast(context, 'Transaction ID copied');
        },
      );
}

class _DetailsDivider extends StatelessWidget {
  const _DetailsDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Divider(height: 1, thickness: .5, color: Color(0xFFEBEDF3)),
      );
}

String _formatEditable(double value) =>
    formatGroupedAmount(value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2));

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

String _two(int value) => value.toString().padLeft(2, '0');

String _month(int month) => const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
