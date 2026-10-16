import 'dart:convert';

const davochainFiatWalletVersion = 2;

/// Known v1 checkpoints contain independently funded NGN and NGD buckets.
/// The marker makes their 1:1 consolidation idempotent; unknown layouts fail.
Map<String, Object?> migrateDavochainNairaCheckpoint(
  Map<String, Object?> input,
) {
  try {
    final data = Map<String, Object?>.from(
      jsonDecode(jsonEncode(input)) as Map,
    );
    if (data['schema'] != 1) {
      throw const FormatException('Unknown account schema');
    }
    final wallet = Map<String, Object?>.from(data['wallet'] as Map);
    final canonical = wallet['fiatWalletVersion'] == davochainFiatWalletVersion;
    data['wallet'] = migrateDavochainNairaWallet(wallet);
    data['receipts'] = [
      for (final raw in data['receipts'] as List)
        _receipt(Map<String, Object?>.from(raw as Map), canonical: canonical),
    ];
    return data;
  } catch (error) {
    if (error is FormatException) rethrow;
    throw const FormatException('Invalid fiat account checkpoint');
  }
}

Map<String, Object?> migrateDavochainNairaWallet(Map<String, Object?> input) {
  try {
    final wallet = Map<String, Object?>.from(
      jsonDecode(jsonEncode(input)) as Map,
    );
    if (wallet['schema'] != 1) {
      throw const FormatException('Unknown wallet schema');
    }
    final version = wallet['fiatWalletVersion'];
    if (version != null &&
        version != 1 &&
        version != davochainFiatWalletVersion) {
      throw const FormatException('Unknown fiat wallet layout');
    }
    final canonical = version == davochainFiatWalletVersion;
    final amounts = Map<String, Object?>.from(wallet['amounts'] as Map);
    if (!amounts.containsKey('NGN') && !amounts.containsKey('NGD')) {
      throw const FormatException('Missing naira wallet');
    }
    final prices = Map<String, Object?>.from(wallet['prices'] as Map);
    for (final currency in ['NGN', 'NGD']) {
      if (prices.containsKey(currency) && prices[currency] != 100) {
        throw const FormatException(
          'Fiat wallet must represent naira at one to one',
        );
      }
    }
    wallet['amounts'] = _amounts(amounts, canonical: canonical);
    wallet['prices'] = {...prices..remove('NGD'), 'NGN': 100};
    wallet['reserved'] = {
      for (final entry in (wallet['reserved'] as Map).entries)
        entry.key as String: _effect(
          Map<String, Object?>.from(entry.value as Map),
          canonical: canonical,
        ),
    };
    wallet['fiatWalletVersion'] = davochainFiatWalletVersion;
    return wallet;
  } catch (error) {
    if (error is FormatException) rethrow;
    throw const FormatException('Invalid fiat wallet checkpoint');
  }
}

Map<String, Object?> _amounts(
  Map<String, Object?> input, {
  required bool canonical,
}) {
  final result = Map<String, Object?>.from(input);
  if (canonical && result.containsKey('NGD')) {
    throw const FormatException('Retired fiat balance reintroduced');
  }
  BigInt units(Object? raw) {
    final row = raw as Map;
    final amount = BigInt.parse(row['units'] as String);
    if (row['decimals'] != 2 || amount < BigInt.zero) {
      throw const FormatException('Invalid fiat precision');
    }
    return amount;
  }

  if (result.containsKey('NGN')) units(result['NGN']);
  if (result.containsKey('NGD')) {
    final combined =
        units(result.remove('NGD')) +
        (result.containsKey('NGN') ? units(result['NGN']) : BigInt.zero);
    result['NGN'] = {'units': combined.toString(), 'decimals': 2};
  }
  return result;
}

Map<String, Object?> _effect(
  Map<String, Object?> effect, {
  required bool canonical,
}) => {
  ...effect,
  'debits': _amounts(
    Map<String, Object?>.from(effect['debits'] as Map),
    canonical: canonical,
  ),
  'credits': _amounts(
    Map<String, Object?>.from(effect['credits'] as Map),
    canonical: canonical,
  ),
};
Map<String, Object?> _receipt(
  Map<String, Object?> record, {
  required bool canonical,
}) => {
  ...record,
  if (record['effect'] != null)
    'effect': _effect(
      Map<String, Object?>.from(record['effect'] as Map),
      canonical: canonical,
    ),
};
