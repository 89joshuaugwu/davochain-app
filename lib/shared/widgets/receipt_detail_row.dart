import 'package:flutter/material.dart';
import 'davo_copy_button.dart';

import '../../core/theme/app_theme.dart';

/// Receipt columns share a value edge, including rows with copy controls.
/// Values wrap without truncation; clipboard data always retains the raw value.
class ReceiptDetailRow extends StatelessWidget {
  const ReceiptDetailRow(
      {super.key,
      required this.label,
      required this.value,
      this.copyable = false,
      this.leading,
      this.valueColor,
      this.labelStyle,
      this.valueStyle,
      this.onCopy});

  final String label, value;
  final bool copyable;
  final Widget? leading;
  final Color? valueColor;
  final TextStyle? labelStyle, valueStyle;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: labelStyle ??
                      const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.bodyMuted))),
          const SizedBox(width: 12),
          Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (leading != null) ...[
                    SizedBox(width: 24, height: 24, child: leading),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                      child: Text(value,
                          textAlign: TextAlign.right,
                          style: valueStyle ??
                              TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  height: 1.35,
                                  color: valueColor ?? AppColors.ink))),
                ],
              )),
          SizedBox(
              width: 32,
              child: copyable
                  ? DavoCopyButton(value: value, label: label, onCopied: onCopy)
                  : null),
        ],
      );
}
