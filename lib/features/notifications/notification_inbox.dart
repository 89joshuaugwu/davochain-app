import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Immutable display record. Backend adapters must supply account-stable IDs.
enum NotificationAction {
  support,
  transactions,
  receipt,
  security,
  basicVerification,
  advancedVerification,
}

enum NotificationKind {
  general,
  welcome,
  deposit,
  withdrawal,
  crypto,
  giftCard,
  verification,
  security,
}

/// Immutable account-local inbox facts; IDs are independent of display copy.
@immutable
class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.day,
    required this.category,
    this.isRead = false,
    this.createdAt,
    this.kind = NotificationKind.general,
    this.action,
    this.receiptId,
    this.status,
    this.amount,
    this.asset,
    this.facts = const {},
  });
  final String id, title, body, time, day;
  final int category;
  final bool isRead;
  final DateTime? createdAt;
  final NotificationKind kind;
  final NotificationAction? action;
  final String? receiptId, status, amount, asset;
  final Map<String, String> facts;
  InboxNotification withRead(bool value) => InboxNotification(
    id: id,
    title: title,
    body: body,
    time: time,
    day: day,
    category: category,
    isRead: value,
    createdAt: createdAt,
    kind: kind,
    action: action,
    receiptId: receiptId,
    status: status,
    amount: amount,
    asset: asset,
    facts: facts,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'time': time,
    'day': day,
    'category': category,
    'isRead': isRead,
    'createdAt': createdAt?.toIso8601String(),
    'kind': kind.name,
    'action': action?.name,
    'receiptId': receiptId,
    'status': status,
    'amount': amount,
    'asset': asset,
    'facts': facts,
  };
  factory InboxNotification.fromJson(Map<String, Object?> json) =>
      InboxNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        time: json['time'] as String? ?? '',
        day: json['day'] as String? ?? '',
        category: json['category'] as int,
        isRead: json['isRead'] == true,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        kind:
            NotificationKind.values
                .where((v) => v.name == json['kind'])
                .firstOrNull ??
            NotificationKind.general,
        action: NotificationAction.values
            .where((v) => v.name == json['action'])
            .firstOrNull,
        receiptId: json['receiptId'] as String?,
        status: json['status'] as String?,
        amount: json['amount'] as String?,
        asset: json['asset'] as String?,
        facts: Map<String, String>.from(json['facts'] as Map? ?? const {}),
      );
}

