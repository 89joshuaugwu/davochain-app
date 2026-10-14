/// Exact non-negative quantities at the boundary of a financial journey.
class AssetAmount {
  const AssetAmount(this.assetId, this.atomicUnits, this.decimals);
  factory AssetAmount.parse(String value, String assetId, int decimals) {
    if (decimals < 0 || decimals > 30) {
      throw const FormatException('Invalid precision');
    }
    final input = value.trim();
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(input)) {
      throw const FormatException('Enter a valid amount');
    }
    final parts = input.split('.');
    final fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > decimals) {
      throw const FormatException('Too many decimal places');
    }
    return AssetAmount(assetId,
        BigInt.parse(parts[0] + fraction.padRight(decimals, '0')), decimals);
  }
  final String assetId;
  final BigInt atomicUnits;
  final int decimals;
  String get decimal {
    if (decimals == 0) return atomicUnits.toString();
    final raw = atomicUnits.toString().padLeft(decimals + 1, '0');
    final fraction =
        raw.substring(raw.length - decimals).replaceFirst(RegExp(r'0+$'), '');
    return '${raw.substring(0, raw.length - decimals)}${fraction.isEmpty ? '' : '.$fraction'}';
  }

  bool covers(AssetAmount other) =>
      assetId == other.assetId &&
      decimals == other.decimals &&
      atomicUnits >= other.atomicUnits;
}

class Money {
  const Money(this.currency, this.minorUnits);
  final String currency;
  final int minorUnits;
}
