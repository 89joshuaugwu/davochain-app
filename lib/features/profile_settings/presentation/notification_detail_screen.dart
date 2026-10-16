import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davo_refresh_region.dart';
import '../../../shared/receipts/receipt_activity.dart';
import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/receipts/transaction_record_details_screen.dart';
import '../../notifications/notification_inbox.dart';
import 'profile_settings_flow.dart'
    show ChangePasswordScreen, CustomerSupportScreen;
import '../../transactions/presentation/transaction_history_screen.dart';
import 'verification/verification_overview_screen.dart';
import 'verification/verification_state.dart';
import 'verification/advanced_verification_flow.dart';

String notificationActionLabel(InboxNotification item) => switch (item.action) {
  NotificationAction.basicVerification =>
    item.kind == NotificationKind.welcome
        ? 'Get started'
        : 'View verification status',
  NotificationAction.advancedVerification =>
    'Continue with Advanced verification',
  NotificationAction.receipt => 'View transaction',
  NotificationAction.security => 'Secure your account',
  NotificationAction.transactions => 'View transaction history',
  NotificationAction.support => 'Open customer support',
  null =>
    item.category == 2
        ? 'Secure your account'
        : item.category == 1
        ? 'View transaction history'
        : 'Open customer support',
};

Widget notificationDestination(InboxNotification item) {
  switch (item.action) {
    case NotificationAction.basicVerification:
      return item.kind == NotificationKind.welcome &&
              !VerificationSession.instance.basicSubmitted
          ? const BasicVerificationIntroScreen()
          : const VerificationOverviewScreen();
    case NotificationAction.advancedVerification:
      return VerificationSession.instance.canStartAdvanced
          ? const AdvancedVerificationFlowScreen()
          : const VerificationOverviewScreen();
    case NotificationAction.receipt:
      final record = ReceiptActivity.records.value
          .where((r) => r.id == item.receiptId)
          .firstOrNull;
      return record == null
          ? const TransactionHistoryScreen()
          : TransactionRecordDetailsScreen(record: record);
    case NotificationAction.security:
      return const ChangePasswordScreen();
    case NotificationAction.transactions:
      return const TransactionHistoryScreen();
    case NotificationAction.support:
      return const CustomerSupportScreen();
    case null:
      return item.category == 2
          ? const ChangePasswordScreen()
          : item.category == 1
          ? const TransactionHistoryScreen()
          : const CustomerSupportScreen();
  }
}

/// Shared, restrained icon treatment for inbox rows and their detail view.
class NotificationLeading extends StatelessWidget {
  const NotificationLeading({super.key, required this.item, this.size = 44});
  final InboxNotification item;
  final double size;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final asset = ReceiptAsset.values
        .where((a) => a.name == item.asset)
        .firstOrNull;
    final icon = switch (item.kind) {
      NotificationKind.welcome => Icons.waving_hand_outlined,
      NotificationKind.deposit => Icons.south_west_rounded,
      NotificationKind.withdrawal => Icons.north_east_rounded,
      NotificationKind.giftCard => Icons.card_giftcard_outlined,
      NotificationKind.verification => Icons.verified_user_outlined,
      NotificationKind.security => Icons.shield_outlined,
      _ =>
        item.category == 2
            ? Icons.shield_outlined
            : item.category == 1
            ? Icons.swap_horiz_rounded
            : Icons.notifications_none_rounded,
    };
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * .25),
        decoration: BoxDecoration(
          color: colors.primarySoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: asset?.svgPath != null
            ? SvgPicture.asset(asset!.svgPath!, fit: BoxFit.contain)
            : Icon(icon, color: colors.link, size: size * .5),
      ),
    );
  }
}

class DavoNotificationDetailScreen extends StatelessWidget {
  const DavoNotificationDetailScreen({
    super.key,
    required this.title,
    required this.message,
    required this.receivedAt,
    required this.category,
    required this.actionLabel,
    required this.onAction,
    this.notification,
  });
  final String title, message, receivedAt, actionLabel;
  final int category;
  final VoidCallback onAction;
  final InboxNotification? notification;
  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
    target: DavoRefreshTarget.notifications,
    builder: (context) {
      final colors = DavoColors.of(context);
      final item =
          notification ??
          InboxNotification(
            id: '',
            title: title,
            body: message,
            time: receivedAt,
            day: '',
            category: category,
          );
      final facts = <String, String>{
        if (item.status != null) 'Status': item.status!,
        ...item.facts,
        'Received': item.createdAt == null
            ? receivedAt
            : formatReceiptDate(item.createdAt!.toLocal()),
      };
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          title: const Text(
            'Notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  NotificationLeading(item: item, size: 56),
                  const Spacer(),
                  Icon(Icons.done_rounded, size: 16, color: colors.bodyMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Read',
                    style: TextStyle(fontSize: 12, color: colors.bodyMuted),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: colors.body,
                ),
              ),
              if (item.amount != null) ...[
                const SizedBox(height: 28),
                Text(
                  item.amount!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.offWhite,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    for (final entry in facts.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final label = Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: colors.bodyMuted,
                              ),
                            );
                            final value = SelectableText(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: colors.ink,
                              ),
                            );
                            if (MediaQuery.textScalerOf(context).scale(1) >
                                1.4) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label,
                                  const SizedBox(height: 6),
                                  value,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: label),
                                const SizedBox(width: 16),
                                Expanded(flex: 3, child: value),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (item.kind == NotificationKind.welcome) ...[
                const SizedBox(height: 24),
                Text(
                  'A good place to begin',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your profile details, choose your verification method and keep your account information up to date.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.65,
                    color: colors.body,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 17,
                  ),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(actionLabel, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      );
    },
  );
}
