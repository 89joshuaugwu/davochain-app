import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/core/providers/account_scope.dart';
import 'package:davochain/features/notifications/notification_events.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/features/notifications/notification_providers.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/transaction_controller.dart';
import 'package:davochain/shared/receipts/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> flush() async {
    for (var i = 0; i < 4; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  late WalletAccountState ledger;
  late LocalTransactionRepository repo;
  late NotificationInbox inbox;
  late NotificationEventCoordinator events;
  late ProviderContainer container;
  ReceiptRecord deposit(String id) => ReceiptRecord(
    id: id,
    reference: id,
    type: 'Deposit',
    status: ReceiptStatus.completed,
    occurredAt: DateTime.now(),
    amount: '100 NGN',
    fields: const [],
    walletEffect: ledger.effect(credits: {'NGN': '100'}),
  );

  setUp(() {
    ledger = WalletAccountState()..startSimulation(empty: true);
    repo = LocalTransactionRepository(ledger);
    inbox = NotificationInbox(records: const []);
    events = NotificationEventCoordinator(inbox: inbox);
    container = ProviderContainer(
      overrides: [
        walletEngineProvider.overrideWithValue(ledger),
        transactionRepositoryProvider.overrideWithValue(repo),
        notificationCoordinatorProvider.overrideWithValue(events),
      ],
    );
    PreviewAccountState.notificationPreferences.fillRange(0, 11, true);
    PreviewAccountState.notificationChannels[0][0] = true;
  });
  tearDown(() {
    container.dispose();
    repo.dispose();
    inbox.dispose();
    PreviewAccountState.notificationPreferences.fillRange(0, 11, true);
    PreviewAccountState.notificationChannels[0][0] = true;
  });

  test(
    'phone channel off does not erase committed in-app inbox events',
    () async {
      PreviewAccountState.notificationChannels[0][0] = false;
      container.listen(notificationEventBridgeProvider, (_, _) {});
      await flush();
      repo.accept(deposit('inbox-only'));
      await flush();
      expect(inbox.snapshot.single.receiptId, 'inbox-only');
    },
  );
  test(
    'mounted bridge publishes committed receipts once and respects deposit preference',
    () async {
      container.listen(notificationEventBridgeProvider, (_, _) {});
      await flush();
      repo.accept(deposit('first'));
      await flush();
      expect(inbox.snapshot.single.title, 'Deposit received');
      repo.accept(deposit('first'));
      await flush();
      expect(inbox.snapshot.length, 1);
      PreviewAccountState.notificationPreferences[3] = false;
      repo.accept(deposit('disabled'));
      await flush();
      expect(inbox.snapshot.length, 1);
    },
  );

  test(
    'queued receipt callbacks cannot cross an immediate account switch',
    () async {
      container.listen(notificationEventBridgeProvider, (_, _) {});
      await flush();
      repo.accept(deposit('stale'));
      ledger.startSimulation(empty: true);
      await flush();
      expect(events.accountId, ledger.snapshot.accountId);
      expect(inbox.snapshot, isEmpty);
      repo.accept(deposit('new'));
      await flush();
      expect(inbox.snapshot.single.receiptId, 'new');
    },
  );

  test(
    'restored deposit initiation stays quiet and later completion is delivered',
    () async {
      final id = ledger.snapshot.accountId;
      final generation = ledger.generation;
      events.activate(id, generation);
      final record = deposit('restored');
      events.receipt(id, generation, record.withStatus(ReceiptStatus.pending));
      expect(inbox.snapshot, isEmpty);
      final saved = events.exportState();
      repo.accept(record);
      events.restoreState(id, generation, saved);
      container.listen(notificationEventBridgeProvider, (_, _) {});
      await flush();
      expect(inbox.snapshot.length, 1);
      expect(inbox.snapshot.first.status, 'Completed');
      expect(inbox.snapshot.single.isRead, isFalse);
      expect(inbox.unreadCount, 1);
    },
  );
}
