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
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_input_decoration.dart';

const _g = 'assets/figma_exact';
const _f = 'assets/figma_exact';

enum GiftCardMode { buy, sell }

enum _GiftCardStep { first, second, third }

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
    return _GiftScaffold(
      scroll: true,
      bottom: _ReferralCard(
          onTap: () => Navigator.of(context).push(AppPageRoute<void>(
              builder: (_) => const ReferralDashboardScreen()))),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PopularBrand(
                  brand: _brands[2], onTap: () => _openBrand(_brands[2])),
              _PopularBrand(
                  brand: _brands[3], onTap: () => _openBrand(_brands[3])),
              _PopularBrand(
                  brand: _brands[5], onTap: () => _openBrand(_brands[5])),
              _PopularBrand(
                  brand: _brands[4], onTap: () => _openBrand(_brands[4])),
            ],
          ),
          const SizedBox(height: 10),
          Center(
              child: TextButton(
                  onPressed: _openSelector,
                  child: Text('View All',
                      style: TextStyle(
                          fontSize: 12, color: DavoColors.of(context).body)))),
          const SizedBox(height: 12),
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

class GiftCardSellFormScreen extends StatefulWidget {
  const GiftCardSellFormScreen(
      {super.key, required this.brand, this.evidencePicker = pickGiftEvidence});
  final GiftEvidencePicker evidencePicker;
  final GiftCardBrand brand;

  @override
  State<GiftCardSellFormScreen> createState() => _GiftCardSellFormScreenState();
}

class _GiftCardSellFormScreenState extends State<GiftCardSellFormScreen> {
  final amount = TextEditingController();
  bool physical = true;
  bool categorySelected = false;
  GiftEvidence? evidence;
  GiftCatalogProduct? selectedProduct;
  bool picking = false;
  String? evidenceError;
  bool get uploaded => evidence != null;

  double get numeric => parseAmount(amount.text);
  int get naira => (numeric * (selectedProduct?.rateNaira ?? 865)).round();
  bool get ready =>
      selectedProduct != null &&
      numeric.isFinite &&
      numeric >= selectedProduct!.minimumDenomination &&
      uploaded &&
      !picking;

  @override
  void dispose() {
    if (evidence != null) unawaited(evidence!.release());
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      bottom: _PrimaryButton(
        label: 'Continue',
        enabled: ready,
        onTap: ready
            ? () => Navigator.of(context).push<void>(
                  AppPageRoute<void>(
                      builder: (_) => GiftCardSellReviewScreen(
                          brand: widget.brand,
                          amount: numeric,
                          country: selectedProduct!.country,
                          draft: GiftOrderDraft(
                              product: selectedProduct!,
                              denomination: numeric,
                              evidence: evidence),
                          physical: physical,
                          cardType: selectedProduct!.label)),
                )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Sell Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Text('Sell ${widget.brand.name}', style: _title24(context)),
          const SizedBox(height: 8),
          const _StepProgress(step: _GiftCardStep.first),
          const SizedBox(height: 24),
          Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Sort by:', style: _body14(context)),
                _TwoChoice(
                    left: 'Physical',
                    right: 'E-code',
                    leftActive: physical,
                    onLeft: () => setState(() {
                          physical = true;
                          selectedProduct = null;
                          categorySelected = false;
                        }),
                    onRight: () => setState(() {
                          physical = false;
                          selectedProduct = null;
                          categorySelected = false;
                        })),
              ]),
          const SizedBox(height: 20),
          const _Label('Sub Category'),
          const SizedBox(height: 6),
          _SelectField(
            brand: widget.brand,
            value: categorySelected
                ? selectedProduct!.label
                : 'Select Gift Card Sub Category',
            onTap: () async {
              FocusScope.of(context).unfocus();
              final picked = await _showGiftSubcategories(context, widget.brand,
                  physical: physical);
              if (mounted && picked != null) {
                setState(() {
                  selectedProduct = picked;
                  categorySelected = true;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const _Label('Card Amount'),
          const SizedBox(height: 6),
          _AmountField(controller: amount, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          _RateOutput(value: naira, rate: selectedProduct?.rateNaira ?? 865),
          const SizedBox(height: 16),
          const _Label('Upload Card Image(s)'),
          const SizedBox(height: 8),
          InkWell(
            onTap: picking ? null : _pickEvidence,
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              height: uploaded ? 118 : 74,
              decoration: BoxDecoration(
                color: uploaded
                    ? DavoColors.of(context).offWhite
                    : DavoColors.of(context).surface,
                border: Border.all(
                    color: uploaded
                        ? AppColors.primary
                        : DavoColors.of(context).border),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: uploaded
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(evidence!.path),
                          height: 92, width: 188, fit: BoxFit.cover),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('$_g/gallery.png',
                            color: DavoColors.of(context).bodyMuted,
                            width: 24,
                            height: 24),
                        const SizedBox(width: 8),
                        Text(
                            picking
                                ? 'Selecting image...'
                                : 'Upload Card Image(s)',
                            style: _body14(context)),
                      ],
                    ),
            ),
          ),
          if (evidence != null)
            Row(children: [
              Expanded(child: Text(evidence!.name, style: _caption(context))),
              TextButton(
                  onPressed: picking
                      ? null
                      : () async {
                          final old = evidence;
                          setState(() => evidence = null);
                          await old?.release();
                        },
                  child: const Text('Remove')),
              TextButton(
                  onPressed: picking ? null : _pickEvidence,
                  child: const Text('Replace')),
            ]),
          if (evidenceError != null)
            Text(evidenceError!, style: _caption(context)),
        ],
      ),
    );
  }

  Future<void> _pickEvidence() async {
    setState(() {
      picking = true;
      evidenceError = null;
    });
    final account = WalletAccountState.instance;
    final generation = account.generation;
    final accountId = account.snapshot.accountId;
    try {
      final picked = await widget.evidencePicker(accountId);
      if (account.generation != generation ||
          account.snapshot.accountId != accountId) {
        await picked?.release();
        return;
      }
      if (!mounted) {
        await picked?.release();
        return;
      }
      if (picked != null) {
        final old = evidence;
        setState(() => evidence = picked);
        await old?.release();
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => evidenceError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() =>
            evidenceError = 'Unable to select this image. Please try again.');
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }
}

