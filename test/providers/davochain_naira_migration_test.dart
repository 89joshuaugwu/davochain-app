import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:davochain/features/wallets/local_ledger_store.dart';
import 'package:davochain/features/wallets/local_account_persistence.dart';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/shared/receipts/receipt_codec.dart';
import 'dart:convert';
import 'package:davochain/features/wallets/davochain_naira_migration.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/transaction_repository.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> legacy() => {
  'schema': 1,
  'accountId': 'a',
  'revision': 3,
  'wallet': {
    'schema': 1,
    'accountId': 'a',
    'version': 2,
    'enabled': true,
    'quote': null,
    'fx': 150000,
    'prices': {'NGN': 100, 'NGD': 100, 'BTC': 10000000},
    'amounts': {
      'NGN': {'units': '10000', 'decimals': 2},
      'NGD': {'units': '20000', 'decimals': 2},
      'BTC': {'units': '0', 'decimals': 8},
    },
    'reserved': {},
    'settled': <String>[],
    'rejected': <String>[],
  },
  'receipts': <Object?>[],
  'notifications': {'version': 1, 'example': 'must stay untouched'},
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  test(
    'migration is persisted before publishing the restored account',
    () async {
      final store = await LocalLedgerStore.open(
        database: await databaseFactoryFfi.openDatabase(inMemoryDatabasePath),
      );
      final profile = LocalPreviewProfile.instance;
      final input = legacy()..remove('notifications');
      input['profile'] = profile.exportDisplay();
      await store.write(input);
      await store.putMetadata('active-account', 'a');
      final ledger = WalletAccountState();
      final repo = LocalTransactionRepository(ledger);
      final persistence = LocalAccountPersistence(store, repo, profile);
      await persistence.initialize();
      expect(ledger.snapshot.accountId, 'a');
      expect(ledger.ngnAvailableMinorUnits, 30000);
      final saved = await store.read('a');
      expect((saved!['wallet'] as Map)['fiatWalletVersion'], 2);
      expect(
        ((saved['wallet'] as Map)['amounts'] as Map).containsKey('NGD'),
        false,
      );
      expect(await store.operationCount('a'), 0);
      await persistence.close();
      repo.dispose();
      ledger.dispose();
      await store.close();
    },
  );
  test('pending legacy reserve settles once without a second debit', () async {
    final input = legacy();
    final wallet = input['wallet'] as Map;
    final effect = {
      'accountId': 'a',
      'generation': 0,
      'debits': {
        'NGD': {'units': '5000', 'decimals': 2},
      },
      'credits': {
        'BTC': {'units': '1000', 'decimals': 8},
      },
    };
    (wallet['reserved'] as Map)['pending-complete'] = effect;
    final encoded = encodeReceipt(
      ReceiptRecord(
        id: 'pending-complete',
        reference: 'pending-complete',
        type: 'Buy',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.now(),
        amount: '0.00001 BTC',
        fields: const [],
      ),
    );
    encoded['effect'] = effect;
    input['receipts'] = [encoded];
    final ledger = WalletAccountState();
    final repo = LocalTransactionRepository(
      ledger,
      settlementDelay: const Duration(days: 1),
    );
    repo.restoreState(input);
    final pending = repo.records.value.single;
    repo.accept(pending.withStatus(ReceiptStatus.completed));
    repo.accept(pending.withStatus(ReceiptStatus.completed));
    expect(ledger.ngnAvailableMinorUnits, 30000);
    expect(ledger.snapshot.available('BTC').atomicUnits, BigInt.from(1000));
    await Future<void>.delayed(Duration.zero);
    repo.dispose();
    ledger.dispose();
  });
  test(
    'one fiat wallet is exposed and legacy read aliases cannot split funds',
    () {
      final ledger = WalletAccountState()..startSimulation(empty: false);
      expect(ledger.snapshot.assets, isNot(contains('NGD')));
      expect(
        ledger.snapshot.available('NGN').atomicUnits,
        BigInt.from(141950035),
      );
      expect(
        ledger.snapshot.available('NGD').atomicUnits,
        ledger.snapshot.available('NGN').atomicUnits,
      );
      final effect = ledger.effect(debits: {'NGN': '10', 'NGD': '20'});
      expect(effect.debits.keys, ['NGN']);
      expect(effect.debits['NGN']!.atomicUnits, BigInt.from(3000));
      ledger.dispose();
    },
  );
  test(
    'consolidates known independent buckets once without changing input or history',
    () {
      final input = legacy();
      final before = jsonEncode(input);
      final result = migrateDavochainNairaCheckpoint(input);
      final wallet = result['wallet'] as Map;
      expect((wallet['amounts'] as Map).keys, isNot(contains('NGD')));
      expect(((wallet['amounts'] as Map)['NGN'] as Map)['units'], '30000');
      expect(jsonEncode(input), before);
      expect(result['notifications'], input['notifications']);
      expect(
        jsonEncode(migrateDavochainNairaCheckpoint(result)),
        jsonEncode(result),
      );
    },
  );
  test(
    'NGD-only wallet becomes canonical; unknown schema and corrupt mixed marker reject',
    () {
      final input = legacy();
      ((input['wallet'] as Map)['amounts'] as Map).remove('NGN');
      final result = migrateDavochainNairaCheckpoint(input);
      expect(
        ((((result['wallet'] as Map)['amounts'] as Map)['NGN'])
            as Map)['units'],
        '20000',
      );
      final unknown = legacy()..['schema'] = 9;
      expect(
        () => migrateDavochainNairaCheckpoint(unknown),
        throwsFormatException,
      );
      final corrupt = legacy();
      (corrupt['wallet'] as Map)['fiatWalletVersion'] = 2;
      expect(
        () => migrateDavochainNairaCheckpoint(corrupt),
        throwsFormatException,
      );
    },
  );
  test(
    'pending legacy debit restores, settles or refunds exactly once from same wallet',
    () async {
      final ledger = WalletAccountState()..startSimulation(empty: true);
      // Build a genuine old checkpoint with an independent NGD reserve.
      final data = legacy();
      final wallet = data['wallet'] as Map;
      wallet['accountId'] = ledger.snapshot.accountId;
      data['accountId'] = ledger.snapshot.accountId;
      final effect = {
        'accountId': ledger.snapshot.accountId,
        'generation': ledger.generation,
        'debits': {
          'NGD': {'units': '5000', 'decimals': 2},
        },
        'credits': {
          'BTC': {'units': '1000', 'decimals': 8},
        },
      };
      (wallet['reserved'] as Map)['pending'] = effect;
      final record = ReceiptRecord(
        id: 'pending',
        reference: 'pending',
        type: 'Buy',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.now(),
        amount: '0.00001 BTC',
        fields: const [],
      );
      final encoded = encodeReceipt(record);
      encoded['effect'] = effect;
      data['receipts'] = [encoded];
      final migrated = migrateDavochainNairaCheckpoint(data);
      final repo = LocalTransactionRepository(
        ledger,
        settlementDelay: const Duration(days: 1),
      );
      repo.restoreState(migrated);
      final pending = repo.records.value.single;
      expect(ledger.snapshot.available('NGN').atomicUnits, BigInt.from(30000));
      repo.accept(pending.withStatus(ReceiptStatus.failed));
      repo.accept(pending.withStatus(ReceiptStatus.failed));
      expect(ledger.snapshot.available('NGN').atomicUnits, BigInt.from(35000));
      expect(ledger.snapshot.available('BTC').atomicUnits, BigInt.zero);
      await Future<void>.delayed(Duration.zero);
      repo.dispose();
      ledger.dispose();
    },
  );
}
