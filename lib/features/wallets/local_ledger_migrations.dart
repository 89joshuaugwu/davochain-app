import 'package:sqflite/sqflite.dart';

abstract final class LocalLedgerMigrations {
  static const version = 1;
  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS accounts(account_id TEXT PRIMARY KEY, revision INTEGER NOT NULL, payload TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS operations(account_id TEXT NOT NULL, operation_id TEXT NOT NULL, status TEXT NOT NULL, PRIMARY KEY(account_id,operation_id))',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS metadata(key TEXT PRIMARY KEY,value TEXT NOT NULL)',
    );
  }
}
