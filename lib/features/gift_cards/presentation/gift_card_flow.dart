import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_input_decoration.dart';

const _g = 'assets/figma_exact';
const _f = 'assets/figma_exact';

enum GiftCardMode { buy, sell }

enum GiftCardCategory { all, shopping, gaming, streaming, food }

class GiftCardBrand {
  const GiftCardBrand({
    required this.name,
    required this.asset,
    this.subtitle,
    this.rate,
    this.hot = false,
    this.category = GiftCardCategory.shopping,
  });

  final String name;
  final String asset;
  final String? subtitle;
  final String? rate;
  final bool hot;
  final GiftCardCategory category;
}

const _brands = <GiftCardBrand>[
  GiftCardBrand(name: 'Amazon', asset: '$_g/amazon.png', subtitle: 'Fast payout', rate: '₦865/\$1', hot: true),
  GiftCardBrand(name: 'iTunes/Apple', asset: '$_g/apple.png', subtitle: '99% accepted', rate: '₦865/\$1', category: GiftCardCategory.streaming),
  GiftCardBrand(name: 'Google Play', asset: '$_g/google_play.png', category: GiftCardCategory.gaming),
  GiftCardBrand(name: 'Steam', asset: '$_g/steam.png', category: GiftCardCategory.gaming),
  GiftCardBrand(name: 'Walmart', asset: '$_g/walmart.png'),
  GiftCardBrand(name: 'Razer Gold', asset: '$_g/razer.png', category: GiftCardCategory.gaming),
  GiftCardBrand(name: 'Ebay Gift Card', asset: '$_g/ebay.png'),
  GiftCardBrand(name: 'American Express (AMEX) Gift Card', asset: '$_g/amex.png'),
];

Future<void> startGiftCardFlow(BuildContext context, {GiftCardMode mode = GiftCardMode.buy}) async {
  HapticFeedback.selectionClick();
  await Navigator.of(context).push<void>(
    AppPageRoute<void>(builder: (_) => GiftCardHomeScreen(initialMode: mode)),
  );
}

class GiftCardHomeScreen extends StatefulWidget {
  const GiftCardHomeScreen({super.key, this.initialMode = GiftCardMode.buy});

  final GiftCardMode initialMode;

  @override
  State<GiftCardHomeScreen> createState() => _GiftCardHomeScreenState();
}

class _GiftCardHomeScreenState extends State<GiftCardHomeScreen> {
  late GiftCardMode mode;

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
  }

  void _setMode(GiftCardMode value) {
    HapticFeedback.selectionClick();
    setState(() => mode = value);
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Gift cards', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 22),
          const Text('Gift Cards', style: _title20),
          const SizedBox(height: 2),
          const Text('Buy and sell gift cards instantly', style: _body14),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _softCard,
            child: const Row(
              children: [
                Expanded(child: _Stat(label: '24h Volume', value: '₦42M')),
                SizedBox(height: 38, child: VerticalDivider(color: Color(0xFFEBEDF3))),
                Expanded(child: _Stat(label: 'Active Now', value: '2,840')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ModeTabs(mode: mode, onChanged: _setMode),
          const SizedBox(height: 22),
          const Text('Top Gift Cards', style: _section),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TopBrandCard(brand: _brands[0], accent: const Color(0xFFF59E0B), onTap: () => _openBrand(_brands[0]))),
              const SizedBox(width: 12),
              Expanded(child: _TopBrandCard(brand: _brands[1], accent: const Color(0xFF151515), onTap: () => _openBrand(_brands[1]))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Popular Brands', style: _section),
              const Spacer(),
              InkWell(
                onTap: _openSelector,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text('View All', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PopularBrand(brand: _brands[2], onTap: () => _openBrand(_brands[2])),
              _PopularBrand(brand: _brands[3], onTap: () => _openBrand(_brands[3])),
              _PopularBrand(brand: _brands[5], onTap: () => _openBrand(_brands[5])),
              _PopularBrand(brand: _brands[4], onTap: () => _openBrand(_brands[4])),
            ],
          ),
          const SizedBox(height: 28),
          _ReferralCard(onTap: () => HapticFeedback.lightImpact()),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _openBrand(GiftCardBrand brand) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      AppPageRoute<void>(
        builder: (_) => mode == GiftCardMode.buy
            ? GiftCardBuyFormScreen(brand: brand)
            : GiftCardSellFormScreen(brand: brand),
      ),
    );
  }

  void _openSelector() {
    Navigator.of(context).push<void>(
      AppPageRoute<void>(builder: (_) => GiftCardBrandScreen(mode: mode)),
    );
  }
}

class GiftCardBrandScreen extends StatefulWidget {
  const GiftCardBrandScreen({super.key, required this.mode});
  final GiftCardMode mode;

  @override
  State<GiftCardBrandScreen> createState() => _GiftCardBrandScreenState();
}

class _GiftCardBrandScreenState extends State<GiftCardBrandScreen> {
  final controller = TextEditingController();
  GiftCardCategory category = GiftCardCategory.all;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = controller.text.trim().toLowerCase();
    final visible = _brands.where((brand) {
      final matchesQuery = q.isEmpty || brand.name.toLowerCase().contains(q);
      final matchesCategory = category == GiftCardCategory.all || brand.category == category;
      return matchesQuery && matchesCategory;
    }).toList();

    return _GiftScaffold(
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Gift cards', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mode == GiftCardMode.buy ? 'Buy Gift Card' : 'Sell Gift Card', style: _title24),
                    const SizedBox(height: 3),
                    const Text('Sell gift cards instantly', style: _body14),
                  ],
                ),
              ),
              _ModeChip(label: widget.mode == GiftCardMode.buy ? 'Buy' : 'Sell'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 48,
            decoration: _fieldDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Image.asset('$_g/search.png', width: 22, height: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: const DavoInlineInputDecoration(hintText: 'Search 50+ gift card brands...'),
                    style: _body14,
                  ),
                ),
              ],
            ),
          ),
          if (widget.mode == GiftCardMode.buy) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: GiftCardCategory.values.map((item) {
                  final active = category == item;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: _categoryName(item),
                      active: active,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => category = item);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Text('TOP RATES', style: _eyebrow),
          const SizedBox(height: 8),
          _BrandListTile(brand: _brands[0], selected: true, onTap: () => _open(_brands[0])),
          const SizedBox(height: 8),
          _BrandListTile(brand: _brands[1], onTap: () => _open(_brands[1])),
          const SizedBox(height: 22),
          const Text('ALL BRANDS', style: _eyebrow),
          const SizedBox(height: 8),
          ...visible.skip(2).map((brand) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BrandListTile(brand: brand, onTap: () => _open(brand)),
              )),
        ],
      ),
    );
  }

  void _open(GiftCardBrand brand) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      AppPageRoute<void>(
        builder: (_) => widget.mode == GiftCardMode.buy
            ? GiftCardBuyFormScreen(brand: brand)
            : GiftCardSellFormScreen(brand: brand),
      ),
    );
  }
}

