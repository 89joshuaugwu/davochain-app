import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/account_scope.dart';
import '../../core/providers/account_services.dart';
import '../../core/preview/preview_account_state.dart';
import '../../shared/receipts/transaction_controller.dart';
import 'notification_events.dart';

final notificationCoordinatorProvider = Provider<NotificationEventCoordinator>(
  (ref) => NotificationEventCoordinator.instance,
);

/// Mount once from AccountBootstrap. Event work is deferred outside widget build,
/// and every deferred callback checks both account identity and generation.
final notificationEventBridgeProvider = Provider<void>((ref) {
  final coordinator = ref.watch(notificationCoordinatorProvider);
  final verification = ref.watch(verificationServiceProvider);
  var active = ref.read(accountSessionProvider);
  var basic = verification.basicSubmitted;
  var advanced = verification.advancedSubmitted;
  var disposed = false;

  void enqueue(void Function() action) {
    final session = ref.read(accountSessionProvider);
    scheduleMicrotask(() {
      if (!disposed && ref.read(accountSessionProvider) == session) action();
    });
  }

  void activate() {
    active = ref.read(accountSessionProvider);
    basic = verification.basicSubmitted;
    advanced = verification.advancedSubmitted;
    final session = active;
    enqueue(
      () => coordinator.activate(
        session.accountId,
        session.generation,
        baseline: ref.read(transactionRepositoryProvider).records.value,
      ),
    );
  }

  activate();
  ref.listen(accountSessionProvider, (_, _) => activate());
  ref.listen(receiptRecordsProvider, (_, next) {
    final session = ref.read(accountSessionProvider);
    final records = next.asData?.value;
    if (records == null) return;
    enqueue(() {
      final repo = ref.read(transactionRepositoryProvider);
      for (final receipt in records) {
        if (!repo.needsSave(receipt.id)) {
          final index = notificationReceiptPreference(receipt);
          coordinator.receipt(
            session.accountId,
            session.generation,
            receipt,
            enabled:
                PreviewAccountState.notificationPreferences[index] &&
                PreviewAccountState.notificationChannels[0][0],
          );
        }
      }
    });
  });
  void verificationChanged() {
    if (ref.read(accountSessionProvider) != active) return;
    final nextBasic = verification.basicSubmitted;
    final nextAdvanced = verification.advancedSubmitted;
    final session = active;
    if ((!basic && nextBasic) || (!advanced && nextAdvanced)) {
      final publishBasic = !basic && nextBasic;
      final publishAdvanced = !advanced && nextAdvanced;
      enqueue(() {
        final enabled =
            PreviewAccountState.notificationPreferences[6] &&
            PreviewAccountState.notificationChannels[1][0];
        if (publishBasic) {
          coordinator.verification(
            session.accountId,
            session.generation,
            advanced: false,
            status: NotificationVerificationStatus.submitted,
            enabled: enabled,
          );
        }
        if (publishAdvanced) {
          coordinator.verification(
            session.accountId,
            session.generation,
            advanced: true,
            status: NotificationVerificationStatus.submitted,
            enabled: enabled,
          );
        }
      });
    }
    basic = nextBasic;
    advanced = nextAdvanced;
  }

  verification.addListener(verificationChanged);
  ref.onDispose(() {
    disposed = true;
    verification.removeListener(verificationChanged);
  });
});
