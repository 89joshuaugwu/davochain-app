import 'package:davochain/core/preview/preview_transaction_operation.dart';
import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/shared/widgets/davo_auth_journey.dart';
import 'package:davochain/shared/motion/davo_working_indicator.dart';
import 'package:davochain/shared/motion/davo_motion_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'popping a live progress route cancels navigation even before disposal',
      (tester) async {
    final operation = Completer<PreviewTransactionOutcome>();
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: Text('Original page'))));
    navigator.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => BuyProgressScreen(
            operation: operation.future,
            order: const BuyCryptoOrder(
                asset: BuyCryptoAsset.bitcoin,
                wallet: BuyFundingWallet.ngn,
                ngnAmount: 10000))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    navigator.currentState!.pop();
    operation.complete(PreviewTransactionOutcome.completed);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Original page'), findsOneWidget);
    expect(find.byType(BuySuccessScreen), findsNothing);
  });
  testWidgets('popping accepted auth before handoff never delivers late unlock',
      (tester) async {
    var callbacks = 0;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: Text('Original page'))));
    navigator.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => DavoAuthJourney(
            method: AuthJourneyMethod.password,
            onComplete: () => callbacks++,
            child: const Scaffold())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    navigator.currentState!.pop();
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pumpAndSettle();
    expect(callbacks, 0);
    expect(find.text('Original page'), findsOneWidget);
  });
  testWidgets('submitted buy displays waiting state instead of completion',
      (tester) async {
    final operation = Completer<PreviewTransactionOutcome>();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: BuyProgressScreen(
            operation: operation.future,
            order: const BuyCryptoOrder(
                asset: BuyCryptoAsset.bitcoin,
                wallet: BuyFundingWallet.ngn,
                ngnAmount: 10000))));
    operation.complete(PreviewTransactionOutcome.submitted);
    await tester.pumpAndSettle();
    expect(find.text('Purchase submitted'), findsOneWidget);
    expect(find.text('Purchase successful'), findsNothing);
  });

  testWidgets('slow and failed work never becomes success when motion ends',
      (tester) async {
    final operation = Completer<PreviewTransactionOutcome>();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: BuyProgressScreen(
            operation: operation.future,
            order: const BuyCryptoOrder(
                asset: BuyCryptoAsset.bitcoin,
                wallet: BuyFundingWallet.ngn,
                ngnAmount: 720000))));
    await tester.pump(const Duration(seconds: 10));
    expect(find.byType(BuySuccessScreen), findsNothing);
    expect(find.byType(DavoWorkingIndicator), findsOneWidget);
    operation.complete(PreviewTransactionOutcome.failed);
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Could not complete'), findsOneWidget);
    expect(find.byType(DavoWorkingIndicator), findsNothing);
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets(
      'reduced working is static and never announces accepted; failure permits retry',
      (tester) async {
    var callbacks = 0, taps = 0;
    final state = ValueNotifier(AuthJourneyState.working);
    addTearDown(state.dispose);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: ValueListenableBuilder<AuthJourneyState>(
                valueListenable: state,
                builder: (context, value, child) => DavoAuthJourney(
                    method: AuthJourneyMethod.password,
                    state: value,
                    onComplete: () => callbacks++,
                    child: Scaffold(
                        body: TextButton(
                            onPressed: () => taps++,
                            child: const Text('Retry'))))))));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Welcome back'), findsNothing);
    expect(callbacks, 0);
    expect(tester.binding.transientCallbackCount, 0);
    state.value = AuthJourneyState.failed;
    await tester.pump();
    await tester.tap(find.text('Retry'));
    expect(taps, 1);
  });
  testWidgets(
      'acceptance in background cannot route until resumed and routes once',
      (tester) async {
    var callbacks = 0;
    final state = ValueNotifier(AuthJourneyState.working);
    addTearDown(state.dispose);
    await tester.pumpWidget(MaterialApp(
        home: ValueListenableBuilder<AuthJourneyState>(
            valueListenable: state,
            builder: (context, value, child) => DavoAuthJourney(
                method: AuthJourneyMethod.password,
                state: value,
                onComplete: () => callbacks++,
                child: const Scaffold()))));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    state.value = AuthJourneyState.accepted;
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(callbacks, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(callbacks, 1);
    await tester.pump(const Duration(seconds: 3));
    expect(callbacks, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'review attention stops after two cycles without changing pending state',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Center(
            child: DavoWorkingIndicator(kind: DavoWorkingKind.reviewPending))));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    expect(find.bySemanticsLabel('Pending review'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    expect(tester.binding.transientCallbackCount, 0);
  });
}