class GiftCardSellFormScreen extends StatefulWidget {
  const GiftCardSellFormScreen({super.key, required this.brand});
  final GiftCardBrand brand;

  @override
  State<GiftCardSellFormScreen> createState() => _GiftCardSellFormScreenState();
}

class _GiftCardSellFormScreenState extends State<GiftCardSellFormScreen> {
  final amount = TextEditingController();
  bool physical = true;
  bool categorySelected = false;
  bool uploaded = false;

  double get numeric => double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
  int get naira => (numeric * 865).round();
  bool get ready => categorySelected && numeric > 0 && uploaded;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Sell Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Text('Sell ${widget.brand.name}', style: _section),
          const SizedBox(height: 8),
          const _StepProgress(step: 1),
          const SizedBox(height: 24),
          const Text('Sort by:', style: _caption),
          const SizedBox(height: 8),
          _TwoChoice(
            left: 'Physical',
            right: 'E-code',
            leftActive: physical,
            onLeft: () => setState(() => physical = true),
            onRight: () => setState(() => physical = false),
          ),
          const SizedBox(height: 20),
          const _Label('Sub Category'),
          const SizedBox(height: 6),
          _SelectField(
            value: categorySelected ? 'France iTunes/Apple, Physical (50 above)' : 'Select Gift Card Sub Category',
            onTap: () => setState(() => categorySelected = true),
          ),
          const SizedBox(height: 16),
          const _Label('Card Amount'),
          const SizedBox(height: 6),
          _AmountField(controller: amount, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          _RateOutput(value: naira),
          const SizedBox(height: 16),
          const _Label('Upload Card Image(s)'),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => uploaded = true);
            },
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              height: uploaded ? 118 : 74,
              decoration: BoxDecoration(
                color: uploaded ? const Color(0xFFF8F9FB) : Colors.white,
                border: Border.all(color: uploaded ? AppColors.primary : AppColors.mutedSoft),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: uploaded
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset('$_g/apple_card_photo.png', height: 92, width: 188, fit: BoxFit.cover),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('$_g/gallery.png', width: 24, height: 24),
                        const SizedBox(width: 8),
                        const Text('Upload Card Image(s)', style: _body14),
                      ],
                    ),
            ),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Continue',
            enabled: ready,
            onTap: ready
                ? () => Navigator.of(context).push<void>(
                      AppPageRoute<void>(builder: (_) => GiftCardSellReviewScreen(brand: widget.brand, amount: numeric)),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class GiftCardSellReviewScreen extends StatefulWidget {
  const GiftCardSellReviewScreen({super.key, required this.brand, required this.amount});
  final GiftCardBrand brand;
  final double amount;

  @override
  State<GiftCardSellReviewScreen> createState() => _GiftCardSellReviewScreenState();
}

class _GiftCardSellReviewScreenState extends State<GiftCardSellReviewScreen> {
  bool accepted = false;
  bool confirmed = false;

  int get payout => (widget.amount * 865).round();

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Sell Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 12),
          Text('Sell ${widget.brand.name}', style: _section),
          const SizedBox(height: 8),
          const _StepProgress(step: 2),
          const SizedBox(height: 22),
          const Center(child: Text('Trade Breakdown', style: _title20)),
          const SizedBox(height: 3),
          const Center(child: Text('Kindly read the terms carefully', style: _caption)),
          const SizedBox(height: 18),
          _BreakdownCard(amount: widget.amount, naira: payout, sell: true),
          const SizedBox(height: 14),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('$_g/apple_card_photo.png', width: 120, height: 68, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          const _InfoNote(
            text: 'Please note that the payable amount may change if you upload the wrong subcategory. To avoid issues, kindly review the trade terms below carefully.',
          ),
          const SizedBox(height: 14),
          const Text('Trade Terms', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 6),
          const Text(
            'Please ensure you have uploaded a physical picture of your FRANCE iTunes gift card purchased from the store. iTunes gift card codes start with X and are 16 digits.',
            style: _caption,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => accepted = !accepted);
            },
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accepted ? AppColors.primary : Colors.white,
                    border: Border.all(color: accepted ? AppColors.primary : AppColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: accepted ? Padding(padding: const EdgeInsets.all(2), child: Image.asset('$_g/check_mark.png')) : null,
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('I have read and accepted the terms', style: _caption)),
              ],
            ),
          ),
          if (confirmed) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(8)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('I confirm this card is valid', style: _section),
                  SizedBox(height: 4),
                  Text('Submitting invalid or used cards may result in account restrictions.', style: _caption),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          _PrimaryButton(
            label: confirmed ? 'Submit' : 'Continue',
            enabled: accepted,
            onTap: accepted
                ? () {
                    if (!confirmed) {
                      HapticFeedback.mediumImpact();
                      setState(() => confirmed = true);
                    } else {
                      Navigator.of(context).pushReplacement<void, void>(
                        AppPageRoute<void>(builder: (_) => const GiftCardSellSubmittedScreen()),
                      );
                    }
                  }
                : null,
          ),
          if (confirmed) ...[
            const SizedBox(height: 10),
            _SecondaryButton(label: 'Edit Details', onTap: () => setState(() => confirmed = false)),
          ],
        ],
      ),
    );
  }
}

