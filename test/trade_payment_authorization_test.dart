import 'dart:async';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/preview/preview_transaction_operation.dart';
import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/core/money/money.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/widgets/transaction_pin_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> enterPin(WidgetTester tester) async {
  for (final digit in ['1', '2', '3', '4']) {
    await tester.ensureVisible(find.text(digit));
    await tester.tap(find.text(digit));
    await tester.pump();
  }
  await tester.ensureVisible(find.text('Confirm').last);
  await tester.tap(find.text('Confirm').last);
}

void main() {
  setUp(LocalPreviewProfile.instance.loginSample);
  tearDown(() {
    LocalPreviewProfile.instance.loginSample();
    ReceiptActivity.reset();
  });

  test('resetting transaction PIN preserves the active hour payment lock', () {
    final now = DateTime.now();
    for (var i = 0; i < 5; i++) {
      PreviewAuthState.verifyTransactionPin('9999', now: now);
    }
    PreviewAuthState.setTransactionPin('5678');
    expect(PreviewAuthState.paymentsLocked(now: now), isTrue);
    expect(PreviewAuthState.verifyTransactionPin('5678', now: now), isFalse);
    expect(
        PreviewAuthState.verifyTransactionPin('5678', payment: false), isTrue);
    expect(
        PreviewAuthState.verifyTransactionPin('5678',
            now: now.add(const Duration(hours: 1))),
        isTrue);
  });

  testWidgets('old account progress cannot publish a new account receipt',
      (tester) async {
    final operation = Completer<PreviewTransactionOutcome>();
    await tester.pumpWidget(MaterialApp(
        home: TransactionProgressScreen(
            kind: TxKind.sell,
            target: 'NGN',
            amount: '0.001',
            operation: operation.future)));
    LocalPreviewProfile.instance.loginSample();
    operation.complete(PreviewTransactionOutcome.completed);
    await tester.pump();
    expect(find.byType(TransactionSuccessScreen), findsNothing);
    expect(ReceiptActivity.records.value, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  for (final kind in [TxKind.sell, TxKind.conversion]) {
    final label = kind == TxKind.conversion ? 'Confirm conversion' : 'Confirm';
    testWidgets('$kind requires PIN before creating a trade', (tester) async {
      await tester.pumpWidget(
          MaterialApp(home: TradeReviewScreen(kind: kind, amount: '0.001')));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionPinEntryScreen), findsOneWidget);
      expect(find.byType(TransactionProgressScreen), findsNothing);
      expect(ReceiptActivity.records.value, isEmpty);
      await enterPin(tester);
      await tester.pumpAndSettle();
      expect(find.byType(TransactionPinEntryScreen), findsNothing);
      expect(ReceiptActivity.records.value, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 21));
    });

    testWidgets('$kind cannot bypass payment lock with fingerprint enabled',
        (tester) async {
      PreviewAuthState.paymentBiometricsEnabled.value = true;
      for (var i = 0; i < 5; i++) {
        PreviewAuthState.verifyTransactionPin('9999');
      }
      await tester.pumpWidget(
          MaterialApp(home: TradeReviewScreen(kind: kind, amount: '0.001')));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionPinEntryScreen), findsOneWidget);
      expect(find.text('Use fingerprint'), findsNothing);
      expect(find.textContaining('Payments are paused'), findsOneWidget);
      expect(ReceiptActivity.records.value, isEmpty);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('account change while reviewing prevents stale trade submission',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TradeReviewScreen(kind: TxKind.conversion, amount: '0.001')));
    LocalPreviewProfile.instance.loginSample();
    await tester.tap(find.text('Confirm conversion'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionPinEntryScreen), findsNothing);
    expect(ReceiptActivity.records.value, isEmpty);
  });

  testWidgets('trade rechecks source funds after successful PIN',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TradeReviewScreen(kind: TxKind.conversion, amount: '0.001')));
    await tester.tap(find.text('Confirm conversion'));
    await tester.pumpAndSettle();
    final wallet = WalletAccountState.instance;
    final previous = wallet.snapshot;
    wallet.publish(
        WalletSnapshot(
            accountId: previous.accountId,
            version: previous.version + 1,
            available: {
              'BTC': AssetAmount.parse('0', 'BTC', 8),
              'USDT': previous.available('USDT'),
            },
            pricesMinorUnits: {
              'BTC': 2400000000,
              'USDT': 154000
            }),
        generation: wallet.generation);
    await enterPin(tester);
    await tester.pumpAndSettle();
    expect(find.byType(TransactionProgressScreen), findsNothing);
    expect(find.byType(TradeReviewScreen), findsOneWidget);
    expect(ReceiptActivity.records.value, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