class GiftCardSellReviewScreen extends StatefulWidget {
  const GiftCardSellReviewScreen(
      {super.key,
      this.draft,
      required this.brand,
      required this.amount,
      this.cardType,
      this.country,
      this.physical});
  final GiftOrderDraft? draft;
  final GiftCardBrand brand;
  final double amount;
  final String? cardType;
  final String? country;
  final bool? physical;

  @override
  State<GiftCardSellReviewScreen> createState() =>
      _GiftCardSellReviewScreenState();
}

class _GiftCardSellReviewScreenState extends State<GiftCardSellReviewScreen> {
  bool accepted = false;
  bool confirmed = false;
  bool cardValid = false;

  int get payout =>
      (widget.amount * (widget.draft?.product.rateNaira ?? 865)).round();

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      bottom: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PrimaryButton(
              label: confirmed ? 'Submit' : 'Continue',
              enabled: accepted && (!confirmed || cardValid),
              onTap: accepted && (!confirmed || cardValid)
                  ? () {
                      if (!confirmed) {
                        setState(() => confirmed = true);
                      } else {
                        Navigator.of(context).pushReplacement<void, void>(
                          AppPageRoute<void>(
                              builder: (_) => GiftCardSellSubmittedScreen(
                                  brand: widget.brand,
                                  amount: widget.amount,
                                  naira: payout,
                                  subcategory: widget.cardType,
                                  country: widget.country,
                                  draft: widget.draft,
                                  cardType: widget.physical == null
                                      ? null
                                      : widget.physical!
                                          ? 'Physical'
                                          : 'E-code')),
                        );
                      }
                    }
                  : null,
            ),
            if (confirmed) ...[
              const SizedBox(height: 10),
              _SecondaryButton(
                  label: 'Edit Details', onTap: () => Navigator.pop(context)),
            ],
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Sell Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 12),
          Text('Sell ${widget.brand.name}', style: _title24(context)),
          const SizedBox(height: 8),
          _StepProgress(
              step: confirmed ? _GiftCardStep.third : _GiftCardStep.second),
          const SizedBox(height: 22),
          Center(child: Text('Trade Breakdown', style: _title20(context))),
          const SizedBox(height: 3),
          Center(
              child: Text('Kindly read the terms carefully',
                  style: _caption(context))),
          const SizedBox(height: 18),
          _BreakdownCard(
              amount: widget.amount,
              naira: payout,
              sell: true,
              rate: widget.draft?.product.rateNaira ?? 865,
              cardType: widget.cardType ??
                  widget.draft?.product.label ??
                  _product(widget.brand).label,
              footer: Column(children: [
                const SizedBox(height: 14),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: widget.draft?.evidence == null
                        ? const SizedBox.shrink()
                        : Image.file(File(widget.draft!.evidence!.path),
                            width: 120, height: 68, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                const _InfoNote(
                  text:
                      'Please note that the payable amount may change if you upload the wrong subcategory. To avoid issues, kindly review the trade terms below carefully.',
                ),
              ])),
          const SizedBox(height: 14),
          Text('Trade Terms',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DavoColors.of(context).link)),
          const SizedBox(height: 6),
          Text(
            (widget.draft?.product ??
                    _product(widget.brand, physical: widget.physical ?? true))
                .terms,
            style: _caption(context),
          ),
          const SizedBox(height: 16),
          if (!confirmed)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: _outlinedCard(context),
                child: Row(children: [
                  DavoAnimatedCheckbox(
                      value: accepted,
                      semanticLabel: 'I have read and accepted the terms',
                      onChanged: (value) => setState(() => accepted = value)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: GestureDetector(
                          onTap: () => setState(() => accepted = !accepted),
                          child: Text('I have read and accepted the terms',
                              style: _caption(context)))),
                ])),
          if (confirmed) ...[
            const SizedBox(height: 16),
            Container(
                padding: const EdgeInsets.all(8),
                decoration: _softCard(context),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DavoAnimatedCheckbox(
                          value: cardValid,
                          semanticLabel: 'I confirm this card is valid',
                          onChanged: (value) =>
                              setState(() => cardValid = value)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            GestureDetector(
                                onTap: () =>
                                    setState(() => cardValid = !cardValid),
                                child: Text('I confirm this card is valid',
                                    style: _section(context))),
                            const SizedBox(height: 4),
                            Text(
                                'Submitting invalid or used cards may result in account restrictions.',
                                style: _caption(context)),
                          ])),
                    ])),
          ],
        ],
      ),
    );
  }
}

class GiftCardSellSubmittedScreen extends StatefulWidget {
  const GiftCardSellSubmittedScreen(
      {super.key,
      this.draft,
      this.record,
      this.brand,
      this.amount,
      this.naira,
      this.subcategory,
      this.country,
      this.cardType});
  final GiftOrderDraft? draft;
  final ReceiptRecord? record;
  final GiftCardBrand? brand;
  final double? amount;
  final int? naira;
  final String? subcategory, country, cardType;

  @override
  State<GiftCardSellSubmittedScreen> createState() =>
      _GiftCardSellSubmittedScreenState();
}

