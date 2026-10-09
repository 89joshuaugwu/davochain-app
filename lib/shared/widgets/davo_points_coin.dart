import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Davochain's rewards symbol. Currency and crypto asset icons remain separate.
class DavoPointsCoin extends StatelessWidget {
  const DavoPointsCoin({super.key, this.size = 20});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Davo Points',
      image: true,
      child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF377CFF),
                      AppColors.primary,
                      AppColors.primaryDark
                    ]),
                border: Border.all(
                    color: const Color(0xFF84AEFF), width: size * .045)),
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(size * .15),
                    child: Image.asset('assets/images/brand/davochain_logo.png',
                        color: Colors.white,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true))),
          )));
}

class DavoPointsAmount extends StatelessWidget {
  const DavoPointsAmount({super.key, required this.text, required this.style});
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const DavoPointsCoin(size: 18),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: style)),
      ]);
}
