part of 'gift_card_flow.dart';

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
      height: 48,
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
    return IconButton(
      tooltip: 'Back',
      onPressed: onTap,
      icon: Icon(Icons.arrow_back_rounded, color: DavoColors.of(context).ink),
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
      height: 56,
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
          duration: DavoMotionPolicy.reduce(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
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
          duration: DavoMotionPolicy.reduce(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
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
              duration: DavoMotionPolicy.reduce(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
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

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard(
      {required this.amount,
      required this.naira,
      required this.sell,
      required this.cardType,
      this.rate = 865,
      this.footer});
  final Object amount;
  final Object naira;
  final bool sell;
  final Widget? footer;
  final String cardType;
  final Object rate;

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
              value:
                  '\$${formatGroupedAmount(ExactDecimal.from(amount).toFixed(2))}'),
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

String _money(Object value) => formatGroupedAmount(
    ExactDecimal.from(value).toFixed(2).replaceFirst(RegExp(r'\.00$'), ''));

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
