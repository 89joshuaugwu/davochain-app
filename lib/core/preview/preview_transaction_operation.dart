enum PreviewTransactionOutcome { completed, submitted, failed }

/// Local acceptance fixture. ReceiptActivity owns the subsequent 20-second
/// simulated preview completion; provider results must bypass that lifecycle.
abstract final class PreviewTransactionOperation {
  static Future<PreviewTransactionOutcome> buy() async {
    await Future<void>.delayed(const Duration(milliseconds: 2100));
    return PreviewTransactionOutcome.submitted;
  }

  static Future<PreviewTransactionOutcome> transfer(
      {bool external = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return PreviewTransactionOutcome.submitted;
  }
}
