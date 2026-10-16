import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../formatters/grouped_amount_formatter.dart';

/// Shared pay/receive layout. Selectors remain explicit, reachable controls.
class TradeAmountCard extends StatelessWidget {
  const TradeAmountCard({
    super.key,
    required this.label,
    required this.selector,
    required this.footer,
    this.controller,
    this.value,
    this.valueWidget,
    this.amountPrefix,
    this.onChanged,
  });
  final String label, footer;
  final Widget selector;
  final TextEditingController? controller;
  final String? value;
  final Widget? valueWidget, amountPrefix;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final quantity = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Align(
        alignment: Alignment.centerRight,
        child: controller != null
            ? Semantics(
                label: '$label amount',
                child: TextField(
                  controller: controller,
                  onChanged: (_) => onChanged?.call(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [GroupedAmountInputFormatter()],
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: amountPrefix,
                    hintText: '0.00',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
            : valueWidget ??
                  Text(
                    value ?? '0.00',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
      ),
    );
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
                  : colors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 12, color: colors.body),
                    ),
                  ),
                  Text(
                    'Amount',
                    style: TextStyle(fontSize: 12, color: colors.body),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Keep a two-column hierarchy until text needs its own full-width row.
                  final stacked =
                      constraints.maxWidth < 280 ||
                      MediaQuery.textScalerOf(context).scale(14) > 19;
                  return stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: selector,
                            ),
                            const SizedBox(height: 8),
                            quantity,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 5, child: selector),
                            const SizedBox(width: 12),
                            Expanded(flex: 6, child: quantity),
                          ],
                        );
                },
              ),
              const SizedBox(height: 10),
              Text(
                footer,
                style: TextStyle(fontSize: 12, height: 1.5, color: colors.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TradeCurrencySelector extends StatelessWidget {
  const TradeCurrencySelector({
    super.key,
    required this.icon,
    required this.name,
    required this.symbol,
    this.onTap,
  });
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 12,
                        color: DavoColors.of(context).body,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: DavoColors.of(context).link,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// Full-width shortcuts, with selection cleared when the amount is edited.
class TradePercentageButtons extends StatefulWidget {
  const TradePercentageButtons({
    super.key,
    required this.controller,
    required this.onPick,
  });
  final TextEditingController controller;
  final ValueChanged<int> onPick;
  @override
  State<TradePercentageButtons> createState() => _TradePercentageButtonsState();
}

class _TradePercentageButtonsState extends State<TradePercentageButtons> {
  int? _selected;
  String? _selectedText;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_edited);
  }

  @override
  void didUpdateWidget(covariant TradePercentageButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_edited);
      widget.controller.addListener(_edited);
      _selected = null;
      _selectedText = null;
    }
  }

  void _edited() {
    if (_selected != null && widget.controller.text != _selectedText) {
      setState(() {
        _selected = null;
        _selectedText = null;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_edited);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const values = [10, 25, 50, 75, 100];
      final colors = DavoColors.of(context);
      final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final columns = constraints.maxWidth >= (48 * textScale + 8) * 5 - 8
          ? 5
          : 3;
      final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final percent in values)
            SizedBox(
              width: width,
              child: Semantics(
                selected: _selected == percent,
                child: OutlinedButton(
                  onPressed: () {
                    widget.onPick(percent);
                    setState(() {
                      _selected = percent;
                      _selectedText = widget.controller.text;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    foregroundColor: _selected == percent
                        ? Colors.white
                        : colors.link,
                    backgroundColor: _selected == percent
                        ? AppColors.primary
                        : colors.surface,
                    side: BorderSide(
                      color: _selected == percent
                          ? AppColors.primary
                          : colors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(percent == 100 ? 'Max' : '$percent%'),
                ),
              ),
            ),
        ],
      );
    },
  );
}
