import 'dart:async';
import 'device_notification_gateway.dart';
import 'notification_delivery_policy.dart';
import 'notification_inbox.dart';

/// Durable device projection. It observes accepted facts and never writes funds.
class NotificationDeliveryController {
  NotificationDeliveryController({
    required this.phone,
    required this.save,
    this.preferencesAllow,
    this.flushFacts,
    this.onError,
  });
  final DeviceNotificationGateway phone;
  final Future<void> Function(Map<String, Object?>) save;
  final bool Function(InboxNotification)? preferencesAllow;
  final Future<void> Function()? flushFacts;
  final void Function(Object)? onError;
  String? _account;
  int _generation = -1, _epoch = 0, _nextId = 1;
  Map<String, Map<String, Object?>> _entries = {};
  Future<void> _tail = Future.value();
  bool _valid(String account, int generation, int epoch) =>
      _account == account && _generation == generation && _epoch == epoch;
  Future<void> _serial(Future<void> Function() work) {
    final task = _tail.then((_) => work());
    _tail = task.catchError((Object error) {
      onError?.call(error);
    });
    return task;
  }

  Map<String, Object?> exportState() => {
    'version': 1,
    'accountId': _account,
    'nextId': _nextId,
    'entries': {for (final e in _entries.entries) e.key: Map.of(e.value)},
  };
  Future<void> _checkpoint() => save(exportState());
  Future<void> activate(
    String account,
    int generation, {
    Iterable<InboxNotification> baseline = const [],
    Map<String, Object?>? restored,
  }) {
    final changedAccount = _account != null && _account != account;
    final epoch = ++_epoch;
    _account = account;
    _generation = generation;
    return _serial(() async {
      if (changedAccount) await phone.cancelAll();
      if (!_valid(account, generation, epoch)) return;
      final raw = restored;
      if (raw != null && raw['version'] != 1) {
        throw const FormatException('Notification delivery version');
      }
      if (raw?['accountId'] != null && raw!['accountId'] != account) {
        throw const FormatException('Notification account mismatch');
      }
      _nextId = (raw?['nextId'] as int?) ?? 1;
      if (_nextId < 1 || _nextId >= 2147483000) {
        throw const FormatException('Notification ID range');
      }
      _entries = {
        for (final e in ((raw?['entries'] as Map?) ?? {}).entries)
          e.key as String: Map<String, Object?>.from(e.value as Map),
      };
      // Never replay old inbox/history on feature upgrade or a new login.
      for (final item in raw == null ? baseline : <InboxNotification>[]) {
        _entries.putIfAbsent(
          item.id,
          () => {'id': _nextId++, 'state': 'historical'},
        );
      }
      // An interrupted post may have already been dismissed. Do not repost it.
      for (final entry in _entries.values) {
        if (entry['state'] == 'posting') entry['state'] = 'suppressed';
      }
      await _checkpoint();
    });
  }

  Future<void> deliver(
    Iterable<InboxNotification> items, {
    required String account,
    required int generation,
    bool foreground = false,
    bool showDetails = false,
  }) {
    final epoch = _epoch;
    final snapshot = items.toList();
    return _serial(() async {
      if (!_valid(account, generation, epoch)) return;
      for (final item in snapshot.reversed) {
        if (!_valid(account, generation, epoch)) return;
        if (!item.id.startsWith('$account:') ||
            (_entries.containsKey(item.id) &&
                _entries[item.id]!['state'] != 'queued')) {
          continue;
        }
        final entry =
            _entries[item.id] ??
            <String, Object?>{'id': _nextId++, 'state': 'queued'};
        _entries[item.id] = entry;
        await flushFacts?.call();
        if (!_valid(account, generation, epoch)) return;
        final allowed =
            phoneEligible(item) &&
            (preferencesAllow?.call(item) ?? true) &&
            await phone.enabled(channel: notificationChannel(item));
        if (!_valid(account, generation, epoch)) return;
        if (!allowed) {
          entry['state'] = 'suppressed';
          await _checkpoint();
          continue;
        }
        entry['state'] = 'posting';
        await _checkpoint();
        if (!_valid(account, generation, epoch)) return;
        try {
          await phone.show(
            phonePresentation(
              item,
              id: entry['id'] as int,
              account: account,
              foreground: foreground,
              showDetails: showDetails,
            ),
          );
          if (!_valid(account, generation, epoch)) {
            await phone.cancel(entry['id'] as int);
            return;
          }
          entry['state'] = 'posted';
        } catch (error) {
          entry['state'] = 'failed';
          onError?.call(error);
        }
        await _checkpoint();
      }
    });
  }

  Future<void> acknowledge(String id) => _serial(() async {
    final entry = _entries[id];
    if (entry == null || entry['state'] == 'read') return;
    await phone.cancel(entry['id'] as int);
    entry['state'] = 'read';
    await _checkpoint();
  });
  Future<void> deactivate() {
    ++_epoch;
    _account = null;
    _generation = -1;
    return _serial(() => phone.cancelAll());
  }

  Future<void> flush() => _tail;
}
