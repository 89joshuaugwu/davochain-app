import '../../../shared/widgets/davo_celebration_emoji.dart';
import 'gift_card_models.dart';
export 'gift_card_models.dart';
import '../../../core/money/exact_decimal.dart';
import 'gift_flow_controllers.dart';
import 'dart:io';
import '../gift_order_draft.dart';
import '../gift_evidence_picker.dart';
import '../../wallets/wallet_repository.dart';
export '../gift_order_draft.dart';
export '../gift_evidence_picker.dart';
import '../../../shared/widgets/davo_refresh_region.dart';
import '../../profile_settings/presentation/profile_settings_flow.dart'
    show ReferralDashboardScreen;
import '../../../shared/widgets/davo_main_shell.dart';
import '../../../shared/receipts/transaction_record_details_screen.dart';
import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/receipts/receipt_screen.dart';
import '../../../shared/receipts/receipt_activity.dart';
import 'gift_card_receipt_records.dart';
import '../../../shared/motion/davo_outcome_content.dart';
import '../../../shared/motion/davo_working_indicator.dart';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../../shared/widgets/davo_toast.dart';
import '../../../shared/widgets/davo_animated_checkbox.dart';
import '../../../shared/widgets/receipt_detail_row.dart';
import '../../../shared/widgets/transaction_pin_entry.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_input_decoration.dart';

part 'gift_flow_components.dart';
part 'gift_buy_screens.dart';
part 'gift_sell_screens.dart';
part 'gift_amount_widgets.dart';
part 'gift_delivery_widgets.dart';

const _g = 'assets/figma_exact';
const _f = 'assets/figma_exact';

enum _GiftCardStep { first, second, third }

GiftCatalogProduct _product(GiftCardBrand brand, {bool physical = true}) =>
    GiftCatalogProduct(
        skuId:
            '${brand.name.toLowerCase().replaceAll(' ', '-')}-fr-${physical ? 'physical' : 'ecode'}',
        brandName: brand.name,
        country: 'France',
        category: brand.category.name,
        cardType: physical ? GiftCardType.physical : GiftCardType.eCode);

const _brands = <GiftCardBrand>[
  GiftCardBrand(
      name: 'Amazon',
      asset: '$_g/amazon.png',
      subtitle: 'Shopping ? Physical / E-code',
      rate: '₦865/\$1',
      hot: true),
  GiftCardBrand(
      name: 'iTunes/Apple',
      asset: '$_g/apple.png',
      subtitle: 'Streaming ? Physical / E-code',
      rate: '₦865/\$1',
      category: GiftCardCategory.streaming),
  GiftCardBrand(
      name: 'Google Play',
      asset: '$_g/google_play.png',
      category: GiftCardCategory.gaming),
  GiftCardBrand(
      name: 'Steam', asset: '$_g/steam.png', category: GiftCardCategory.gaming),
  GiftCardBrand(name: 'Walmart', asset: '$_g/walmart.png'),
  GiftCardBrand(
      name: 'Razer Gold',
      asset: '$_g/razer.png',
      category: GiftCardCategory.gaming),
  GiftCardBrand(name: 'Ebay Gift Card', asset: '$_g/ebay.png'),
  GiftCardBrand(
      name: 'American Express (AMEX) Gift Card', asset: '$_g/amex.png'),
];

Future<void> startGiftCardFlow(BuildContext context,
    {GiftCardMode mode = GiftCardMode.buy}) async {
  await selectDavoMainTab(context, 2, giftMode: mode);
}

