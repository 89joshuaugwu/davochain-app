import 'package:flutter/material.dart';
import '../../core/preview/preview_auth_state.dart';
import '../../core/navigation/app_page_route.dart';
import '../profile_settings/presentation/notification_detail_screen.dart';
import '../profile_settings/presentation/profile_settings_flow.dart';
import 'notification_inbox.dart';
import 'notification_runtime.dart';

final notificationNavigatorKey = GlobalKey<NavigatorState>();

/// Cold and warm notification taps share the normal restore/unlock gate.
class NotificationTapHost extends StatefulWidget {
  const NotificationTapHost({super.key, required this.child, this.runtime});
  final Widget child;
  final NotificationRuntime? runtime;
  @override
  State<NotificationTapHost> createState() => _TapHostState();
}

class _TapHostState extends State<NotificationTapHost> {
  bool _scheduled = false;
  late final phone = widget.runtime ?? NotificationRuntime.instance;
  @override
  void initState() {
    super.initState();
    phone.pendingTap.addListener(_changed);
    PreviewAuthState.unlocked.addListener(_changed);
    _changed();
  }

  void _changed() {
    if (_scheduled || phone.pendingTap.value == null) return;
    _scheduled = true;
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final intent = phone.pendingTap.value;
      if (intent == null) return;
      if (!phone.validTap(intent)) {
        phone.pendingTap.value = null;
        return;
      }
      if (!PreviewAuthState.unlocked.value) return;
      final navigator = notificationNavigatorKey.currentState;
      if (navigator == null) return;
      phone.pendingTap.value = null;
      if (intent.eventId == 'diagnostic') {
        navigator.push(
          AppPageRoute<void>(
            builder: (_) => const NotificationSettingsScreen(),
          ),
        );
        return;
      }
      final inbox = NotificationInbox.instance;
      final item = inbox.snapshot
          .where((n) => n.id == intent.eventId)
          .firstOrNull;
      if (item == null) return;
      inbox.markRead(item.id);
      phone.acknowledgeSafely(item.id);
      if (item.action == NotificationAction.receipt) {
        navigator.push(
          AppPageRoute<void>(builder: (_) => notificationDestination(item)),
        );
        return;
      }
      navigator.push(
        AppPageRoute<void>(
          builder: (_) => DavoNotificationDetailScreen(
            title: item.title,
            message: item.body,
            receivedAt: notificationTime(item),
            category: item.category,
            notification: item,
            actionLabel: notificationActionLabel(item),
            onAction: () => navigator.push(
              AppPageRoute<void>(builder: (_) => notificationDestination(item)),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    phone.pendingTap.removeListener(_changed);
    PreviewAuthState.unlocked.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
