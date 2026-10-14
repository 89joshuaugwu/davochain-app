part of 'gift_card_flow.dart';

class GiftCardSellFormScreen extends StatefulWidget {
  const GiftCardSellFormScreen(
      {super.key, required this.brand, this.evidencePicker = pickGiftEvidence});
  final GiftEvidencePicker evidencePicker;
  final GiftCardBrand brand;

  @override
  State<GiftCardSellFormScreen> createState() => _GiftCardSellFormScreenState();
}

class _GiftCardSellFormScreenState extends State<GiftCardSellFormScreen> {
  final _flow = GiftAmountController();
  TextEditingController get amount => _flow.amount;
  bool physical = true;
  bool categorySelected = false;
  GiftEvidence? evidence;
  GiftCatalogProduct? get selectedProduct => _flow.product;
  set selectedProduct(GiftCatalogProduct? value) => _flow.product = value;
  bool picking = false;
  String? evidenceError;
  bool get uploaded => evidence != null;

  ExactDecimal get numeric => _flow.denomination;
  ExactDecimal get naira => _flow.cost;
  bool get ready =>
      selectedProduct != null && _flow.ready && uploaded && !picking;

  void _flowChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _flow.addListener(_flowChanged);
  }

  @override
  void dispose() {
    if (evidence != null) unawaited(evidence!.release());
    _flow.removeListener(_flowChanged);
    _flow.dispose();
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
            value: selectedProduct != null
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
              duration: DavoMotionPolicy.reduce(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
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
  final Object amount;
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

  ExactDecimal get payout =>
      widget.draft?.costNaira ??
      ExactDecimal.parse(
          (ExactDecimal.from(widget.amount) * ExactDecimal.from(865))
              .toFixed(2));

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
  final Object? amount;
  final Object? naira;
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
