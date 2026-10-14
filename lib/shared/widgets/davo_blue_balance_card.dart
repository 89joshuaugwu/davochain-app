import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The branded mountain card, with content flowing above its decorative art.
class DavoBlueBalanceCard extends StatelessWidget {
  const DavoBlueBalanceCard(
      {super.key,
      required this.label,
      required this.amount,
      required this.caption,
      this.trailing});
  final String label;
  final String amount;
  final String caption;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
      child: Stack(children: [
        Positioned(
            right: 0,
            bottom: 0,
            width: 268,
            height: 104,
            child: Image.asset('assets/figma_exact/balance_wave.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true)),
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white))),
                if (trailing != null) trailing!
              ]),
              const SizedBox(height: 10),
              Semantics(
                  label: '$label: $amount',
                  excludeSemantics: true,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(amount,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)))),
              const SizedBox(height: 6),
              Text(caption,
                  style: const TextStyle(fontSize: 13, color: Colors.white)),
            ])),
      ]));
}
