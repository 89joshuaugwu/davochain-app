import '../buy_crypto/presentation/buy_crypto_models.dart';
import 'wallet_repository.dart';

/// A stable product shortlist, not a claim about live market rankings.
const popularCryptoSymbols = ['USDT', 'BTC', 'ETH', 'USDC', 'SOL'];

/// A common positive FX factor preserves exact naira/USD value ordering.
/// Compare minor units before display rounding so small positions do not tie.
List<BuyCryptoAsset> orderedCryptoAssets(
  WalletSnapshot wallet, {
  String query = '',
  int? limit,
  bool fundedOnly = false,
  BuyCryptoAsset? excluded,
}) {
  bool funded(BuyCryptoAsset asset) =>
      wallet.assets.contains(asset.symbol) &&
      wallet.available(asset.symbol).atomicUnits > BigInt.zero;
  int? value(BuyCryptoAsset asset) =>
      wallet.assets.contains(asset.symbol) &&
          wallet.priceMinorUnits(asset.symbol) != null
      ? wallet.valuationMinorUnits(asset.symbol)
      : null;
  int popularity(BuyCryptoAsset asset) {
    final index = popularCryptoSymbols.indexOf(asset.symbol);
    return index < 0 ? popularCryptoSymbols.length : index;
  }

  final search = query.trim().toLowerCase();
  final result = BuyCryptoAsset.values
      .where(
        (asset) =>
            asset != excluded &&
            (!fundedOnly || funded(asset)) &&
            '${asset.name} ${asset.symbol}'.toLowerCase().contains(search),
      )
      .toList();
  result.sort((a, b) {
    final aFunded = funded(a), bFunded = funded(b);
    if (aFunded != bFunded) return aFunded ? -1 : 1;
    if (aFunded) {
      final av = value(a), bv = value(b);
      if ((av == null) != (bv == null)) return av == null ? 1 : -1;
      final compared = (bv ?? 0).compareTo(av ?? 0);
      if (compared != 0) return compared;
    }
    final popular = popularity(a).compareTo(popularity(b));
    if (popular != 0) return popular;
    final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return name != 0 ? name : a.symbol.compareTo(b.symbol);
  });
  return List.unmodifiable(
    limit == null ? result : result.take(limit < 0 ? 0 : limit),
  );
}
