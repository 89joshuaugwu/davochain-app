import 'quote_repository.dart';
import 'dart:async';
import 'wallet_effect.dart';
import 'simulation_quotes.dart';
import 'package:flutter/foundation.dart';
import '../../core/money/money.dart';
import '../../shared/formatters/grouped_amount_formatter.dart';

class WalletSnapshot {
  WalletSnapshot({
    required this.accountId,
    required this.version,
    required Map<String, AssetAmount> available,
    required Map<String, int> pricesMinorUnits,
    this.usdNgnMinorUnits,
  }) : _available = Map.unmodifiable(available),
       _prices = Map.unmodifiable(pricesMinorUnits);
  final String accountId;
  final int? usdNgnMinorUnits;
  final int version;
  final Map<String, AssetAmount> _available;
  final Map<String, int> _prices;
  AssetAmount available(String asset) =>
      _available[asset] ?? (throw StateError('Unsupported wallet $asset'));
  int? priceMinorUnits(String asset) => _prices[asset];
  Iterable<String> get assets => _available.keys;
  int get portfolioMinorUnits => assets
      .where((asset) => asset != 'NGN' && asset != 'NGD')
      .fold(0, (total, asset) => total + valuationMinorUnits(asset));
  int valuationMinorUnits(String asset) {
    final amount = available(asset);
    return (amount.atomicUnits *
            BigInt.from(_prices[asset]!) ~/
            BigInt.from(10).pow(amount.decimals))
        .toInt();
  }

  /// Indicative USD equivalent using the same snapshot's USDC/NGN quote.
  /// A service-provided FX quote can replace this estimate at integration.
  String? usdEquivalentLabel(int ngnMinorUnits) {
    final price = usdNgnMinorUnits ?? _prices['USDC'];
    if (price == null || price <= 0) return null;
    final cents =
        BigInt.from(ngnMinorUnits) * BigInt.from(100) ~/ BigInt.from(price);
    final whole = formatGroupedAmount((cents ~/ BigInt.from(100)).toString());
    return '\u2248 \$$whole.${(cents % BigInt.from(100)).toString().padLeft(2, '0')} USD';
  }

  static WalletSnapshot seeded() => WalletSnapshot(
    accountId: 'local-account',
    version: 1,
    available: {
      'NGN': AssetAmount.parse('1284500.35', 'NGN', 2),
      'NGD': AssetAmount.parse('135000', 'NGD', 2),
      'BTC': AssetAmount.parse('0.0086', 'BTC', 8),
      'ETH': AssetAmount.parse('0.102', 'ETH', 8),
      'SOL': AssetAmount.parse('2', 'SOL', 9),
      'USDT': AssetAmount.parse('250', 'USDT', 6),
      'USDC': AssetAmount.parse('112.20', 'USDC', 6),
    },
    pricesMinorUnits: {
      'NGN': 100,
      'NGD': 100,
      'BTC': 2400000000,
      'ETH': 520000000,
      'SOL': 26500000,
      'USDT': 154000,
      'USDC': 154000,
    },
  );
}

/// Observable account facts; provider adapters publish snapshots after a read.
class WalletAccountState extends ChangeNotifier {
  WalletAccountState();
  static final instance = WalletAccountState();
  WalletSnapshot snapshot = WalletSnapshot.seeded();
  int generation = 0;
  int _fundsRevision = 0;
  bool simulationEnabled = false;
  final Map<String, WalletEffect> _reserved = {};
  final Set<String> _settled = {}, _rejected = {};

  void startSimulation({required bool empty}) {
    reset();
    simulationEnabled = true;
    final previous = snapshot;
    snapshot = WalletSnapshot(
      accountId: 'account-${DateTime.now().microsecondsSinceEpoch}-$generation',
      version: 1,
      available: {
        for (final entry in SimulationQuotes.decimals.entries)
          entry.key: AssetAmount(
            entry.key,
            empty || !previous.assets.contains(entry.key)
                ? BigInt.zero
                : previous.available(entry.key).atomicUnits,
            entry.value,
          ),
      },
      pricesMinorUnits: SimulationQuotes.pricesMinorUnits,
      usdNgnMinorUnits: SimulationQuotes.usdNgnMinorUnits,
    );
    notifyListeners();
  }

  WalletEffect effect({
    Map<String, String> debits = const {},
    Map<String, String> credits = const {},
  }) => WalletEffect(
    accountId: snapshot.accountId,
    generation: generation,
    debits: {
      for (final entry in debits.entries)
        entry.key: AssetAmount.parse(
          entry.value,
          entry.key,
          snapshot.available(entry.key).decimals,
        ),
    },
    credits: {
      for (final entry in credits.entries)
        entry.key: AssetAmount.parse(
          entry.value,
          entry.key,
          snapshot.available(entry.key).decimals,
        ),
    },
  );

