import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ReceiptAsset {
  btc('BTC', 'assets/figma_exact/dashboard_crypto_icons__CurrencyBtc.svg'),
  eth('ETH', 'assets/figma_exact/dashboard_crypto_icons__CurrencyEth.svg'),
  sol('SOL', 'assets/images/brand/solana_mark.svg'),
  usdt('USDT',
      'assets/figma_exact/dashboard_crypto_icons__vuesax_linear_tether-_usdt_.svg'),
  ngn('NGN', null, '₦'),
  ngd('NGD', null, '₦'),
  usd('USD', null, '\$'),
  giftCard('Gift card', 'assets/figma_exact/giftcards_icons__iconoir_gift.svg');

  const ReceiptAsset(this.label, this.svgPath, [this.glyph = '']);
  final String label;
  final String? svgPath;
  final String glyph;

  static ReceiptAsset? fromText(String text) {
    final upper = text.toUpperCase();
    for (final asset in values.where((a) => a != giftCard)) {
      if (RegExp('\\b${asset.label}\\b').hasMatch(upper)) return asset;
    }
    if (upper.contains('DAVOCHAIN NAIRA')) return ngd;
    if (upper.contains('NAIRA') || text.contains('₦')) return ngn;
    if (upper.contains('BITCOIN')) return btc;
    if (upper.contains('ETHEREUM')) return eth;
    if (upper.contains('SOLANA')) return sol;
    if (upper.contains('TETHER')) return usdt;
    if (upper.contains('DOLLAR') || text.contains('\$')) return usd;
    return null;
  }
}

/// The same supplied marks and currency glyphs are used in exported PDFs.
class ReceiptAssetBadges extends StatelessWidget {
  const ReceiptAssetBadges({super.key, required this.assets});
  final List<ReceiptAsset> assets;
  @override
  Widget build(BuildContext context) => Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final asset in assets)
              Semantics(
                label: 'Asset: ${asset.label}',
                excludeSemantics: true,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 28,
                          height: 28,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: asset == ReceiptAsset.sol
                                  ? Colors.black
                                  : Colors.white,
                              shape: BoxShape.circle),
                          child: asset.svgPath != null
                              ? SvgPicture.asset(asset.svgPath!,
                                  fit: BoxFit.contain)
                              : Center(
                                  child: Text(asset.glyph,
                                      style: const TextStyle(
                                          fontFamily: 'DavoNotoSans',
                                          fontSize: 17,
                                          color: Color(0xFF135CF7),
                                          fontWeight: FontWeight.w700)))),
                      const SizedBox(width: 6),
                      Text(asset.label,
                          style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 11,
                              color: Color(0xFF17202F),
                              fontWeight: FontWeight.w600)),
                    ])),
              ),
          ]);
}
