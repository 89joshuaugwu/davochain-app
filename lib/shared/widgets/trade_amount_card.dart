import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../formatters/grouped_amount_formatter.dart';

/// Shared pay/receive layout. Selectors remain explicit, reachable controls.
class TradeAmountCard extends StatelessWidget {
  const TradeAmountCard(
      {super.key,
      required this.label,
      required this.selector,
      required this.footer,
      this.controller,
      this.value,
      this.onChanged});
  final String label, footer;
  final Widget selector;
  final TextEditingController? controller;
  final String? value;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return Focus(
        child: Builder(
            builder: (context) => Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Focus.of(context).hasFocus
                            ? AppColors.primary
                            : colors.border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(fontSize: 12, color: colors.body)),
                      const SizedBox(height: 10),
                      selector,
                      const SizedBox(height: 12),
                      if (controller != null)
                        Semantics(
                            label: '$label amount',
                            child: TextField(
                                controller: controller,
                                onChanged: (_) => onChanged?.call(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: const [
                                  GroupedAmountInputFormatter()
                                ],
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: colors.ink),
                                decoration: const InputDecoration(
                                    hintText: '0.00',
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero)))
                      else
                        Text(value ?? '0.00',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: colors.ink)),
                      const SizedBox(height: 10),
                      Text(footer,
                          style: TextStyle(fontSize: 12, color: colors.body)),
                    ]))));
  }
}

class TradeCurrencySelector extends StatelessWidget {
  const TradeCurrencySelector(
      {super.key,
      required this.icon,
      required this.name,
      required this.symbol,
      this.onTap});
  final Widget icon;
  final String name, symbol;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
      button: onTap != null,
      label: onTap == null ? name : 'Change currency, $name',
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                icon,
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(symbol,
                          style: TextStyle(
                              fontSize: 12, color: DavoColors.of(context).body))
                    ])),
                if (onTap != null)
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: DavoColors.of(context).link),
              ]))));
}