class GiftCardHomeScreen extends StatefulWidget {
  const GiftCardHomeScreen(
      {super.key, this.initialMode = GiftCardMode.buy, this.onBack});
  final VoidCallback? onBack;

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
    setState(() => mode = value);
  }

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.giftCardCatalogue, builder: _buildRefreshed);
  Widget _buildRefreshed(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    final referral = _ReferralCard(
        onTap: () => Navigator.of(context).push(AppPageRoute<void>(
            builder: (_) => const ReferralDashboardScreen())));
    return _GiftScaffold(
      scroll: true,
      bottom: largeText ? null : referral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
              title: 'Gift cards',
              onBack: widget.onBack ?? () => Navigator.pop(context)),
          const SizedBox(height: 22),
          Text('Gift Cards', style: _title20(context)),
          const SizedBox(height: 2),
          Text('Buy and sell gift cards instantly', style: _body14(context)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _softCard(context),
            child: Row(
              children: [
                const Expanded(
                    child: _Stat(label: '24h Volume', value: '₦42M')),
                SizedBox(
                    height: 38,
                    child:
                        VerticalDivider(color: DavoColors.of(context).divider)),
                const Expanded(
                    child: _Stat(label: 'Active Now', value: '2,840')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ModeTabs(mode: mode, onChanged: _setMode),
          const SizedBox(height: 22),
          Text('Top Gift Cards', style: _section(context)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _TopBrandCard(
                      brand: _brands[0],
                      mode: mode,
                      accent: const Color(0xFFF59E0B),
                      onTap: () => _openBrand(_brands[0]))),
              const SizedBox(width: 12),
              Expanded(
                  child: _TopBrandCard(
                      brand: _brands[1],
                      mode: mode,
                      accent: const Color(0xFF151515),
                      onTap: () => _openBrand(_brands[1]))),
            ],
          ),
          const SizedBox(height: 24),
          Text('Popular Brands', style: _section(context)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final cards = [2, 3, 5, 4]
                .map((index) => _PopularBrand(
                    width: largeText ? (constraints.maxWidth - 12) / 2 : 68,
                    brand: _brands[index],
                    onTap: () => _openBrand(_brands[index])))
                .toList();
            return largeText
                ? Wrap(spacing: 12, runSpacing: 12, children: cards)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: cards);
          }),
          const SizedBox(height: 10),
          Center(
              child: TextButton(
                  onPressed: _openSelector,
                  child: Text('View All',
                      style: TextStyle(
                          fontSize: 12, color: DavoColors.of(context).body)))),
          const SizedBox(height: 12),
          if (largeText) referral,
        ],
      ),
    );
  }

  void _openBrand(GiftCardBrand brand) {
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
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.giftCardCatalogue, builder: _buildRefreshed);
  Widget _buildRefreshed(BuildContext context) {
    final q = controller.text.trim().toLowerCase();
    final visible = _brands.where((brand) {
      final matchesQuery = q.isEmpty || brand.name.toLowerCase().contains(q);
      final matchesCategory =
          category == GiftCardCategory.all || brand.category == category;
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
                    Text(
                        widget.mode == GiftCardMode.buy
                            ? 'Buy Gift Card'
                            : 'Sell Gift Card',
                        style: _title24(context)),
                    const SizedBox(height: 3),
                    Text(
                        widget.mode == GiftCardMode.buy
                            ? 'Buy gift cards instantly'
                            : 'Sell gift cards instantly',
                        style: _body14(context)),
                  ],
                ),
              ),
              _ModeChip(
                  label: widget.mode == GiftCardMode.buy ? 'Buy' : 'Sell'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 48,
            decoration: _fieldDecoration(context).copyWith(
                color: DavoColors.of(context).offWhite,
                borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Image.asset('$_g/search.png',
                    color: DavoColors.of(context).bodyMuted,
                    width: 22,
                    height: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardAppearance: Theme.of(context).brightness,
                    controller: controller,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: const DavoInlineInputDecoration(
                        hintText: 'Search 50+ gift card brands...'),
                    style: _body14(context),
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
                        setState(() => category = item);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text('TOP RATES', style: _eyebrow(context)),
          const SizedBox(height: 8),
          _BrandListTile(
              brand: _brands[0],
              selected: true,
              onTap: () => _open(_brands[0])),
          const SizedBox(height: 8),
          _BrandListTile(brand: _brands[1], onTap: () => _open(_brands[1])),
          const SizedBox(height: 22),
          Text('ALL BRANDS', style: _eyebrow(context)),
          const SizedBox(height: 8),
          ...visible
              .where((brand) => brand != _brands[0] && brand != _brands[1])
              .map((brand) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        _BrandListTile(brand: brand, onTap: () => _open(brand)),
                  )),
        ],
      ),
    );
  }

  void _open(GiftCardBrand brand) {
    Navigator.of(context).push<void>(
      AppPageRoute<void>(
        builder: (_) => widget.mode == GiftCardMode.buy
            ? GiftCardBuyFormScreen(brand: brand)
            : GiftCardSellFormScreen(brand: brand),
      ),
    );
  }
}
