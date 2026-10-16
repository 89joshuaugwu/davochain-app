import 'package:davochain/features/notifications/notification_inbox.dart';
import 'dart:async';
import 'package:davochain/features/wallets/quote_repository.dart';
import 'package:davochain/features/wallets/local_account_persistence.dart';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:davochain/features/wallets/local_ledger_store.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/transaction_repository.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  test(
    'SQLite checkpoint restores reserved funds and settles once after restart',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      final store = await LocalLedgerStore.open(database: db);
      final ledger = WalletAccountState()..startSimulation(empty: true);
      final repo = LocalTransactionRepository(
        ledger,
        settlementDelay: const Duration(days: 1),
      );
      repo.accept(
        ReceiptRecord(
          id: 'fund',
          reference: 'fund',
          type: 'Deposit',
          status: ReceiptStatus.completed,
          occurredAt: DateTime.now(),
          amount: '1000',
          fields: const [],
          walletEffect: ledger.effect(credits: {'NGN': '1000'}),
        ),
      );
      repo.submit(
        ReceiptRecord(
          id: 'buy',
          reference: 'buy',
          type: 'Buy',
          status: ReceiptStatus.pending,
          occurredAt: DateTime.now(),
          amount: 'BTC',
          fields: const [],
          walletEffect: ledger.effect(
            debits: {'NGN': '600'},
            credits: {'BTC': '0.000001'},
          ),
        ),
      );
      final saved = repo.exportState();
      await store.write(saved);
      await store.write(saved);
      final restored = await store.read(ledger.snapshot.accountId);
      expect(restored, isNotNull);
      repo.dispose();
      final nextLedger = WalletAccountState();
      final next = LocalTransactionRepository(
        nextLedger,
        settlementDelay: const Duration(days: 1),
      );
      next.restoreState(restored!);
      expect(nextLedger.ngnAvailableMinorUnits, 40000);
      final pending = next.records.value.firstWhere((r) => r.id == 'buy');
      next.accept(pending.withStatus(ReceiptStatus.completed));
      next.accept(pending.withStatus(ReceiptStatus.completed));
      expect(nextLedger.snapshot.available('BTC').decimal, '0.000001');
      expect(nextLedger.ngnAvailableMinorUnits, 40000);
      await store.write(next.exportState());
      expect(await store.operationCount(nextLedger.snapshot.accountId), 2);
      next.dispose();
      await store.close();
    },
  );
  test(
    'invalid checkpoint does not replace valid balances and accounts stay separate',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      final store = await LocalLedgerStore.open(database: db);
      final a = WalletAccountState()..startSimulation(empty: true);
      final ar = LocalTransactionRepository(a);
      final before = a.snapshot.accountId;
      expect(() => ar.restoreState({'schema': 999}), throwsFormatException);
      expect(a.snapshot.accountId, before);
      await store.write(ar.exportState());
      final b = WalletAccountState()..startSimulation(empty: true);
      final br = LocalTransactionRepository(b);
      await store.write(br.exportState());
      expect(await store.read('missing'), isNull);
      expect(
        (await store.read(a.snapshot.accountId))!['accountId'],
        a.snapshot.accountId,
      );
      ar.dispose();
      br.dispose();
      await store.close();
    },
  );
  test(
    'active account display and exact wallet restore through the app storage adapter',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      final store = await LocalLedgerStore.open(database: db);
      final profile = LocalPreviewProfile.instance;
      profile.register(
        name: 'Persisted Account',
        email: 'saved@example.com',
        phone: '+234 8012345678',
      );
      final welcome = NotificationInbox.instance.snapshot.single;
      NotificationInbox.instance.markRead(welcome.id);
      final ledger = WalletAccountState.instance;
      final repo = LocalTransactionRepository.instance;
      final persistence = LocalAccountPersistence(store, repo, profile);
      await persistence.initialize();
      repo.accept(
        ReceiptRecord(
          id: 'persist-fund',
          reference: 'persist-fund',
          type: 'Deposit',
          status: ReceiptStatus.completed,
          occurredAt: DateTime.now(),
          amount: '2500',
          fields: const [],
          walletEffect: ledger.effect(credits: {'NGN': '2500'}),
        ),
      );
      await persistence.flush();
      final account = ledger.snapshot.accountId;
      expect(await store.metadata('active-account'), account);
      profile.loginSample();
      await persistence.flush();
      expect(await persistence.signIn('saved@example.com'), isTrue);
      expect(profile.fullName, 'Persisted Account');
      expect(NotificationInbox.instance.snapshot.single.id, welcome.id);
      expect(NotificationInbox.instance.snapshot.single.isRead, isTrue);
      expect(ledger.ngnAvailableMinorUnits, 250000);
      final payload = (await store.read(account))!.toString();
      expect(payload.contains('transactionPin'), isFalse);
      expect(payload.contains('password'), isFalse);
      await persistence.close();
      profile.loginSample();
    },
  );
  test('overdue pending local deposit reconciles automatically once', () async {
    final ledger = WalletAccountState()..startSimulation(empty: true);
    final repo = LocalTransactionRepository(
      ledger,
      settlementDelay: const Duration(milliseconds: 10),
    );
    repo.submit(
      ReceiptRecord(
        id: 'due',
        reference: 'due',
        type: 'Deposit',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.now().subtract(const Duration(seconds: 1)),
        amount: '50',
        fields: const [],
        walletEffect: ledger.effect(credits: {'NGN': '50'}),
      ),
    );
    final data = repo.exportState();
    repo.dispose();
    final nextLedger = WalletAccountState();
    final next = LocalTransactionRepository(
      nextLedger,
      settlementDelay: const Duration(milliseconds: 10),
    );
    next.restoreState(data);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(nextLedger.ngnAvailableMinorUnits, 5000);
    expect(next.records.value.single.status, ReceiptStatus.completed);
    next.accept(next.records.value.single);
    expect(nextLedger.ngnAvailableMinorUnits, 5000);
    next.dispose();
  });
  test('abandoned saved login cannot replace a newer account', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final store = await LocalLedgerStore.open(database: db);
    final profile = LocalPreviewProfile.instance;
    profile.register(
      name: 'First',
      email: 'first@example.com',
      phone: '1234567890',
    );
    final repo = LocalTransactionRepository.instance;
    final data = {...repo.exportState(), 'profile': profile.exportDisplay()};
    await store.putMetadata(
      'email:first@example.com',
      data['accountId'] as String,
    );
    final gate = Completer<Map<String, Object?>?>();
    final started = Completer<void>();
    final persistence = LocalAccountPersistence(
      store,
      repo,
      profile,
      readAccount: (_) {
        started.complete();
        return gate.future;
      },
    );
    final pending = persistence.signIn('first@example.com');
    await started.future;
    profile.register(
      name: 'Second',
      email: 'second@example.com',
      phone: '1234567890',
    );
    final second = repo.ledger.snapshot.accountId;
    gate.complete(data);
    expect(await pending, isFalse);
    expect(repo.ledger.snapshot.accountId, second);
    expect(profile.fullName, 'Second');
    await store.close();
    profile.loginSample();
  });
  test('quote identity and expiry survive wallet restoration', () {
    final ledger = WalletAccountState()..startSimulation(empty: true);
    final offline = QuoteSnapshot.offline();
    final quote = QuoteSnapshot(
      id: 'stored-rate',
      asOf: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      pricesMinorUnits: offline.pricesMinorUnits,
      usdNgnMinorUnits: offline.usdNgnMinorUnits,
    );
    ledger.updateQuotes(quote);
    final restored = WalletAccountState()..restoreState(ledger.exportState());
    expect(restored.quoteId, quote.id);
    expect(restored.activeQuote!.asOf, quote.asOf);
    expect(restored.activeQuote!.expiresAt, quote.expiresAt);
    expect(
      restored.snapshot.priceMinorUnits('BTC'),
      quote.pricesMinorUnits['BTC'],
    );
  });
}
