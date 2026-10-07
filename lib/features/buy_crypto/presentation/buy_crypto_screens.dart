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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(left: 0, right: 0, top: 16, height: 40, child: _ExactTradeHeader(title: 'Sell', onBack: () => Navigator.pop(context))),
            const Positioned(left: 16, right: 16, top: 76, height: 55, child: _ModeToggle()),
            Positioned(
              left: 89.5,
              top: 147,
              width: 211,
              height: 82,
              child: InkWell(
                onTap: _changeWallet,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    _WalletBadge(wallet: _order.wallet),
                    const SizedBox(height: 12),
                    Text(
                      '${_order.wallet.symbol} Balance',
                      style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: AppColors.body),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order.wallet.formattedBalance,
                      style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 253,
              height: 77,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _focusNode.hasFocus ? AppColors.primary : const Color(0xFFEBEDF3), width: _focusNode.hasFocus ? 1.2 : 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    if (_amountController.text.isNotEmpty)
                      const Text('₦', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        focusNode: _focusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), _ThousandsFormatter()],
                        onChanged: (_) => setState(() {}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0.00',
                          hintStyle: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                      ),
                    ),
                    Text(_order.wallet.symbol, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.body)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 32,
              right: 32,
              top: 354,
              height: 19,
              child: InkWell(
                onTap: _changeAsset,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('≈', style: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.2, color: AppColors.bodyMuted)),
                    const SizedBox(width: 4),
                    Text(
                      _amount == 0 ? r'$0.00' : '${crypto.toStringAsFixed(5)} ${_order.asset.symbol}',
                      style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.body),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 32,
              right: 32,
              top: 385,
              height: 19,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('1 USDT', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink)),
                  const SizedBox(width: 12),
                  const Text('≈', style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.bodyMuted)),
                  const SizedBox(width: 4),
                  Text('(₦${_formatNgn(BuyCryptoOrder.usdtNgnRate)})', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.bodyMuted)),
                ],
              ),
            ),
            Positioned(left: 32, right: 32, top: 436, height: 25, child: _PercentageButtons(balance: _order.wallet.balance, onPick: _setAmount)),
            if (_amount > _order.wallet.balance)
              const Positioned(left: 16, right: 16, top: 480, child: Text('Amount exceeds your selected wallet balance.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.danger))),
            Positioned(
              left: 16,
              right: 16,
              top: 653,
              height: 48,
              child: _PrimaryButton(
                label: 'Continue',
                enabled: _canContinue,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  final order = _order.copyWith(ngnAmount: _amount);
                  Navigator.of(context).push<void>(AppPageRoute<void>(builder: (_) => BuyReviewScreen(order: order)));
                },
              ),
            ),
          ],
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
        bottom: false,
        child: Stack(
          children: [
            Positioned(left: 0, right: 0, top: 16, height: 40, child: _ExactTradeHeader(title: 'Sell', onBack: () => Navigator.pop(context))),
            Positioned(left: 16, right: 16, top: 76, height: 193, child: _ReviewExchangeCards(order: order)),
            Positioned(
              left: 16,
              right: 16,
              top: 290,
              height: 192,
              child: _ExactReviewSummary(
                rows: [
                  ('Exchange Rate', '1 USDT   ₦${_formatNgn(BuyCryptoOrder.usdtNgnRate)}', false),
                  ('Network Fee', 'Free', true),
                  ('Total you Pay', '₦${_formatNgn(order.ngnAmount)}', false),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 661,
              height: 48,
              child: _PrimaryButton(
                label: 'Confirm',
                enabled: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push<void>(AppPageRoute<void>(builder: (_) => BuyPinScreen(order: order)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuyPinScreen extends StatefulWidget {
  const BuyPinScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  State<BuyPinScreen> createState() => _BuyPinScreenState();
}

class _BuyPinScreenState extends State<BuyPinScreen> {
  String pin = '';

  void _key(String value) {
    HapticFeedback.selectionClick();
    if (value == '⌫') {
      if (pin.isNotEmpty) setState(() => pin = pin.substring(0, pin.length - 1));
    } else if (pin.length < 4) {
      setState(() => pin += value);
    }
  }

  void _confirm() {
    if (pin.length != 4) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement<void, void>(AppPageRoute<void>(builder: (_) => BuyProgressScreen(order: widget.order)));
  }

  @override
  Widget build(BuildContext context) {
    final active = pin.length == 4;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: active ? _active(context) : _inactive(context),
        ),
      ),
    );
  }

  Widget _inactive(BuildContext context) => Stack(
        key: const ValueKey('buy-pin-inactive'),
        children: [
          Positioned(left: 6, top: 16, width: 32, height: 32, child: InkResponse(onTap: () => Navigator.pop(context), child: Image.asset('assets/figma_exact/buy_back.png', width: 32, height: 32))),
          Positioned(
            left: 147,
            top: 56,
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0x4DC4C6CF)), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))]),
              child: Image.asset('assets/figma_exact/buy_pin_shield.png', width: 32, height: 40),
            ),
          ),
          const Positioned(left: 54, top: 176, width: 282, height: 32, child: Text('Confirm Your Pin', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
          const Positioned(left: 54, top: 220, width: 282, height: 38, child: Text('Please enter your 4-digit security PIN to\nauthorize this transaction securely.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242)))),
          Positioned(left: 63, top: 298, child: _BuyPinSlots(pin: pin, active: false)),
          const Positioned(left: 16, right: 16, top: 394, height: 19, child: Text('Enter Secure PIN', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242)))),
          Positioned(left: 22, right: 22, top: 443, child: _BuyFigmaPinKeypad(onKey: _key)),
          const Positioned(left: 76, top: 743, width: 238, height: 15, child: Text('Authentication is required', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)))),
          Positioned(
            left: 104,
            top: 774,
            child: Row(
              children: [
                Image.asset('assets/figma_exact/buy_lock.png', width: 11, height: 14),
                const SizedBox(width: 8),
                const Text('ENCRYPTED END-TO-END', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, height: 1.5, letterSpacing: .1, color: Color(0xFF424242))),
              ],
            ),
          ),
        ],
      );

  Widget _active(BuildContext context) => Stack(
        key: const ValueKey('buy-pin-active'),
        children: [
          Positioned(left: 6, top: 20, width: 32, height: 32, child: InkResponse(onTap: () => Navigator.pop(context), child: Image.asset('assets/figma_exact/buy_back.png', width: 32, height: 32))),
          const Positioned(left: 16, top: 60, width: 360, height: 32, child: Text('Confirm Your Pin', style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
          const Positioned(left: 16, top: 104, width: 360, height: 38, child: Text('Please enter your 4-digit security PIN to\nauthorize this transaction securely.', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242)))),
          Positioned(left: 64, top: 158, child: _BuyPinSlots(pin: pin, active: true)),
          Positioned(left: 16, right: 14, top: 260, height: 48, child: _PrimaryButton(label: 'Confirm', enabled: true, onPressed: _confirm)),
          Positioned(left: 22, right: 22, top: 516, child: _BuyFigmaPinKeypad(onKey: _key)),
        ],
      );
}

