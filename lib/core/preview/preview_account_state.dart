import 'package:flutter/foundation.dart';

/// Session-only UI preview state. This does not verify a real account.
class PreviewAccountState {
  PreviewAccountState._();
  static final setupComplete = ValueNotifier<bool>(false);
}
