import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/notifications/notification_permission_panel.dart';
import 'package:davochain/features/notifications/notification_runtime.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/notifications/device_notification_gateway.dart';
import 'package:davochain/features/notifications/notification_delivery_controller.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/features/notifications/notification_preferences.dart';

class VoicePhone extends DeviceNotificationGateway {
  bool allowed = true, fail = false;
  int voices = 0, stops = 0;
  Completer<bool>? voiceGate;
  final order = <String>[];
  @override
  Future<bool> enabled({String? channel}) async => allowed;
  @override
  Future<void> show(DeviceNotificationRequest request) async {
    if (fail) throw StateError('post');
    order.add('posted');
  }

  @override
  Future<bool> speakDeposit() async {
    voices++;
    order.add('voice');
    return voiceGate == null ? true : await voiceGate!.future;
  }

  @override
  Future<void> stopSpeaking() async {
    stops++;
  }
}

InboxNotification item(
  String id, {
  NotificationKind kind = NotificationKind.deposit,
  String status = 'Completed',
}) => InboxNotification(
  id: 'a:$id',
  title: 'Test',
  body: 'Private amount',
  time: '',
  day: '',
  category: 1,
  kind: kind,
  status: status,
  receiptId: id,
);
void main() {
  test(
    'voice is off for old settings and survives account preference roundtrip',
    () {
      final prefs = NotificationPreferences();
      expect(prefs.depositVoiceAlerts, isFalse);
      prefs.depositVoiceAlerts = true;
      final next = NotificationPreferences()..restore(prefs.exportState());
      expect(next.depositVoiceAlerts, isTrue);
      next.restore(null);
      expect(next.depositVoiceAlerts, isFalse);
    },
  );
  test(
    'only a newly posted completed deposit speaks once after durable posting',
    () async {
      final phone = VoicePhone();
      bool enabled = true;
      Map<String, Object?> saved = {};
      final delivery = NotificationDeliveryController(
        phone: phone,
        voiceEnabled: () => enabled,
        save: (state) async {
          saved = state;
          phone.order.add('saved');
        },
      );
      await delivery.activate('a', 1, baseline: [item('old')]);
      await delivery.deliver(
        [
          item('new'),
          item('old'),
          item('pending', status: 'Pending'),
          item('withdraw', kind: NotificationKind.withdrawal),
        ],
        account: 'a',
        generation: 1,
      );
      expect(phone.voices, 1);
      expect(phone.order.last, 'voice');
      expect(phone.order[phone.order.length - 2], 'saved');
      await delivery.deliver([item('new')], account: 'a', generation: 1);
      expect(phone.voices, 1);
      final restored = NotificationDeliveryController(
        phone: phone,
        voiceEnabled: () => true,
        save: (_) async {},
      );
      await restored.activate('a', 2, restored: saved);
      await restored.deliver([item('new')], account: 'a', generation: 2);
      expect(phone.voices, 1);
      enabled = false;
      await delivery.deliver([item('off')], account: 'a', generation: 1);
      expect(phone.voices, 1);
    },
  );
  test(
    'denied or failed posts and account changes never trigger speech',
    () async {
      final phone = VoicePhone()..allowed = false;
      final delivery = NotificationDeliveryController(
        phone: phone,
        voiceEnabled: () => true,
        save: (_) async {},
      );
      await delivery.activate('a', 1);
      await delivery.deliver([item('denied')], account: 'a', generation: 1);
      expect(phone.voices, 0);
      phone.allowed = true;
      phone.fail = true;
      await delivery.deliver([item('failed')], account: 'a', generation: 1);
      expect(phone.voices, 0);
      await delivery.deactivate();
      expect(phone.stops, 1);
    },
  );
  test('disabling while native post awaits prevents voice', () async {
    final gate = Completer<void>();
    var enabled = true;
    var saves = 0;
    final phone = VoicePhone();
    final delivery = NotificationDeliveryController(
      phone: phone,
      voiceEnabled: () => enabled,
      save: (_) async {
        if (++saves == 3) await gate.future;
      },
    );
    await delivery.activate('a', 1);
    final posting = delivery.deliver(
      [item('race')],
      account: 'a',
      generation: 1,
    );
    await Future<void>.delayed(Duration.zero);
    enabled = false;
    gate.complete();
    await posting;
    expect(phone.voices, 0);
  });
  testWidgets(
    'settings voice is optional, previews the fixed phrase and remains readable at 200 percent',
    (tester) async {
      final runtime = NotificationRuntime.instance;
      final calls = <MethodCall>[];
      const channel = MethodChannel('davochain/deposit_voice');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return call.method == 'speak' ? true : null;
          });
      runtime.initialized = true;
      runtime.allowed = true;
      runtime.preferences.depositVoiceAlerts = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(child: NotificationPermissionPanel()),
            ),
          ),
        ),
      );
      expect(find.text('Deposit voice alert'), findsOneWidget);
      final toggle = find.widgetWithText(
        SwitchListTile,
        'Announce received payments',
      );
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
      expect(runtime.preferences.depositVoiceAlerts, isTrue);
      final preview = find.text('Test voice');
      await tester.ensureVisible(preview);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      expect(
        calls.where((call) => call.method == 'speak').single.arguments,
        isNull,
      );
      expect(find.text('Voice preview requested.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      runtime.preferences.depositVoiceAlerts = false;
      runtime.initialized = false;
      runtime.allowed = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test('a slow speech engine cannot delay later phone notifications', () async {
    final phone = VoicePhone()..voiceGate = Completer<bool>();
    final delivery = NotificationDeliveryController(
      phone: phone,
      voiceEnabled: () => true,
      save: (_) async {},
    );
    await delivery.activate('a', 1);
    try {
      await delivery
          .deliver([item('slow')], account: 'a', generation: 1)
          .timeout(const Duration(seconds: 1));
      await delivery.deliver(
        [item('security', kind: NotificationKind.security)],
        account: 'a',
        generation: 1,
      );
      expect(phone.order.where((value) => value == 'posted').length, 2);
    } finally {
      phone.voiceGate!.complete(true);
      await delivery.flush();
    }
  });
  test('activating another account stops pending speech immediately', () async {
    final phone = VoicePhone();
    final delivery = NotificationDeliveryController(
      phone: phone,
      voiceEnabled: () => true,
      save: (_) async {},
    );
    await delivery.activate('a', 1);
    await delivery.deliver([item('a-deposit')], account: 'a', generation: 1);
    final next = delivery.activate('b', 2);
    expect(phone.stops, 1);
    await next;
    await delivery.deliver([item('late')], account: 'a', generation: 1);
    expect(phone.voices, 1);
  });
}
