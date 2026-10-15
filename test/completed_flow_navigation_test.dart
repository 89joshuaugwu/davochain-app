import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/motion/davo_motion_spec.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/widgets/davo_main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ReceiptRecord get accepted => ReceiptRecord(
    id: 'accepted-back-test',
    reference: 'accepted-back-test',
    type: 'Trade',
    status: ReceiptStatus.completed,
    occurredAt: DateTime.utc(2026, 10, 15),
    amount: '100',
    fields: const []);
const order = BuyCryptoOrder(
    asset: BuyCryptoAsset.bitcoin,
    wallet: BuyFundingWallet.ngn,
    ngnAmount: 1000);
void main() {
  testWidgets(
      'pending swap message identifies conversion rather than withdrawal',
      (tester) async {
    addTearDown(ReceiptActivity.reset);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const TransactionSuccessScreen(
            kind: TxKind.conversion,
            target: 'USDT',
            amount: 1,
            outcomeKind: DavoOutcomeKind.submitted)));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Your conversion has been submitted. Its status will update after confirmation.'),
        findsOneWidget);
    expect(find.textContaining('Your withdrawal'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    ReceiptActivity.reset();
  });
  final cases = <String, (Widget Function(), int)>{
    'crypto buy': (() => BuySuccessScreen(order: order, record: accepted), 1),
    'crypto sell': (
      () => TransactionSuccessScreen(
          kind: TxKind.sell, target: 'NGN', amount: 1, record: accepted),
      1
    ),
    'crypto swap': (
      () => TransactionSuccessScreen(
          kind: TxKind.conversion, target: 'ETH', amount: 1, record: accepted),
      1
    ),
    'crypto withdrawal': (
      () => TransactionSuccessScreen(
          kind: TxKind.external,
          target: 'address',
          amount: 1,
          record: accepted),
      0
    ),
    'gift buy': (
      () =>
          GiftCardBuySuccessScreen(amount: 100, naira: 1000, record: accepted),
      2
    ),
    'gift sell': (() => GiftCardSellSubmittedScreen(record: accepted), 2),
    'naira withdrawal': (
      () => FundingOutcomeScreen(
          record: FundingRecord(
              id: 'funding-back',
              direction: FundingDirection.withdrawal,
              status: FundingStatus.completed,
              amount: 1000,
              currency: 'NGN',
              destination: 'Bank',
              occurredAt: DateTime.utc(2026, 10, 15)),
          returnToWallet: true),
      0
    ),
    'deposit': (
      () => FundingOutcomeScreen(
          record: FundingRecord(
              id: 'deposit-back',
              direction: FundingDirection.deposit,
              status: FundingStatus.completed,
              amount: 1000,
              currency: 'NGN',
              destination: 'Wallet',
              occurredAt: DateTime.utc(2026, 10, 15))),
      0
    ),
  };
  testWidgets(
      'starting another gift trade clears old steps and Back reaches its hub',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
        navigatorKey: navigator,
        theme: AppTheme.light,
        home: const Scaffold(body: Text('stale gift form'))));
    navigator.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => GiftCardBuySuccessScreen(
            amount: 100, naira: 1000, record: accepted)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start New Trade'));
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardBrandScreen), findsOneWidget);
    expect(find.text('stale gift form', skipOffstage: false), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardHomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('purchase Details returns to its result before exiting to Trade',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: BuySuccessScreen(order: order, record: accepted)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyTransactionDetailsScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(BuySuccessScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
        tester.widget<DavoMainShell>(find.byType(DavoMainShell)).initialIndex,
        1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final entry in cases.entries) {
    for (final systemBack in [false, true]) {
      testWidgets(
          '${entry.key} ${systemBack ? 'system' : 'arrow'} Back discards completed forms',
          (tester) async {
        tester.view.physicalSize = const Size(411, 914);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final navigator = GlobalKey<NavigatorState>();
        await tester.pumpWidget(MaterialApp(
            navigatorKey: navigator,
            theme: AppTheme.light,
            home: const Scaffold(body: Text('stale first form'))));
        navigator.currentState!.push(MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('stale review form'))));
        await tester.pumpAndSettle();
        navigator.currentState!
            .push(MaterialPageRoute<void>(builder: (_) => entry.value.$1()));
        await tester.pumpAndSettle();
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          final arrow = find.byWidgetPredicate((w) =>
              w is IconButton &&
              w.icon is Icon &&
              ((w.icon as Icon).icon == Icons.arrow_back ||
                  (w.icon as Icon).icon == Icons.arrow_back_rounded));
          expect(arrow, findsOneWidget);
          await tester.tap(arrow);
        }
        await tester.pumpAndSettle();
        expect(find.byType(DavoMainShell), findsOneWidget);
        expect(
            tester
                .widget<DavoMainShell>(find.byType(DavoMainShell))
                .initialIndex,
            entry.value.$2);
        expect(
            find.text('stale first form', skipOffstage: false), findsNothing);
        expect(
            find.text('stale review form', skipOffstage: false), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