class _GiftCardSellSubmittedScreenState
    extends State<GiftCardSellSubmittedScreen>
    with ReceiptActivityObserver<GiftCardSellSubmittedScreen> {
  late final ReceiptRecord _record;
  ReceiptRecord get record => ReceiptActivity.resolve(_record);
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _record = widget.record ??
        giftCardPreviewReceipt(
          sell: true,
          occurredAt: now,
          id: receiptDemoId(now),
          cardValue: widget.amount,
          naira: widget.naira,
          brand: widget.brand?.name,
          category: widget.brand?.category.name,
          subcategory: widget.subcategory,
          country: widget.country,
          cardType: widget.cardType,
          draft: widget.draft,
        );
    if (widget.record == null) {
      ReceiptActivity.submitPreview(record);
    } else {
      ReceiptActivity.accept(record);
    }
  }

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.transaction,
      recordId: record.id,
      builder: _buildRefreshed);
  Widget _buildRefreshed(BuildContext context) {
    return _GiftScaffold(
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: () => Navigator.pop(context))),
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: DavoOutcomeContent(
                          mark: record.status == ReceiptStatus.failed
                              ? const _GiftTerminalMark(
                                  status: ReceiptStatus.failed)
                              : null,
                          kind: record.status == ReceiptStatus.completed
                              ? DavoOutcomeKind.completed
                              : DavoOutcomeKind.submitted,
                          semanticLabel: record.status == ReceiptStatus.pending
                              ? 'Trade submitted; review pending'
                              : 'Gift card sale ${record.status.label}',
                          heading: Column(children: [
                            Text(
                                record.status == ReceiptStatus.pending
                                    ? 'Transaction Submitted'
                                    : 'Transaction ${record.status.label}',
                                style: _title20(context)),
                            const SizedBox(height: 4),
                            Text.rich(
                                TextSpan(style: _caption(context), children: [
                              const TextSpan(text: 'Current Trade Status: '),
                              TextSpan(
                                  text: record.status.label,
                                  style: TextStyle(
                                      color: record.status ==
                                              ReceiptStatus.completed
                                          ? DavoColors.of(context).success
                                          : DavoColors.of(context).warning,
                                      fontWeight: FontWeight.w500))
                            ]))
                          ]),
                          details: _GiftOutcomeDetails(record: record))))),
          const SizedBox(height: 12),
          _PrimaryButton(
            label: 'Start New Trade',
            onTap: () => Navigator.of(context).pushReplacement<void, void>(
              AppPageRoute<void>(
                  builder: (_) =>
                      const GiftCardBrandScreen(mode: GiftCardMode.sell)),
            ),
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            label: 'View Receipt',
            onTap: () => Navigator.of(context).push<void>(AppPageRoute<void>(
                builder: (_) => ReceiptScreen(record: record))),
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            label: 'Track Verification',
            onTap: () => Navigator.of(context).push<void>(AppPageRoute<void>(
                builder: (_) => GiftCardVerificationScreen(record: record))),
          ),
        ],
      ),
    );
  }
}

class GiftCardVerificationScreen extends StatefulWidget {
  const GiftCardVerificationScreen({super.key, this.record});
  final ReceiptRecord? record;

  @override
  State<GiftCardVerificationScreen> createState() =>
      _GiftCardVerificationScreenState();
}