class GiftCardSellSubmittedScreen extends StatefulWidget {
  const GiftCardSellSubmittedScreen({super.key});

  @override
  State<GiftCardSellSubmittedScreen> createState() => _GiftCardSellSubmittedScreenState();
}

class _GiftCardSellSubmittedScreenState extends State<GiftCardSellSubmittedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 620))..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    return _GiftScaffold(
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: _BackButton(onTap: () => Navigator.pop(context))),
          const SizedBox(height: 30),
          ScaleTransition(scale: Tween<double>(begin: .65, end: 1).animate(curve), child: const _SuccessCircle()),
          const SizedBox(height: 22),
          const Text('Transaction Submitted', style: _title20),
          const SizedBox(height: 4),
          const Text('Current Trade Status: Pending', style: _body14),
          const SizedBox(height: 28),
          const _TransactionCard(
            rows: [
              ('Transaction ID', '32525258296589677845', true, false),
              ('Reference Code', '965X-896756', true, false),
              ('Card Value', '\$500.00', false, false),
              ('Amount', '₦432,500', false, true),
              ('Date', '12-05-2026 08:48:48', false, false),
            ],
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Start New Trade',
            onTap: () => Navigator.of(context).pushReplacement<void, void>(
              AppPageRoute<void>(builder: (_) => const GiftCardBrandScreen(mode: GiftCardMode.sell)),
            ),
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            label: 'Save New Trade',
            onTap: () => Navigator.of(context).push<void>(AppPageRoute<void>(builder: (_) => const GiftCardVerificationScreen())),
          ),
        ],
      ),
    );
  }
}

class GiftCardVerificationScreen extends StatefulWidget {
  const GiftCardVerificationScreen({super.key});

  @override
  State<GiftCardVerificationScreen> createState() => _GiftCardVerificationScreenState();
}

