import '../../shared/formatters/grouped_amount_formatter.dart';
import 'quote_repository.dart';
import 'wallet_repository.dart';

/// Both display estimates derive from one immutable wallet/quote observation.
class WalletValuation {
  const WalletValuation({
    required this.nairaMinorUnits,
    this.usdMinorUnits,
    this.asOf,
    this.quoteId,
  });
  final int nairaMinorUnits;
  final int? usdMinorUnits;
  final DateTime? asOf;
  final String? quoteId;
  factory WalletValuation.forAsset(
    WalletSnapshot wallet,
    String asset, {
    QuoteSnapshot? quote,
  }) {
    final naira = wallet.valuationMinorUnits(asset);
    final fx = wallet.usdNgnMinorUnits;
    final sameQuote =
        quote == null ||
        !quote.isExpired(DateTime.now().toUtc()) &&
            quote.pricesMinorUnits[asset] == wallet.priceMinorUnits(asset) &&
            quote.usdNgnMinorUnits == fx;
    return WalletValuation(
      nairaMinorUnits: naira,
      usdMinorUnits: fx == null || fx <= 0 || !sameQuote
          ? null
          : (BigInt.from(naira) * BigInt.from(100) ~/ BigInt.from(fx)).toInt(),
      asOf: sameQuote ? quote?.asOf : null,
      quoteId: sameQuote ? quote?.id : null,
    );
  }
  String get nairaLabel => WalletAccountState.formatFiat(nairaMinorUnits);
  String? get usdLabel {
    final value = usdMinorUnits;
    if (value == null) return null;
    return '\u2248 \$${formatGroupedAmount((value ~/ 100).toString())}.${(value % 100).toString().padLeft(2, '0')} USD';
  }
}
