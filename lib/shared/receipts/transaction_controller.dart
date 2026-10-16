import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/account_scope.dart';
import 'transaction_repository.dart';
import 'receipt_record.dart';

final transactionRepositoryProvider = Provider<LocalTransactionRepository>((
  ref,
) {
  final engine = ref.watch(walletEngineProvider);
  if (identical(engine, LocalTransactionRepository.instance.ledger))
    return LocalTransactionRepository.instance;
  final repo = LocalTransactionRepository(engine);
  ref.onDispose(repo.dispose);
  return repo;
});
final receiptRecordsProvider = StreamProvider<List<ReceiptRecord>>((ref) {
  ref.watch(accountSessionProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return Stream.multi((sink) {
    void changed() => sink.add(repo.records.value);
    repo.records.addListener(changed);
    changed();
    sink.onCancel = () => repo.records.removeListener(changed);
  });
});
final currentReceiptsProvider = Provider<List<ReceiptRecord>>(
  (ref) =>
      ref.watch(receiptRecordsProvider).value ??
      ref.watch(transactionRepositoryProvider).records.value,
);

enum SubmissionPhase { submitting, pending, completed, failed, unknown }

final transactionControllerProvider =
    NotifierProvider<TransactionController, Map<String, SubmissionPhase>>(
      TransactionController.new,
    );

class TransactionController extends Notifier<Map<String, SubmissionPhase>> {
  final _inFlight = <String, Future<ReceiptRecord>>{};
  @override
  Map<String, SubmissionPhase> build() {
    ref.watch(accountSessionProvider);
    return const {};
  }

  Future<ReceiptRecord> submit(ReceiptRecord record) {
    final existing = _inFlight[record.id];
    if (existing != null) return existing;
    final repo = ref.read(transactionRepositoryProvider);
    final session = ref.read(accountSessionProvider);
    state = {...state, record.id: SubmissionPhase.submitting};
    final accepted = repo.submit(record);
    final future = () async {
      try {
        await repo.flush();
        if (ref.mounted && ref.read(accountSessionProvider) == session)
          state = {...state, record.id: _phase(repo.resolve(accepted).status)};
      } catch (_) {
        if (ref.mounted && ref.read(accountSessionProvider) == session)
          state = {...state, record.id: SubmissionPhase.unknown};
      }
      return repo.resolve(accepted);
    }();
    _inFlight[record.id] = future;
    future.whenComplete(() => _inFlight.remove(record.id));
    return future;
  }

  Future<void> reconcile(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    final record = repo.records.value.where((r) => r.id == id).firstOrNull;
    if (record == null) return;
    // Reads only. A timeout never creates a second submission identity.
    if (repo.storageError != null) return;
    state = {...state, id: _phase(record.status)};
  }

  SubmissionPhase _phase(ReceiptStatus s) => switch (s) {
    ReceiptStatus.pending => SubmissionPhase.pending,
    ReceiptStatus.completed => SubmissionPhase.completed,
    ReceiptStatus.failed => SubmissionPhase.failed,
  };
}