class _GiftCardVerificationScreenState extends State<GiftCardVerificationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController pulse;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: .96, end: 1.04).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut));
    return _GiftScaffold(
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: _BackButton(onTap: () => Navigator.pop(context))),
          const SizedBox(height: 20),
          ScaleTransition(scale: scale, child: const _VerificationOrb()),
          const SizedBox(height: 20),
          const Text('Verifying your card...', style: _title20),
          const SizedBox(height: 5),
          const Text('This usually takes 5–30 minutes', style: _caption),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _outlinedCard,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Progress', style: _section),
                SizedBox(height: 16),
                _ProgressRow(color: Color(0xFF20C55D), title: 'Submission received', meta: 'Just now'),
                _TimelineLine(active: true),
                _ProgressRow(color: Color(0xFFF59E0B), title: 'Photo verification', meta: 'In progress'),
                _TimelineLine(active: false),
                _ProgressRow(color: Color(0xFFD2D2D2), title: 'Card validation', meta: 'Up next'),
                _TimelineLine(active: false),
                _ProgressRow(color: Color(0xFFD2D2D2), title: 'Funds credited', meta: '~25 mins'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: _softCard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('GC-SELL-2826491', style: _section),
                InkWell(
                  onTap: () => Clipboard.setData(const ClipboardData(text: 'GC-SELL-2826491')),
                  child: Row(children: [Image.asset('$_f/buy_copy.png', width: 15), const SizedBox(width: 5), const Text('Copy', style: _caption)]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(children: [TextSpan(text: 'Need help? ', style: _caption), TextSpan(text: 'Contact support', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))]),
          ),
        ],
      ),
    );
  }
}

class GiftCardBuyFormScreen extends StatefulWidget {
  const GiftCardBuyFormScreen({super.key, required this.brand});
  final GiftCardBrand brand;

  @override
  State<GiftCardBuyFormScreen> createState() => _GiftCardBuyFormScreenState();
}

class _GiftCardBuyFormScreenState extends State<GiftCardBuyFormScreen> {
  final amount = TextEditingController();
  bool categorySelected = false;
  int quantity = 1;

  double get numeric => double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
  bool get ready => categorySelected && numeric > 0;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Buy Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Text('Buy ${widget.brand.name}', style: _section),
          const SizedBox(height: 8),
          const _StepProgress(step: 1),
          const SizedBox(height: 24),
          const _Label('Sub Category'),
          const SizedBox(height: 6),
          _SelectField(
            value: categorySelected ? 'France iTunes/Apple, Physical (50 above)' : 'Select Gift Card Sub Category',
            onTap: () => setState(() => categorySelected = true),
          ),
          const SizedBox(height: 16),
          const _Label('Card Amount'),
          const SizedBox(height: 6),
          _AmountField(controller: amount, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          _RateOutput(value: (numeric * 865).round()),
          const SizedBox(height: 22),
          const _Label('QUANTITY'),
          const SizedBox(height: 10),
          Container(
            height: 52,
            decoration: _fieldDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuantityButton(label: '−', onTap: quantity > 1 ? () => setState(() => quantity--) : null),
                AnimatedSwitcher(duration: const Duration(milliseconds: 160), child: Text('$quantity', key: ValueKey(quantity), style: _section)),
                _QuantityButton(label: '+', filled: true, onTap: () => setState(() => quantity++)),
              ],
            ),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Continue',
            enabled: ready,
            onTap: ready
                ? () => Navigator.of(context).push<void>(
                      AppPageRoute<void>(builder: (_) => GiftCardDeliveryScreen(brand: widget.brand, amount: numeric, quantity: quantity)),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class GiftCardDeliveryScreen extends StatefulWidget {
  const GiftCardDeliveryScreen({super.key, required this.brand, required this.amount, required this.quantity});
  final GiftCardBrand brand;
  final double amount;
  final int quantity;

  @override
  State<GiftCardDeliveryScreen> createState() => _GiftCardDeliveryScreenState();
}

class _GiftCardDeliveryScreenState extends State<GiftCardDeliveryScreen> {
  bool forMe = true;
  bool instant = true;
  final email = TextEditingController();
  final phone = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Buy Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Text('Buy ${widget.brand.name}', style: _section),
          const SizedBox(height: 8),
          const _StepProgress(step: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _DeliverySegment(label: 'For Me', asset: '$_g/user.png', active: forMe, onTap: () => setState(() => forMe = true))),
              const SizedBox(width: 8),
              Expanded(child: _DeliverySegment(label: 'Send Gift', asset: '$_g/gift.png', active: !forMe, onTap: () => setState(() => forMe = false))),
            ],
          ),
          const SizedBox(height: 22),
          Text(forMe ? 'Delivery Details' : 'Recipient Details', style: _section),
          const SizedBox(height: 12),
          const _Label('Email Address'),
          const SizedBox(height: 6),
          _IconTextField(asset: '$_g/mail.png', controller: email, hint: forMe ? '@gmail.com' : 'recipient@gmail.com', keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          const _Label('Phone (optional)'),
          const SizedBox(height: 6),
          _IconTextField(asset: '$_g/phone.png', controller: phone, hint: '234 000 0000 000', keyboard: TextInputType.phone),
          const SizedBox(height: 22),
          const Text('Delivery Method', style: _section),
          const SizedBox(height: 10),
          _DeliveryChoice(
            title: 'Instant Delivery',
            subtitle: 'Card code shown in app immediately',
            active: instant,
            onTap: () => setState(() => instant = true),
          ),
          const SizedBox(height: 10),
          _DeliveryChoice(
            title: 'Email Delivery',
            subtitle: 'Sent to your email address',
            active: !instant,
            onTap: () => setState(() => instant = false),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(
            label: 'Continue',
            onTap: () => Navigator.of(context).push<void>(
              AppPageRoute<void>(builder: (_) => GiftCardBuyReviewScreen(brand: widget.brand, amount: widget.amount, quantity: widget.quantity)),
            ),
          ),
        ],
      ),
    );
  }
}

