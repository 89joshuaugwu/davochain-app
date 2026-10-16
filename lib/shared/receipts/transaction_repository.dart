import 'receipt_codec.dart';
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
    await _durable;
    await _saving;
    if (storageError != null) {
      throw StateError('Account changes could not be saved');
    }
  }

  Map<String, Object?> Function()? exportCheckpoint;
  void _checkpoint() {
    if (checkpoint == null) return;
    final data = exportCheckpoint?.call() ?? exportState();
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
  int _revision = 0;

  final Map<String, ReceiptRecord> _uncertain = {};
  final Map<String, ReceiptRecord> _retryRecords = {};
  Iterable<String> get uncertainIds => _uncertain.keys;
  Future<void> retrySave(String id) async {
    final record = _retryRecords[id];
    if (record == null) return;
    final saved = await acceptDurable(record);
    if (!needsSave(id) &&
        saved.status == ReceiptStatus.pending &&
        saved.preview) {
      _schedule(saved);
    }
  }

  bool needsSave(String id) => _uncertain.containsKey(id);
  Future<void> _durable = Future.value();

  ReceiptRecord resolve(ReceiptRecord fallback) =>
      _uncertain[fallback.id] ??
      records.value.where((record) => record.id == fallback.id).firstOrNull ??
      fallback;

  /// Only explicit new local submissions enter the simulated lifecycle.
  /// Accepting historical or provider facts never starts a completion timer.
  ReceiptRecord submit(ReceiptRecord record) {
    if (record.id.isEmpty) return record;
    if (!_belongs(record)) return record.withStatus(ReceiptStatus.failed);
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
      unawaited(acceptDurable(current.withStatus(ReceiptStatus.completed)));
    });
    return resolve(pending);
  }

  void accept(ReceiptRecord record) {
    if (record.id.isEmpty || !_belongs(record) || needsSave(record.id)) return;
    if (checkpoint != null) {
      unawaited(acceptDurable(record));
      return;
    }
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
    _revision++;
    _checkpoint();
  }

  bool _belongs(ReceiptRecord record) =>
      record.walletEffect == null ||
      (record.walletEffect!.accountId == ledger.snapshot.accountId &&
          record.walletEffect!.generation == ledger.generation);

  Future<ReceiptRecord> submitDurable(ReceiptRecord record) async {
    if (!_belongs(record)) return record.withStatus(ReceiptStatus.failed);
    if (needsSave(record.id)) return resolve(record);
    if (records.value.any((r) => r.id == record.id)) return resolve(record);
    final accepted = await acceptDurable(
      record.preview && record.status != ReceiptStatus.failed
          ? record.withStatus(ReceiptStatus.pending)
          : record,
    );
    if (!needsSave(record.id) &&
        accepted.preview &&
        accepted.status == ReceiptStatus.pending) {
      _schedule(accepted);
    }
    return accepted;
  }

  void _schedule(ReceiptRecord pending) {
    _timers.remove(pending.id)?.cancel();
    final session = _session;
    final remaining = pending.occurredAt
        .add(settlementDelay)
        .difference(DateTime.now());
    _timers[pending.id] = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        _timers.remove(pending.id);
        if (session != _session || needsSave(pending.id)) return;
        final current = resolve(pending);
        if (current.status == ReceiptStatus.pending) {
          unawaited(acceptDurable(current.withStatus(ReceiptStatus.completed)));
        }
      },
    );
  }

  Future<ReceiptRecord> acceptDurable(ReceiptRecord record) {
    if (checkpoint == null) {
      accept(record);
      return Future.value(resolve(record));
    }
    final session = _session;
    final result = Completer<ReceiptRecord>();
    _durable = _durable.then((_) async {
      if (session != _session || !_belongs(record)) {
        result.complete(record.withStatus(ReceiptStatus.failed));
        return;
      }
      final revision = ledger.fundsRevision;
      final stagedLedger = ledger.fork();
      final staged = LocalTransactionRepository(stagedLedger);
      staged.records.value = records.value;
      staged._revision = _revision;
      staged.accept(record);
      final accepted = staged.resolve(record);
      final data = {...?exportCheckpoint?.call(), ...staged.exportState()};
      try {
        await checkpoint!(data);
        if (session != _session ||
            !ledger.adoptFunds(stagedLedger, expectedRevision: revision)) {
          result.complete(record.withStatus(ReceiptStatus.failed));
          return;
        }
        _revision = staged._revision;
        storageError = null;
        _uncertain.remove(record.id);
        _retryRecords.remove(record.id);
        records.value = staged.records.value;
        result.complete(accepted);
      } catch (error) {
        storageError = error;
        final waiting = record.withStatus(ReceiptStatus.pending);
        _uncertain[record.id] = waiting;
        _retryRecords[record.id] = record;
        records.value = List.unmodifiable(records.value);
        result.complete(waiting);
      } finally {
        staged.dispose();
      }
    });
    return result.future;
  }

  Map<String, Object?> exportState() => {
    'schema': 1,
    'accountId': ledger.snapshot.accountId,
    'revision': _revision,
    'wallet': ledger.exportState(),
    'receipts': [for (final record in records.value) encodeReceipt(record)],
  };
  void restoreState(Map<String, Object?> data) {
    try {
      if (data['schema'] != 1) {
        throw const FormatException('Unknown ledger version');
      }
      final wallet = Map<String, Object?>.from(data['wallet'] as Map);
      final account = wallet['accountId'];
      if (account != data['accountId']) {
        throw const FormatException('Wrong account');
      }
      final parsed = [
        for (final raw in data['receipts'] as List)
          decodeReceipt(
            Map<String, Object?>.from(raw as Map),
            generation: ledger.generation + 1,
          ),
      ];
      if (parsed.map((r) => r.id).toSet().length != parsed.length ||
          parsed.any(
            (r) =>
                r.walletEffect != null && r.walletEffect!.accountId != account,
          )) {
        throw const FormatException('Invalid operation identity');
      }
      final revision = data['revision'] as int;
      ledger.restoreState(wallet);
      reset();
      _revision = revision;
      records.value = List.unmodifiable(parsed);
      final session = _session;
      for (final record in parsed.where(
        (r) => r.preview && r.status == ReceiptStatus.pending,
      )) {
        final remaining = record.occurredAt
            .add(settlementDelay)
            .difference(DateTime.now());
        _timers[record.id] = Timer(
          remaining.isNegative ? Duration.zero : remaining,
          () {
            if (_session != session) return;
            _timers.remove(record.id);
            final current = resolve(record);
            if (current.status == ReceiptStatus.pending) {
              unawaited(
                acceptDurable(current.withStatus(ReceiptStatus.completed)),
              );
            }
          },
        );
      }
    } catch (e) {
      if (e is FormatException) rethrow;
      throw const FormatException('Invalid account checkpoint');
    }
  }

  void reset() {
    _session++;
    _uncertain.clear();
    _retryRecords.clear();
    storageError = null;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    records.value = const [];
  }
}
