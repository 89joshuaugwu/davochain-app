import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The branded mountain card, with content flowing above its decorative art.
class DavoBlueBalanceCard extends StatelessWidget {
  const DavoBlueBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    required this.caption,
    this.artBottom = 0,
    this.amountWidget,
    this.trailing,
    this.labelAction,
  });
  final String label;
  final String amount;
  final String caption;
  final double artBottom;
  final Widget? trailing, labelAction, amountWidget;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final painter =
          TextPainter(
            text: TextSpan(
              text: label,
              style: DefaultTextStyle.of(
                context,
              ).style.merge(const TextStyle(fontSize: 12, color: Colors.white)),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(
            maxWidth: (constraints.maxWidth - 72).clamp(0.0, double.infinity),
          );
      final actionLeft = (16 + painter.width - 8).clamp(
        0.0,
        (constraints.maxWidth - 48).clamp(0.0, double.infinity),
      );
      painter.dispose();
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 130),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: artBottom,
              width: 268,
              height: 60,
              child: Image.asset(
                'assets/figma_exact/balance_wave.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: trailing != null
                          ? MediaQuery.textScalerOf(context).scale(10) * 7 + 28
                          : labelAction != null
                          ? 40
                          : 0,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Semantics(
                    label: '$label: $amount',
                    excludeSemantics: true,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child:
                          amountWidget ??
                          Text(
                            amount,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (labelAction != null)
              Positioned(
                top: 0,
                left: actionLeft,
                child: SizedBox(width: 48, height: 48, child: labelAction!),
              ),
            if (trailing != null)
              Positioned(top: 0, right: 8, child: trailing!),
          ],
        ),
      );
    },
  );
}
