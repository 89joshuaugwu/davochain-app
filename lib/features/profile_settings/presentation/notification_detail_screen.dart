import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davo_refresh_region.dart';

class DavoNotificationDetailScreen extends StatelessWidget {
  const DavoNotificationDetailScreen(
      {super.key,
      required this.title,
      required this.message,
      required this.receivedAt,
      required this.category,
      required this.actionLabel,
      required this.onAction});
  final String title, message, receivedAt, actionLabel;
  final int category;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.notifications,
      builder: (context) {
        final colors = DavoColors.of(context);
        final icon = category == 2
            ? Icons.shield_outlined
            : category == 1
                ? Icons.swap_horiz_rounded
                : Icons.support_agent_rounded;
        final label = category == 2
            ? 'Account security'
            : category == 1
                ? 'Transaction update'
                : 'Support update';
        return Scaffold(
          backgroundColor: colors.canvas,
          appBar: AppBar(
              centerTitle: true,
              title: const Text('Notification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
          body: SafeArea(
              top: false,
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  children: [
                    Row(children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(18)),
                          child: Icon(icon, color: colors.link, size: 28)),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: colors.surface,
                              border: Border.all(color: colors.border),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.done_rounded,
                                size: 14, color: colors.bodyMuted),
                            const SizedBox(width: 4),
                            Text('Read',
                                style: TextStyle(
                                    fontSize: 11, color: colors.bodyMuted)),
                          ])),
                    ]),
                    const SizedBox(height: 24),
                    Text(label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.link)),
                    const SizedBox(height: 8),
                    Text(title,
                        style: TextStyle(
                            fontSize: 24,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            color: colors.ink)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.schedule_rounded,
                          size: 15, color: colors.bodyMuted),
                      const SizedBox(width: 6),
                      Text(receivedAt,
                          style:
                              TextStyle(fontSize: 12, color: colors.bodyMuted))
                    ]),
                    const SizedBox(height: 28),
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: colors.surface,
                            border: Border.all(color: colors.border),
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Message',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: colors.bodyMuted)),
                              const SizedBox(height: 10),
                              Text(message,
                                  style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: colors.body)),
                            ])),
                  ])),
          bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text(actionLabel, textAlign: TextAlign.center)))),
        );
      });
}
