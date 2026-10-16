import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/account_scope.dart';
import 'local_wallet_repository.dart';
import 'wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => LocalWalletRepository(ref.watch(walletEngineProvider)),
);
final walletSnapshotProvider = StreamProvider<WalletSnapshot>((ref) {
  final session = ref.watch(accountSessionProvider);
  return ref
      .watch(walletRepositoryProvider)
      .watchSnapshot()
      .where((s) => s.accountId == session.accountId);
});

/// Synchronous initial data avoids a loading flash while the stream subscribes.
final currentWalletProvider = Provider<WalletSnapshot>((ref) {
  ref.watch(accountSessionProvider);
  ref.watch(walletSnapshotProvider);
  return ref.watch(walletRepositoryProvider).current;
});
