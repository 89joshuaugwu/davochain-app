import 'dart:async';
import 'package:flutter/widgets.dart';
import 'receipt_record.dart';

/// Session-only records. Provider storage and authenticated history come later.
abstract final class ReceiptActivity {
  static final records = ValueNotifier<List<ReceiptRecord>>(const []);
  static const previewDelay = Duration(seconds: 20);
  static final Map<String, Timer> _timers = {};
  static int _session = 0;

  static ReceiptRecord resolve(ReceiptRecord fallback) => records.value
      .where((record) => record.id == fallback.id)
      .firstOrNull ?? fallback;

  /// Only explicit new local submissions enter the simulated lifecycle.
  /// Accepting historical or provider facts never starts a completion timer.
  static ReceiptRecord submitPreview(ReceiptRecord record) {
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
    final session = _session;
    _timers[record.id] = Timer(previewDelay, () {
      if (session != _session) return;
      _timers.remove(record.id);
      final current = resolve(pending);
      if (!records.value.any((r) => r.id == record.id) ||
          !current.preview || current.status != ReceiptStatus.pending) {
        return;
      }
      accept(current.withStatus(ReceiptStatus.completed));
    });
    return pending;
  }
  static void accept(ReceiptRecord record) {
    if (record.id.isEmpty) return;
    final prior = records.value.where((r) => r.id == record.id);
    if (prior.isNotEmpty &&
        prior.first.status == ReceiptStatus.completed &&
        record.status != ReceiptStatus.completed) {
      return;
    }
    records.value = List.unmodifiable([
      record,
      ...records.value.where((r) => r.id != record.id),
    ]);
  }

  static void reset() {
    _session++;
    for (final timer in _timers.values) { timer.cancel(); }
    _timers.clear();
    records.value = const [];
  }
}

/// Result, details and export pages observe the same transaction identity.
mixin ReceiptActivityObserver<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    ReceiptActivity.records.addListener(_refreshReceipt);
  }
  void _refreshReceipt() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    ReceiptActivity.records.removeListener(_refreshReceipt);
    super.dispose();
  }
}
