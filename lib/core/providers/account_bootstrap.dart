import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/wallets/quote_repository.dart';
import 'account_scope.dart';
import '../../features/notifications/notification_providers.dart';

class AccountBootstrap extends ConsumerWidget {
  const AccountBootstrap({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationEventBridgeProvider);
    void update() {
      final ledger = ref.read(walletEngineProvider);
      final generation = ledger.generation;
      final quote = ref.read(quoteProvider);
      scheduleMicrotask(() {
        if (context.mounted &&
            ledger.generation == generation &&
            !quote.isExpired(DateTime.now())) {
          ledger.updateQuotes(quote);
        }
      });
    }

    ref.listen(quoteProvider, (_, _) => update());
    ref.listen(accountSessionProvider, (_, _) => update());
    ref.watch(quoteProvider);
    ref.watch(accountSessionProvider);
    update();
    return child;
  }
}
