import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import 'buy_crypto_models.dart';
import 'buy_crypto_widgets.dart';

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
    final normalized = _amountController.text.replaceAll(',', '').replaceAll('₦', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  bool get _canContinue => _amount > 0 && _amount <= _order.wallet.balance;

  void _setAmount(double value) {
    HapticFeedback.selectionClick();
    final safe = value.clamp(0.0, _order.wallet.balance).toDouble();
    _amountController.text = _formatEditable(safe);
    _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
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
      _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
    }
    setState(() => _order = _order.copyWith(wallet: wallet));
  }

  @override
  Widget build(BuildContext context) {
    final crypto = _amount / _order.asset.ngnPerUnit;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              _TradeTopBar(title: 'Buy', onBack: () => Navigator.pop(context)),
              const SizedBox(height: 18),
              const _ModeToggle(),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _changeWallet,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              _WalletBadge(wallet: _order.wallet),
                              const SizedBox(height: 10),
                              Text(
                                '${_order.wallet.symbol} Balance',
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.body,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _order.wallet.formattedBalance,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 77,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _focusNode.hasFocus ? AppColors.primary : const Color(0xFFEBEDF3),
                            width: _focusNode.hasFocus ? 1.2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 160),
                              opacity: _amountController.text.isEmpty ? 0 : 1,
                              child: const Text(
                                '₦',
                                style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                focusNode: _focusNode,
                                autofocus: false,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), _ThousandsFormatter()],
                                onChanged: (_) => setState(() {}),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                                decoration: const InputDecoration(
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Text(
                              _order.wallet.symbol,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                color: AppColors.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: Tween(begin: .98, end: 1.0).animate(animation), child: child),
                        ),
                        child: Column(
                          key: ValueKey('${_amount.toStringAsFixed(2)}-${_order.asset.name}'),
                          children: [
                            InkWell(
                              onTap: _changeAsset,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('≈', style: TextStyle(fontFamily: 'Sora', fontSize: 18, color: AppColors.bodyMuted)),
                                    const SizedBox(width: 5),
                                    Text(
                                      _amount == 0 ? '\$0.00' : '${crypto.toStringAsFixed(5)} ${_order.asset.symbol}',
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '1 USDT',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('≈', style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.bodyMuted)),
                                const SizedBox(width: 4),
                                Text(
                                  '(₦${_formatNgn(BuyCryptoOrder.usdtNgnRate)})',
                                  style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.bodyMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _PercentageButtons(
                        balance: _order.wallet.balance,
                        onPick: _setAmount,
                      ),
                      if (_amount > _order.wallet.balance) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Amount exceeds your selected wallet balance.',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: 'Continue',
                enabled: _canContinue,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  final order = _order.copyWith(ngnAmount: _amount);
                  Navigator.of(context).push<void>(
                    AppPageRoute<void>(builder: (_) => BuyReviewScreen(order: order)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuyReviewScreen extends StatelessWidget {
  const BuyReviewScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              _TradeTopBar(title: 'Buy', onBack: () => Navigator.pop(context)),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _ReviewExchangeCards(order: order),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _ReviewRow(
                              label: 'Exchange Rate',
                              value: '1 USDT ≈ ₦${_formatNgn(BuyCryptoOrder.usdtNgnRate)}',
                            ),
                            const _ReviewDivider(),
                            const _ReviewRow(label: 'Network Fee', value: 'Free', accent: true),
                            const _ReviewDivider(),
                            _ReviewRow(label: 'Total you Pay', value: '₦${_formatNgn(order.ngnAmount)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _PrimaryButton(
                label: 'Confirm',
                enabled: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pushReplacement<void, void>(
                    AppPageRoute<void>(builder: (_) => BuyProgressScreen(order: order)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuyProgressScreen extends StatefulWidget {
  const BuyProgressScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  State<BuyProgressScreen> createState() => _BuyProgressScreenState();
}

class _BuyProgressScreenState extends State<BuyProgressScreen> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1050))..repeat();
    _timer = Timer(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement<void, void>(
        AppPageRoute<void>(builder: (_) => BuySuccessScreen(order: widget.order)),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 4,
              top: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: const Offset(0, -130),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => CustomPaint(
                          painter: _ProcessingPainter(progress: _pulse.value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Buying ${widget.order.cryptoAmount.toStringAsFixed(5)} ${widget.order.asset.symbol}',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait while we process your purchase',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuySuccessScreen extends StatefulWidget {
  const BuySuccessScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  State<BuySuccessScreen> createState() => _BuySuccessScreenState();
}

class _BuySuccessScreenState extends State<BuySuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 720));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -66),
                    child: FadeTransition(
                      opacity: _fade,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _scale,
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .10),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 74,
                                  height: 74,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'Purchase Successful',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 20,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                height: 1.35,
                                color: AppColors.bodyMuted,
                              ),
                              children: [
                                const TextSpan(text: 'You have successfully bought '),
                                TextSpan(
                                  text: '${widget.order.cryptoAmount.toStringAsFixed(4)} ${widget.order.asset.symbol}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                                ),
                                const TextSpan(text: ' for '),
                                TextSpan(
                                  text: '₦${_formatNgn(widget.order.ngnAmount)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _PrimaryButton(
                label: 'View Details',
                enabled: true,
                onPressed: () => Navigator.of(context).push<void>(
                  AppPageRoute<void>(builder: (_) => BuyTransactionDetailsScreen(order: widget.order)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement<void, void>(
                    AppPageRoute<void>(builder: (_) => BuyAmountScreen(initialOrder: widget.order.copyWith(ngnAmount: 0))),
                  ),
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEAF0FB),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Buy another asset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuyTransactionDetailsScreen extends StatelessWidget {
  const BuyTransactionDetailsScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final transactionId = 'DVC-BUY-${now.millisecondsSinceEpoch.toString().substring(5)}';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              _TradeTopBar(title: 'Transaction Details', onBack: () => Navigator.pop(context)),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      BuyAssetIcon(asset: order.asset, size: 56),
                      const SizedBox(height: 14),
                      Text(
                        '${order.cryptoAmount.toStringAsFixed(5)} ${order.asset.symbol}',
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\$${order.usdAmount.toStringAsFixed(2)} USD',
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.bodyMuted),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFF3FAF5), borderRadius: BorderRadius.circular(100)),
                        child: const Text(
                          'Completed',
                          style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            _DetailsRow(label: 'Asset', value: '${order.asset.name} (${order.asset.symbol})'),
                            const _DetailsDivider(),
                            _DetailsRow(label: 'Paid from', value: '${order.wallet.name} (${order.wallet.symbol})'),
                            const _DetailsDivider(),
                            _DetailsRow(label: 'Amount paid', value: '₦${_formatNgn(order.ngnAmount)}'),
                            const _DetailsDivider(),
                            _DetailsRow(label: 'Exchange rate', value: '1 ${order.asset.symbol} ≈ ₦${_formatNgn(order.asset.ngnPerUnit)}'),
                            const _DetailsDivider(),
                            const _DetailsRow(label: 'Network fee', value: 'Free'),
                            const _DetailsDivider(),
                            _DetailsRow(
                              label: 'Date',
                              value: '${_month(now.month)} ${now.day}, ${now.year}, ${_two(now.hour)}:${_two(now.minute)}',
                            ),
                            const _DetailsDivider(),
                            _DetailsRow(label: 'Transaction ID', value: transactionId, copyable: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/images/brand/davochain_logo.png', width: 26, height: 26, fit: BoxFit.contain),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Davochain • Transaction receipt',
                                style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
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
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeTopBar extends StatelessWidget {
  const _TradeTopBar({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.ink),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFFF3F3F9), borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 43,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
              child: const Text(
                'Buy',
                style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
          const Expanded(child: Center(child: Text('Sell', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)))),
          const Expanded(child: Center(child: Text('Convert', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)))),
        ],
      ),
    );
  }
}

class _WalletBadge extends StatelessWidget {
  const _WalletBadge({required this.wallet});
  final BuyFundingWallet wallet;

  @override
  Widget build(BuildContext context) {
    if (wallet.isDavochain) {
      return Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          child: Image.asset('assets/images/brand/davochain_logo.png', fit: BoxFit.contain),
        ),
      );
    }
    return const NigeriaFlagCircle(size: 32);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(values.length, (index) {
        return InkWell(
          onTap: () => onPick(balance * values[index]),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 46,
            height: 25,
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
  const _PrimaryButton({required this.label, required this.enabled, required this.onPressed});
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
          disabledBackgroundColor: const Color(0xFFC4C5CA),
          disabledForegroundColor: AppColors.body,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ReviewExchangeCards extends StatelessWidget {
  const _ReviewExchangeCards({required this.order});
  final BuyCryptoOrder order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 193,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ReviewMoneyCard(
              label: 'You will pay',
              leading: _WalletBadge(wallet: order.wallet),
              primary: '₦${_formatNgn(order.ngnAmount)}',
              secondary: order.wallet.name,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ReviewMoneyCard(
              label: 'You will receive',
              leading: BuyAssetIcon(asset: order.asset, size: 32),
              primary: order.cryptoAmount.toStringAsFixed(5),
              secondary: '≈ \$${order.usdAmount.toStringAsFixed(2)}',
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 23),
          ),
        ],
      ),
    );
  }
}

class _ReviewMoneyCard extends StatelessWidget {
  const _ReviewMoneyCard({required this.label, required this.leading, required this.primary, required this.secondary});
  final String label;
  final Widget leading;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF5F6F9)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.bodyMuted)),
          const Spacer(),
          Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(primary, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.body)),
                  const SizedBox(height: 1),
                  Text(secondary, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.bodyMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, this.accent = false});
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.bodyMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: accent ? AppColors.primary : AppColors.ink),
          ),
        ),
      ],
    );
  }
}

