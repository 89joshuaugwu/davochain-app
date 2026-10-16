import 'dart:async';
import 'package:davochain/features/notifications/notification_delivery_controller.dart';
import 'package:davochain/features/notifications/device_notification_gateway.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePhone extends DeviceNotificationGateway {
  final shown = <DeviceNotificationRequest>[];
  bool allowed = true;
  bool failPost = false;
  final active = <int>{};
  @override
  Future<bool> enabled({String? channel}) async => allowed;
  @override
  Future<void> show(DeviceNotificationRequest request) async {
    if (failPost) throw StateError('Native delivery unavailable');
    shown.add(request);
    active.add(request.id);
  }

  @override
  Future<Set<int>> activeIds() async => active;
  @override
  Future<void> cancel(int id) async => active.remove(id);
  @override
  Future<void> cancelAll() async => active.clear();
}

InboxNotification deposit(String id) => InboxNotification(
  id: 'a:$id',
  title: 'Deposit received',
  body: '100 NGN received',
  time: '',
  day: '',
  category: 1,
  kind: NotificationKind.deposit,
  status: 'Completed',
  receiptId: id,
);
void main() {
  test(
    'native failure checkpoints failure without throwing or replaying',
    () async {
      final phone = FakePhone()..failPost = true;
      Map<String, Object?> saved = {};
      final delivery = NotificationDeliveryController(
        phone: phone,
        save: (state) async {
          saved = state;
        },
      );
      await delivery.activate('a', 1);
      await delivery.deliver([deposit('failure')], account: 'a', generation: 1);
      expect(
        ((saved['entries'] as Map)['a:failure'] as Map)['state'],
        'failed',
      );
      phone.failPost = false;
      await delivery.deliver([deposit('failure')], account: 'a', generation: 1);
      expect(phone.shown, isEmpty);
    },
  );
  test('accepted facts survive a restart before delivery checkpoint', () async {
    final phone = FakePhone();
    final delivery = NotificationDeliveryController(
      phone: phone,
      save: (_) async {},
    );
    await delivery.activate(
      'a',
      1,
      baseline: [deposit('committed')],
      restored: {'version': 1, 'accountId': 'a', 'nextId': 1, 'entries': {}},
    );
    await delivery.deliver([deposit('committed')], account: 'a', generation: 1);
    expect(phone.shown.single.eventId, 'a:committed');
  });
  test(
    'facts must flush before any native delivery; account switch invalidates the await',
    () async {
      final phone = FakePhone();
      final gate = Completer<void>();
      final delivery = NotificationDeliveryController(
        phone: phone,
        save: (_) async {},
        flushFacts: () => gate.future,
      );
      await delivery.activate('a', 1);
      final posting = delivery.deliver(
        [deposit('late')],
        account: 'a',
        generation: 1,
      );
      await Future<void>.delayed(Duration.zero);
      expect(phone.shown, isEmpty);
      final switching = delivery.activate('b', 2);
      gate.complete();
      await posting;
      await switching;
      expect(phone.shown, isEmpty);
    },
  );
  test(
    'restored queued fact delivers; reading cancels once without replay',
    () async {
      final phone = FakePhone();
      final delivery = NotificationDeliveryController(
        phone: phone,
        save: (_) async {},
      );
      await delivery.activate(
        'a',
        1,
        restored: {
          'version': 1,
          'accountId': 'a',
          'nextId': 2,
          'entries': {
            'a:one': {'id': 1, 'state': 'queued'},
          },
        },
      );
      await delivery.deliver([deposit('one')], account: 'a', generation: 1);
      expect(phone.active, {1});
      await delivery.acknowledge('a:one');
      await delivery.deliver([deposit('one')], account: 'a', generation: 1);
      expect(phone.active, isEmpty);
      expect(phone.shown, hasLength(1));
      await delivery.deactivate();
      expect(phone.active, isEmpty);
    },
  );
  test('malformed and unversioned tap payloads are rejected', () {
    for (final raw in [
      null,
      '',
      '{}',
      'https://example.com',
      '{"v":9,"account":"a","event":"one"}',
    ]) {
      expect(NotificationTapIntent.parse(raw), isNull);
    }
    final intent = NotificationTapIntent.parse(
      const NotificationTapIntent('a', 'a:one').encode(),
    );
    expect(intent!.accountId, 'a');
    expect(intent.eventId, 'a:one');
  });
  test(
    'new event posts once with private copy, history is never replayed',
    () async {
      final phone = FakePhone();
      Map<String, Object?> saved = {};
      final delivery = NotificationDeliveryController(
        phone: phone,
        save: (data) async {
          saved = data;
        },
      );
      await delivery.activate('a', 1, baseline: [deposit('old')]);
      await delivery.deliver(
        [deposit('new'), deposit('old')],
        account: 'a',
        generation: 1,
      );
      await delivery.deliver([deposit('new')], account: 'a', generation: 1);
      expect(phone.shown, hasLength(1));
      expect(phone.shown.single.body, isNot(contains('100')));
      expect(saved, isNotEmpty);
    },
  );
  test('permission denied consumes event without a future burst', () async {
    final phone = FakePhone()..allowed = false;
    final delivery = NotificationDeliveryController(
      phone: phone,
      save: (_) async {},
    );
    await delivery.activate('a', 1);
    await delivery.deliver([deposit('one')], account: 'a', generation: 1);
    phone.allowed = true;
    await delivery.deliver(
      [deposit('one'), deposit('two')],
      account: 'a',
      generation: 1,
    );
    expect(phone.shown, hasLength(1));
    expect(phone.shown.single.eventId, 'a:two');
  });
  test(
    'crash after post then swipe never reposts an ambiguous attempt',
    () async {
      final phone = FakePhone();
      final delivery = NotificationDeliveryController(
        phone: phone,
        save: (_) async {},
      );
      await delivery.activate(
        'a',
        1,
        restored: {
          'version': 1,
          'nextId': 2,
          'entries': {
            'a:one': {'id': 1, 'state': 'posting'},
          },
        },
      );
      await delivery.deliver([deposit('one')], account: 'a', generation: 1);
      expect(phone.shown, isEmpty);
    },
  );
  test('stale account callback does not deliver', () async {
    final phone = FakePhone();
    final delivery = NotificationDeliveryController(
      phone: phone,
      save: (_) async {},
    );
    await delivery.activate('b', 2);
    await delivery.deliver([deposit('one')], account: 'a', generation: 1);
    expect(phone.shown, isEmpty);
  });
}
