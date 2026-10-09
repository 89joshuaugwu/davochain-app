import 'package:flutter/foundation.dart';

/// Session-only demonstration settings; no credentials or biometric data stored.
class PreviewAuthState {
  PreviewAuthState._();
  static String? accountEmail;
  static final biometricsEnabled = ValueNotifier<bool>(false);
  static final unlocked = ValueNotifier<bool>(false);
}