class _ReviewDivider extends StatelessWidget {
  const _ReviewDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, thickness: .5, color: Color(0xFFEBEDF3)),
      );
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value, this.copyable = false});
  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.bodyMuted)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
        ),
        if (copyable) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction ID copied'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(milliseconds: 1200),
                ),
              );
            },
            child: const Icon(Icons.copy_rounded, size: 17, color: AppColors.bodyMuted),
          ),
        ],
      ],
    );
  }
}

class _DetailsDivider extends StatelessWidget {
  const _DetailsDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Divider(height: 1, thickness: .5, color: Color(0xFFEBEDF3)),
      );
}

class _ProcessingPainter extends CustomPainter {
  const _ProcessingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = AppColors.primary;
    final angle = progress * math.pi * 2;
    for (var i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1;
      final radius = 10 + 25 * math.sin(phase * math.pi).abs();
      final theta = angle + i * (math.pi * 2 / 3);
      final p = center + Offset(math.cos(theta), math.sin(theta)) * (22 + 18 * phase);
      canvas.drawCircle(p, radius * .35, paint..color = AppColors.primary.withValues(alpha: .45 + .5 * (1 - phase)));
    }
    canvas.drawCircle(center, 25 + 5 * math.sin(progress * math.pi * 2), Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _ProcessingPainter oldDelegate) => oldDelegate.progress != progress;
}