  /// Reserves pending debits, settles destination once, refunds failed requests.
  /// False means the local record must fail; no negative balance is published.
  bool applyEffect(
    String id,
    WalletEffect effect, {
    required bool completed,
    required bool failed,
  }) {
    if (!simulationEnabled ||
        effect.generation != generation ||
        effect.accountId != snapshot.accountId) {
      return false;
    }
    if (_settled.contains(id)) {
      return true;
    }
    if (_rejected.contains(id)) {
      return failed;
    }
    final values = {
      for (final asset in snapshot.assets) asset: snapshot.available(asset),
    };
    bool valid(AssetAmount amount) =>
        values.containsKey(amount.assetId) &&
        amount.atomicUnits >= BigInt.zero &&
        amount.decimals == values[amount.assetId]!.decimals;
    if ([
      ...effect.debits.values,
      ...effect.credits.values,
    ].any((a) => !valid(a))) {
      return false;
    }
    void change(AssetAmount amount, bool subtract) {
      final current = values[amount.assetId]!;
      values[amount.assetId] = AssetAmount(
        current.assetId,
        current.atomicUnits +
            (subtract ? -amount.atomicUnits : amount.atomicUnits),
        current.decimals,
      );
    }

    if (failed) {
      final held = _reserved.remove(id);
      if (held != null) {
        for (final amount in held.debits.values) {
          change(amount, false);
        }
      }
      _rejected.add(id);
    } else {
      final held = _reserved[id];
      if (held == null) {
        if (effect.debits.values.any((a) => !values[a.assetId]!.covers(a))) {
          _rejected.add(id);
          return false;
        }
        for (final amount in effect.debits.values) {
          change(amount, true);
        }
        _reserved[id] = effect;
      }
      if (completed) {
        // Use the originally reserved instruction, never a changed receipt payload.
        for (final amount in (held ?? effect).credits.values) {
          change(amount, false);
        }
        _reserved.remove(id);
        _settled.add(id);
      }
    }
    _fundsRevision++;
    snapshot = WalletSnapshot(
      accountId: snapshot.accountId,
      version: snapshot.version + 1,
      available: values,
      pricesMinorUnits: snapshot._prices,
      usdNgnMinorUnits: snapshot.usdNgnMinorUnits,
    );
    scheduleMicrotask(notifyListeners);
    return true;
  }

  /// Private working copy: mutations are published only after a durable write.
  WalletAccountState fork() {
    final copy = WalletAccountState();
    copy.snapshot = snapshot;
    copy.generation = generation;
    copy.simulationEnabled = simulationEnabled;
    copy._fundsRevision = _fundsRevision;
    copy._reserved.addAll(_reserved);
    copy._settled.addAll(_settled);
    copy._rejected.addAll(_rejected);
    copy.quoteId = quoteId;
    copy.activeQuote = activeQuote;
    return copy;
  }

  int get fundsRevision => _fundsRevision;
  bool adoptFunds(WalletAccountState staged, {required int expectedRevision}) {
    if (generation != staged.generation ||
        snapshot.accountId != staged.snapshot.accountId ||
        _fundsRevision != expectedRevision) {
      return false;
    }
    _reserved
      ..clear()
      ..addAll(staged._reserved);
    _settled
      ..clear()
      ..addAll(staged._settled);
    _rejected
      ..clear()
      ..addAll(staged._rejected);
    snapshot = WalletSnapshot(
      accountId: snapshot.accountId,
      version: snapshot.version + 1,
      available: staged.snapshot._available,
      pricesMinorUnits: snapshot._prices,
      usdNgnMinorUnits: snapshot.usdNgnMinorUnits,
    );
    _fundsRevision++;
    notifyListeners();
    return true;
  }

  String? quoteId;
  QuoteSnapshot? activeQuote;
  void updateQuotes(QuoteSnapshot quote) {
    if (!simulationEnabled || quoteId == quote.id) return;
    if (snapshot.assets.any(
      (asset) => !quote.pricesMinorUnits.containsKey(asset),
    )) {
      return;
    }
    snapshot = WalletSnapshot(
      accountId: snapshot.accountId,
      version: snapshot.version + 1,
      available: snapshot._available,
      pricesMinorUnits: quote.pricesMinorUnits,
      usdNgnMinorUnits: quote.usdNgnMinorUnits,
    );
    quoteId = quote.id;
    activeQuote = quote;
    notifyListeners();
  }

