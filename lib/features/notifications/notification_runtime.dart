import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../wallets/local_ledger_store.dart';
import '../wallets/wallet_repository.dart';
import 'android_notification_gateway.dart';
import 'device_notification_gateway.dart';
import 'notification_account_events.dart';
import 'notification_delivery_controller.dart';
import 'notification_events.dart';
import 'notification_inbox.dart';
import 'notification_preferences.dart';

/// Installation-scoped OS state, account-scoped delivery and preferences.
class NotificationRuntime extends ChangeNotifier with WidgetsBindingObserver {
  NotificationRuntime({DeviceNotificationGateway? gateway})
    : phone = gateway ?? AndroidNotificationGateway();
  static final instance = NotificationRuntime();
  final DeviceNotificationGateway phone;
  final preferences = NotificationPreferences();
  final pendingTap = ValueNotifier<NotificationTapIntent?>(null);
  LocalLedgerStore? _store;
  NotificationDeliveryController? _delivery;
  bool initialized = false,
      allowed = false,
      invitationShown = false,
      permissionRequested = false,
      busy = false;
  bool foreground = true;
  bool voiceBusy = false, _disposed = false;
  bool get supported => phone.supported;
  final Map<String, bool> channelEnabled = {};
  bool channelAllowed(int type) =>
      allowed &&
      (channelEnabled[[
            'davo_transactions_v1',
            'davo_security_v1',
            'davo_updates_v1',
          ][type]] ??
          true);
  void acknowledgeSafely(String id) => _guard(acknowledge(id));
  String? error;
  String? _account;
  int _generation = -1, _epoch = 0;
  final _wallet = WalletAccountState.instance;
  final _inbox = NotificationInbox.instance;
  Future<void> _settingsWrites = Future.value();
  Future<void> _activation = Future.value();
  Future<void> settle() async {
    await _activation;
    await _delivery?.flush();
    await _settingsWrites;
  }

  Future<void> initialize(
    LocalLedgerStore store,
    Future<void> Function() flushFacts,
  ) async {
    if (initialized) return;
    _store = store;
    await phone.initialize((intent) {
      pendingTap.value = intent;
    });
    invitationShown =
        await store.metadata('phone-notification-invitation') == 'shown';
    permissionRequested =
        await store.metadata('phone-notification-requested') == 'yes';
    _delivery = NotificationDeliveryController(
      phone: phone,
      flushFacts: flushFacts,
      preferencesAllow: preferences.allows,
      voiceEnabled: () => preferences.depositVoiceAlerts,
      save: (raw) async {
        final account = raw['accountId'] as String?;
        if (account != null) {
          await store.putMetadata('phone-delivery:$account', jsonEncode(raw));
        }
      },
      onError: (_) {
        error = 'Phone notifications could not be updated.';
        notifyListeners();
      },
    );
    WidgetsBinding.instance.addObserver(this);
    _wallet.addListener(_accountChanged);
    _inbox.addListener(_inboxChanged);
    NotificationAccountEvents.onAccepted = _securityChanged;
    initialized = true;
    await refreshPermission();
    await (_activation = _activate());
    pendingTap.value = await phone.launchIntent();
  }

  Map<String, Object?>? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return Map<String, Object?>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  void _guard(Future<void> operation) {
    unawaited(
      operation.catchError((Object _) {
        error = 'Phone notifications could not be updated.';
        notifyListeners();
      }),
    );
  }

  void _accountChanged() {
    if (_account != _wallet.snapshot.accountId ||
        _generation != _wallet.generation ||
        !_wallet.simulationEnabled) {
      _guard(_activation = _activate());
    }
  }

  Future<void> _activate() async {
    final epoch = ++_epoch;
    pendingTap.value = null;
    final account = _wallet.snapshot.accountId;
    final generation = _wallet.generation;
    final previousInvalidation =
        _account != null && (_account != account || _generation != generation)
        ? _delivery?.deactivate()
        : null;
    _account = account;
    _generation = generation;
    if (!_wallet.simulationEnabled) {
      await _delivery?.deactivate();
      return;
    }
    await previousInvalidation;
    if (epoch != _epoch) return;
    final rawPrefs = await _store!.metadata('phone-preferences:$account');
    final rawDelivery = await _store!.metadata('phone-delivery:$account');
    final lastAccount = await _store!.metadata('phone-last-account');
    if (epoch != _epoch) return;
    if (lastAccount != null && lastAccount != account) await phone.cancelAll();
    if (epoch != _epoch) return;
    preferences.restore(_decode(rawPrefs));
    final baseline = NotificationEventCoordinator.instance.accountId == account
        ? _inbox.snapshot
        : <InboxNotification>[];
    await _delivery!.activate(
      account,
      generation,
      baseline: baseline,
      restored: _decode(rawDelivery),
    );
    if (epoch != _epoch) return;
    await _store!.putMetadata('phone-last-account', account);
    _inboxChanged();
    notifyListeners();
  }

