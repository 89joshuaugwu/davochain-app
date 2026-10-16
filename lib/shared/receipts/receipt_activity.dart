import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_controller.dart';
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
  ProviderContainer? _container;
  bool _ownsContainer = false;
  ProviderSubscription<AsyncValue<List<ReceiptRecord>>>? _subscription;
  @override
  void initState() {
    super.initState();
    try {
      _container = ProviderScope.containerOf(context, listen: false);
    } on StateError {
      _container = ProviderContainer();
      _ownsContainer = true;
    }
    _subscription = _container!.listen(
      receiptRecordsProvider,
      (_, _) => _refreshReceipt(),
    );
  }

  void _refreshReceipt() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _subscription?.close();
    if (_ownsContainer) _container?.dispose();
    super.dispose();
  }
}
