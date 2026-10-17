import 'package:flutter/material.dart';
import '../formatters/grouped_amount_formatter.dart';

/// A custom brand glyph; never send this private-use character as plain text.
const davochainCurrencyGlyph = '\ue900';
const _currencyFont = 'DavochainCurrency';

String davochainNairaText(int minorUnits) {
  final units = minorUnits.abs();
  final amount =
      '${minorUnits < 0 ? '-' : ''}${formatGroupedAmount((units ~/ 100).toString())}.${(units % 100).toString().padLeft(2, '0')}';
  return '$amount Davochain Naira';
}

/// Exact two-decimal money, with accessible speech and a baseline-aligned mark.
class DavoNairaAmount extends StatelessWidget {
  const DavoNairaAmount({
    super.key,
    required this.minorUnits,
    this.style,
    this.visible = true,
    this.textAlign,
  });
  final int minorUnits;
  final TextStyle? style;
  final bool visible;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Semantics(
        label: 'Balance hidden',
        child: ExcludeSemantics(
          child: Text(
            '\u2022\u2022\u2022\u2022',
            style: style,
            textAlign: textAlign,
          ),
        ),
      );
    }
    final amount = davochainNairaText(
      minorUnits,
    ).replaceFirst(' Davochain Naira', '');
    return Semantics(
      label: davochainNairaText(minorUnits),
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              if (minorUnits < 0) const TextSpan(text: '\u2212'),
              const TextSpan(
                text: davochainCurrencyGlyph,
                style: TextStyle(
                  fontFamily: _currencyFont,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                ),
              ),
              TextSpan(text: minorUnits < 0 ? amount.substring(1) : amount),
            ],
          ),
          style: style,
          textAlign: textAlign,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}

class DavoCurrencyMark extends StatelessWidget {
  const DavoCurrencyMark({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
    davochainCurrencyGlyph,
    semanticsLabel: 'Davochain Naira',
    style: TextStyle(
      fontFamily: _currencyFont,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.normal,
      height: 1,
    ),
  );
}

/// A trading quote denominated in the Davochain cash wallet.
class DavoCashExchangeRate extends StatelessWidget {
  const DavoCashExchangeRate({
    super.key,
    required this.assetSymbol,
    required this.minorUnits,
  });
  final String assetSymbol;
  final int minorUnits;
  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: 12, height: 1.5);
    return Semantics(
      label: '1 $assetSymbol approximately ${davochainNairaText(minorUnits)}',
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('1 $assetSymbol \u2248 ', style: style),
          DavoNairaAmount(minorUnits: minorUnits, style: style),
        ],
      ),
    );
  }
}