class GiftCardBuyReviewScreen extends StatelessWidget {
  const GiftCardBuyReviewScreen({super.key, required this.brand, required this.amount, required this.quantity});
  final GiftCardBrand brand;
  final double amount;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final naira = (amount * 865 * quantity).round();
    return _GiftScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Review Purchase', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 16),
          Text('Buy ${brand.name}', style: _section),
          const SizedBox(height: 8),
          const _StepProgress(step: 1),
          const SizedBox(height: 22),
          const Center(child: Text('Trade Breakdown', style: _title20)),
          const SizedBox(height: 3),
          const Center(child: Text('Kindly read the terms carefully', style: _caption)),
          const SizedBox(height: 18),
          _BreakdownCard(amount: amount * quantity, naira: naira, sell: false),
          const Spacer(),
          _PrimaryButton(
            label: 'Continue',
            onTap: () => Navigator.of(context).push<void>(
              AppPageRoute<void>(builder: (_) => GiftCardPaymentScreen(amount: amount * quantity, naira: naira)),
            ),
          ),
        ],
      ),
    );
  }
}

class GiftCardPaymentScreen extends StatefulWidget {
  const GiftCardPaymentScreen({super.key, required this.amount, required this.naira});
  final double amount;
  final int naira;

  @override
  State<GiftCardPaymentScreen> createState() => _GiftCardPaymentScreenState();
}

class _GiftCardPaymentScreenState extends State<GiftCardPaymentScreen> {
  bool selected = true;

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.centerLeft, child: _BackButton(onTap: () => Navigator.pop(context))),
          const SizedBox(height: 24),
          const Text('Choose payment method', style: _title20),
          const SizedBox(height: 5),
          const Text('Select how you would like to fund your gift card purchase. Balance updates are near-instant.', style: _caption),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => setState(() => selected = true),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 128,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                border: Border.all(color: selected ? const Color(0xFFC4C5CA) : AppColors.mutedSoft),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(color: Color(0xFFF0F4FD), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/brand/naira_coin.png', width: 24, height: 24, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NGN Wallet Balance', style: _section),
                        const SizedBox(height: 4),
                        const Text('Available balance: ₦1,240,500.00', maxLines: 1, overflow: TextOverflow.ellipsis, style: _body14),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE9EEFA), borderRadius: BorderRadius.circular(999)),
                          child: const Text('INSTANT SETTLEMENT', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF5F6F9)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('You are buying', style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF434656))),
                      const SizedBox(height: 4),
                      Row(children: [Text('\$${widget.amount.toStringAsFixed(2)}', style: _section), const SizedBox(width: 7), Image.asset('$_g/trend.png', width: 18, height: 11)]),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Estimated Cost', style: _caption),
                      const SizedBox(height: 4),
                      Text('₦${_money(widget.naira)}', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                _PrimaryButton(
                  label: 'Continue',
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final ok = await Navigator.of(context).push<bool>(AppPageRoute<bool>(builder: (_) => const GiftCardPinScreen()));
                    if (!context.mounted || ok != true) return;
                    Navigator.of(context).pushReplacement<void, void>(
                      AppPageRoute<void>(builder: (_) => GiftCardBuySuccessScreen(amount: widget.amount, naira: widget.naira)),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('$_f/buy_lock.png', width: 11, height: 14),
                    const SizedBox(width: 7),
                    const Flexible(child: Text('SECURE TRANSACTION POWERED BY DAVOVAULT', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 9, letterSpacing: .9, color: AppColors.bodyMuted))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GiftCardPinScreen extends StatefulWidget {
  const GiftCardPinScreen({super.key});

  @override
  State<GiftCardPinScreen> createState() => _GiftCardPinScreenState();
}

class _GiftCardPinScreenState extends State<GiftCardPinScreen> {
  String pin = '';

  void key(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (value == 'back') {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else if (pin.length < 4) {
        pin += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: _BackButton(onTap: () => Navigator.pop(context, false))),
          const SizedBox(height: 24),
          Image.asset('$_f/buy_pin_shield.png', width: 56, height: 56),
          const SizedBox(height: 14),
          const Text('Confirm Your Pin', style: _title20),
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Please enter your 4-digit security PIN to authorize this transaction securely.', textAlign: TextAlign.center, style: _caption),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final filled = index < pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 42,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled ? Colors.white : const Color(0xFFF8F9FB),
                  border: Border.all(color: filled ? AppColors.primary : AppColors.mutedSoft),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: filled ? const [BoxShadow(color: Color(0x22135CF7), blurRadius: 8)] : null,
                ),
                child: filled ? Text(pin[index], style: const TextStyle(fontFamily: 'Sora', fontSize: 22, color: AppColors.ink)) : null,
              );
            }),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: pin.length == 4
                ? SizedBox(width: double.infinity, child: _PrimaryButton(label: 'Confirm', onTap: () => Navigator.pop(context, true)))
                : const Text('Enter Secure PIN', style: _body14),
          ),
          const Spacer(),
          _NumericKeyboard(onKey: key),
          const SizedBox(height: 12),
          const Text('Authentication is required', style: _caption),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('$_f/buy_lock.png', width: 11, height: 14), const SizedBox(width: 7), const Text('ENCRYPTED END-TO-END', style: _eyebrow)]),
        ],
      ),
    );
  }
}