class _GiftCardVerificationScreenState extends State<GiftCardVerificationScreen>
    with ReceiptActivityObserver<GiftCardVerificationScreen> {
  late final ReceiptRecord _record;
  ReceiptRecord get record => ReceiptActivity.resolve(_record);
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _record = widget.record ??
        giftCardPreviewReceipt(
            sell: true, occurredAt: now, id: receiptDemoId(now));
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: () => Navigator.pop(context))),
          const SizedBox(height: 20),
          if (record.status == ReceiptStatus.pending)
            const DavoWorkingIndicator(kind: DavoWorkingKind.reviewPending)
          else
            _GiftTerminalMark(status: record.status),
          const SizedBox(height: 20),
          Text(
              record.status == ReceiptStatus.pending
                  ? 'Verifying your card...'
                  : 'Card trade ${record.status.label}',
              style: _title20(context)),
          const SizedBox(height: 5),
          Text(record.status.label, style: _caption(context)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _outlinedCard(context).copyWith(boxShadow: [
              const BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 3))
            ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Progress', style: _section(context)),
                Divider(height: 28, color: DavoColors.of(context).divider),
                for (final event in record.events) ...[
                  _ProgressRow(
                    color: event.state == ReceiptEventState.current
                        ? DavoColors.of(context).warning
                        : AppColors.primary,
                    state: event.state,
                    title: event.label,
                    meta: event.occurredAt == null
                        ? event.description
                        : '${formatReceiptDate(event.occurredAt!)} ? ${event.description}',
                  ),
                  if (event != record.events.last)
                    const _TimelineLine(active: false),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: _softCard(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Reference', style: _caption(context)),
                      const SizedBox(height: 4),
                      Text(record.reference, style: _section(context)),
                    ])),
                const SizedBox(width: 10),
                TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: record.reference));
                      if (context.mounted) {
                        showDavoToast(context, 'Reference copied');
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: DavoColors.of(context).primarySoft,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: const StadiumBorder()),
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: const Text('Copy')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SecondaryButton(
            label: 'Transaction Details',
            onTap: () => Navigator.of(context).push<void>(AppPageRoute<void>(
                builder: (_) =>
                    TransactionRecordDetailsScreen(record: record))),
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
  GiftCatalogProduct? selectedProduct;
  int quantity = 1;

  double get numeric => parseAmount(amount.text);
  bool get ready =>
      selectedProduct != null &&
      numeric.isFinite &&
      numeric >= selectedProduct!.minimumDenomination;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      bottom: _PrimaryButton(
        label: 'Continue',
        enabled: ready,
        onTap: ready
            ? () => Navigator.of(context).push<void>(
                  AppPageRoute<void>(
                      builder: (_) => GiftCardDeliveryScreen(
                          brand: widget.brand,
                          amount: numeric,
                          quantity: quantity,
                          draft: GiftOrderDraft(
                              product: selectedProduct!,
                              denomination: numeric,
                              quantity: quantity))),
                )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: 'Buy Card', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Text('Buy ${widget.brand.name}', style: _title24(context)),
          const SizedBox(height: 8),
          const _StepProgress(step: _GiftCardStep.first),
          const SizedBox(height: 24),
          const _Label('Sub Category'),
          const SizedBox(height: 6),
          _SelectField(
            brand: widget.brand,
            value: categorySelected
                ? selectedProduct!.label
                : 'Select Gift Card Sub Category',
            onTap: () async {
              FocusScope.of(context).unfocus();
              final picked = await _showGiftSubcategories(context, widget.brand,
                  physical: true);
              if (mounted && picked != null) {
                setState(() {
                  categorySelected = true;
                  selectedProduct = picked;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const _Label('Card Amount'),
          const SizedBox(height: 6),
          _AmountField(controller: amount, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          _RateOutput(
              value: (numeric * (selectedProduct?.rateNaira ?? 865)).round(),
              rate: selectedProduct?.rateNaira ?? 865),
          const SizedBox(height: 22),
          const _Label('QUANTITY'),
          const SizedBox(height: 10),
          Container(
            height: 52,
            decoration: _fieldDecoration(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuantityButton(
                    label: '−',
                    onTap:
                        quantity > 1 ? () => setState(() => quantity--) : null),
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: Text('$quantity',
                        key: ValueKey(quantity), style: _section(context))),
                _QuantityButton(
                    label: '+',
                    filled: true,
                    onTap: () => setState(() => quantity++)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GiftCardDeliveryScreen extends StatefulWidget {
  const GiftCardDeliveryScreen(
      {super.key,
      this.draft,
      required this.brand,
      required this.amount,
      required this.quantity});
  final GiftOrderDraft? draft;
  final GiftCardBrand brand;
  final double amount;
  final int quantity;

  @override
  State<GiftCardDeliveryScreen> createState() => _GiftCardDeliveryScreenState();
}

class _GiftCardDeliveryScreenState extends State<GiftCardDeliveryScreen> {
  bool forMe = true;
  bool instant = true;
  String? deliveryError;
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
          Text('Buy ${widget.brand.name}', style: _title24(context)),
          const SizedBox(height: 8),
          const _StepProgress(step: _GiftCardStep.second),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _DeliverySegment(
                      label: 'For Me',
                      asset: '$_g/user.png',
                      active: forMe,
                      onTap: () => setState(() => forMe = true))),
              const SizedBox(width: 8),
              Expanded(
                  child: _DeliverySegment(
                      label: 'Send Gift',
                      asset: '$_g/gift.png',
                      active: !forMe,
                      onTap: () => setState(() => forMe = false))),
            ],
          ),
          const SizedBox(height: 22),
          Text(forMe ? 'Delivery Details' : 'Recipient Details',
              style: _section(context)),
          const SizedBox(height: 12),
          const _Label('Email Address'),
          const SizedBox(height: 6),
          _IconTextField(
              asset: '$_g/mail.png',
              controller: email,
              hint: forMe ? '@gmail.com' : 'recipient@gmail.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          const _Label('Phone (optional)'),
          const SizedBox(height: 6),
          _IconTextField(
              asset: '$_g/phone.png',
              controller: phone,
              hint: '234 000 0000 000',
              keyboard: TextInputType.phone),
          const SizedBox(height: 22),
          Text('Delivery Method', style: _section(context)),
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
            subtitle: forMe
                ? 'Sent to your email address'
                : 'Sent to the recipient email address',
            active: !instant,
            onTap: () => setState(() => instant = false),
          ),
          const SizedBox(height: 28),
          if (deliveryError != null)
            Text(deliveryError!, style: _caption(context)),
          _PrimaryButton(
            label: 'Continue',
            onTap: () {
              final delivery = GiftDelivery(
                  forMe: forMe,
                  instant: instant,
                  email: email.text.trim(),
                  phone: phone.text.trim());
              if (delivery.validationError != null) {
                setState(() => deliveryError = delivery.validationError);
                return;
              }
              final draft = (widget.draft ??
                      GiftOrderDraft(
                          product: _product(widget.brand),
                          denomination: widget.amount,
                          quantity: widget.quantity))
                  .withDelivery(delivery);
              Navigator.of(context).push<void>(
                AppPageRoute<void>(
                    builder: (_) => GiftCardBuyReviewScreen(
                        brand: widget.brand,
                        amount: widget.amount,
                        quantity: widget.quantity,
                        draft: draft)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GiftCardBuyReviewScreen extends StatelessWidget {
  const GiftCardBuyReviewScreen(
      {super.key,
      this.draft,
      required this.brand,
      required this.amount,
      required this.quantity});
  final GiftOrderDraft? draft;
  final GiftCardBrand brand;
  final double amount;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final naira =
        (amount * (draft?.product.rateNaira ?? 865) * quantity).round();
    return _GiftScaffold(
      scroll: true,
      bottom: _PrimaryButton(
        label: 'Continue',
        onTap: () => Navigator.of(context).push<void>(
          AppPageRoute<void>(
              builder: (_) => GiftCardPaymentScreen(
                  amount: amount * quantity,
                  naira: naira,
                  brand: brand,
                  quantity: quantity,
                  country: draft?.product.country ?? _product(brand).country,
                  draft: draft,
                  cardType:
                      draft?.product.typeLabel ?? _product(brand).typeLabel,
                  subcategory: draft?.product.label ?? _product(brand).label)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
              title: 'Review Purchase', onBack: () => Navigator.pop(context)),
          const SizedBox(height: 16),
          Text('Buy ${brand.name}', style: _title24(context)),
          const SizedBox(height: 8),
          const _StepProgress(step: _GiftCardStep.third),
          const SizedBox(height: 22),
          Center(child: Text('Trade Breakdown', style: _title20(context))),
          const SizedBox(height: 3),
          Center(
              child: Text('Kindly read the terms carefully',
                  style: _caption(context))),
          const SizedBox(height: 18),
          _BreakdownCard(
              amount: amount * quantity,
              naira: naira,
              sell: false,
              rate: draft?.product.rateNaira ?? 865,
              cardType: draft?.product.label ?? _product(brand).label),
          if (draft != null) _GiftDeliverySummary(delivery: draft!.delivery),
        ],
      ),
    );
  }
}

class GiftCardPaymentScreen extends StatefulWidget {
  const GiftCardPaymentScreen(
      {super.key,
      this.draft,
      required this.amount,
      required this.naira,
      this.brand,
      this.quantity,
      this.country,
      this.cardType,
      this.subcategory,
      this.record});
  final GiftOrderDraft? draft;
  final double amount;
  final int naira;

  final GiftCardBrand? brand;
  final int? quantity;
  final String? country, cardType, subcategory;
  final ReceiptRecord? record;

  @override
  State<GiftCardPaymentScreen> createState() => _GiftCardPaymentScreenState();
}

class _GiftCardPaymentScreenState extends State<GiftCardPaymentScreen> {
  bool selected = true;

  @override
  Widget build(BuildContext context) {
    return _GiftScaffold(
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: () => Navigator.pop(context))),
          const SizedBox(height: 24),
          Text('Choose payment method', style: _title20(context)),
          const SizedBox(height: 5),
          Text(
              'Select how you would like to fund your gift card purchase. Balance updates are near-instant.',
              style: _caption(context)),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => setState(() => selected = true),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 128),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: DavoColors.of(context).offWhite,
                border: Border.all(
                    color: selected
                        ? DavoColors.of(context).border
                        : DavoColors.of(context).border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: DavoColors.of(context).primarySoft,
                        shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Image.asset('$_f/buy_nigeria.png',
                        width: 24, height: 24, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NGN Wallet Balance', style: _section(context)),
                        const SizedBox(height: 4),
                        ListenableBuilder(
                            listenable: WalletAccountState.instance,
                            builder: (context, _) => Text(
                                'Available balance: ${WalletAccountState.instance.ngnBalanceLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _body14(context))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: DavoColors.of(context).primarySoft,
                              borderRadius: BorderRadius.circular(999)),
                          child: Text('INSTANT SETTLEMENT',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  color: DavoColors.of(context).link)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.draft != null)
            _GiftDeliverySummary(delivery: widget.draft!.delivery),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
            decoration: BoxDecoration(
              color: DavoColors.of(context).surface,
              border: Border.all(color: DavoColors.of(context).divider),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You are buying',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  color: DavoColors.of(context).body)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text(
                                '\$${formatGroupedAmount(widget.amount.toStringAsFixed(2))}',
                                style: _section(context)),
                            const SizedBox(width: 7),
                            Image.asset('$_g/trend.png', width: 18, height: 11)
                          ]),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Estimated Cost', style: _caption(context)),
                          const SizedBox(height: 4),
                          Text('₦${_money(widget.naira)}',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: DavoColors.of(context).link)),
                        ]),
                  ],
                ),
                const SizedBox(height: 16),
                _PrimaryButton(
                  label: 'Continue',
                  onTap: () async {
                    final ok = await Navigator.of(context).push<bool>(
                        AppPageRoute<bool>(
                            builder: (_) => const GiftCardPinScreen()));
                    if (!context.mounted || ok != true) return;
                    Navigator.of(context).pushReplacement<void, void>(
                      AppPageRoute<void>(
                          builder: (_) => GiftCardBuySuccessScreen(
                              amount: widget.amount,
                              naira: widget.naira,
                              brand: widget.brand,
                              quantity: widget.quantity,
                              country: widget.country,
                              cardType: widget.cardType,
                              subcategory: widget.subcategory,
                              record: widget.record,
                              draft: widget.draft)),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('$_f/buy_lock.png',
                        color: DavoColors.of(context).bodyMuted,
                        width: 11,
                        height: 14),
                    const SizedBox(width: 7),
                    Flexible(
                        child: Text('SECURE TRANSACTION POWERED BY DAVOVAULT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 9,
                                letterSpacing: .9,
                                color: DavoColors.of(context).bodyMuted))),
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

class GiftCardPinScreen extends StatelessWidget {
  const GiftCardPinScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      TransactionPinEntryScreen(onConfirm: () => Navigator.pop(context, true));
}

class GiftCardBuySuccessScreen extends StatefulWidget {
  const GiftCardBuySuccessScreen(
      {super.key,
      this.draft,
      required this.amount,
      required this.naira,
      this.brand,
      this.quantity,
      this.country,
      this.cardType,
      this.subcategory,
      this.record});
  final GiftOrderDraft? draft;
  final double amount;
  final int naira;

  final GiftCardBrand? brand;
  final int? quantity;
  final String? country, cardType, subcategory;
  final ReceiptRecord? record;

  @override
  State<GiftCardBuySuccessScreen> createState() =>
      _GiftCardBuySuccessScreenState();
}

class _GiftCardBuySuccessScreenState extends State<GiftCardBuySuccessScreen>
    with ReceiptActivityObserver<GiftCardBuySuccessScreen> {
  late final ReceiptRecord _record;
  ReceiptRecord get record => ReceiptActivity.resolve(_record);
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _record = widget.record ??
        giftCardPreviewReceipt(
          sell: false,
          occurredAt: now,
          id: receiptDemoId(now),
          cardValue: widget.amount,
          naira: widget.naira,
          brand: widget.brand?.name,
          category: widget.brand?.category.name,
          quantity: widget.quantity,
          country: widget.country,
          cardType: widget.cardType,
          subcategory: widget.subcategory,
          draft: widget.draft,
        );
    if (widget.record == null) {
      ReceiptActivity.submitPreview(record);
    } else {
      ReceiptActivity.accept(record);
    }
  }

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.transaction,
      recordId: record.id,
      builder: _buildRefreshed);
  Widget _buildRefreshed(BuildContext context) {
    return _GiftScaffold(
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: () => Navigator.pop(context))),
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: DavoOutcomeContent(
                          mark: record.status == ReceiptStatus.failed
                              ? const _GiftTerminalMark(
                                  status: ReceiptStatus.failed)
                              : null,
                          kind: record.status == ReceiptStatus.completed
                              ? DavoOutcomeKind.completed
                              : DavoOutcomeKind.submitted,
                          semanticLabel:
                              'Gift card purchase ${record.status.label}',
                          heading: Column(children: [
                            Text(
                                record.status == ReceiptStatus.completed
                                    ? 'Purchase Successful!'
                                    : 'Purchase ${record.status.label}',
                                style: _title20(context)),
                            const SizedBox(height: 4),
                            Text(
                                'Gift card purchase ${record.status.label.toLowerCase()}',
                                textAlign: TextAlign.center,
                                style: _body14(context))
                          ]),
                          details: _GiftOutcomeDetails(record: record))))),
          const SizedBox(height: 12),
          _PrimaryButton(
            label: 'Start New Trade',
            onTap: () => Navigator.of(context).pushReplacement<void, void>(
              AppPageRoute<void>(
                  builder: (_) =>
                      const GiftCardBrandScreen(mode: GiftCardMode.buy)),
            ),
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
              label: 'View Receipt',
              onTap: () => Navigator.of(context).push<void>(AppPageRoute<void>(
                  builder: (_) => ReceiptScreen(record: record)))),
        ],
      ),
    );
  }
}

