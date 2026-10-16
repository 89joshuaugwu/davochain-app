import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../wallets/wallet_repository.dart';
import '../wallets/local_ledger_store.dart';
import 'portfolio_performance.dart';

/// Records observed local valuations, never fabricated prices or investment returns.
class PortfolioValuationHistory extends ChangeNotifier {
  static final instance = PortfolioValuationHistory();
  final Map<String, List<PortfolioValuePoint>> _accounts = {};
  LocalLedgerStore? _store;
  String? _active;
  int _epoch = 0;
  Future<void> _writes = Future.value();
  List<PortfolioValuePoint> points(String account) =>
      List.unmodifiable(_accounts[account] ?? []);
  void record(String account, int value, DateTime timestamp) {
    final points = _accounts.putIfAbsent(account, () => []);
    if (value < 0 ||
        points.isNotEmpty &&
            (points.last.valueKobo == value ||
                !timestamp.isAfter(points.last.timestamp))) {
      return;
    }
    points.add(
      PortfolioValuePoint(timestamp: timestamp.toUtc(), valueKobo: value),
    );
    if (points.length > 2048) points.removeRange(0, points.length - 2048);
    notifyListeners();
  }

  Map<String, Object?> export(String account) => {
    'version': 1,
    'points': points(account)
        .map((p) => {'at': p.timestamp.toIso8601String(), 'value': p.valueKobo})
        .toList(),
  };
  void restore(String account, Map<String, Object?> data) {
    if (data['version'] != 1) {
      throw const FormatException('Valuation history version');
    }
    final candidate = <PortfolioValuePoint>[];
    for (final raw in (data['points'] as List? ?? [])) {
      final item = raw as Map;
      final value = item['value'] as int;
      final time = DateTime.parse(item['at'] as String).toUtc();
      if (value < 0 ||
          candidate.isNotEmpty && !time.isAfter(candidate.last.timestamp)) {
        throw const FormatException('Invalid valuation history');
      }
      candidate.add(PortfolioValuePoint(timestamp: time, valueKobo: value));
    }
    _accounts[account] = candidate.length > 2048
        ? candidate.sublist(candidate.length - 2048)
        : candidate;
  }

  Future<void> initialize(LocalLedgerStore store) async {
    if (_store != null) return;
    _store = store;
    WalletAccountState.instance.addListener(_changed);
    await _loadAccount();
  }

  void _changed() {
    final wallet = WalletAccountState.instance;
    if (_active != wallet.snapshot.accountId) {
      unawaited(_loadAccount());
    } else {
      capture();
    }
  }

  Future<void> _loadAccount() async {
    final epoch = ++_epoch;
    final wallet = WalletAccountState.instance;
    final account = wallet.snapshot.accountId;
    _active = null;
    try {
      final raw = await _store?.metadata('valuation-history:$account');
      if (epoch != _epoch || account != wallet.snapshot.accountId) return;
      if (raw != null) {
        restore(account, Map<String, Object?>.from(jsonDecode(raw) as Map));
      }
    } catch (_) {
      /* A damaged chart must never block the wallet. */
    }
    if (epoch != _epoch || account != wallet.snapshot.accountId) return;
    _active = account;
    capture();
    notifyListeners();
  }

  void capture() {
    final wallet = WalletAccountState.instance;
    final account = wallet.snapshot.accountId;
    if (!wallet.simulationEnabled || _store != null && _active != account) {
      return;
    }
    final previous = _accounts[account]?.lastOrNull;
    record(
      account,
      wallet.snapshot.portfolioMinorUnits,
      DateTime.now().toUtc(),
    );
    if (_store != null && _accounts[account]?.lastOrNull != previous) {
      final encoded = jsonEncode(export(account));
      _writes = _writes
          .catchError((Object _) {})
          .then(
            (_) => _store!.putMetadata('valuation-history:$account', encoded),
          );
      unawaited(_writes.catchError((Object _) {}));
    }
  }
}