class GiftCardBuySuccessScreen extends StatefulWidget {
  const GiftCardBuySuccessScreen({super.key, required this.amount, required this.naira});
  final double amount;
  final int naira;

  @override
  State<GiftCardBuySuccessScreen> createState() => _GiftCardBuySuccessScreenState();
}

class _GiftCardBuySuccessScreenState extends State<GiftCardBuySuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: .62, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    return _GiftScaffold(
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: _BackButton(onTap: () => Navigator.pop(context))),
          const SizedBox(height: 28),
          ScaleTransition(scale: scale, child: const _SuccessCircle()),
          const SizedBox(height: 22),
          const Text('Purchase Successful!', style: _title20),
          const SizedBox(height: 4),
          const Text('Your gift card has been purchased successfully', style: _body14),
          const SizedBox(height: 28),
          _TransactionCard(
            rows: [
              const ('Transaction ID', '32525258296589677845', true, false),
              const ('Reference Code', '965X-896756', true, false),
              ('Card Value', '\$${widget.amount.toStringAsFixed(2)}', false, false),
              ('Amount', '₦${_money(widget.naira)}', false, true),
              const ('Status', 'Completed', false, false),
              const ('Date', '12-05-2026 08:48:48', false, false),
            ],
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Start New Trade',
            onTap: () => Navigator.of(context).pushReplacement<void, void>(
              AppPageRoute<void>(builder: (_) => const GiftCardBrandScreen(mode: GiftCardMode.buy)),
            ),
          ),
          const SizedBox(height: 10),
          _SecondaryButton(label: 'Save New Trade', onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
        ],
      ),
    );
  }
}

class _GiftScaffold extends StatelessWidget {
  const _GiftScaffold({required this.child, this.scroll = false});
  final Widget child;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 18), child: child);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: scroll
            ? SingleChildScrollView( padding: EdgeInsets.zero, child: body)
            : body,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: _BackButton(onTap: onBack)),
          Text(title, style: _section),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(width: 32, height: 32, child: Image.asset('$_f/buy_back.png', fit: BoxFit.contain)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: _caption), const SizedBox(height: 2), Text(value, style: _section)]);
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.mode, required this.onChanged});
  final GiftCardMode mode;
  final ValueChanged<GiftCardMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F7), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(child: _ModeTab(label: 'Buy', active: mode == GiftCardMode.buy, onTap: () => onChanged(GiftCardMode.buy))),
        Expanded(child: _ModeTab(label: 'Sell', active: mode == GiftCardMode.sell, onTap: () => onChanged(GiftCardMode.sell))),
      ]),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: active ? const [BoxShadow(color: Color(0x11000000), blurRadius: 6)] : null),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: active ? AppColors.primary : AppColors.bodyMuted)),
        ),
      );
}

class _TopBrandCard extends StatelessWidget {
  const _TopBrandCard({required this.brand, required this.accent, required this.onTap});
  final GiftCardBrand brand;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 158,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(6), child: Image.asset(brand.asset)),
            const Spacer(),
            Text(brand.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 3),
            const Text('Up to ₦865/\$1', style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Colors.white70)),
          ]),
        ),
      );
}

class _PopularBrand extends StatelessWidget {
  const _PopularBrand({required this.brand, required this.onTap});
  final GiftCardBrand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 30,
        child: SizedBox(width: 72, child: Column(children: [Container(width: 46, height: 46, padding: const EdgeInsets.all(7), decoration: _softCard, child: Image.asset(brand.asset)), const SizedBox(height: 6), Text(brand.name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: _caption)])),
      );
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Text('🎉', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Refer & Earn ₦5,000', style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)), SizedBox(height: 2), Text('Get ₦500 for every friend who trades', style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Colors.white70))])),
          TextButton(onPressed: onTap, style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 14)), child: const Text('Refer', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
      );
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE8EFFD), borderRadius: BorderRadius.circular(14)), child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), decoration: BoxDecoration(color: active ? AppColors.primary : const Color(0xFFF1F3F7), borderRadius: BorderRadius.circular(16)), child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: active ? Colors.white : AppColors.body, fontWeight: FontWeight.w600))));
}

