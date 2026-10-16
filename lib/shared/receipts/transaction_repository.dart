import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/wallets/wallet_repository.dart';
import 'receipt_record.dart';

class LocalTransactionRepository {
  LocalTransactionRepository(
    this.ledger, {
    this.settlementDelay = const Duration(seconds: 20),
    this.checkpoint,
  }) {
    _generation = ledger.generation;
    ledger.addListener(_accountChanged);
  }
  late int _generation;
  void _accountChanged() {
    if (_generation == ledger.generation) return;
    _generation = ledger.generation;
    reset();
  }

  static final instance = LocalTransactionRepository(
    WalletAccountState.instance,
  );
  final WalletAccountState ledger;
  final Duration settlementDelay;
  Future<void> Function(Map<String, Object?>)? checkpoint;
  Future<void> _saving = Future.value();
  Object? storageError;
  Future<void> flush() async {
    await _saving;
    if (storageError != null)
      throw StateError('Account changes could not be saved');
  }

  Map<String, Object?> Function()? exportCheckpoint;
  void _checkpoint() {
    if (checkpoint == null) return;
    final data = exportCheckpoint?.call() ?? <String, Object?>{};
    _saving = _saving
        .then((_) => checkpoint!(data))
        .then((_) {
          storageError = null;
        })
        .catchError((Object e) {
          storageError = e;
        });
  }

  void dispose() {
    ledger.removeListener(_accountChanged);
    reset();
    records.dispose();
  }

  final records = ValueNotifier<List<ReceiptRecord>>(const []);
  final Map<String, Timer> _timers = {};
  int _session = 0;

  ReceiptRecord resolve(ReceiptRecord fallback) =>
      records.value.where((record) => record.id == fallback.id).firstOrNull ??
      fallback;

  /// Only explicit new local submissions enter the simulated lifecycle.
  /// Accepting historical or provider facts never starts a completion timer.
  ReceiptRecord submit(ReceiptRecord record) {
    if (record.id.isEmpty) return record;
    if (!record.preview || record.status == ReceiptStatus.failed) {
      accept(record);
      return resolve(record);
    }
    if (records.value.any((existing) => existing.id == record.id)) {
      return resolve(record);
    }
    final pending = record.withStatus(ReceiptStatus.pending);
    accept(pending);
    final accepted = resolve(pending);
    if (accepted.status != ReceiptStatus.pending) return accepted;
    final session = _session;
    _timers[record.id] = Timer(settlementDelay, () {
      if (session != _session) return;
      _timers.remove(record.id);
      final current = resolve(pending);
      if (!records.value.any((r) => r.id == record.id) ||
          !current.preview ||
          current.status != ReceiptStatus.pending) {
        return;
      }
      accept(current.withStatus(ReceiptStatus.completed));
    });
    return resolve(pending);
  }

  void accept(ReceiptRecord record) {
    if (record.id.isEmpty) return;
    final prior = records.value.where((r) => r.id == record.id);
    if (prior.isNotEmpty &&
        prior.first.status == ReceiptStatus.completed &&
        record.status != ReceiptStatus.completed) {
      return;
    }
    final wallet = ledger;
    if (record.preview &&
        record.walletEffect != null &&
        wallet.simulationEnabled) {
      final applied = wallet.applyEffect(
        record.id,
        record.walletEffect!,
        completed: record.status == ReceiptStatus.completed,
        failed: record.status == ReceiptStatus.failed,
      );
      if (!applied) record = record.withStatus(ReceiptStatus.failed);
    }
    records.value = List.unmodifiable([
      record,
      ...records.value.where((r) => r.id != record.id),
    ]);
    _checkpoint();
  }

  void reset() {
    _session++;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    records.value = const [];
  }
}
