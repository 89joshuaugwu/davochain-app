import 'package:flutter/foundation.dart';
import '../../core/money/money.dart';
import '../../shared/formatters/grouped_amount_formatter.dart';

class WalletSnapshot {
  WalletSnapshot(
      {required this.accountId,
      required this.version,
      required Map<String, AssetAmount> available,
      required Map<String, int> pricesMinorUnits})
      : _available = Map.unmodifiable(available),
        _prices = Map.unmodifiable(pricesMinorUnits);
  final String accountId;
  final int version;
  final Map<String, AssetAmount> _available;
  final Map<String, int> _prices;
  AssetAmount available(String asset) =>
      _available[asset] ?? (throw StateError('Unsupported wallet $asset'));
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
    generation++;
    snapshot = WalletSnapshot.seeded();
    notifyListeners();
  }
}

abstract interface class WalletRepository {
  Stream<WalletSnapshot> watchSnapshot();
  Future<void> refresh();
}
