import '../../core/money/exact_decimal.dart';
import '../../core/money/money.dart';

/// Atomic-unit rules shared by trade entry and withdrawal authorization.
abstract final class CryptoTradeAmounts {
  static ExactDecimal percentage(AssetAmount available, int percent) {
    if (percent < 0 || percent > 100) throw RangeError.range(percent, 0, 100);
    return (ExactDecimal.parse(available.decimal) * ExactDecimal.from(percent))
        .divide(ExactDecimal.from(100),
            scale: available.decimals, rounding: DecimalRounding.floor);
  }

  static bool canSpend(AssetAmount available, ExactDecimal amount,
      {ExactDecimal? fee}) {
    if (amount.isZero || amount.isNegative || (fee?.isNegative ?? false)) {
      return false;
    }
    try {
      final requested = AssetAmount.parse(
          amount.toString(), available.assetId, available.decimals);
      final total = AssetAmount.parse(
          (amount + (fee ?? ExactDecimal.zero)).toString(),
          available.assetId,
          available.decimals);
      return requested.atomicUnits > BigInt.zero && available.covers(total);
    } on FormatException {
      return false;
    }
  }
}