  void _inboxChanged() {
    if (!initialized ||
        _account == null ||
        !_wallet.simulationEnabled ||
        NotificationEventCoordinator.instance.accountId != _account) {
      return;
    }
    final items = _inbox.snapshot;
    _guard(
      _delivery!.deliver(
        items,
        account: _account!,
        generation: _generation,
        foreground: foreground,
        showDetails: preferences.showDetails,
      ),
    );
    for (final item in items.where((n) => n.isRead)) {
      _guard(_delivery!.acknowledge(item.id));
    }
  }

  void _securityChanged(String title, String detail) {
    if (!initialized || !_wallet.simulationEnabled) return;
    NotificationEventCoordinator.instance.security(
      _wallet.snapshot.accountId,
      _wallet.generation,
      operationId: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      detail: detail,
    );
  }

  Future<void> refreshPermission() async {
    if (!initialized && _store == null) return;
    allowed = await phone.enabled();
    for (final channel in [
      'davo_transactions_v1',
      'davo_security_v1',
      'davo_updates_v1',
    ]) {
      channelEnabled[channel] = await phone.enabled(channel: channel);
    }
    notifyListeners();
  }

  Future<void> enable() async {
    if (!initialized || busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await rememberInvitation();
      permissionRequested = true;
      await _store?.putMetadata('phone-notification-requested', 'yes');
      allowed = await phone.requestPermission();
      await refreshPermission();
    } catch (_) {
      error =
          'Could not request notification permission. Open phone settings to check.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> rememberInvitation() async {
    invitationShown = true;
    await _store?.putMetadata('phone-notification-invitation', 'shown');
    notifyListeners();
  }

  void saveSettings() => _guard(settingsChanged());
  Future<void> settingsChanged() async {
    if (!initialized || _account == null) return;
    final account = _account!;
    final encoded = jsonEncode(preferences.exportState());
    _settingsWrites = _settingsWrites
        .catchError((Object _) {})
        .then(
          (_) => _store!.putMetadata('phone-preferences:$account', encoded),
        );
    await _settingsWrites;
    notifyListeners();
  }

  void setDepositVoice(bool enabled) {
    preferences.depositVoiceAlerts = enabled;
    if (!enabled) unawaited(phone.stopSpeaking());
    saveSettings();
    notifyListeners();
  }

  Future<bool> testDepositVoice() async {
    if (!initialized || voiceBusy || !channelAllowed(0)) return false;
    voiceBusy = true;
    notifyListeners();
    try {
      return await phone.speakDeposit();
    } catch (_) {
      return false;
    } finally {
      voiceBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> openSettings() => phone.openSettings();
  Future<bool> sendTest() async {
    if (!initialized || !await phone.enabled(channel: 'davo_diagnostics_v1')) {
      return false;
    }
    await phone.show(
      DeviceNotificationRequest(
        id: 2147483000,
        eventId: 'diagnostic',
        accountId: _wallet.snapshot.accountId,
        title: 'Davochain notifications are ready',
        body: 'Tap to return to notification settings.',
        channel: 'davo_diagnostics_v1',
      ),
    );
    return true;
  }

  Future<void> acknowledge(String id) async {
    await _delivery?.acknowledge(id);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(phone.stopSpeaking());
    WidgetsBinding.instance.removeObserver(this);
    _wallet.removeListener(_accountChanged);
    _inbox.removeListener(_inboxChanged);
    NotificationAccountEvents.onAccepted = null;
    pendingTap.dispose();
    super.dispose();
  }

  bool validTap(NotificationTapIntent intent) =>
      initialized &&
      _wallet.simulationEnabled &&
      intent.accountId == _wallet.snapshot.accountId &&
      (intent.eventId == 'diagnostic' ||
          _inbox.snapshot.any((n) => n.id == intent.eventId));
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (foreground) _guard(refreshPermission());
  }
}