class _BrandListTile extends StatelessWidget {
  const _BrandListTile({required this.brand, required this.onTap, this.selected = false});
  final GiftCardBrand brand;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FB), border: Border.all(color: selected ? AppColors.primary : Colors.transparent), borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            Container(width: 38, height: 38, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Image.asset(brand.asset)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(brand.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _section)), if (brand.hot) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFE8E3), borderRadius: BorderRadius.circular(6)), child: const Text('HOT', style: TextStyle(fontFamily: 'Sora', fontSize: 8, color: Color(0xFFF44336), fontWeight: FontWeight.w700)))]]), if (brand.subtitle != null) ...[const SizedBox(height: 2), Text(brand.subtitle!, style: _caption)]])),
            if (brand.rate != null) Text(brand.rate!, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(height: 4, child: Row(children: List.generate(3, (index) => Expanded(child: Container(margin: EdgeInsets.only(right: index == 2 ? 0 : 4), color: index < step ? AppColors.primary : const Color(0xFFEBEDF3))))))),
        const SizedBox(height: 5),
        Text('Step $step of 3', style: _caption),
      ]);
}

class _TwoChoice extends StatelessWidget {
  const _TwoChoice({required this.left, required this.right, required this.leftActive, required this.onLeft, required this.onRight});
  final String left;
  final String right;
  final bool leftActive;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) => Container(height: 40, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF1F3F7), borderRadius: BorderRadius.circular(20)), child: Row(children: [Expanded(child: _ModeTab(label: left, active: leftActive, onTap: onLeft)), Expanded(child: _ModeTab(label: right, active: !leftActive, onTap: onRight))]));
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: _caption);
}

class _SelectField extends StatelessWidget {
  const _SelectField({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(height: 50, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: _fieldDecoration, child: Row(children: [Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: _body14)), Image.asset('assets/icons/auth/arrow_down.png', width: 20, height: 20)])),
      );
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(height: 50, decoration: _fieldDecoration, child: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: onChanged, decoration: const DavoInlineInputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), hintText: 'Enter Gift Card Amount'), style: _body14));
}

class _RateOutput extends StatelessWidget {
  const _RateOutput({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Container(height: 44, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFFEDF2FD), borderRadius: BorderRadius.circular(4)), child: Text('₦${_money(value)}', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)))), const SizedBox(width: 8), Container(height: 44, alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(4)), child: const Text('Rate: ₦865/\$1', style: _caption))]);
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.amount, required this.naira, required this.sell});
  final double amount;
  final int naira;
  final bool sell;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _outlinedCard,
        child: Column(children: [
          const _SummaryLine(label: 'Card Type', value: 'France iTunes/Apple, Physical (50 above)'),
          const Divider(height: 22, color: Color(0xFFEBEDF3)),
          _SummaryLine(label: 'Card Value', value: '\$${amount.toStringAsFixed(2)}'),
          const Divider(height: 22, color: Color(0xFFEBEDF3)),
          const _SummaryLine(label: 'Exchange Rate', value: '₦865/\$1'),
          const Divider(height: 22, color: Color(0xFFEBEDF3)),
          _SummaryLine(label: 'Gross Amount', value: '₦${_money(naira)}'),
          const Divider(height: 22, color: Color(0xFFEBEDF3)),
          const _SummaryLine(label: 'Processing Fee', value: '₦0'),
          const Divider(height: 22, color: Color(0xFFEBEDF3)),
          _SummaryLine(label: sell ? 'Net Payout' : 'Net Debited', value: '₦${_money(naira)}', blue: true),
        ]),
      );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value, this.blue = false});
  final String label;
  final String value;
  final bool blue;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label, style: _caption)), const SizedBox(width: 12), Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: blue ? FontWeight.w600 : FontWeight.w400, color: blue ? AppColors.primary : AppColors.ink)))]);
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(6)), child: Text(text, style: _caption));
}

class _SuccessCircle extends StatelessWidget {
  const _SuccessCircle();
  @override
  Widget build(BuildContext context) => Container(width: 128, height: 128, decoration: const BoxDecoration(color: Color(0xFF1BA44D), shape: BoxShape.circle), alignment: Alignment.center, child: Container(width: 50, height: 50, padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Image.asset('$_g/check_mark.png')));
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.rows});
  final List<(String, String, bool, bool)> rows;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _outlinedCard,
        child: Column(children: rows.indexed.map((entry) {
          final i = entry.$1;
          final row = entry.$2;
          final status = row.$1 == 'Status';
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(children: [
                Expanded(child: Text(row.$1, style: _body14)),
                if (row.$3)
                  InkWell(
                    onTap: () => Clipboard.setData(ClipboardData(text: row.$2)),
                    child: Row(children: [Text(row.$2, style: _caption), const SizedBox(width: 5), Image.asset('$_f/buy_copy.png', width: 18, height: 18)]),
                  )
                else
                  Text(row.$2, style: TextStyle(fontFamily: 'Sora', fontSize: 12, color: status ? const Color(0xFF1BA44D) : row.$4 ? AppColors.primary : AppColors.ink, fontWeight: status || row.$4 ? FontWeight.w600 : FontWeight.w400)),
              ]),
            ),
            if (i != rows.length - 1) const Divider(height: 1, color: Color(0xFFEBEDF3)),
          ]);
        }).toList()),
      );
}