class _GiftTerminalMark extends StatelessWidget {
  const _GiftTerminalMark({required this.status});
  final ReceiptStatus status;
  @override
  Widget build(BuildContext context) {
    final failed = status == ReceiptStatus.failed;
    final color =
        failed ? DavoColors.of(context).danger : DavoColors.of(context).success;
    return Semantics(
      label: 'Gift card trade ${status.label}',
      child: Container(
        width: 148,
        height: 148,
        decoration: BoxDecoration(
            color: color.withValues(alpha: .1), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(
            failed
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 72,
            color: color),
      ),
    );
  }
}

class _GiftOutcomeDetails extends StatelessWidget {
  const _GiftOutcomeDetails({required this.record});
  final ReceiptRecord record;
  @override
  Widget build(BuildContext context) => Column(children: [
        _TransactionCard(rows: [
          ('Transaction ID', record.id, true, false),
          ('Reference Code', record.reference, true, false),
          ...record.fields.map((field) => (
                field.label,
                field.sensitive ? '\u2022\u2022\u2022\u2022' : field.value,
                field.copyable && !field.sensitive,
                false
              )),
          ('Amount', record.amount, false, true),
          ('Status', record.status.label, false, false),
          ('Date', formatReceiptDate(record.occurredAt), false, false),
        ]),
      ]);
}

class _GiftScaffold extends StatelessWidget {
  const _GiftScaffold({required this.child, this.scroll = false, this.bottom});
  final Widget child;
  final Widget? bottom;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18), child: child);
    return Scaffold(
      backgroundColor: DavoColors.of(context).surface,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: bottom)),
      body: SafeArea(
        child: scroll
            ? SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.zero,
                child: body)
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
          Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: onBack)),
          Text(title, style: _section(context)),
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
      child: SizedBox(
          width: 32,
          height: 32,
          child: Image.asset('$_f/buy_back.png',
              color: DavoColors.of(context).ink, fit: BoxFit.contain)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: _caption(context)),
        const SizedBox(height: 2),
        Text(value, style: _section(context))
      ]);
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
      decoration: BoxDecoration(
          color: DavoColors.of(context).fieldFill,
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(
            child: _ModeTab(
                label: 'Buy',
                active: mode == GiftCardMode.buy,
                onTap: () => onChanged(GiftCardMode.buy))),
        Expanded(
            child: _ModeTab(
                label: 'Sell',
                active: mode == GiftCardMode.sell,
                onTap: () => onChanged(GiftCardMode.sell))),
      ]),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
              color:
                  active ? DavoColors.of(context).elevated : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x11000000), blurRadius: 6)]
                  : null),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? AppColors.primary
                      : DavoColors.of(context).bodyMuted)),
        ),
      );
}