class _BuyPinSlots extends StatelessWidget {
  const _BuyPinSlots({required this.pin, required this.active});
  final String pin;
  final bool active;

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(4, (i) {
          final filled = i < pin.length;
          return Container(
            width: 60,
            height: 70,
            margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white : const Color(0xFFF5F6F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: active ? AppColors.primary : const Color(0xFFEBEDF3)),
              boxShadow: active ? const [BoxShadow(color: Color(0x26135CF7), blurRadius: 5, offset: Offset(0, 1))] : null,
            ),
            child: filled ? Text(pin[i], style: const TextStyle(fontFamily: 'Poppins', fontSize: 40, fontWeight: FontWeight.w500, height: .9, color: Color(0xFF555555))) : null,
          );
        }),
      );
}

class _BuyFigmaPinKeypad extends StatelessWidget {
  const _BuyFigmaPinKeypad({required this.onKey});
  final ValueChanged<String> onKey;
  static const keys = [('1', ''), ('2', 'ABC'), ('3', 'DEF'), ('4', 'GHI'), ('5', 'JKL'), ('6', 'MNO'), ('7', 'PQRS'), ('8', 'TUV'), ('9', 'WXYZ'), ('', ''), ('0', ''), ('⌫', '')];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 205,
        child: Column(
          children: List.generate(4, (row) => SizedBox(
                height: row == 3 ? 46 : 53,
                child: Row(
                  children: List.generate(3, (col) {
                    final item = keys[(row * 3) + col];
                    if (item.$1.isEmpty) return const Expanded(child: SizedBox());
                    return Expanded(
                      child: InkWell(
                        onTap: () => onKey(item.$1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.$1, style: TextStyle(fontSize: item.$1 == '⌫' ? 22 : 25, height: 1, color: Colors.black)),
                            if (item.$2.isNotEmpty) Text(item.$2, style: const TextStyle(fontSize: 10, height: 1.3, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.black)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              )),
        ),
      );
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
        AppPageRoute<void>(builder: (_) => BuySuccessScreen(order: widget.order)),
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
                child: Image.asset('assets/figma_exact/buy_back.png', width: 24, height: 24),
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
                'Buying ${widget.order.cryptoAmount.toStringAsFixed(5)} ${widget.order.asset.symbol}',
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
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false),
                radius: 20,
                child: Image.asset('assets/figma_exact/buy_back.png', width: 24, height: 24),
              ),
            ),
            Positioned(
              left: 120,
              top: 91,
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/figma_exact/dashboard_crypto_gifs__dashbardandcryptgifs_4d6e1474ce658d29d4eaabd043e0c07fe0db035c.gif',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const Positioned(
              left: 51.5,
              top: 257,
              width: 287,
              height: 27,
              child: Text(
                'Sold  Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            Positioned(
              left: 51.5,
              top: 292,
              width: 287,
              height: 38,
              child: Text.rich(
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
                      text: ' 0.0300 ${order.asset.symbol} ',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    const TextSpan(text: 'for'),
                    TextSpan(
                      text: ' ₦${_formatNgn(order.ngnAmount)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 644,
              height: 48,
              child: _PrimaryButton(
                label: 'View Details',
                enabled: true,
                onPressed: () => Navigator.of(context).push<void>(
                  AppPageRoute<void>(builder: (_) => BuyTransactionDetailsScreen(order: order)),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 708,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement<void, void>(
                  AppPageRoute<void>(builder: (_) => BuyAmountScreen(initialOrder: order.copyWith(ngnAmount: 0))),
                ),
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFEAF0FB),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600),
                ),
                child: const Text('Send another transfer'),
              ),
            ),
          ],
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
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Text(
                        '${order.cryptoAmount.toStringAsFixed(4)} ${order.asset.symbol}',
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
                        '\$${order.usdAmount.toStringAsFixed(2)} USD',
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
                              value: '${order.asset.name} (${order.asset.symbol})',
                              leading: BuyAssetIcon(asset: order.asset, size: 24),
                            ),
                            const _DetailsDivider(),
                            _DetailsRow(
                              label: 'Date',
                              value: '${_month(now.month)} ${now.day}, ${now.year}, ${_two(now.hour)}:${_two(now.minute)}',
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt ready to share'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 1200),
                      ),
                    );
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
            child: InkResponse(onTap: onBack, radius: 22, child: Image.asset('assets/figma_exact/buy_back.png', width: 32, height: 32)),
          ),
          Positioned.fill(
            child: Center(
              child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w400, height: 1.35, color: AppColors.ink)),
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
        width: double.infinity,
        height: 192,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: List.generate(rows.length, (i) {
            final row = rows[i];
            final top = 31.5 + (i * 47.0);
            return Positioned(
              left: 15,
              right: 15,
              top: top,
              height: i == rows.length - 1 ? 35 : 35,
              child: Column(
                children: [
                  SizedBox(
                    height: 19,
                    child: Row(
                      children: [
                        Text(row.$1, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.bodyMuted)),
                        const Spacer(),
                        Flexible(child: Text(row.$2, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: row.$3 ? AppColors.primary : AppColors.ink))),
                      ],
                    ),
                  ),
                  if (i != rows.length - 1) ...[
                    const SizedBox(height: 15),
                    const Divider(height: 1, thickness: .5, color: Color(0xFFF2F2F2)),
                  ],
                ],
              ),
            );
          }),
        ),
      );
}

