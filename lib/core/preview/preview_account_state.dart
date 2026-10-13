import 'package:flutter/foundation.dart';

/// Session-only UI preview state. This does not verify a real account.
class PreviewAccountState {
  PreviewAccountState._();
  static final setupComplete = ValueNotifier<bool>(false);
  static final notificationPreferences = List<bool>.filled(11, true);
  static final notificationChannels =
      List.generate(3, (_) => [true, false, false]);
  static final readNotifications = <String>{};
}