class _VerificationOrb extends StatelessWidget {
  const _VerificationOrb();
  @override
  Widget build(BuildContext context) => Container(
        width: 126,
        height: 126,
        decoration: const BoxDecoration(color: Color(0xFFE7EEFD), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(color: Color(0xFFBBD0FF), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(color: Color(0xFFE8EEFD), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Image.asset('$_g/clock.png', width: 40, height: 40, fit: BoxFit.contain),
          ),
        ),
      );
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.color, required this.title, required this.meta});
  final Color color;
  final String title;
  final String meta;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 13, height: 13, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 10), Expanded(child: Text(title, style: _caption)), Text(meta, style: _caption)]);
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 18, margin: const EdgeInsets.only(left: 6), color: active ? const Color(0xFF20C55D) : const Color(0xFFEBEDF3));
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.label, this.filled = false, this.onTap});
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkResponse(onTap: onTap, radius: 22, child: Container(width: 42, height: 42, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: filled ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(4)), alignment: Alignment.center, child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 22, color: filled ? Colors.white : onTap == null ? AppColors.muted : AppColors.ink))));
}

class _DeliverySegment extends StatelessWidget {
  const _DeliverySegment({required this.label, required this.asset, required this.active, required this.onTap});
  final String label;
  final String asset;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: AnimatedContainer(duration: const Duration(milliseconds: 180), height: 48, decoration: BoxDecoration(color: active ? const Color(0xFFE8EFFD) : const Color(0xFFF8F9FB), border: Border.all(color: active ? AppColors.primary : AppColors.mutedSoft), borderRadius: BorderRadius.circular(6)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(asset, width: 22, height: 22), const SizedBox(width: 7), Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 13, color: active ? AppColors.primary : AppColors.body, fontWeight: FontWeight.w600))])));
}

class _IconTextField extends StatelessWidget {
  const _IconTextField({required this.asset, required this.controller, required this.hint, required this.keyboard});
  final String asset;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  @override
  Widget build(BuildContext context) => Container(height: 50, decoration: _fieldDecoration, child: Row(children: [const SizedBox(width: 12), Image.asset(asset, width: 20, height: 20), const SizedBox(width: 8), Expanded(child: TextField(controller: controller, keyboardType: keyboard, decoration: DavoInlineInputDecoration(hintText: hint), style: _body14)), const SizedBox(width: 12)]));
}

class _DeliveryChoice extends StatelessWidget {
  const _DeliveryChoice({required this.title, required this.subtitle, required this.active, required this.onTap});
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: active ? AppColors.primary : AppColors.mutedSoft, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFFE6EDFD), borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Image.asset('$_g/lightning.png', width: 16, height: 16, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: _section), const SizedBox(height: 2), Text(subtitle, style: _caption)])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE6EDFD), borderRadius: BorderRadius.circular(10)),
              child: const Text('Free', style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}

class _NumericKeyboard extends StatelessWidget {
  const _NumericKeyboard({required this.onKey});
  final ValueChanged<String> onKey;
  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'back'];
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GridView.builder(
        itemCount: keys.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.45),
        itemBuilder: (_, index) {
          final key = keys[index];
          if (key.isEmpty) return const SizedBox.shrink();
          return InkWell(
            onTap: () => onKey(key),
            child: Center(child: key == 'back' ? Image.asset('$_f/buy_backspace.png', width: 22, height: 22) : Text(key, style: const TextStyle(fontFamily: 'Sora', fontSize: 18, color: AppColors.ink))),
          );
        },
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onTap, this.enabled = true});
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: enabled ? onTap : null, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, disabledBackgroundColor: AppColors.primaryDisabled, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600)), child: Text(label)));
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 48, child: TextButton(onPressed: onTap, style: TextButton.styleFrom(foregroundColor: AppColors.ink, textStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600)), child: Text(label)));
}

String _categoryName(GiftCardCategory item) => switch (item) {
      GiftCardCategory.all => 'All',
      GiftCardCategory.shopping => 'Shopping',
      GiftCardCategory.gaming => 'Gaming',
      GiftCardCategory.streaming => 'Streaming',
      GiftCardCategory.food => 'Food',
    };

String _money(num value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}

const _title24 = TextStyle(fontFamily: 'Sora', fontSize: 24, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.ink);
const _title20 = TextStyle(fontFamily: 'Sora', fontSize: 20, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.inkStrong);
const _section = TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.ink);
const _body14 = TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, fontWeight: FontWeight.w400, color: AppColors.body);
const _caption = TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, fontWeight: FontWeight.w400, color: AppColors.bodyMuted);
const _eyebrow = TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: .45, color: AppColors.bodyMuted);

final _fieldDecoration = BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEBEDF3)), borderRadius: BorderRadius.circular(4));
final _softCard = BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(8));
final _outlinedCard = BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEBEDF3)), borderRadius: BorderRadius.circular(12));