class _TopBrandCard extends StatelessWidget {
  const _TopBrandCard(
      {required this.brand,
      required this.accent,
      required this.onTap,
      required this.mode});
  final GiftCardBrand brand;
  final Color accent;
  final VoidCallback onTap;
  final GiftCardMode mode;
  @override
  Widget build(BuildContext context) => Material(
        color: DavoColors.of(context).surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: DavoColors.of(context).divider)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(9)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(brand.asset,
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.contain),
                                      const Spacer(),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: const Text('BEST',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white))),
                                    ]),
                                const SizedBox(height: 8),
                                Text(brand.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ])),
                      Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mode == GiftCardMode.buy ? 'BUY' : 'SELL',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: DavoColors.of(context).body)),
                                Divider(
                                    height: 16,
                                    color: DavoColors.of(context).divider),
                                Row(children: [
                                  Flexible(
                                      child: Text('Tap to trade',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: DavoColors.of(context)
                                                  .link))),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: DavoColors.of(context).link)
                                ]),
                              ])),
                    ]))),
      );
}

class _PopularBrand extends StatelessWidget {
  const _PopularBrand({required this.brand, required this.onTap});
  final GiftCardBrand brand;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
            width: 68,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            decoration: _outlinedCard(context),
            child: Column(children: [
              Image.asset(brand.asset,
                  width: 30, height: 30, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(brand.name.split(' ').first,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: DavoColors.of(context).ink)),
            ])),
      );
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('gift-referral-card'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.celebration_outlined,
                  size: 30, color: Colors.white)),
          const SizedBox(width: 10),
          const Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Refer & earn',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Invite friends. Earn rewards.',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        color: Colors.white70))
              ])),
          TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14)),
              child: const Text('Refer',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
        ]),
      );
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: DavoColors.of(context).primarySoft,
          borderRadius: BorderRadius.circular(14)),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DavoColors.of(context).link)));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
              color:
                  active ? AppColors.primary : DavoColors.of(context).fieldFill,
              borderRadius: BorderRadius.circular(16)),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: active ? Colors.white : DavoColors.of(context).body,
                  fontWeight: FontWeight.w600))));
}

class _BrandListTile extends StatelessWidget {
  const _BrandListTile(
      {required this.brand, required this.onTap, this.selected = false});
  final GiftCardBrand brand;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: DavoColors.of(context).offWhite,
                border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent),
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Image.asset(brand.asset,
                  width: 30, height: 30, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(brand.name,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: DavoColors.of(context).ink)),
                    if (brand.hot) ...[
                      const SizedBox(height: 4),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: DavoColors.of(context).dangerSurface,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('HOT',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: DavoColors.of(context).danger))),
                    ] else if (brand.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(brand.subtitle!,
                          style: TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              color: DavoColors.of(context).body)),
                    ],
                  ])),
              if (brand.rate != null) ...[
                const SizedBox(width: 8),
                Text(brand.rate!,
                    style: TextStyle(
                        fontSize: 10,
                        color: DavoColors.of(context).link,
                        fontWeight: FontWeight.w600)),
              ],
            ])),
      );
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step});
  final _GiftCardStep step;

  @override
  Widget build(BuildContext context) {
    final number = step.index + 1;
    final fraction = number / 3;
    final reduced = DavoMotionPolicy.reduce(context);
    Widget bar(double value) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: DavoColors.of(context).divider,
            color: DavoColors.of(context).link));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      reduced
          ? bar(fraction)
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: fraction, end: fraction),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => bar(value)),
      const SizedBox(height: 6),
      Text('Step $number of 3',
          style: TextStyle(
              fontSize: 10,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: DavoColors.of(context).body)),
    ]);
  }
}

