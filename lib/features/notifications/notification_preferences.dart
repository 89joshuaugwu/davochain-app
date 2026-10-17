import 'deposit_voice.dart';
import '../../core/preview/preview_account_state.dart';
import 'notification_inbox.dart';

int notificationTopic(InboxNotification item) {
  if (item.kind == NotificationKind.security) return 6;
  if (item.kind == NotificationKind.verification) return 6;
  final type = (item.facts['Transaction'] ?? '').toLowerCase();
  if (item.kind == NotificationKind.giftCard) return 5;
  if (item.kind == NotificationKind.deposit) return 3;
  if (item.kind == NotificationKind.withdrawal) return 4;
  if (type.contains('sell') || type.contains('sale')) return 1;
  if (type.contains('swap') || type.contains('conversion')) return 2;
  return item.category == 1 ? 0 : 9;
}

class NotificationPreferences {
  bool showDetails = false;
  bool depositVoiceAlerts = false;
  String? depositVoiceId;
  DepositVoiceStyle depositVoiceStyle = DepositVoiceStyle.natural;
  bool allows(InboxNotification item) {
    final category = item.category == 1
        ? 0
        : item.category == 2
        ? 1
        : 2;
    return PreviewAccountState.notificationPreferences[notificationTopic(
          item,
        )] &&
        PreviewAccountState.notificationChannels[category][0];
  }

  Map<String, Object?> exportState() => {
    'version': 1,
    'details': showDetails,
    'depositVoice': depositVoiceAlerts,
    'depositVoiceId': depositVoiceId,
    'depositVoiceStyle': depositVoiceStyle.name,
    'topics': [...PreviewAccountState.notificationPreferences],
    'channels': PreviewAccountState.notificationChannels
        .map((c) => [...c])
        .toList(),
  };
  void restore(Map<String, Object?>? raw) {
    showDetails = raw?['details'] == true;
    depositVoiceAlerts = raw?['depositVoice'] == true;
    final voiceId = raw?['depositVoiceId'];
    depositVoiceId =
        voiceId is String && voiceId.isNotEmpty && voiceId.length <= 256
        ? voiceId
        : null;
    depositVoiceStyle = DepositVoiceStyle.parse(raw?['depositVoiceStyle']);
    final topics = raw?['topics'];
    final channels = raw?['channels'];
    for (var i = 0; i < 11; i++) {
      PreviewAccountState.notificationPreferences[i] =
          topics is List && topics.length == 11 && topics[i] is bool
          ? topics[i] as bool
          : i < 8;
    }
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        PreviewAccountState.notificationChannels[i][j] =
            channels is List &&
                channels.length == 3 &&
                channels[i] is List &&
                (channels[i] as List).length == 3 &&
                channels[i][j] is bool
            ? channels[i][j] as bool
            : j == 0 && i < 2;
      }
    }
  }
}
