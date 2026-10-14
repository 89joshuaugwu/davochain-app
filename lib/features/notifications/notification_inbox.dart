import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Immutable display record. Backend adapters must supply account-stable IDs.
@immutable
class InboxNotification {
  const InboxNotification(
      {required this.id,
      required this.title,
      required this.body,
      required this.time,
      required this.day,
      required this.category,
      this.isRead = false});
  final String id, title, body, time, day;
  final int category;
  final bool isRead;
  InboxNotification withRead(bool value) => InboxNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      day: day,
      category: category,
      isRead: value);
}

const previewNotifications = <InboxNotification>[
  InboxNotification(
      id: 'preview-deposit',
      title: 'Deposit Received',
      body:
          'Your monthly salary of \$4,250.00 has been received in your account.',
      time: '2m ago',
      day: 'TODAY',
      category: 1),
  InboxNotification(
      id: 'preview-login',
      title: 'New Login Detected',
      body:
          'A login attempt was made from a new device in Nigeria, Lagos. If this was not you, change your password and contact support.',
      time: '45m ago',
      day: 'TODAY',
      category: 2),
  InboxNotification(
      id: 'preview-transfer',
      title: 'Transfer Sent',
      body: 'You sent \$150.00 to Chukwu Vincent for Family Support.',
      time: '2hr ago',
      day: 'TODAY',
      category: 1),
  InboxNotification(
      id: 'preview-support',
      title: 'Support Ticket Updated',
      body:
          'Your inquiry regarding the international wire transfer has been updated. Open Customer Support to continue the conversation.',
      time: '1d ago',
      day: 'YESTERDAY',
      category: 0),
];

@immutable
class InboxPublicationToken {
  const InboxPublicationToken._(this.generation, this.revision);
  final int generation, revision;
}

/// One canonical observable inbox for the bell and notification center.
/// Publication tokens reject responses superseded by reads or account resets.
class NotificationInbox extends ChangeNotifier {
  NotificationInbox(
      {Iterable<InboxNotification> records = previewNotifications})
      : _snapshot = List.unmodifiable(records);
  static final instance = NotificationInbox();
  List<InboxNotification> _snapshot;
  int? _totalUnread;
  int _generation = 0, _revision = 0;
  List<InboxNotification> get snapshot => _snapshot;
  int get unreadCount =>
      _totalUnread ?? _snapshot.where((item) => !item.isRead).length;
  InboxPublicationToken capturePublicationToken() =>
      InboxPublicationToken._(_generation, _revision);

  bool publish(Iterable<InboxNotification> records,
      {required InboxPublicationToken token, int? unreadCount}) {
    if (token.generation != _generation || token.revision != _revision) {
      return false;
    }
    final next = List<InboxNotification>.unmodifiable(records);
    if (next.any((item) => item.id.isEmpty) ||
        next.map((item) => item.id).toSet().length != next.length ||
        (unreadCount != null &&
            unreadCount < next.where((item) => !item.isRead).length)) {
      throw ArgumentError(
          'Inbox needs unique IDs and a consistent unread total');
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
    _snapshot =
        List.unmodifiable(_snapshot.map((item) => item.withRead(false)));
    if (_totalUnread != null) _totalUnread = _totalUnread! + readCount;
    _changed();
  }

  void reset() {
    _generation++;
    _snapshot = List.unmodifiable(previewNotifications);
    _totalUnread = null;
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
