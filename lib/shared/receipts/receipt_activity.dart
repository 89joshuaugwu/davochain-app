import 'transaction_repository.dart';
import 'package:flutter/widgets.dart';
import 'receipt_record.dart';

/// Session-only records. Provider storage and authenticated history come later.
/// Compatibility API. Repository owns lifecycle, reservations and persistence.
abstract final class ReceiptActivity {
  static const previewDelay = Duration(seconds: 20);
  static ValueNotifier<List<ReceiptRecord>> get records =>
      LocalTransactionRepository.instance.records;
  static ReceiptRecord resolve(ReceiptRecord fallback) =>
      LocalTransactionRepository.instance.resolve(fallback);
  static ReceiptRecord submitPreview(ReceiptRecord record) =>
      LocalTransactionRepository.instance.submit(record);
  static void accept(ReceiptRecord record) =>
      LocalTransactionRepository.instance.accept(record);
  static void reset() => LocalTransactionRepository.instance.reset();
}

/// Result, details and export pages observe the same transaction identity.
mixin ReceiptActivityObserver<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    ReceiptActivity.records.addListener(_refreshReceipt);
  }

  void _refreshReceipt() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ReceiptActivity.records.removeListener(_refreshReceipt);
    super.dispose();
  }
}
