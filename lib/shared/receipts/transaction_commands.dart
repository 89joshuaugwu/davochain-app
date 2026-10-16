import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'receipt_activity.dart';
import 'receipt_record.dart';
import 'transaction_controller.dart';

Future<ReceiptRecord> submitAccountTransaction(
  BuildContext context,
  ReceiptRecord record,
) async {
  ProviderContainer? container;
  try {
    container = ProviderScope.containerOf(context, listen: false);
  } on StateError {
    return ReceiptActivity.submitPreview(record);
  }
  // Result routes may initialize while widgets build. Execute commands afterwards.
  await Future<void>.microtask(() {});
  if (!context.mounted) return record.withStatus(ReceiptStatus.failed);
  return container.read(transactionControllerProvider.notifier).submit(record);
}