class _TwoChoice extends StatelessWidget {
  const _TwoChoice(
      {required this.left,
      required this.right,
      required this.leftActive,
      required this.onLeft,
      required this.onRight});
  final String left;
  final String right;
  final bool leftActive;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  Widget _pill(BuildContext context, String label, bool selected,
          VoidCallback onTap) =>
      Semantics(
          selected: selected,
          button: true,
          child: Material(
              color:
                  selected ? AppColors.primary : DavoColors.of(context).divider,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : DavoColors.of(context).ink))))));
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 20, runSpacing: 8, children: [
        _pill(context, left, leftActive, onLeft),
        _pill(context, right, !leftActive, onRight),
      ]);
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: _caption(context));
}

Future<GiftCatalogProduct?> _showGiftSubcategories(
        BuildContext context, GiftCardBrand brand,
        {required bool physical}) =>
    showModalBottomSheet<GiftCatalogProduct>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
          top: false,
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select subcategory',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        leading: Image.asset(brand.asset,
                            width: 36, height: 36, fit: BoxFit.contain),
                        title: Text('France ${brand.name}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${physical ? 'Physical' : 'E-code'} (50 above)'),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: DavoColors.of(context).link),
                        onTap: () => Navigator.pop(
                            sheetContext, _product(brand, physical: physical))),
                  ]))),
    );

class _SelectField extends StatelessWidget {
  const _SelectField(
      {required this.value, required this.onTap, required this.brand});
  final GiftCardBrand brand;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: _fieldDecoration(context),
            child: Row(children: [
              Image.asset(brand.asset,
                  width: 24, height: 24, fit: BoxFit.contain),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body14(context))),
              Image.asset('assets/icons/auth/arrow_down.png',
                  color: DavoColors.of(context).ink, width: 20, height: 20)
            ])),
      );
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Focus(
      child: Builder(
          builder: (context) => Container(
              height: 50,
              decoration: _fieldDecoration(context).copyWith(
                  border: Border.all(
                      color: Focus.of(context).hasFocus
                          ? AppColors.primary
                          : DavoColors.of(context).border)),
              child: TextField(
                  keyboardAppearance: Theme.of(context).brightness,
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [GroupedAmountInputFormatter()],
                  onChanged: onChanged,
                  decoration: const DavoInlineInputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      hintText: 'Enter Gift Card Amount'),
                  style: _body14(context)))));
}

class _RateOutput extends StatelessWidget {
  const _RateOutput({required this.value, this.rate = 865});
  final int rate;
  final int value;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: DavoColors.of(context).primarySoft,
                borderRadius: BorderRadius.circular(12)),
            child: Text('\u20a6${_money(value)}',
                style: TextStyle(
                    fontSize: 14,
                    color: DavoColors.of(context).link,
                    fontWeight: FontWeight.w500))),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
                color: DavoColors.of(context).primarySoft,
                borderRadius: BorderRadius.circular(20)),
            child: Text('Rate: \u20a6$rate/\$1',
                style: TextStyle(
                    fontSize: 11, color: DavoColors.of(context).link))),
      ]);
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard(
      {required this.amount,
      required this.naira,
      required this.sell,
      required this.cardType,
      this.rate = 865,
      this.footer});
  final double amount;
  final int naira;
  final bool sell;
  final Widget? footer;
  final String cardType;
  final int rate;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _outlinedCard(context),
        child: Column(children: [
          _SummaryLine(label: 'Card Type', value: cardType),
          Divider(height: 22, color: DavoColors.of(context).divider),
          _SummaryLine(
              label: 'Card Value',
              value: '\$${formatGroupedAmount(amount.toStringAsFixed(2))}'),
          Divider(height: 22, color: DavoColors.of(context).divider),
          _SummaryLine(label: 'Exchange Rate', value: '\u20a6$rate/\$1'),
          Divider(height: 22, color: DavoColors.of(context).divider),
          _SummaryLine(label: 'Gross Amount', value: '₦${_money(naira)}'),
          Divider(height: 22, color: DavoColors.of(context).divider),
          const _SummaryLine(label: 'Processing Fee', value: '₦0'),
          Divider(height: 22, color: DavoColors.of(context).divider),
          _SummaryLine(
              label: sell ? 'Net Payout' : 'Net Debited',
              value: '₦${_money(naira)}',
              blue: true),
          if (footer != null) footer!,
        ]),
      );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(
      {required this.label, required this.value, this.blue = false});
  final String label;
  final String value;
  final bool blue;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 2, child: Text(label, style: _caption(context))),
        const SizedBox(width: 12),
        Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: blue ? FontWeight.w600 : FontWeight.w400,
                    color:
                        blue ? AppColors.primary : DavoColors.of(context).ink)))
      ]);
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: DavoColors.of(context).offWhite,
          borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: _caption(context)));
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.rows});
  final List<(String, String, bool, bool)> rows;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _outlinedCard(context),
        child: Column(
            children: rows.indexed.map((entry) {
          final i = entry.$1;
          final row = entry.$2;
          final status = row.$1 == 'Status';
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: ReceiptDetailRow(
                label: row.$1,
                value: row.$2,
                copyable: row.$3,
                labelStyle: _caption(context),
                valueStyle: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    height: 1.35,
                    color: status
                        ? DavoColors.of(context).success
                        : row.$4
                            ? AppColors.primary
                            : DavoColors.of(context).ink,
                    fontWeight:
                        status || row.$4 ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
            if (i != rows.length - 1)
              Divider(height: 1, color: DavoColors.of(context).divider),
          ]);
        }).toList()),
      );
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow(
      {required this.color,
      required this.title,
      required this.meta,
      required this.state});
  final Color color;
  final String title;
  final String meta;
  final ReceiptEventState state;
  @override
  Widget build(BuildContext context) {
    final done = state == ReceiptEventState.complete;
    final active = done || state == ReceiptEventState.current;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
              color: active ? color : DavoColors.of(context).fieldFill,
              shape: BoxShape.circle),
          child: done
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : active
                  ? Icon(Icons.more_horiz_rounded,
                      size: 16,
                      color: DavoColors.of(context).isDark
                          ? DavoColors.of(context).canvas
                          : DavoColors.of(context).ink)
                  : null),
      const SizedBox(width: 14),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? DavoColors.of(context).ink
                    : DavoColors.of(context).bodyMuted)),
        const SizedBox(height: 4),
        Text(meta,
            style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: state == ReceiptEventState.current
                    ? DavoColors.of(context).warning
                    : DavoColors.of(context).bodyMuted)),
      ])),
    ]);
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.only(left: 10.5),
      color: active ? AppColors.primary : DavoColors.of(context).divider);
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.label, this.filled = false, this.onTap});
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
                child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: filled
                            ? AppColors.primary
                            : DavoColors.of(context).fieldFill,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: filled
                                ? Colors.white
                                : DavoColors.of(context).bodyMuted))))),
      );
}

