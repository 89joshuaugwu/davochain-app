part of 'profile_settings_flow.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key, this.hasNotifications = true});
  final bool hasNotifications;
  const NotificationCenterScreen.empty({super.key}) : hasNotifications = false;

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  int tab = 0;
  static const labels = ['All', 'Transactions', 'Security', 'Rewards'];
  final inbox = PreviewAccountState.notificationInbox;

  @override
  void initState() {
    super.initState();
    inbox.addListener(_inboxChanged);
  }

  void _inboxChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    inbox.removeListener(_inboxChanged);
    super.dispose();
  }

  void _open(InboxNotification item) {
    inbox.markRead(item.id);
    final title = item.title, body = item.body, time = item.time;
    final category = item.category;
    _push(
        context,
        DavoNotificationDetailScreen(
          title: title,
          message: body,
          receivedAt: time,
          category: category,
          actionLabel: category == 2
              ? 'Secure your account'
              : category == 1
                  ? 'View transaction history'
                  : 'Open customer support',
          onAction: () => _push(
              context,
              category == 2
                  ? const ChangePasswordScreen()
                  : category == 1
                      ? const TransactionHistoryScreen()
                      : const CustomerSupportScreen()),
        ));
  }

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
      target: DavoRefreshTarget.notifications, builder: _buildNotifications);
  Widget _buildNotifications(BuildContext context) {
    final visible = widget.hasNotifications
        ? inbox.snapshot
            .where((item) => tab == 0 || item.category == tab)
            .toList()
        : <InboxNotification>[];
    return _Shell(
        title: 'Notification',
        scroll: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (var i = 0; i < labels.length; i++)
                  Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _NotificationFilterPill(
                          label: labels[i],
                          width: [53.0, 102.0, 75.0, 77.0][i],
                          selected: tab == i,
                          onTap: () => setState(() => tab = i))),
              ])),
          const SizedBox(height: 24),
          if (visible.isEmpty)
            Center(
                child: Column(children: [
              const SizedBox(height: 32),
              DavoEmptyBell(key: ValueKey(tab), asset: _notificationEmpty),
              const SizedBox(height: 24),
              Text(
                  tab == 3
                      ? 'No rewards notifications yet'
                      : 'No notifications yet',
                  textAlign: TextAlign.center,
                  style: _t20sb(context)),
              const SizedBox(height: 16),
              Text(
                  tab == 3
                      ? 'Your reward updates will appear here.'
                      : 'We will notify you about your orders and updates here.',
                  textAlign: TextAlign.center,
                  style: _t14(context)),
            ])),
          for (var i = 0; i < visible.length; i++) ...[
            if (i == 0 || visible[i].day != visible[i - 1].day)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(visible[i].day, style: _sectionLabel14(context))),
            Semantics(
                label: visible[i].isRead
                    ? 'Read notification'
                    : 'Unread notification',
                child: InkWell(
                    onTap: () => _open(visible[i]),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                  visible[i].category == 2
                                      ? Icons.shield_outlined
                                      : Icons.swap_horiz,
                                  size: 24,
                                  color: DavoColors.of(context).link),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(visible[i].title,
                                        style: visible[i].isRead
                                            ? _t14(context)
                                            : _t14b(context)),
                                    const SizedBox(height: 6),
                                    Text(visible[i].body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: _t12(context)),
                                    const SizedBox(height: 8),
                                    Text(visible[i].time, style: _t12(context)),
                                  ])),
                              if (!visible[i].isRead)
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle)),
                            ])))),
            Divider(height: 1, color: DavoColors.of(context).divider),
          ],
          const SizedBox(height: 24),
        ]));
  }
}

class EmptyNotificationScreen extends StatelessWidget {
  const EmptyNotificationScreen({super.key});
  @override
  Widget build(BuildContext context) => const NotificationCenterScreen.empty();
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Notification Settings',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 17),
            Text('Alert Preferences', style: _t16b(context)),
            const SizedBox(height: 24),
            _settingsAssetRow(
                context,
                '$_exactAssets/icon_transaction.png',
                'Transaction Alerts',
                '',
                () => _push(context, const NotificationChannelScreen(type: 0))),
            _settingsAssetRow(
                context,
                '$_exactAssets/icon_security.png',
                'Security Alerts',
                '',
                () => _push(context, const NotificationChannelScreen(type: 1))),
            _settingsAssetRow(
                context,
                '$_exactAssets/icon_campaign.png',
                'Marketing & News',
                '',
                () => _push(context, const NotificationChannelScreen(type: 2))),
          ],
        ),
      );
}

class NotificationChannelScreen extends StatefulWidget {
  const NotificationChannelScreen({super.key, required this.type});
  final int type;
  @override
  State<NotificationChannelScreen> createState() =>
      _NotificationChannelScreenState();
}

class _NotificationChannelScreenState extends State<NotificationChannelScreen> {
  List<bool> get channels =>
      PreviewAccountState.notificationChannels[widget.type];
  bool get push => channels[0];
  set push(bool value) => channels[0] = value;
  bool get email => channels[1];
  set email(bool value) => channels[1] = value;
  bool get sms => channels[2];
  set sms(bool value) => channels[2] = value;

  @override
  Widget build(BuildContext context) {
    final title = [
      'Transaction Alerts',
      'Security Alerts',
      'Marketing & News'
    ][widget.type];
    final pushSub = widget.type == 0
        ? 'Real-Time  Alerts'
        : widget.type == 1
            ? 'Login Alerts, Password Changes, New Device Sign-in'
            : 'Promotions, New Features, Newsletter';
    final emailSub = widget.type == 0
        ? 'Detailed Statements'
        : widget.type == 1
            ? 'Secondary Channel. Audit Trail, Detailed Logs'
            : 'Promotions, New Features, Newsletter';
    return _Shell(
      title: 'Notification Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 17),
          Text(title, style: _t16b(context)),
          const SizedBox(height: 26),
          _toggleRow(context, 'Push Notification', pushSub, push,
              (v) => setState(() => push = v)),
          _toggleRow(context, 'Email', emailSub, email,
              (v) => setState(() => email = v)),
          if (widget.type == 0)
            _toggleRow(context, 'SMS', 'Standard Rates Apply', sms,
                (v) => setState(() => sms = v)),
        ],
      ),
    );
  }
}
