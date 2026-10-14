import 'package:davochain/core/providers/app_providers.dart';
import 'package:davochain/core/session/session_context.dart';
import 'package:davochain/features/transactions/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production composition refuses local financial authority', () {
    expect(() => AppProviders(environment: AppEnvironment.production,
      authority: ProviderAuthority.local), throwsStateError);
    expect(() => AppProviders(environment: AppEnvironment.production,
      authority: ProviderAuthority.remote), returnsNormally);
  });
  test('session binding discards delayed old-account results', () {
    final session = SessionContext('one');
    final token = session.capture();
    session.switchAccount('two');
    expect(session.accepts(token), isFalse);
    expect(session.accepts(session.capture()), isTrue);
  });
  test('transaction facts require versions and allow explicit reversals', () {
    final store = TransactionEventStore('one');
    expect(store.accept(const TransactionEvent(accountId: 'one', id: 'tx', version: 2, state: TransactionState.completed)), isTrue);
    expect(store.accept(const TransactionEvent(accountId: 'one', id: 'tx', version: 1, state: TransactionState.pending)), isFalse);
    expect(store.accept(const TransactionEvent(accountId: 'other', id: 'tx', version: 3, state: TransactionState.reversed)), isFalse);
    expect(store.accept(const TransactionEvent(accountId: 'one', id: 'tx', version: 3, state: TransactionState.reversed)), isTrue);
    expect(store.events['tx']!.state, TransactionState.reversed);
    expect(store.accept(const TransactionEvent(accountId: 'one', id: 'tx', version: 4, state: TransactionState.pending)), isFalse);
  });
}
