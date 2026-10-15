import 'dart:async';
import 'wallet_effect.dart';
import 'simulation_quotes.dart';
import 'package:flutter/foundation.dart';
import '../../core/money/money.dart';
import '../../shared/formatters/grouped_amount_formatter.dart';

class WalletSnapshot {
  WalletSnapshot(
      {required this.accountId,
      required this.version,
      required Map<String, AssetAmount> available,
      required Map<String, int> pricesMinorUnits,
      this.usdNgnMinorUnits})
      : _available = Map.unmodifiable(available),
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

  static WalletSnapshot seeded() =>
      WalletSnapshot(accountId: 'local-account', version: 1, available: {
        'NGN': AssetAmount.parse('1284500.35', 'NGN', 2),
        'NGD': AssetAmount.parse('135000', 'NGD', 2),
        'BTC': AssetAmount.parse('0.0086', 'BTC', 8),
        'ETH': AssetAmount.parse('0.102', 'ETH', 8),
        'SOL': AssetAmount.parse('2', 'SOL', 9),
        'USDT': AssetAmount.parse('250', 'USDT', 6),
        'USDC': AssetAmount.parse('112.20', 'USDC', 6),
      }, pricesMinorUnits: {
        'NGN': 100,
        'NGD': 100,
        'BTC': 2400000000,
        'ETH': 520000000,
        'SOL': 26500000,
        'USDT': 154000,
        'USDC': 154000
      });
}

/// Observable account facts; provider adapters publish snapshots after a read.
class WalletAccountState extends ChangeNotifier {
  WalletAccountState._();
  static final instance = WalletAccountState._();
  WalletSnapshot snapshot = WalletSnapshot.seeded();
  int generation = 0;
  bool simulationEnabled = false;
  final Map<String, WalletEffect> _reserved = {};
  final Set<String> _settled = {}, _rejected = {};

  void startSimulation({required bool empty}) {
    reset();
    simulationEnabled = true;
    final previous = snapshot;
    snapshot = WalletSnapshot(
        accountId: 'simulation-$generation',
        version: 1,
        available: {
          for (final entry in SimulationQuotes.decimals.entries)
            entry.key: AssetAmount(
                entry.key,
                empty || !previous.assets.contains(entry.key)
                    ? BigInt.zero
                    : previous.available(entry.key).atomicUnits,
                entry.value)
        },
        pricesMinorUnits: SimulationQuotes.pricesMinorUnits,
        usdNgnMinorUnits: SimulationQuotes.usdNgnMinorUnits);
    notifyListeners();
  }

  WalletEffect effect(
          {Map<String, String> debits = const {},
          Map<String, String> credits = const {}}) =>
      WalletEffect(
          accountId: snapshot.accountId,
          generation: generation,
          debits: {
            for (final entry in debits.entries)
              entry.key: AssetAmount.parse(entry.value, entry.key,
                  snapshot.available(entry.key).decimals)
          },
          credits: {
            for (final entry in credits.entries)
              entry.key: AssetAmount.parse(entry.value, entry.key,
                  snapshot.available(entry.key).decimals)
          });

  /// Reserves pending debits, settles destination once, refunds failed requests.
  /// False means the local record must fail; no negative balance is published.
  bool applyEffect(String id, WalletEffect effect,
      {required bool completed, required bool failed}) {
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
      for (final asset in snapshot.assets) asset: snapshot.available(asset)
    };
    bool valid(AssetAmount amount) =>
        values.containsKey(amount.assetId) &&
        amount.atomicUnits >= BigInt.zero &&
        amount.decimals == values[amount.assetId]!.decimals;
    if ([...effect.debits.values, ...effect.credits.values]
        .any((a) => !valid(a))) {
      return false;
    }
    void change(AssetAmount amount, bool subtract) {
      final current = values[amount.assetId]!;
      values[amount.assetId] = AssetAmount(
          current.assetId,
          current.atomicUnits +
              (subtract ? -amount.atomicUnits : amount.atomicUnits),
          current.decimals);
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
    snapshot = WalletSnapshot(
        accountId: snapshot.accountId,
        version: snapshot.version + 1,
        available: values,
        pricesMinorUnits: snapshot._prices,
        usdNgnMinorUnits: snapshot.usdNgnMinorUnits);
    scheduleMicrotask(notifyListeners);
    return true;
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
    snapshot = next;
    notifyListeners();
    return true;
  }

  void reset() {
    simulationEnabled = false;
    _reserved.clear();
    _settled.clear();
    _rejected.clear();
    generation++;
    snapshot = WalletSnapshot.seeded();
    notifyListeners();
  }
}

abstract interface class WalletRepository {
  Stream<WalletSnapshot> watchSnapshot();
  Future<void> refresh();
}
