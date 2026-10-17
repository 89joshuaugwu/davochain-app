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
    _push(
      context,
      DavoNotificationDetailScreen(
        title: item.title,
        message: item.body,
        receivedAt: notificationTime(item),
        category: item.category,
        notification: item,
        actionLabel: notificationActionLabel(item),
        onAction: () => _push(context, notificationDestination(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
    target: DavoRefreshTarget.notifications,
    builder: _buildNotifications,
  );
  Widget _buildNotifications(BuildContext context) {
    final visible = widget.hasNotifications
        ? inbox.snapshot
              .where((item) => tab == 0 || item.category == tab)
              .toList()
        : <InboxNotification>[];
    final colors = DavoColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        centerTitle: true,
        title: Text('Notifications', style: _navSora20(context)),
        actions: [
          IconButton(
            tooltip: 'Notification settings',
            onPressed: () => _push(context, const NotificationSettingsScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Notification actions',
            onSelected: (action) async {
              if (action == 'read') {
                NotificationRuntime.instance.markAllInboxRead();
                return;
              }
              final generation = inbox.generation;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialog) => AlertDialog(
                  title: const Text('Clear notifications?'),
                  content: const Text(
                    'This removes all messages from your inbox. Your transaction records will remain available.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Clear notifications'),
                    ),
                  ],
                ),
              );
              if (!mounted ||
                  confirmed != true ||
                  generation != inbox.generation) {
                return;
              }
              NotificationRuntime.instance.clearInbox();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'read',
                enabled: widget.hasNotifications && inbox.unreadCount > 0,
                child: const Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 12),
                    Flexible(child: Text('Mark all as read')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                enabled: widget.hasNotifications && inbox.snapshot.isNotEmpty,
                child: const Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 12),
                    Flexible(child: Text('Clear notifications')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Semantics(
                        label: '${labels[i]} notifications',
                        button: true,
                        selected: tab == i,
                        excludeSemantics: true,
                        onTap: () => setState(() => tab = i),
                        child: ChoiceChip(
                          label: Text(labels[i]),
                          selected: tab == i,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: colors.offWhite,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: tab == i ? Colors.white : colors.body,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          onSelected: (_) => setState(() => tab = i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    DavoEmptyBell(
                      key: ValueKey(tab),
                      asset: _notificationEmpty,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      tab == 3
                          ? 'No rewards notifications yet'
                          : 'You are all caught up',
                      textAlign: TextAlign.center,
                      style: _t20sb(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tab == 3
                          ? 'Your reward updates will appear here.'
                          : tab == 1
                          ? 'Your transaction updates will appear here.'
                          : tab == 2
                          ? 'Your account security updates will appear here.'
                          : 'Your account and transaction updates will appear here.',
                      textAlign: TextAlign.center,
                      style: _t14(context),
                    ),
                  ],
                ),
              ),
            for (var i = 0; i < visible.length; i++) ...[
              if (i == 0 ||
                  notificationDay(visible[i]) !=
                      notificationDay(visible[i - 1]))
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Text(
                    notificationDay(visible[i]),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.bodyMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Semantics(
                label: visible[i].isRead
                    ? 'Read notification'
                    : 'Unread notification',
                button: true,
                child: Material(
                  color: colors.surface,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _open(visible[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NotificationLeading(item: visible[i]),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        visible[i].title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: colors.ink,
                                          fontWeight: visible[i].isRead
                                              ? FontWeight.w500
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (!visible[i].isRead)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          top: 7,
                                        ),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  visible[i].body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.6,
                                    color: colors.bodyMuted,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  notificationTime(visible[i]),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.bodyMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: colors.divider),
            ],
          ],
        ),
      ),
    );
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
    scroll: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 17),
        const NotificationPermissionPanel(),
        const SizedBox(height: 24),
        Text('Alert Preferences', style: _t16b(context)),
        const SizedBox(height: 24),
        _settingsAssetRow(
          context,
          '$_exactAssets/icon_transaction.png',
          'Transaction Alerts',
          '',
          () => _push(context, const NotificationChannelScreen(type: 0)),
        ),
        _settingsAssetRow(
          context,
          '$_exactAssets/icon_security.png',
          'Security Alerts',
          '',
          () => _push(context, const NotificationChannelScreen(type: 1)),
        ),
        _settingsAssetRow(
          context,
          '$_exactAssets/icon_campaign.png',
          'Marketing & News',
          '',
          () => _push(context, const NotificationChannelScreen(type: 2)),
        ),
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
  @override
  void initState() {
    super.initState();
    NotificationRuntime.instance.addListener(_phoneChanged);
  }

  void _phoneChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    NotificationRuntime.instance.removeListener(_phoneChanged);
    super.dispose();
  }

  List<bool> get channels =>
      PreviewAccountState.notificationChannels[widget.type];
  bool get push =>
      channels[0] &&
      (!NotificationRuntime.instance.initialized ||
          NotificationRuntime.instance.channelAllowed(widget.type));
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
      'Marketing & News',
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
          const Text(
            'Email and SMS delivery are not available yet.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          _toggleRow(context, 'Phone notifications', pushSub, push, (v) async {
            if (v &&
                NotificationRuntime.instance.initialized &&
                !NotificationRuntime.instance.channelAllowed(widget.type)) {
              if (NotificationRuntime.instance.allowed ||
                  NotificationRuntime.instance.permissionRequested) {
                await NotificationRuntime.instance.openSettings();
              } else {
                await NotificationRuntime.instance.enable();
              }
            }
            if (!mounted) return;
            setState(
              () => push =
                  v &&
                  (!NotificationRuntime.instance.initialized ||
                      NotificationRuntime.instance.allowed),
            );
            NotificationRuntime.instance.saveSettings();
          }),
          _toggleRow(context, 'Email', emailSub, email, (v) {
            setState(() => email = v);
            NotificationRuntime.instance.saveSettings();
          }),
          if (widget.type == 0)
            _toggleRow(context, 'SMS', 'Standard Rates Apply', sms, (v) {
              setState(() => sms = v);
              NotificationRuntime.instance.saveSettings();
            }),
        ],
      ),
    );
  }
}
