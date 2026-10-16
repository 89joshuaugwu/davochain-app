import 'dart:async';
import 'package:davochain/features/notifications/notification_runtime.dart';
import 'package:davochain/features/notifications/device_notification_gateway.dart';
import 'package:davochain/features/notifications/notification_preferences.dart';
import 'package:davochain/features/notifications/notification_events.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/features/notifications/notification_tap_router.dart';
import 'package:davochain/features/wallets/local_ledger_store.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/features/profile_settings/presentation/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestPhone extends DeviceNotificationGateway {
  bool allowed = false;
  int requests = 0;
  final shown = <DeviceNotificationRequest>[];
  @override
  Future<bool> enabled({String? channel}) async => allowed;
  @override
  Future<bool> requestPermission() async {
    requests++;
    return allowed;
  }

  @override
  Future<void> show(DeviceNotificationRequest request) async =>
      shown.add(request);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  test(
    'runtime invalidates old account before awaiting restoration metadata',
    () async {
      final store = await LocalLedgerStore.open(
        database: await databaseFactoryFfi.openDatabase(inMemoryDatabasePath),
      );
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      final oldAccount = wallet.snapshot.accountId;
      NotificationEventCoordinator.instance.activate(
        oldAccount,
        wallet.generation,
      );
      final phone = TestPhone()..allowed = true;
      final gate = Completer<void>();
      final entered = Completer<void>();
      final runtime = NotificationRuntime(gateway: phone);
      await runtime.initialize(store, () {
        if (!entered.isCompleted) entered.complete();
        return gate.future;
      });
      NotificationEventCoordinator.instance.security(
        oldAccount,
        wallet.generation,
        operationId: 'old',
        title: 'Password changed',
        detail: 'Review your account.',
      );
      await entered.future;
      wallet.startSimulation(empty: true);
      gate.complete();
      await runtime.settle();
      expect(phone.shown, isEmpty);
      runtime.dispose();
      wallet.reset();
      await store.close();
    },
  );
  test(
    'permission denial is persisted; explicit diagnostic has no inbox or funds effects',
    () async {
      final store = await LocalLedgerStore.open(
        database: await databaseFactoryFfi.openDatabase(inMemoryDatabasePath),
      );
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      final phone = TestPhone();
      final runtime = NotificationRuntime(gateway: phone);
      await runtime.initialize(store, () async {});
      await runtime.enable();
      expect(runtime.allowed, false);
      expect(phone.requests, 1);
      expect(await store.metadata('phone-notification-requested'), 'yes');
      expect(runtime.invitationShown, true);
      runtime.preferences.showDetails = true;
      await runtime.settingsChanged();
      expect(
        await store.metadata('phone-preferences:${wallet.snapshot.accountId}'),
        contains('"details":true'),
      );
      final before = wallet.snapshot.portfolioMinorUnits;
      final inbox = NotificationInbox.instance.snapshot.length;
      expect(await runtime.sendTest(), false);
      phone.allowed = true;
      await runtime.refreshPermission();
      expect(await runtime.sendTest(), true);
      expect(phone.shown.single.eventId, 'diagnostic');
      expect(wallet.snapshot.portfolioMinorUnits, before);
      expect(NotificationInbox.instance.snapshot.length, inbox);
      runtime.dispose();
      wallet.reset();
      await store.close();
    },
  );
  test(
    'preferences round trip and missing account preferences reset private defaults',
    () {
      final preferences = NotificationPreferences()..restore(null);
      preferences.showDetails = true;
      PreviewAccountState.notificationChannels[0][0] = false;
      final state = preferences.exportState();
      preferences.restore(null);
      expect(preferences.showDetails, false);
      expect(PreviewAccountState.notificationChannels[0][0], true);
      preferences.restore(state);
      expect(preferences.showDetails, true);
      expect(PreviewAccountState.notificationChannels[0][0], false);
      preferences.restore(null);
    },
  );
  testWidgets(
    'notification waits for unlock, opens once, rejects another account',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      final account = wallet.snapshot.accountId;
      NotificationEventCoordinator.instance.activate(
        account,
        wallet.generation,
      );
      NotificationInbox.instance.insert(
        InboxNotification(
          id: '$account:security-test',
          title: 'Security update',
          body: 'Review your settings.',
          time: '',
          day: '',
          category: 2,
          kind: NotificationKind.security,
        ),
      );
      final runtime = NotificationRuntime(gateway: TestPhone())
        ..initialized = true;
      PreviewAuthState.unlocked.value = false;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: notificationNavigatorKey,
          builder: (_, child) =>
              NotificationTapHost(runtime: runtime, child: child!),
          home: const Scaffold(body: Text('Locked')),
        ),
      );
      runtime.pendingTap.value = NotificationTapIntent(
        account,
        '$account:security-test',
      );
      await tester.pumpAndSettle();
      expect(find.byType(DavoNotificationDetailScreen), findsNothing);
      expect(runtime.pendingTap.value, isNotNull);
      expect(runtime.validTap(runtime.pendingTap.value!), true);
      PreviewAuthState.unlocked.value = true;
      await tester.pumpAndSettle();
      expect(find.byType(DavoNotificationDetailScreen), findsOneWidget);
      expect(runtime.pendingTap.value, isNull);
      expect(NotificationInbox.instance.snapshot.single.isRead, true);
      notificationNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      runtime.pendingTap.value = const NotificationTapIntent(
        'other-account',
        'diagnostic',
      );
      await tester.pumpAndSettle();
      expect(runtime.pendingTap.value, isNull);
      expect(find.byType(DavoNotificationDetailScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
      runtime.dispose();
      wallet.reset();
    },
  );
}