class _TradeTopBar extends StatelessWidget {
  const _TradeTopBar({required this.title, required this.onBack, this.compactTitle = false});
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
              icon: Image.asset('assets/figma_exact/buy_back.png', width: 24, height: 24),
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
  const _ModeToggle();

  @override
  Widget build(BuildContext context) => Container(
        height: 55,
        decoration: BoxDecoration(color: const Color(0xFFF3F3F9), borderRadius: BorderRadius.circular(999)),
        child: const Stack(
          children: [
            Positioned(left: 15, top: 6, width: 101, height: 43, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(999))))),
            Positioned(left: 15, top: 6, width: 101, height: 43, child: Center(child: Text('Buy', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)))),
            Positioned(left: 128, top: 6, width: 101, height: 43, child: Center(child: Text('Sell', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)))),
            Positioned(left: 241, top: 6, width: 101, height: 43, child: Center(child: Text('Convert', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)))),
          ],
        ),
      );
}

class _WalletBadge extends StatelessWidget {
  const _WalletBadge({required this.wallet});
  final BuyFundingWallet wallet;

  @override
  Widget build(BuildContext context) {
    if (wallet.isDavochain) {
      return Image.asset('assets/figma_exact/dashboard_crypto_images__Davochain_Logo.png', width: 32, height: 32, fit: BoxFit.contain, filterQuality: FilterQuality.high);
    }
    return const NigeriaFlagMark(width: 32);
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
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 92,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF5F6F9)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  const Positioned(left: 16, top: 14, child: Text('You will pay', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.bodyMuted))),
                  Positioned(left: 18, top: 44.5, width: 32, height: 32, child: _WalletBadge(wallet: order.wallet)),
                  Positioned(left: 62, top: 41, child: Text('₦${_formatNgn(order.ngnAmount)}', style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
                  Positioned(left: 62, top: 66, child: Text(order.wallet.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.bodyMuted))),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 101,
            height: 92,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF5F6F9)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  const Positioned(left: 16, top: 14, child: Text('You will receive', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.bodyMuted))),
                  Positioned(left: 16, top: 44.5, width: 32, height: 32, child: Center(child: BuyAssetIcon(asset: order.asset, size: 20))),
                  Positioned(left: 54, top: 41, child: Text(order.cryptoAmount.toStringAsFixed(5), style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
                  const Positioned(left: 54, top: 65.5, child: Text('≈', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.0, color: AppColors.bodyMuted))),
                  Positioned(left: 72, top: 66, child: Text('\$${order.usdAmount.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.bodyMuted))),
                ],
              ),
            ),
          ),
          Positioned(
            left: 159,
            top: 78,
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle),
              child: Image.asset('assets/figma_exact/buy_exchange_down.png', width: 24, height: 24, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 14,
            height: 1.35,
            color: AppColors.bodyMuted,
          ),
        ),
        const Spacer(),
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              height: 1.35,
              color: accent ? AppColors.primary : AppColors.ink,
            ),
          ),
        ),
        if (copyable) ...[
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(18),
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
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Image.asset(
                'assets/figma_exact/buy_copy.png',
                width: 16,
                height: 16,
              ),
            ),
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
