import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:davochain/core/providers/account_scope.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/transaction_repository.dart';
import 'package:davochain/shared/receipts/transaction_controller.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';

void main() {
  test(
    'commands reserve once, settle once and account switches discard old commands',
    () async {
      final ledger = WalletAccountState()..startSimulation(empty: true);
      final repo = LocalTransactionRepository(
        ledger,
        settlementDelay: const Duration(days: 1),
      );
      final c = ProviderContainer(
        overrides: [
          walletEngineProvider.overrideWithValue(ledger),
          transactionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(c.dispose);
      addTearDown(repo.dispose);
      ReceiptRecord record(
        String id,
        Map<String, String> debits,
        Map<String, String> credits,
      ) => ReceiptRecord(
        id: id,
        reference: id,
        type: 'Trade',
        status: ReceiptStatus.completed,
        occurredAt: DateTime.now(),
        amount: 'value',
        walletEffect: ledger.effect(debits: debits, credits: credits),
        fields: const [],
      );
      repo.accept(record('deposit', {}, {'NGN': '1000'}));
      final intent = record('buy', {'NGN': '600'}, {'BTC': '0.000001'});
      final command = c.read(transactionControllerProvider.notifier);
      await Future.wait([command.submit(intent), command.submit(intent)]);
      expect(ledger.ngnAvailableMinorUnits, 40000);
      repo.accept(intent);
      repo.accept(intent);
      expect(ledger.snapshot.available('BTC').decimal, '0.000001');
      final stale = record('stale', {}, {'NGN': '1000'});
      ledger.startSimulation(empty: true);
      expect((await command.submit(stale)).status, ReceiptStatus.failed);
      expect(repo.records.value, isEmpty);
      expect(ledger.ngnAvailableMinorUnits, 0);
    },
  );
  test(
    'unknown submission looks up same identity without repeating financial write',
    () async {
      final ledger = WalletAccountState()..startSimulation(empty: true);
      final repo = LocalTransactionRepository(
        ledger,
        settlementDelay: const Duration(days: 1),
        checkpoint: (_) => Future.error(StateError('storage unavailable')),
      );
      final c = ProviderContainer(
        overrides: [
          walletEngineProvider.overrideWithValue(ledger),
          transactionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(c.dispose);
      addTearDown(repo.dispose);
      final record = ReceiptRecord(
        id: 'uncertain',
        reference: 'uncertain',
        type: 'Deposit',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.now(),
        amount: '100',
        fields: const [],
        walletEffect: ledger.effect(credits: {'NGN': '100'}),
      );
      await c.read(transactionControllerProvider.notifier).submit(record);
      expect(
        c.read(transactionControllerProvider)['uncertain'],
        SubmissionPhase.unknown,
      );
      expect(repo.records.value, isEmpty);
      await c
          .read(transactionControllerProvider.notifier)
          .reconcile('uncertain');
      expect(repo.records.value, isEmpty);
      expect(ledger.ngnAvailableMinorUnits, 0);
    },
  );
  test('failed save cannot settle a deposit or report completion', () async {
    final ledger = WalletAccountState()..startSimulation(empty: true);
    final repo = LocalTransactionRepository(
      ledger,
      settlementDelay: const Duration(milliseconds: 5),
      checkpoint: (_) => Future.error(StateError('disk full')),
    );
    addTearDown(repo.dispose);
    final c = ProviderContainer(
      overrides: [
        walletEngineProvider.overrideWithValue(ledger),
        transactionRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    final record = ReceiptRecord(
      id: 'disk',
      reference: 'disk',
      type: 'Deposit',
      status: ReceiptStatus.completed,
      occurredAt: DateTime.now(),
      amount: '100',
      fields: const [],
      walletEffect: ledger.effect(credits: {'NGN': '100'}),
    );
    final result = await c
        .read(transactionControllerProvider.notifier)
        .submit(record);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(ledger.ngnAvailableMinorUnits, 0);
    expect(result.status, isNot(ReceiptStatus.completed));
    expect(repo.resolve(result).status, isNot(ReceiptStatus.completed));
  });
  test(
    'durable completion waits for storage and retry credits the same identity once',
    () async {
      final ledger = WalletAccountState()..startSimulation(empty: true);
      var failCompletion = true;
      var writes = 0;
      final repo = LocalTransactionRepository(
        ledger,
        settlementDelay: const Duration(milliseconds: 5),
        checkpoint: (data) async {
          writes++;
          if ((data['receipts'] as List).first['status'] == 'completed' &&
              failCompletion) {
            throw StateError('disk full');
          }
        },
      );
      addTearDown(repo.dispose);
      final record = ReceiptRecord(
        id: 'retry',
        reference: 'retry',
        type: 'Deposit',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.now(),
        amount: '100',
        fields: const [],
        walletEffect: ledger.effect(credits: {'NGN': '100'}),
      );
      await repo.submitDurable(record);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(ledger.ngnAvailableMinorUnits, 0);
      expect(repo.needsSave('retry'), isTrue);
      failCompletion = false;
      await repo.retrySave('retry');
      expect(ledger.ngnAvailableMinorUnits, 10000);
      expect(repo.records.value.single.status, ReceiptStatus.completed);
      await repo.submitDurable(record);
      expect(ledger.ngnAvailableMinorUnits, 10000);
      expect(writes, 3);
    },
  );
}
