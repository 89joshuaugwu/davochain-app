part of 'gift_card_flow.dart';

class GiftCardBuyFormScreen extends StatefulWidget {
  const GiftCardBuyFormScreen({super.key, required this.brand});
  final GiftCardBrand brand;

  @override
  State<GiftCardBuyFormScreen> createState() => _GiftCardBuyFormScreenState();
}

class _GiftCardBuyFormScreenState extends State<GiftCardBuyFormScreen> {
  final _flow = GiftAmountController();
  TextEditingController get amount => _flow.amount;
  bool categorySelected = false;
  GiftCatalogProduct? get selectedProduct => _flow.product;
  set selectedProduct(GiftCatalogProduct? value) => _flow.product = value;
  int get quantity => _flow.quantity;
  set quantity(int value) => _flow.quantity = value;

  ExactDecimal get numeric => _flow.denomination;
  bool get ready => selectedProduct != null && _flow.ready;

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
            value: selectedProduct != null
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
              value: _flow.cost, rate: selectedProduct?.rateNaira ?? 865),
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
                    duration: DavoMotionPolicy.reduce(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
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
  final Object amount;
  final int quantity;

  @override
  State<GiftCardDeliveryScreen> createState() => _GiftCardDeliveryScreenState();
}

class _GiftCardDeliveryScreenState extends State<GiftCardDeliveryScreen> {
  late final _delivery = GiftDeliveryController(
      initial: widget.draft?.delivery ?? const GiftDelivery());
  bool get forMe => _delivery.forMe;
  set forMe(bool value) => _delivery.forMe = value;
  bool get instant => _delivery.instant;
  set instant(bool value) => _delivery.instant = value;
  String? deliveryError;
  TextEditingController get email => _delivery.email;
  TextEditingController get phone => _delivery.phone;

  @override
  void dispose() {
    _delivery.dispose();
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
              final delivery = _delivery.delivery;
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
  final Object amount;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final total = draft?.totalDenomination ??
        ExactDecimal.from(amount) * ExactDecimal.from(quantity);
    final naira = draft?.costNaira ??
        ExactDecimal.parse((total * ExactDecimal.from(865)).toFixed(2));
    return _GiftScaffold(
      scroll: true,
      bottom: _PrimaryButton(
        label: 'Continue',
        onTap: () => Navigator.of(context).push<void>(
          AppPageRoute<void>(
              builder: (_) => GiftCardPaymentScreen(
                  amount: total,
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
              amount: total,
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
  final Object amount;
  final Object naira;

  final GiftCardBrand? brand;
  final int? quantity;
  final String? country, cardType, subcategory;
  final ReceiptRecord? record;

  @override
  State<GiftCardPaymentScreen> createState() => _GiftCardPaymentScreenState();
}

class _GiftCardPaymentScreenState extends State<GiftCardPaymentScreen> {
  bool selected = true;
  final int _generation = WalletAccountState.instance.generation;

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
              duration: DavoMotionPolicy.reduce(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
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
                                '\$${formatGroupedAmount(ExactDecimal.from(widget.amount).toFixed(2))}',
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
                if (WalletAccountState.instance.simulationEnabled &&
                    ExactDecimal.from(widget.naira).compareTo(
                            ExactDecimal.parse(WalletAccountState
                                .instance.snapshot
                                .available('NGN')
                                .decimal)) >
                        0)
                  const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                          'Insufficient Naira balance. Deposit funds before continuing.')),
                _PrimaryButton(
                  label: 'Continue',
                  enabled: !WalletAccountState.instance.simulationEnabled ||
                      ExactDecimal.from(widget.naira).compareTo(
                              ExactDecimal.parse(WalletAccountState
                                  .instance.snapshot
                                  .available('NGN')
                                  .decimal)) <=
                          0,
                  onTap: () async {
                    final ok = await Navigator.of(context).push<bool>(
                        AppPageRoute<bool>(
                            builder: (_) => const GiftCardPinScreen()));
                    if (!context.mounted ||
                        ok != true ||
                        _generation != WalletAccountState.instance.generation) {
                      return;
                    }
                    if (WalletAccountState.instance.simulationEnabled &&
                        ExactDecimal.from(widget.naira).compareTo(
                                ExactDecimal.parse(WalletAccountState
                                    .instance.snapshot
                                    .available('NGN')
                                    .decimal)) >
                            0) {
                      return;
                    }
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
  final Object amount;
  final Object naira;

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
      onExit: () =>
          finishDavoTransaction(context, tab: 2, giftMode: GiftCardMode.buy),
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(
                  onTap: () => finishDavoTransaction(context,
                      tab: 2, giftMode: GiftCardMode.buy))),
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
            onTap: () => finishDavoTransaction(context,
                tab: 2,
                giftMode: GiftCardMode.buy,
                start: (_) =>
                    const GiftCardBrandScreen(mode: GiftCardMode.buy)),
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
