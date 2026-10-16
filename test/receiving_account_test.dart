import 'dart:async';
import 'package:davochain/features/funding/receiving_account.dart';
import 'package:davochain/features/funding/receiving_account_gateway.dart';
import 'package:davochain/features/funding/receiving_account_controller.dart';
import 'package:flutter_test/flutter_test.dart';

ReceivingAccount ready(String account) => ReceivingAccount.ready(
  accountId: account,
  details: ReceivingBankDetails(
    accountName: 'Customer $account',
    bankName: 'Preview Bank',
    accountNumber: 'TEST-$account',
    isPreview: true,
  ),
);

class GateGateway implements ReceivingAccountGateway {
  final calls = <(String, String)>[];
  final responses = <String, Completer<ReceivingAccount>>{};
  @override
  Future<ReceivingAccount> provision({
    required String accountId,
    required String idempotencyKey,
    required String accountName,
  }) {
    calls.add((accountId, idempotencyKey));
    return responses
        .putIfAbsent(accountId, Completer<ReceivingAccount>.new)
        .future;
  }
}

void main() {
  test(
    'duplicate activation shares one request and accepted details persist before readiness',
    () async {
      final gateway = GateGateway();
      final saved = <ReceivingAccount>[];
      final controller = ReceivingAccountController(
        gateway: gateway,
        save: (account) async => saved.add(account),
      );
      final first = controller.activate('a', 1, accountName: 'Alice');
      final second = controller.activate('a', 1, accountName: 'Alice');
      await Future<void>.delayed(Duration.zero);
      expect(controller.current.status, ReceivingAccountStatus.creating);
      expect(controller.current.details, isNull);
      expect(gateway.calls, hasLength(1));
      gateway.responses['a']!.complete(ready('a'));
      await first;
      await second;
      expect(controller.current.status, ReceivingAccountStatus.ready);
      expect(saved.single.accountId, 'a');
      controller.dispose();
    },
  );
  test(
    'account switch and logout clear details before delayed old callback',
    () async {
      final gateway = GateGateway();
      final saved = <ReceivingAccount>[];
      final controller = ReceivingAccountController(
        gateway: gateway,
        save: (account) async => saved.add(account),
      );
      final old = controller.activate('a', 1, accountName: 'Alice');
      await Future<void>.delayed(Duration.zero);
      final next = controller.activate('b', 2, accountName: 'Bob');
      await Future<void>.delayed(Duration.zero);
      expect(controller.current.accountId, 'b');
      expect(controller.current.details, isNull);
      gateway.responses['a']!.complete(ready('a'));
      await old;
      expect(saved, isEmpty);
      controller.deactivate();
      gateway.responses['b']!.complete(ready('b'));
      await next;
      expect(controller.current.status, ReceivingAccountStatus.unavailable);
      expect(saved, isEmpty);
      controller.dispose();
    },
  );
  test(
    'saved ready details restore without reprovisioning; wrong-account data never displays',
    () async {
      final gateway = GateGateway();
      final controller = ReceivingAccountController(
        gateway: gateway,
        load: (_) async => ready('a'),
      );
      await controller.activate('a', 1, accountName: 'Alice');
      expect(gateway.calls, isEmpty);
      expect(controller.current.details!.accountNumber, 'TEST-a');
      await controller.activate('b', 2, accountName: 'Bob');
      expect(controller.current.status, ReceivingAccountStatus.failed);
      expect(controller.current.details, isNull);
      controller.dispose();
    },
  );
  test('retry keeps the provider idempotency key after failure', () async {
    final gateway = GateGateway();
    final controller = ReceivingAccountController(gateway: gateway);
    final first = controller.activate('a', 1, accountName: 'Alice');
    await Future<void>.delayed(Duration.zero);
    gateway.responses['a']!.completeError(StateError('unavailable'));
    await first;
    expect(controller.current.status, ReceivingAccountStatus.failed);
    gateway.responses.remove('a');
    final retry = controller.retry();
    await Future<void>.delayed(Duration.zero);
    gateway.responses['a']!.complete(ready('a'));
    await retry;
    expect(gateway.calls[0].$2, gateway.calls[1].$2);
    expect(controller.current.status, ReceivingAccountStatus.ready);
    controller.dispose();
  });
  test(
    'local fixtures are deterministic, account scoped, and clearly non-bank routing details',
    () async {
      const gateway = LocalReceivingAccountGateway();
      final a = await gateway.provision(
        accountId: 'a',
        idempotencyKey: 'a',
        accountName: 'Alice',
      );
      final again = await gateway.provision(
        accountId: 'a',
        idempotencyKey: 'a',
        accountName: 'Alice',
      );
      final b = await gateway.provision(
        accountId: 'b',
        idempotencyKey: 'b',
        accountName: 'Bob',
      );
      expect(a.details!.accountNumber, again.details!.accountNumber);
      expect(a.details!.accountNumber, isNot(b.details!.accountNumber));
      expect(a.details!.isPreview, true);
      expect(a.details!.accountNumber, startsWith('TEST-'));
      expect(a.details!.accountName, 'Alice');
    },
  );
}