String notificationDay(InboxNotification item, [DateTime? now]) {
  if (item.createdAt == null) return item.day;
  final date = item.createdAt!.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  final difference = DateTime(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return '${date.day}/${date.month}/${date.year}';
}

String notificationTime(InboxNotification item, [DateTime? now]) {
  if (item.createdAt == null) return item.time;
  final duration = (now ?? DateTime.now()).difference(item.createdAt!);
  if (duration.inMinutes < 1) return 'Just now';
  if (duration.inHours < 1) return '${duration.inMinutes}m ago';
  if (duration.inDays < 1) return '${duration.inHours}h ago';
  return '${item.createdAt!.toLocal().hour.toString().padLeft(2, '0')}:${item.createdAt!.toLocal().minute.toString().padLeft(2, '0')}';
}

const previewNotifications = <InboxNotification>[
  InboxNotification(
    id: 'preview-deposit',
    title: 'Deposit Received',
    body:
        'Your monthly salary of \$4,250.00 has been received in your account.',
    time: '2m ago',
    day: 'TODAY',
    category: 1,
  ),
  InboxNotification(
    id: 'preview-login',
    title: 'New Login Detected',
    body:
        'A login attempt was made from a new device in Nigeria, Lagos. If this was not you, change your password and contact support.',
    time: '45m ago',
    day: 'TODAY',
    category: 2,
  ),
  InboxNotification(
    id: 'preview-transfer',
    title: 'Transfer Sent',
    body: 'You sent \$150.00 to Chukwu Vincent for Family Support.',
    time: '2hr ago',
    day: 'TODAY',
    category: 1,
  ),
  InboxNotification(
    id: 'preview-support',
    title: 'Support Ticket Updated',
    body:
        'Your inquiry regarding the international wire transfer has been updated. Open Customer Support to continue the conversation.',
    time: '1d ago',
    day: 'YESTERDAY',
    category: 0,
  ),
];

@immutable
class InboxPublicationToken {
  const InboxPublicationToken._(this.generation, this.revision);
  final int generation, revision;
}

/// One canonical observable inbox for the bell and notification center.
/// Publication tokens reject responses superseded by reads or account resets.
class NotificationInbox extends ChangeNotifier {
  NotificationInbox({
    Iterable<InboxNotification> records = previewNotifications,
  }) : _snapshot = List.unmodifiable(records),
       _initialRecords = List.unmodifiable(records);
  static final instance = NotificationInbox(records: const []);
  List<InboxNotification> _snapshot;
  final List<InboxNotification> _initialRecords;
  int? _totalUnread;
  int _generation = 0, _revision = 0;
  List<InboxNotification> get snapshot => _snapshot;
  int get unreadCount =>
      _totalUnread ?? _snapshot.where((item) => !item.isRead).length;
  InboxPublicationToken capturePublicationToken() =>
      InboxPublicationToken._(_generation, _revision);

  bool publish(
    Iterable<InboxNotification> records, {
    required InboxPublicationToken token,
    int? unreadCount,
  }) {
    if (token.generation != _generation || token.revision != _revision) {
      return false;
    }
    final next = List<InboxNotification>.unmodifiable(records);
    if (next.any((item) => item.id.isEmpty) ||
        next.map((item) => item.id).toSet().length != next.length ||
        (unreadCount != null &&
            unreadCount < next.where((item) => !item.isRead).length)) {
      throw ArgumentError(
        'Inbox needs unique IDs and a consistent unread total',
      );
    }
    _snapshot = next;
    _totalUnread = unreadCount;
    _changed();
    return true;
  }

  bool markRead(String id) => _setRead(id, true);
  bool markUnread(String id) => _setRead(id, false);
  bool _setRead(String id, bool value) {
    final index = _snapshot.indexWhere((item) => item.id == id);
    if (index < 0 || _snapshot[index].isRead == value) return false;
    final next = _snapshot.toList();
    next[index] = next[index].withRead(value);
    _snapshot = List.unmodifiable(next);
    if (_totalUnread != null) _totalUnread = _totalUnread! + (value ? -1 : 1);
    _changed();
    return true;
  }

  void clearRead() {
    if (!_snapshot.any((item) => item.isRead)) return;
    final readCount = _snapshot.where((item) => item.isRead).length;
    _snapshot = List.unmodifiable(
      _snapshot.map((item) => item.withRead(false)),
    );
    if (_totalUnread != null) _totalUnread = _totalUnread! + readCount;
    _changed();
  }

  void reset({Iterable<InboxNotification>? records}) {
    _generation++;
    _snapshot = List.unmodifiable(records ?? _initialRecords);
    _totalUnread = null;
    _changed();
  }

  /// Idempotent event insertion never clears an existing read decision.
  bool insert(InboxNotification item) {
    if (_snapshot.any((existing) => existing.id == item.id)) return false;
    _snapshot = List.unmodifiable([item, ..._snapshot]);
    if (_totalUnread != null && !item.isRead) _totalUnread = _totalUnread! + 1;
    _changed();
    return true;
  }

  /// Checkpoint observers also persist consumed, preference-suppressed events.
  void checkpointChanged() => _changed();

  Map<String, Object?> exportState() => {
    'version': 1,
    'records': _snapshot.map((item) => item.toJson()).toList(),
    'unreadCount': _totalUnread,
  };

  void restoreState(Map<String, Object?> data) {
    if (data['version'] != null && data['version'] != 1) {
      throw ArgumentError('Unsupported inbox checkpoint');
    }
    final unread = data['unreadCount'] as int?;
    final records = (data['records'] as List? ?? const [])
        .map(
          (value) => InboxNotification.fromJson(
            Map<String, Object?>.from(value as Map),
          ),
        )
        .toList();
    if (records.any((r) => r.id.isEmpty) ||
        records.map((r) => r.id).toSet().length != records.length) {
      throw ArgumentError('Inbox needs unique IDs');
    }
    _generation++;
    _snapshot = List.unmodifiable(records);
    _totalUnread =
        unread != null && unread >= records.where((r) => !r.isRead).length
        ? unread
        : null;
    _changed();
  }

  void _changed() {
    _revision++;
    notifyListeners();
  }
}

/// Compatibility view for existing preview callers. Titles are never storage IDs.
class NotificationReadTitles extends SetBase<String> {
  NotificationReadTitles(this.inbox);
  final NotificationInbox inbox;
  @override
  Iterator<String> get iterator => inbox.snapshot
      .where((item) => item.isRead)
      .map((item) => item.title)
      .toSet()
      .iterator;
  @override
  int get length => _titles.length;
  Set<String> get _titles => inbox.snapshot
      .where((item) => item.isRead)
      .map((item) => item.title)
      .toSet();
  @override
  bool contains(Object? element) =>
      inbox.snapshot.any((item) => item.title == element && item.isRead);
  @override
  String? lookup(Object? element) =>
      contains(element) ? element as String : null;
  @override
  bool add(String value) {
    var changed = false;
    for (final item in inbox.snapshot.where((item) => item.title == value)) {
      changed = inbox.markRead(item.id) || changed;
    }
    return changed;
  }

  @override
  bool remove(Object? value) {
    var changed = false;
    for (final item in inbox.snapshot.where((item) => item.title == value)) {
      changed = inbox.markUnread(item.id) || changed;
    }
    return changed;
  }

  @override
  void clear() => inbox.clearRead();
  @override
  Set<String> toSet() => _titles;
}
