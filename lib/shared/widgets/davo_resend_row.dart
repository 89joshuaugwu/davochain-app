import 'package:flutter/material.dart';

/// Keeps the resend action and countdown on the right, with room to wrap when
/// the available width or accessibility text size makes one line impractical.
class DavoResendRow extends StatelessWidget {
  const DavoResendRow({
    super.key,
    required this.prompt,
    required this.resend,
    this.countdown,
  });

  final Widget prompt;
  final Widget resend;
  final Widget? countdown;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final actions = Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [resend, if (countdown != null) countdown!],
          );
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          if (constraints.maxWidth < 300 * textScale) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                prompt,
                const SizedBox(height: 4),
                actions,
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: prompt),
              const SizedBox(width: 8),
              Flexible(child: actions),
            ],
          );
        },
      );
}
