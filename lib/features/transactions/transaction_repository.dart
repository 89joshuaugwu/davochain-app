enum TransactionState {
  pending,
  completed,
  failed,
  cancelled,
  reversed,
  refunded
}

class TransactionEvent {
  const TransactionEvent(
      {required this.accountId,
      required this.id,
      required this.version,
      required this.state});
  final String accountId, id;
  final int version;
  final TransactionState state;
}

/// Provider facts are versioned; post-settlement reversals are explicit events.
class TransactionEventStore {
  TransactionEventStore(this.accountId);
  final String accountId;
  final Map<String, TransactionEvent> _events = {};
  Map<String, TransactionEvent> get events => Map.unmodifiable(_events);
  bool accept(TransactionEvent event) {
    if (event.accountId != accountId || event.id.isEmpty || event.version < 1) {
      return false;
    }
    final prior = _events[event.id];
    if (prior != null) {
      if (event.version <= prior.version) return false;
      final allowed = switch (prior.state) {
        TransactionState.pending => TransactionState.values.toSet(),
        TransactionState.completed => {
            TransactionState.completed,
            TransactionState.reversed,
            TransactionState.refunded
          },
        TransactionState.reversed => {
            TransactionState.reversed,
            TransactionState.refunded
          },
        TransactionState.refunded => {TransactionState.refunded},
        TransactionState.failed => {TransactionState.failed},
        TransactionState.cancelled => {TransactionState.cancelled},
      };
      if (!allowed.contains(event.state)) return false;
    }
    _events[event.id] = event;
    return true;
  }
}

abstract interface class TransactionRepository {
  Future<TransactionEvent> read(String operationId);
  Future<TransactionEvent?> reconcile(String idempotencyKey);
  Stream<TransactionEvent> watch(String operationId);
}
