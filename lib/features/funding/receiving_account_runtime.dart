import 'dart:async';
import 'dart:convert';
import '../../core/preview/local_preview_profile.dart';
import '../wallets/local_ledger_store.dart';
import '../wallets/wallet_repository.dart';
import 'receiving_account.dart';
import 'receiving_account_controller.dart';
import 'receiving_account_gateway.dart';

abstract final class ReceivingAccountRuntime {
  static LocalLedgerStore? _store;
  static bool _initialized = false;
  static final controller = ReceivingAccountController(
    gateway: const LocalReceivingAccountGateway(),
    load: (account) async {
      final raw = await _store?.metadata('receiving-account:$account');
      return raw == null
          ? null
          : ReceivingAccount.fromJson(
              Map<String, Object?>.from(jsonDecode(raw) as Map),
            );
    },
    save: (value) async {
      await _store?.putMetadata(
        'receiving-account:${value.accountId}',
        jsonEncode(value.toJson()),
      );
    },
  );
  static Future<void> initialize(LocalLedgerStore store) async {
    if (_initialized) return;
    _initialized = true;
    _store = store;
    LocalPreviewProfile.instance.addListener(_changed);
    WalletAccountState.instance.addListener(_changed);
    await ensureCurrent();
  }

  static void _changed() {
    final wallet = WalletAccountState.instance;
    if (!wallet.simulationEnabled ||
        controller.current.accountId != wallet.snapshot.accountId) {
      controller.deactivate();
    }
    // Registration publishes wallet identity before the profile name.
    scheduleMicrotask(() => unawaited(ensureCurrent()));
  }

  static Future<void> ensureCurrent() {
    final wallet = WalletAccountState.instance;
    if (!wallet.simulationEnabled ||
        const String.fromEnvironment(
              'DAVOCHAIN_ENV',
              defaultValue: 'development',
            ) ==
            'production') {
      if (controller.current.status != ReceivingAccountStatus.unavailable) {
        controller.deactivate();
      }
      return Future.value();
    }
    return controller.activate(
      wallet.snapshot.accountId,
      wallet.generation,
      accountName: LocalPreviewProfile.instance.fullName,
    );
  }
}
