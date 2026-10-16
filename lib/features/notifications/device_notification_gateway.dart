import 'dart:convert';

class NotificationTapIntent {
  const NotificationTapIntent(this.accountId, this.eventId);
  final String accountId, eventId;
  String encode() =>
      jsonEncode({'v': 1, 'account': accountId, 'event': eventId});
  static NotificationTapIntent? parse(String? raw) {
    try {
      final data = jsonDecode(raw ?? '') as Map;
      if (data['v'] != 1 ||
          data['account'] is! String ||
          data['event'] is! String ||
          (data['event'] as String).length > 512 ||
          (data['account'] as String).isEmpty) {
        return null;
      }
      return NotificationTapIntent(
        data['account'] as String,
        data['event'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

class DeviceNotificationRequest {
  const DeviceNotificationRequest({
    required this.id,
    required this.eventId,
    required this.accountId,
    required this.title,
    required this.body,
    required this.channel,
    this.silent = false,
    this.occurredAt,
  });
  final int id;
  final String eventId, accountId, title, body, channel;
  final bool silent;
  final DateTime? occurredAt;
  String get payload => NotificationTapIntent(accountId, eventId).encode();
}

abstract class DeviceNotificationGateway {
  bool get supported => true;
  Future<void> initialize(void Function(NotificationTapIntent) onTap) async {}
  Future<bool> enabled({String? channel}) async => false;
  Future<bool> requestPermission() async => false;
  Future<void> openSettings() async {}
  Future<void> show(DeviceNotificationRequest request) async {}
  Future<Set<int>> activeIds() async => {};
  Future<void> cancel(int id) async {}
  Future<void> cancelAll() async {}
  Future<bool> speakDeposit() async => false;
  Future<void> stopSpeaking() async {}
  Future<NotificationTapIntent?> launchIntent() async => null;
}
