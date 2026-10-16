import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'notification_runtime.dart';

class NotificationPermissionPanel extends StatelessWidget {
  const NotificationPermissionPanel({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: NotificationRuntime.instance,
    builder: (context, _) {
      final phone = NotificationRuntime.instance;
      final colors = DavoColors.of(context);
      if (!phone.supported) return const SizedBox.shrink();
      return Material(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    phone.allowed
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: colors.link,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      phone.allowed
                          ? 'Phone notifications are on'
                          : 'Phone notifications are off',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Get transaction and security updates outside the app. Your in-app inbox stays available either way.',
                style: TextStyle(fontSize: 12, height: 1.6, color: colors.body),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: !phone.initialized || phone.busy
                        ? null
                        : () async {
                            if (phone.allowed || phone.permissionRequested) {
                              await phone.openSettings();
                            } else {
                              await phone.enable();
                            }
                          },
                    child: Text(
                      phone.busy
                          ? 'Checking permission...'
                          : phone.allowed || phone.permissionRequested
                          ? 'Open phone settings'
                          : 'Enable notifications',
                    ),
                  ),
                  TextButton(
                    onPressed: !phone.allowed || phone.busy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final sent = await phone.sendTest();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    sent
                                        ? 'Test notification sent. Swipe down to see it.'
                                        : 'Notification tests are off in phone settings.',
                                  ),
                                ),
                              );
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not send the test notification. Try again.',
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('Send test notification'),
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Show transaction details',
                  style: TextStyle(fontSize: 12),
                ),
                subtitle: const Text(
                  'Include amounts in phone notifications. Lock-screen visibility also follows phone settings.',
                  style: TextStyle(fontSize: 11, height: 1.5),
                ),
                value: phone.preferences.showDetails,
                onChanged: phone.initialized
                    ? (value) {
                        phone.preferences.showDetails = value;
                        phone.saveSettings();
                      }
                    : null,
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.record_voice_over_outlined,
                    size: 21,
                    color: colors.link,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Deposit voice alert',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Announce received payments',
                  style: TextStyle(fontSize: 12),
                ),
                subtitle: const Text(
                  'Says ?Payment received in Davochain? after a completed deposit notification. No amounts or names.',
                  style: TextStyle(fontSize: 11, height: 1.5),
                ),
                value: phone.preferences.depositVoiceAlerts,
                onChanged: phone.initialized ? phone.setDepositVoice : null,
              ),
              Text(
                'Requires phone notifications and deposit alerts. Respects silent mode, Do Not Disturb and notification volume.',
                style: TextStyle(fontSize: 11, height: 1.5, color: colors.body),
              ),
              TextButton.icon(
                icon: const Icon(Icons.volume_up_outlined, size: 18),
                label: Text(
                  phone.voiceBusy ? 'Preparing voice?' : 'Test voice',
                ),
                onPressed:
                    !phone.initialized ||
                        phone.voiceBusy ||
                        !phone.channelAllowed(0)
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final played = await phone.testDepositVoice();
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              played
                                  ? 'Voice preview requested.'
                                  : 'Could not play. Check phone sound, deposit notifications and the installed English voice.',
                            ),
                          ),
                        );
                      },
              ),
              if (phone.error != null)
                Text(
                  phone.error!,
                  style: TextStyle(fontSize: 12, color: colors.danger),
                ),
            ],
          ),
        ),
      );
    },
  );
}

abstract final class NotificationInvitation {
  static bool _showing = false;
  static Future<void> maybeShow(BuildContext context) async {
    final phone = NotificationRuntime.instance;
    if (!phone.supported ||
        _showing ||
        !phone.initialized ||
        phone.allowed ||
        phone.invitationShown ||
        !context.mounted ||
        ModalRoute.of(context)?.isCurrent == false) {
      return;
    }
    _showing = true;
    try {
      await phone.rememberInvitation();
      if (!context.mounted || ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: DavoColors.of(context).surface,
        builder: (sheet) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 38,
                    color: DavoColors.of(sheet).link,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Stay informed',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Get deposit, transaction and security updates on your phone.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(sheet);
                    await phone.enable();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Enable notifications'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheet),
                  child: const Text('Not now'),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      _showing = false;
    }
  }
}
