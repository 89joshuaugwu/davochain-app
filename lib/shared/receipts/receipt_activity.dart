import 'package:flutter/foundation.dart';
import 'receipt_record.dart';

/// Session-only records. Provider storage and authenticated history come later.
abstract final class ReceiptActivity {
  static final records = ValueNotifier<List<ReceiptRecord>>(const []);
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

  static void reset() => records.value = const [];
}
