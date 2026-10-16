import 'wallet_repository.dart';

/// Owns subscription lifetime; the ledger owns exact settlement, never widgets.
class LocalWalletRepository implements WalletRepository {
  LocalWalletRepository(this.ledger);
  final WalletAccountState ledger;
  @override
  WalletSnapshot get current => ledger.snapshot;
  @override
  Stream<WalletSnapshot> watchSnapshot() => Stream.multi((sink) {
    void changed() => sink.add(current);
    ledger.addListener(changed);
    changed();
    sink.onCancel = () => ledger.removeListener(changed);
  });
  @override
  Future<void> refresh() async {}
}
