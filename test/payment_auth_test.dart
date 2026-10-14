import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/shared/widgets/transaction_pin_entry.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_biometric_gateway.dart';
import 'dart:async';

class PendingBiometrics implements BiometricGateway {
  final result = Completer<bool>();
  @override
  Future<bool> authenticate({required String reason}) => result.future;
  @override
  Future<void> cancel() async {}
}

class FailingBiometrics implements BiometricGateway {
  @override
  Future<bool> authenticate({required String reason}) async =>
      throw StateError('Device unavailable');
  @override
  Future<void> cancel() async {}
}

void main() {
  setUp(() {
    PreviewAuthState.resetSession(samplePin: true);
    BiometricGateway.instance = FakeBiometricGateway();
  });
  tearDown(() => BiometricGateway.instance = DeviceBiometricGateway());

  test('fifth wrong PIN locks payments for an hour; account stays unlocked',
      () {
    PreviewAuthState.unlocked.value = true;
    final now = DateTime(2026);
    for (var i = 0; i < 4; i++) {
      expect(PreviewAuthState.verifyTransactionPin('9999', now: now), isFalse);
    }
    expect(PreviewAuthState.paymentPinFailures, 4);
    expect(PreviewAuthState.paymentsLocked(now: now), isFalse);
    expect(PreviewAuthState.verifyTransactionPin('9999', now: now), isFalse);
    expect(PreviewAuthState.verifyTransactionPin('1234', now: now), isFalse);
    expect(PreviewAuthState.unlocked.value, isTrue);
    expect(
        PreviewAuthState.verifyTransactionPin('1234',
            now: now.add(const Duration(hours: 1))),
        isTrue);
  });

  test('new account session clears payment opt-in and retry state', () {
    PreviewAuthState.paymentBiometricsEnabled.value = true;
    PreviewAuthState.verifyTransactionPin('9999');
    PreviewAuthState.resetSession();
    expect(PreviewAuthState.paymentBiometricsEnabled.value, isFalse);
    expect(PreviewAuthState.paymentPinFailures, 0);
    expect(PreviewAuthState.verifyTransactionPin('1234'), isFalse);
  });

  for (final accepted in [true, false]) {
    testWidgets('payment fingerprint ${accepted ? "success" : "cancellation"}',
        (tester) async {
      var confirms = 0;
      PreviewAuthState.paymentBiometricsEnabled.value = true;
      BiometricGateway.instance = FakeBiometricGateway(accept: accepted);
      await tester.pumpWidget(MaterialApp(
          home: TransactionPinEntryScreen(onConfirm: () => confirms++)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Use fingerprint'));
      await tester.tap(find.text('Use fingerprint'));
      await tester.pumpAndSettle();
      expect(confirms, accepted ? 1 : 0);
      if (!accepted) expect(find.text('Enter Secure PIN'), findsOneWidget);
    });
  }

  testWidgets('stale device result cannot confirm a new account payment',
      (tester) async {
    final gateway = PendingBiometrics();
    BiometricGateway.instance = gateway;
    PreviewAuthState.paymentBiometricsEnabled.value = true;
    var confirms = 0;
    await tester.pumpWidget(MaterialApp(
        home: TransactionPinEntryScreen(onConfirm: () => confirms++)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Use fingerprint'));
    await tester.tap(find.text('Use fingerprint'));
    await tester.pump();
    PreviewAuthState.resetSession();
    gateway.result.complete(true);
    await tester.pumpAndSettle();
    expect(confirms, 0);
  });

  testWidgets('payment lock prevents fingerprint bypass', (tester) async {
    PreviewAuthState.paymentBiometricsEnabled.value = true;
    for (var i = 0; i < 5; i++) {
      PreviewAuthState.verifyTransactionPin('9999');
    }
    var confirms = 0;
    await tester.pumpWidget(MaterialApp(
        home: TransactionPinEntryScreen(onConfirm: () => confirms++)));
    await tester.pumpAndSettle();
    expect(find.text('Use fingerprint'), findsNothing);
    expect(confirms, 0);
    expect(find.textContaining('Payments are paused'), findsOneWidget);
  });

  testWidgets('device error falls back to PIN without recording a wrong PIN',
      (tester) async {
    BiometricGateway.instance = FailingBiometrics();
    PreviewAuthState.paymentBiometricsEnabled.value = true;
    var confirms = 0;
    await tester.pumpWidget(MaterialApp(
        home: TransactionPinEntryScreen(onConfirm: () => confirms++)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Use fingerprint'));
    await tester.tap(find.text('Use fingerprint'));
    await tester.pumpAndSettle();
    expect(confirms, 0);
    expect(PreviewAuthState.paymentPinFailures, 0);
    expect(find.text('Enter Secure PIN'), findsOneWidget);
  });

  testWidgets('four wrong PINs offer reset or last try before payment lock',
      (tester) async {
    var confirms = 0;
    await tester.pumpWidget(MaterialApp(
        home: TransactionPinEntryScreen(onConfirm: () => confirms++)));
    for (var attempt = 0; attempt < 4; attempt++) {
      for (var digit = 0; digit < 4; digit++) {
        await tester.ensureVisible(find.text('9'));
        await tester.tap(find.text('9'));
        await tester.pump();
      }
      await tester.ensureVisible(find.text('Confirm'));
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
    }
    expect(confirms, 0);
    expect(find.text('One attempt remaining'), findsOneWidget);
    expect(find.text('Last try'), findsOneWidget);
    await tester.tap(find.text('Last try'));
    await tester.pumpAndSettle();
    for (var digit = 0; digit < 4; digit++) {
      await tester.ensureVisible(find.text('9'));
      await tester.tap(find.text('9'));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Confirm'));
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(confirms, 0);
    expect(find.textContaining('Payments are paused'), findsOneWidget);
  });

  testWidgets(
      'fingerprint settings preserve unlock and independently enable payments',
      (tester) async {
    PreviewAuthState.biometricsEnabled.value = true;
    await tester
        .pumpWidget(const MaterialApp(home: FingerprintSettingsScreen()));
    expect(PreviewAuthState.paymentBiometricsEnabled.value, isFalse);
    await tester
        .tap(find.widgetWithText(SwitchListTile, 'Payment confirmation'));
    await tester.pumpAndSettle();
    expect(PreviewAuthState.biometricsEnabled.value, isTrue);
    expect(PreviewAuthState.paymentBiometricsEnabled.value, isTrue);
    await tester.tap(find.widgetWithText(SwitchListTile, 'App unlock'));
    await tester.pumpAndSettle();
    expect(PreviewAuthState.biometricsEnabled.value, isFalse);
    expect(PreviewAuthState.paymentBiometricsEnabled.value, isTrue);
  });

  testWidgets('successful PIN invokes transaction callback only once',
      (tester) async {
    var confirms = 0;
    await tester.pumpWidget(MaterialApp(
        home: TransactionPinEntryScreen(onConfirm: () => confirms++)));
    for (final digit in ['1', '2', '3', '4']) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Confirm'));
    await tester.tap(find.text('Confirm'));
    await tester.tap(find.text('Confirm'));
    expect(confirms, 1);
  });

  test('payment lock never blocks valid app unlock PIN', () {
    for (var i = 0; i < 5; i++) {
      PreviewAuthState.verifyTransactionPin('9999');
    }
    expect(
        PreviewAuthState.verifyTransactionPin('1234', payment: false), isTrue);
    expect(PreviewAuthState.paymentsLocked(), isTrue);
  });
}
