enum PreviewTransactionOutcome { completed, submitted, failed }

/// Existing local transaction fixture. Replace this with a service result when
/// the backend is connected; UI animation completion never establishes success.
abstract final class PreviewTransactionOperation {
  static Future<PreviewTransactionOutcome> buy() async {
    await Future<void>.delayed(const Duration(milliseconds: 2100));
    return PreviewTransactionOutcome.completed;
  }

  static Future<PreviewTransactionOutcome> transfer(
      {bool external = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return external
        ? PreviewTransactionOutcome.submitted
        : PreviewTransactionOutcome.completed;
  }
}
