import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/notifications/notification_inbox.dart';
import 'davo_action_icon.dart';

class DavoNotificationButton extends StatelessWidget {
  const DavoNotificationButton({super.key, required this.onTap, this.inbox});
  final VoidCallback onTap;
  final NotificationInbox? inbox;

  @override
  Widget build(BuildContext context) {
    final source = inbox ?? NotificationInbox.instance;
    return ListenableBuilder(
        listenable: source,
        builder: (context, _) {
          final count = source.unreadCount;
          return Semantics(
            label:
                count == 0 ? 'Notifications' : 'Notifications, $count unread',
            button: true,
            onTap: onTap,
            child: ExcludeSemantics(
                child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(children: [
                    Center(
                        child: DavoActionIcon(DavoActionGlyph.notifications,
                            color: DavoColors.of(context).link, size: 24)),
                    if (count > 0)
                      Positioned(
                          top: 4,
                          right: 3,
                          child: Container(
                            key: const ValueKey('notification-unread-badge'),
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: AppColors.notificationBadge,
                                shape: BoxShape.circle),
                            child: Text(count > 9 ? '9+' : '$count',
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          )),
                  ])),
            )),
          );
        });
  }
}
