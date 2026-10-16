import '../../core/money/money.dart';

/// Frozen exact local-ledger instruction, separate from receipt display text.
class WalletEffect {
  WalletEffect({
    required this.accountId,
    required this.generation,
    required Map<String, AssetAmount> debits,
    required Map<String, AssetAmount> credits,
  }) : debits = Map.unmodifiable(debits),
       credits = Map.unmodifiable(credits);
  final String accountId;
  final int generation;
  final Map<String, AssetAmount> debits, credits;
  Map<String, Object?> toJson() => {
    'accountId': accountId,
    'generation': generation,
    'debits': _amounts(debits),
    'credits': _amounts(credits),
  };
  static Map<String, Object?> _amounts(Map<String, AssetAmount> values) => {
    for (final e in values.entries)
      e.key: {
        'units': e.value.atomicUnits.toString(),
        'decimals': e.value.decimals,
      },
  };
  factory WalletEffect.fromJson(
    Map<String, Object?> json, {
    required int generation,
  }) {
    Map<String, AssetAmount> amounts(Object? value) {
      final result = <String, AssetAmount>{};
      for (final e in Map<String, Object?>.from(value as Map).entries) {
        final row = Map<String, Object?>.from(e.value as Map);
        final units = BigInt.parse(row['units'] as String);
        final decimals = row['decimals'] as int;
        if (units < BigInt.zero || decimals < 0 || decimals > 30) {
          throw const FormatException('Invalid effect');
        }
        result[e.key] = AssetAmount(e.key, units, decimals);
      }
      return result;
    }

    return WalletEffect(
      accountId: json['accountId'] as String,
      generation: generation,
      debits: amounts(json['debits']),
      credits: amounts(json['credits']),
    );
  }
}
