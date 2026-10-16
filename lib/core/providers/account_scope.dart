import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/wallets/wallet_repository.dart';
import '../session/account_session.dart';

final walletEngineProvider = Provider<WalletAccountState>(
  (ref) => WalletAccountState.instance,
);
final accountSessionProvider =
    NotifierProvider<AccountSessionNotifier, AccountSession>(
      AccountSessionNotifier.new,
    );

class AccountSessionNotifier extends Notifier<AccountSession> {
  @override
  AccountSession build() {
    final ledger = ref.watch(walletEngineProvider);
    AccountSession read() =>
        AccountSession(ledger.snapshot.accountId, ledger.generation);
    void changed() {
      final next = read();
      if (next != state) state = next;
    }

    ledger.addListener(changed);
    ref.onDispose(() => ledger.removeListener(changed));
    return read();
  }
}

/// Root owns the container. Standalone routes in tests get a local scope too.
class DavoAccountScope extends StatelessWidget {
  const DavoAccountScope({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      ProviderScope(retry: (_, _) => null, child: child);
}

class AccountConsumer extends StatelessWidget {
  const AccountConsumer({super.key, required this.builder});
  final Widget Function(BuildContext, WidgetRef) builder;
  @override
  Widget build(BuildContext context) {
    Widget content() =>
        Consumer(builder: (context, ref, _) => builder(context, ref));
    try {
      ProviderScope.containerOf(context, listen: false);
    } on StateError {
      return DavoAccountScope(child: content());
    }
    return content();
  }
}
