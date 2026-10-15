import 'package:flutter/material.dart';

/// Groups the resend action with its prompt and puts only the timer on the right.
/// Allows wrapping when
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
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final promptAndAction = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [prompt, resend],
          );
          if (constraints.maxWidth < 300 * textScale) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                promptAndAction,
                if (countdown != null) ...[
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerRight, child: countdown!),
                ],
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: promptAndAction),
              if (countdown != null) ...[
                const SizedBox(width: 8),
                countdown!,
              ],
            ],
          );
        },
      );
}
