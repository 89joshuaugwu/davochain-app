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
                  Navigator.of(context).push<void>(
                    AppPageRoute<void>(builder: (_) => BuyPinScreen(order: order)),
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

class BuyPinScreen extends StatefulWidget {
  const BuyPinScreen({super.key, required this.order});
  final BuyCryptoOrder order;

  @override
  State<BuyPinScreen> createState() => _BuyPinScreenState();
}

class _BuyPinScreenState extends State<BuyPinScreen> {
  final List<int> _digits = <int>[];

  void _pressDigit(int digit) {
    if (_digits.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() => _digits.add(digit));
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _digits.removeLast());
  }

  void _confirm() {
    if (_digits.length != 4) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement<void, void>(
      AppPageRoute<void>(builder: (_) => BuyProgressScreen(order: widget.order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complete = _digits.length == 4;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 1,
              top: 6,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Image.asset(
                  'assets/images/figma/buy_back.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Positioned.fill(
              top: 48,
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x4DC4C6CF)),
                    ),
                    child: Image.asset(
                      'assets/images/figma/buy_pin_shield.png',
                      width: 32,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Confirm Your Pin',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 24,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 44),
                    child: Text(
                      'Please enter your 4-digit security PIN to\nauthorize this transaction securely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final filled = index < _digits.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: 60,
                        height: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: filled ? Colors.white : const Color(0xFFF5F6F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: filled ? AppColors.primary : const Color(0xFFEBEDF3),
                          ),
                          boxShadow: filled
                              ? const [BoxShadow(color: Color(0x40135CF7), blurRadius: 4)]
                              : const [],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          transitionBuilder: (child, animation) => ScaleTransition(
                            scale: animation,
                            child: FadeTransition(opacity: animation, child: child),
                          ),
                          child: filled
                              ? Text(
                                  '${_digits[index]}',
                                  key: ValueKey(_digits[index]),
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 38,
                                    height: 1,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF555555),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 26),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: complete
                        ? Padding(
                            key: const ValueKey('confirm'),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _PrimaryButton(
                              label: 'Confirm',
                              enabled: true,
                              onPressed: _confirm,
                            ),
                          )
                        : const Text(
                            'Enter Secure PIN',
                            key: ValueKey('hint'),
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              color: Color(0xFF434656),
                            ),
                          ),
                  ),
                  const Spacer(),
                  _PinKeypad(
                    onDigit: _pressDigit,
                    onBackspace: _backspace,
                  ),
                  const SizedBox(height: 14),
                  if (!complete) ...[
                    const Text(
                      'Authentication is required',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/figma/buy_lock.png',
                          width: 11,
                          height: 14,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ENCRYPTED END-TO-END',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: AppColors.body,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({required this.onDigit, required this.onBackspace});
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  static const _letters = <int, String>{
    2: 'ABC', 3: 'DEF', 4: 'GHI', 5: 'JKL', 6: 'MNO',
    7: 'PQRS', 8: 'TUV', 9: 'WXYZ',
  };

  @override
  Widget build(BuildContext context) {
    Widget key(int number) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3.5),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.6),
              elevation: .7,
              child: InkWell(
                onTap: () => onDigit(number),
                borderRadius: BorderRadius.circular(4.6),
                child: SizedBox(
                  height: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$number',
                        style: const TextStyle(
                          fontSize: 25,
                          height: .95,
                          color: Colors.black,
                        ),
                      ),
                      if (_letters.containsKey(number))
                        Text(
                          _letters[number]!,
                          style: const TextStyle(
                            fontSize: 9,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

    Widget blank() => const Expanded(child: SizedBox(height: 53));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(3.5, 3, 3.5, 7),
      color: const Color(0xFFF5F6F9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [key(1), key(2), key(3)]),
          Row(children: [key(4), key(5), key(6)]),
          Row(children: [key(7), key(8), key(9)]),
          Row(
            children: [
              blank(),
              key(0),
              Expanded(
                child: InkWell(
                  onTap: onBackspace,
                  child: SizedBox(
                    height: 53,
                    child: Center(
                      child: Image.asset(
                        'assets/images/figma/buy_backspace.png',
                        width: 34,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
                icon: Image.asset('assets/images/figma/buy_back.png', width: 24, height: 24),
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
                        builder: (_, child) {
                          final wave = math.sin(_pulse.value * math.pi * 2);
                          return Transform.scale(
                            scale: .985 + ((wave + 1) * .0075),
                            child: Opacity(
                              opacity: .9 + ((wave + 1) * .05),
                              child: child,
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/figma/buy_process.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
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
                      'Please wait while we process your Conversion',
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
                  icon: Image.asset('assets/images/figma/buy_back.png', width: 24, height: 24),
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
                            child: const SizedBox(width: 150, height: 150),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sold Successful',
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
                  child: const Text('Send another transfer'),
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
              icon: Image.asset('assets/images/figma/buy_back.png', width: 24, height: 24),
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
          Image.asset(
            'assets/images/figma/buy_exchange_down.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
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
                'assets/images/figma/buy_copy.png',
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
