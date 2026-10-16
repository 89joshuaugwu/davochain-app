/// Secret-free accepted account changes. No screen or keypress produces events.
abstract final class NotificationAccountEvents {
  static void Function(String title, String detail)? onAccepted;
  static void accepted(String title, String detail) =>
      onAccepted?.call(title, detail);
}
