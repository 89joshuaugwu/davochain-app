import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'local_ledger_migrations.dart';

class LocalLedgerStore {
  LocalLedgerStore._(this.database);
  final Database database;
  static Future<LocalLedgerStore> open({
    Database? database,
    String? path,
  }) async {
    final db =
        database ??
        await openDatabase(
          path ?? 'davochain_accounts.db',
          version: LocalLedgerMigrations.version,
          onCreate: (db, _) => LocalLedgerMigrations.create(db),
        );
    if (database != null) await LocalLedgerMigrations.create(db);
    return LocalLedgerStore._(db);
  }

  Future<void> write(Map<String, Object?> data) async {
    if (data['schema'] != 1) {
      throw const FormatException('Unknown account version');
    }
    final account = data['accountId'] as String;
    final revision = data['revision'] as int;
    final payload = jsonEncode(data);
    await database.transaction((tx) async {
      final old = await tx.query(
        'accounts',
        columns: ['revision'],
        where: 'account_id=?',
        whereArgs: [account],
      );
      if (old.isNotEmpty && (old.first['revision'] as int) > revision) return;
      await tx.insert('accounts', {
        'account_id': account,
        'revision': revision,
        'payload': payload,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      for (final raw in data['receipts'] as List) {
        await tx.insert('operations', {
          'account_id': account,
          'operation_id': raw['id'],
          'status': raw['status'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<Map<String, Object?>?> read(String account) async {
    final rows = await database.query(
      'accounts',
      columns: ['payload'],
      where: 'account_id=?',
      whereArgs: [account],
    );
    if (rows.isEmpty) return null;
    final data = Map<String, Object?>.from(
      jsonDecode(rows.single['payload'] as String) as Map,
    );
    if (data['schema'] != 1 || data['accountId'] != account) {
      throw const FormatException('Invalid stored account');
    }
    return data;
  }

  Future<int> operationCount(String account) async =>
      Sqflite.firstIntValue(
        await database.rawQuery(
          'SELECT COUNT(*) FROM operations WHERE account_id=?',
          [account],
        ),
      ) ??
      0;
  Future<void> putMetadata(String key, String value) => database
      .insert('metadata', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace)
      .then((_) {});
  Future<String?> metadata(String key) async {
    final rows = await database.query(
      'metadata',
      where: 'key=?',
      whereArgs: [key],
    );
    return rows.isEmpty ? null : rows.single['value'] as String;
  }

  Future<void> close() => database.close();
}