class _DeliverySegment extends StatelessWidget {
  const _DeliverySegment(
      {required this.label,
      required this.asset,
      required this.active,
      required this.onTap});
  final String label;
  final String asset;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
              color: active
                  ? DavoColors.of(context).primarySoft
                  : DavoColors.of(context).offWhite,
              border: Border.all(
                  color: active
                      ? AppColors.primary
                      : DavoColors.of(context).border),
              borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(asset,
                color: active
                    ? DavoColors.of(context).link
                    : DavoColors.of(context).body,
                width: 22,
                height: 22),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    color: active
                        ? AppColors.primary
                        : DavoColors.of(context).body,
                    fontWeight: FontWeight.w600))
          ])));
}

class _IconTextField extends StatelessWidget {
  const _IconTextField(
      {required this.asset,
      required this.controller,
      required this.hint,
      required this.keyboard});
  final String asset;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  @override
  Widget build(BuildContext context) => Focus(
      child: Builder(
          builder: (context) => Container(
              height: 50,
              decoration: _fieldDecoration(context).copyWith(
                  border: Border.all(
                      color: Focus.of(context).hasFocus
                          ? AppColors.primary
                          : DavoColors.of(context).border)),
              child: Row(children: [
                const SizedBox(width: 12),
                Image.asset(asset,
                    color: DavoColors.of(context).bodyMuted,
                    width: 20,
                    height: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        keyboardAppearance: Theme.of(context).brightness,
                        controller: controller,
                        keyboardType: keyboard,
                        decoration: DavoInlineInputDecoration(hintText: hint),
                        style: _body14(context))),
                const SizedBox(width: 12)
              ]))));
}

class _DeliveryChoice extends StatelessWidget {
  const _DeliveryChoice(
      {required this.title,
      required this.subtitle,
      required this.active,
      required this.onTap});
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
            color: DavoColors.of(context).surface,
            border: Border.all(
                color:
                    active ? AppColors.primary : DavoColors.of(context).border,
                width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: DavoColors.of(context).primarySoft,
                  borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Image.asset('$_g/lightning.png',
                  width: 16, height: 16, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: _section(context)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: _caption(context))
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: DavoColors.of(context).primarySoft,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Free',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      color: DavoColors.of(context).link,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onTap, this.enabled = true});
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: DavoColors.of(context).primaryDisabled,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              textStyle: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          child: Text(label)));
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
              foregroundColor: DavoColors.of(context).ink,
              textStyle: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          child: Text(label)));
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

TextStyle _title24(BuildContext context) => TextStyle(
    fontFamily: 'Sora',
    fontSize: 24,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: DavoColors.of(context).ink);
TextStyle _title20(BuildContext context) => TextStyle(
    fontFamily: 'Sora',
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: DavoColors.of(context).inkStrong);
TextStyle _section(BuildContext context) => TextStyle(
    fontFamily: 'Sora',
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: DavoColors.of(context).ink);
TextStyle _body14(BuildContext context) => TextStyle(
    fontFamily: 'Sora',
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: DavoColors.of(context).body);
TextStyle _caption(BuildContext context) => TextStyle(
    fontFamily: 'Sora',
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w400,
    color: DavoColors.of(context).body);
TextStyle _eyebrow(BuildContext context) => TextStyle(
    fontFamily: 'Sora',
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: .45,
    color: DavoColors.of(context).bodyMuted);

BoxDecoration _fieldDecoration(BuildContext context) => BoxDecoration(
    color: DavoColors.of(context).fieldFill,
    border: Border.all(color: DavoColors.of(context).divider),
    borderRadius: BorderRadius.circular(12));
BoxDecoration _softCard(BuildContext context) => BoxDecoration(
    color: DavoColors.of(context).offWhite,
    borderRadius: BorderRadius.circular(8));
BoxDecoration _outlinedCard(BuildContext context) => BoxDecoration(
    color: DavoColors.of(context).surface,
    border: Border.all(color: DavoColors.of(context).divider),
    borderRadius: BorderRadius.circular(12));

class _GiftDeliverySummary extends StatelessWidget {
  const _GiftDeliverySummary({required this.delivery});
  final GiftDelivery delivery;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(delivery.forMe ? 'For Me' : 'Send Gift', style: _section(context)),
        const SizedBox(height: 6),
        Text(delivery.methodLabel, style: _body14(context)),
        if (delivery.email.isNotEmpty)
          Text(delivery.email, style: _body14(context)),
        if (delivery.phone.isNotEmpty)
          Text(delivery.phone, style: _body14(context)),
      ]));
}
