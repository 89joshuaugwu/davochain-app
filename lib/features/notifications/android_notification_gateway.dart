import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'device_notification_gateway.dart';

class AndroidNotificationGateway extends DeviceNotificationGateway {
  @override
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? get android =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.android
      ? null
      : plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
  static const channels = <String, (String, Importance)>{
    'davo_transactions_v1': ('Transactions', Importance.defaultImportance),
    'davo_security_v1': ('Account security', Importance.high),
    'davo_account_v1': ('Account updates', Importance.defaultImportance),
    'davo_support_v1': ('Support replies', Importance.defaultImportance),
    'davo_updates_v1': ('News and rewards', Importance.low),
    'davo_diagnostics_v1': ('Notification tests', Importance.defaultImportance),
  };
  @override
  Future<void> initialize(void Function(NotificationTapIntent) onTap) async {
    if (android == null) return;
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_davo_notification'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final intent = NotificationTapIntent.parse(response.payload);
        if (intent != null) onTap(intent);
      },
    );
    for (final e in channels.entries) {
      await android!.createNotificationChannel(
        AndroidNotificationChannel(
          e.key,
          e.value.$1,
          importance: e.value.$2,
          playSound: e.value.$2 != Importance.low,
        ),
      );
    }
  }

  @override
  Future<bool> enabled({String? channel}) async {
    if (android == null || await android!.areNotificationsEnabled() != true) {
      return false;
    }
    if (channel != null) {
      final list = await android!.getNotificationChannels();
      final found = list?.where((c) => c.id == channel).firstOrNull;
      if (found?.importance == Importance.none) return false;
    }
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    if (android == null) return false;
    await android!.requestNotificationsPermission();
    return enabled();
  }

  @override
  Future<void> openSettings() async {
    await android?.openAppNotificationSettings();
  }

  @override
  Future<NotificationTapIntent?> launchIntent() async {
    if (android == null) return null;
    final launch = await plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? NotificationTapIntent.parse(launch?.notificationResponse?.payload)
        : null;
  }

  @override
  Future<void> show(DeviceNotificationRequest request) async {
    if (android == null) return;
    final channel = channels[request.channel]!;
    await plugin.show(
      id: request.id,
      title: request.title,
      body: request.body,
      payload: request.payload,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          request.channel,
          channel.$1,
          importance: channel.$2,
          icon: 'ic_davo_notification',
          color: const Color(0xFF135CF7),
          visibility: NotificationVisibility.private,
          priority: channel.$2 == Importance.high
              ? Priority.high
              : Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(request.body),
          silent: request.silent,
          onlyAlertOnce: true,
          autoCancel: true,
          groupKey: '${request.accountId}:${request.channel}',
          when: request.occurredAt?.millisecondsSinceEpoch,
          category: request.channel == 'davo_security_v1'
              ? AndroidNotificationCategory.status
              : AndroidNotificationCategory.event,
        ),
      ),
    );
  }

  @override
  Future<Set<int>> activeIds() async => android == null
      ? {}
      : (await plugin.getActiveNotifications())
            .map((n) => n.id)
            .whereType<int>()
            .toSet();
  @override
  Future<void> cancel(int id) async {
    if (android != null) await plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    if (android != null) await plugin.cancelAll();
  }

  static const _voice = MethodChannel('davochain/deposit_voice');
  @override
  Future<bool> speakDeposit() async {
    if (!supported) return false;
    try {
      return await _voice.invokeMethod<bool>('speak') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stopSpeaking() async {
    if (!supported) return;
    try {
      await _voice.invokeMethod<void>('stop');
    } catch (_) {
      /* Optional native engine. */
    }
  }
}