  Map<String, Object?> exportState() => {
    'schema': 1,
    'accountId': snapshot.accountId,
    'version': snapshot.version,
    'enabled': simulationEnabled,
    'quote': activeQuote == null
        ? null
        : {
            'id': activeQuote!.id,
            'asOf': activeQuote!.asOf.toIso8601String(),
            'expiresAt': activeQuote!.expiresAt?.toIso8601String(),
          },
    'fx': snapshot.usdNgnMinorUnits,
    'prices': snapshot._prices,
    'amounts': {
      for (final a in snapshot.assets)
        a: {
          'units': snapshot.available(a).atomicUnits.toString(),
          'decimals': snapshot.available(a).decimals,
        },
    },
    'reserved': {for (final e in _reserved.entries) e.key: e.value.toJson()},
    'settled': _settled.toList(),
    'rejected': _rejected.toList(),
  };
  void restoreState(Map<String, Object?> data) {
    try {
      if (data['schema'] != 1) {
        throw const FormatException('Unknown wallet version');
      }
      final account = data['accountId'] as String;
      final version = data['version'] as int;
      final amounts = Map<String, Object?>.from(data['amounts'] as Map);
      final prices = Map<String, int>.from(data['prices'] as Map);
      final available = <String, AssetAmount>{};
      for (final e in amounts.entries) {
        final row = Map<String, Object?>.from(e.value as Map);
        final units = BigInt.parse(row['units'] as String);
        final precision = row['decimals'] as int;
        if (units < BigInt.zero ||
            precision < 0 ||
            precision > 30 ||
            !prices.containsKey(e.key) ||
            prices[e.key]! <= 0) {
          throw const FormatException('Invalid wallet amount');
        }
        available[e.key] = AssetAmount(e.key, units, precision);
      }
      if (account.isEmpty || version < 1 || !available.containsKey('NGN')) {
        throw const FormatException('Invalid account');
      }
      final nextGeneration = generation + 1;
      final reserved = <String, WalletEffect>{};
      for (final entry in Map<String, Object?>.from(
        data['reserved'] as Map,
      ).entries) {
        final effect = WalletEffect.fromJson(
          Map<String, Object?>.from(entry.value as Map),
          generation: nextGeneration,
        );
        if (effect.accountId != account) {
          throw const FormatException('Wrong effect account');
        }
        for (final amount in [
          ...effect.debits.values,
          ...effect.credits.values,
        ]) {
          if (available[amount.assetId]?.decimals != amount.decimals) {
            throw const FormatException('Invalid effect precision');
          }
        }
        reserved[entry.key] = effect;
      }
      final settled = List<String>.from(data['settled'] as List);
      final rejected = List<String>.from(data['rejected'] as List);
      final fx = data['fx'] as int?;
      if (fx != null && fx <= 0) throw const FormatException('Invalid FX');
      final enabled = data['enabled'] as bool;
      final quoteData = data['quote'] == null
          ? null
          : Map<String, Object?>.from(data['quote'] as Map);
      final restoredQuote = quoteData == null
          ? null
          : QuoteSnapshot(
              id: quoteData['id'] as String,
              asOf: DateTime.parse(quoteData['asOf'] as String),
              expiresAt: quoteData['expiresAt'] == null
                  ? null
                  : DateTime.parse(quoteData['expiresAt'] as String),
              pricesMinorUnits: prices,
              usdNgnMinorUnits: fx!,
            );

      snapshot = WalletSnapshot(
        accountId: account,
        version: version,
        available: available,
        pricesMinorUnits: prices,
        usdNgnMinorUnits: fx,
      );
      generation = nextGeneration;
      simulationEnabled = enabled;
      _reserved
        ..clear()
        ..addAll(reserved);
      _settled
        ..clear()
        ..addAll(settled);
      _rejected
        ..clear()
        ..addAll(rejected);
      quoteId = restoredQuote?.id;
      activeQuote = restoredQuote;
      _fundsRevision++;
      notifyListeners();
    } catch (e) {
      if (e is FormatException) rethrow;
      throw const FormatException('Invalid wallet checkpoint');
    }
  }

  int get ngnAvailableMinorUnits =>
      snapshot.available('NGN').atomicUnits.toInt();
  String get ngnBalanceLabel => balanceLabel('NGN');
  String get portfolioBalanceLabel => formatFiat(snapshot.portfolioMinorUnits);
  String balanceLabel(String asset) =>
      formatFiat(snapshot.valuationMinorUnits(asset));
  static String formatFiat(int units) {
    return '\u20a6${formatGroupedAmount((units ~/ 100).toString())}.${(units % 100).toString().padLeft(2, '0')}';
  }

  bool publish(WalletSnapshot next, {required int generation}) {
    if (generation != this.generation ||
        next.accountId != snapshot.accountId ||
        next.version < snapshot.version) {
      return false;
    }
    _fundsRevision++;
    snapshot = next;
    notifyListeners();
    return true;
  }

  void reset() {
    simulationEnabled = false;
    quoteId = null;
    activeQuote = null;
    _reserved.clear();
    _settled.clear();
    _rejected.clear();
    generation++;
    _fundsRevision++;
    snapshot = WalletSnapshot.seeded();
    notifyListeners();
  }
}

abstract interface class WalletRepository {
  WalletSnapshot get current;
  Stream<WalletSnapshot> watchSnapshot();
  Future<void> refresh();
}
