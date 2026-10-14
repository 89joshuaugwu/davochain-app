part of 'gift_card_flow.dart';

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
  final Object rate;
  final Object value;

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
