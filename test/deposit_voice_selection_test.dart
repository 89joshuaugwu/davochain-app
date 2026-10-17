import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/notifications/android_notification_gateway.dart';
import 'package:davochain/features/notifications/deposit_voice.dart';
import 'package:davochain/features/notifications/deposit_voice_picker.dart';
import 'package:davochain/features/notifications/device_notification_gateway.dart';
import 'package:davochain/features/notifications/notification_preferences.dart';
import 'package:davochain/features/notifications/notification_runtime.dart';

class VoiceSelectionPhone extends DeviceNotificationGateway {
  String? selected;
  DepositVoiceStyle style = DepositVoiceStyle.natural;
  int previews = 0;
  @override
  void setDepositVoiceOptions({
    String? voiceId,
    DepositVoiceStyle style = DepositVoiceStyle.natural,
  }) {
    selected = voiceId;
    this.style = style;
  }

  @override
  Future<List<DepositVoiceOption>> depositVoices() async => const [
    DepositVoiceOption(
      id: 'voice-a',
      label: 'English - Voice 1',
      locale: 'en-US',
      offline: true,
    ),
    DepositVoiceOption(
      id: 'voice-b',
      label: 'English - Voice 2',
      locale: 'en-US',
      offline: false,
    ),
  ];
  @override
  Future<bool> speakDeposit() async {
    previews++;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'voice preferences survive restore and legacy accounts keep natural default',
    () {
      final preferences = NotificationPreferences()
        ..depositVoiceAlerts = true
        ..depositVoiceId = 'voice-b'
        ..depositVoiceStyle = DepositVoiceStyle.bright;
      final restored = NotificationPreferences()
        ..restore(preferences.exportState());
      expect(restored.depositVoiceAlerts, isTrue);
      expect(restored.depositVoiceId, 'voice-b');
      expect(restored.depositVoiceStyle, DepositVoiceStyle.bright);
      restored.restore({
        'depositVoice': true,
        'depositVoiceId': 12,
        'depositVoiceStyle': 'unknown',
      });
      expect(restored.depositVoiceId, isNull);
      expect(restored.depositVoiceStyle, DepositVoiceStyle.natural);
      expect(restored.depositVoiceAlerts, isTrue);
      restored.restore(null);
      expect(restored.depositVoiceAlerts, isFalse);
    },
  );

  test(
    'native gateway lists real voices and forwards chosen voice and style without private text',
    () async {
      const channel = MethodChannel('davochain/deposit_voice');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'voices') {
              return [
                {
                  'id': 'a',
                  'label': 'English - Voice 1',
                  'locale': 'en-US',
                  'offline': true,
                },
                {'id': 12},
              ];
            }
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final phone = AndroidNotificationGateway();
      expect((await phone.depositVoices()).single.id, 'a');
      phone.setDepositVoiceOptions(voiceId: 'a', style: DepositVoiceStyle.deep);
      expect(await phone.speakDeposit(), isTrue);
      expect(calls.last.arguments, {'voiceId': 'a', 'style': 'deep'});
      phone.setDepositVoiceOptions();
      await phone.speakDeposit();
      expect(calls.last.arguments, isNull);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'voice choice previews selected voice and style at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 820);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final phone = VoiceSelectionPhone();
        final runtime = NotificationRuntime(gateway: phone)
          ..initialized = true
          ..allowed = true;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(360, 820),
                textScaler: TextScaler.linear(scale),
              ),
              child: Scaffold(body: DepositVoicePicker(runtime: runtime)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Bright'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bright'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('English - Voice 2'),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('English - Voice 2'));
        await tester.pumpAndSettle();
        expect(phone.selected, 'voice-b');
        expect(phone.style, DepositVoiceStyle.bright);
        expect(runtime.preferences.depositVoiceAlerts, isFalse);
        await tester.tap(find.text('Preview announcement'));
        await tester.pumpAndSettle();
        expect(phone.previews, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        runtime.dispose();
      },
    );
  }
}
