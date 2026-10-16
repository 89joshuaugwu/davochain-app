import 'dart:async';
import '../notifications/notification_events.dart';
import '../notifications/notification_inbox.dart';
import '../../core/preview/local_preview_profile.dart';
import '../../shared/receipts/transaction_repository.dart';
import 'local_ledger_store.dart';

/// SQLite stores account facts, never passwords, PINs or verification media.
class LocalAccountPersistence {
  LocalAccountPersistence(
    this.store,
    this.repository,
    this.profile, {
    this.readAccount,
  });
  final Future<Map<String, Object?>?> Function(String)? readAccount;
  static LocalAccountPersistence? instance;
  final LocalLedgerStore store;
  final LocalTransactionRepository repository;
  final LocalPreviewProfile profile;
  bool _suspended = false, _queued = false, _closed = false;
  Future<void> _pending = Future.value();
  Object? lastError;
  int _loginEpoch = 0;
  Future<void> initialize() async {
    repository.exportCheckpoint = _export;
    repository.checkpoint = _write;
    final active = await store.metadata('active-account');
    if (active != null && active.isNotEmpty) await _restore(active);
    repository.ledger.addListener(_changed);
    profile.addListener(_changed);
    NotificationInbox.instance.addListener(_changed);
    profile.beforeSignOut = deactivate;
  }

  Map<String, Object?> _export() => {
    ...repository.exportState(),
    'profile': profile.exportDisplay(),
    if (NotificationEventCoordinator.instance.accountId ==
        repository.ledger.snapshot.accountId)
      'notifications': NotificationEventCoordinator.instance.exportState(),
  };
  Future<void> _write(Map<String, Object?> data) async {
    await store.write(data);
    if (data['accountId'] == repository.ledger.snapshot.accountId &&
        repository.ledger.simulationEnabled &&
        !_suspended) {
      await store.putMetadata('active-account', data['accountId'] as String);
      final display = Map<String, Object?>.from(data['profile'] as Map);
      await store.putMetadata(
        'email:${(display['email'] as String).toLowerCase()}',
        data['accountId'] as String,
      );
    }
  }

  void _changed() {
    if (_closed ||
        _queued ||
        _suspended ||
        !repository.ledger.simulationEnabled) {
      return;
    }
    _queued = true;
    scheduleMicrotask(() {
      _queued = false;
      if (_closed || _suspended || !repository.ledger.simulationEnabled) return;
      final data = _export();
      _pending = _pending
          .then((_) => _write(data))
          .then((_) {
            lastError = null;
          })
          .catchError((Object e) {
            lastError = e;
          });
    });
  }

  Future<void> flush() async {
    await Future<void>.delayed(Duration.zero);
    await repository.flush();
    await _pending;
    if (lastError != null) {
      throw StateError('Account changes could not be saved');
    }
  }

  Future<void> deactivate() async {
    _loginEpoch++;
    await flush();
    await store.putMetadata('active-account', '');
  }

  Future<bool> signIn(String email, {bool Function()? isCurrent}) async {
    final epoch = ++_loginEpoch;
    final generation = repository.ledger.generation;
    bool current() =>
        !_closed &&
        epoch == _loginEpoch &&
        generation == repository.ledger.generation &&
        (isCurrent?.call() ?? true);
    await flush();
    if (!current()) return false;
    final account = await store.metadata('email:${email.trim().toLowerCase()}');
    if (account == null || !current()) return false;
    return _restore(account, isCurrent: current);
  }

  Future<bool> _restore(String account, {bool Function()? isCurrent}) async {
    final data = await (readAccount?.call(account) ?? store.read(account));
    if (data == null || !(isCurrent?.call() ?? true)) return false;
    final display = Map<String, Object?>.from(data['profile'] as Map);
    // Validate the display envelope before replacing active account state.
    for (final key in [
      'fullName',
      'email',
      'phone',
      'country',
      'username',
      'dateOfBirth',
      'address',
    ]) {
      if (display[key] is! String) {
        throw const FormatException('Invalid stored profile');
      }
    }
    if (display['sampleAvatar'] is! bool) {
      throw const FormatException('Invalid stored avatar');
    }
    final notificationData = data['notifications'] == null
        ? null
        : Map<String, Object?>.from(data['notifications'] as Map);
    if (notificationData != null) {
      final validationInbox = NotificationInbox(records: const []);
      try {
        NotificationEventCoordinator(
          inbox: validationInbox,
        ).restoreState(account, 0, notificationData);
      } finally {
        validationInbox.dispose();
      }
    }
    _suspended = true;
    try {
      repository.restoreState(data);
      profile.restoreDisplay(display);
      final coordinator = NotificationEventCoordinator.instance;
      if (notificationData == null) {
        coordinator.activate(
          account,
          repository.ledger.generation,
          baseline: repository.records.value,
        );
      } else {
        coordinator.restoreState(
          account,
          repository.ledger.generation,
          notificationData,
        );
      }
    } finally {
      _suspended = false;
    }
    final restoredGeneration = repository.ledger.generation;
    await store.putMetadata('active-account', account);
    return repository.ledger.generation == restoredGeneration &&
        repository.ledger.snapshot.accountId == account;
  }

  Future<void> close() async {
    await flush();
    _closed = true;
    repository.ledger.removeListener(_changed);
    profile.removeListener(_changed);
    NotificationInbox.instance.removeListener(_changed);
    profile.beforeSignOut = null;
    repository.checkpoint = null;
    repository.exportCheckpoint = null;
    await store.close();
  }
}