class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return newValue.copyWith(text: '');
    final parts = raw.split('.');
    if (parts.length > 2) return oldValue;
    final digits = parts.first.replaceAll(RegExp(r'[^0-9]'), '');
    final grouped = _groupDigits(digits);
    final decimal = parts.length == 2 ? '.${parts[1].replaceAll(RegExp(r'[^0-9]'), '').substring(0, math.min(2, parts[1].replaceAll(RegExp(r'[^0-9]'), '').length))}' : '';
    final text = '$grouped$decimal';
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  static String _groupDigits(String digits) {
    if (digits.length <= 3) return digits;
    final chars = digits.split('').reversed.toList();
    final groups = <String>[];
    for (var i = 0; i < chars.length; i += 3) {
      groups.add(chars.sublist(i, math.min(i + 3, chars.length)).reversed.join());
    }
    return groups.reversed.join(',');
  }
}

String _formatEditable(double value) {
  final fixed = value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final grouped = _ThousandsFormatter._groupDigits(parts.first);
  return parts.length == 2 ? '$grouped.${parts[1]}' : grouped;
}

String _formatNgn(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final reversed = whole.split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < reversed.length; i += 3) {
    chunks.add(reversed.sublist(i, math.min(i + 3, reversed.length)).reversed.join());
  }
  return '${chunks.reversed.join(',')}.${parts[1]}';
}

String _two(int value) => value.toString().padLeft(2, '0');

String _month(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];
