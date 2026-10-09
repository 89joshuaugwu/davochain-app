import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/account_welcome_screen.dart';
import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'package:davochain/core/navigation/app_routes.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FundingRecord deposit(FundingStatus status, {String id = 'deposit-1'}) =>
    FundingRecord(
        id: id,
        direction: FundingDirection.deposit,
        status: status,
        amount: 1500,
        currency: 'NGD',
        destination: 'Davochain Naira',
        occurredAt: DateTime(2026, 10, 8),
        network: 'Bank transfer');

void main() {
  tearDown(FundingActivity.reset);
  testWidgets('Android back after an accepted withdrawal returns to wallet',
      (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        navigatorKey: nav,
        home: const Scaffold(body: Text('Wallet destination'))));
    nav.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Old withdrawal form'))));
    await tester.pumpAndSettle();
    nav.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => FundingOutcomeScreen(
            returnToWallet: true,
            record: FundingRecord(
                id: 'withdrawal-back',
                direction: FundingDirection.withdrawal,
                status: FundingStatus.pending,
                amount: 2000,
                currency: 'NGN',
                destination: 'Access Bank',
                occurredAt: DateTime(2026, 10, 8)))));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Wallet destination'), findsOneWidget);
    expect(find.text('Old withdrawal form'), findsNothing);
  });
  testWidgets(
      'deposit presentation stays animated across rebuild and settles on revisit',
      (tester) async {
    final theme = ValueNotifier(false);
    addTearDown(theme.dispose);
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pumpWidget(ValueListenableBuilder<bool>(
        valueListenable: theme,
        builder: (context, dark, _) => MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home:
                const Scaffold(body: DepositActivityBanner(currency: 'NGD')))));
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FundingOutcomeScreen>(find.byType(FundingOutcomeScreen))
            .animate,
        isTrue);
    theme.value = true;
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FundingOutcomeScreen>(find.byType(FundingOutcomeScreen))
            .animate,
        isTrue);
    await tester.tap(find.text('Back to wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FundingOutcomeScreen>(find.byType(FundingOutcomeScreen))
            .animate,
        isFalse);
  });
  testWidgets('Home shows an accepted deposit without navigating away',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark, home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pumpAndSettle();
    expect(find.text('Deposit received'), findsOneWidget);
    expect(find.byType(DavochainDashboardScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'accepted deposits appear above existing history activity',
      (tester) async {
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const TransactionHistoryScreen()));
    expect(tester.getTopLeft(find.text('Deposit received')).dy,
        lessThan(tester.getTopLeft(find.text('Bought Bitcoin')).dy));
  });
  testWidgets(
      'first PIN mismatch stays on form; matching PIN opens welcome before Home',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        routes: {
          AppRoutes.dashboard: (_) =>
              const Scaffold(body: Text('Home destination'))
        },
        home: const TransactionPinScreen()));
    await tester.pumpAndSettle();
    Future<void> enter(String pin) async {
      for (var i = 0; i < 4; i++) {
        await tester.enterText(find.byType(TextField).at(i), pin[i]);
        await tester.pump();
      }
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    await enter('1234');
    await enter('1235');
    expect(find.text('PINs do not match. Try again'), findsOneWidget);
    expect(find.byType(AccountWelcomeScreen), findsNothing);
    await enter('1234');
    expect(find.byType(AccountWelcomeScreen), findsOneWidget);
    expect(find.text('Home destination'), findsNothing);
    await tester.tap(find.text('Explore Davochain'));
    await tester.pumpAndSettle();
    expect(find.text('Home destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'cancelled withdrawal cannot record or navigate after late acceptance',
      (tester) async {
    final operation = Completer<FundingStatus>();
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        navigatorKey: nav,
        home: const Scaffold(body: Text('Wallet'))));
    nav.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => NairaWithdrawalProgressScreen(
            amount: 2000,
            bank: 'Access Bank',
            accountNumber: '1234567890',
            accountName: 'Preview User',
            operation: () => operation.future)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    nav.currentState!.pop();
    operation.complete(FundingStatus.pending);
    await tester.pumpAndSettle();
    expect(find.text('Wallet'), findsOneWidget);
    expect(FundingActivity.records.value, isEmpty);
  });
  testWidgets('failed withdrawal offers retry without recording success',
      (tester) async {
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: NairaWithdrawalProgressScreen(
            amount: 2000,
            bank: 'Access Bank',
            accountNumber: '1234567890',
            accountName: 'Preview User',
            operation: () async => ++attempts == 1
                ? FundingStatus.failed
                : FundingStatus.pending)));
    await tester.pumpAndSettle();
    expect(find.text('Could not submit withdrawal'), findsOneWidget);
    expect(FundingActivity.records.value, isEmpty);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Withdrawal submitted'), findsOneWidget);
    expect(attempts, 2);
  });
  test('deposit status updates replace the event and cannot regress credit',
      () {
    FundingActivity.accept(deposit(FundingStatus.pending));
    FundingActivity.accept(deposit(FundingStatus.completed));
    FundingActivity.accept(deposit(FundingStatus.pending));
    expect(FundingActivity.records.value.length, 1);
    expect(
        FundingActivity.records.value.single.status, FundingStatus.completed);
  });
  testWidgets(
      'receiving details do not manufacture credit; actual event is visible',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: DepositActivityBanner(currency: 'NGD'))));
    expect(find.text('Deposit received'), findsNothing);
    FundingActivity.accept(deposit(FundingStatus.pending));
    await tester.pump();
    expect(find.text('Deposit pending'), findsOneWidget);
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pump();
    expect(find.text('Deposit received'), findsOneWidget);
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.textContaining('1,500'), findsWidgets);
  });
  testWidgets('withdrawal waits for operation then presents submitted not paid',
      (tester) async {
    final operation = Completer<FundingStatus>();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: NairaWithdrawalProgressScreen(
            amount: 2000,
            bank: 'Access Bank',
            accountNumber: '1234567890',
            accountName: 'Preview User',
            operation: () => operation.future)));
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Withdrawal submitted'), findsNothing);
    operation.complete(FundingStatus.pending);
    await tester.pumpAndSettle();
    expect(find.text('Withdrawal submitted'), findsOneWidget);
    expect(find.text('Withdrawal successful'), findsNothing);
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsOneWidget);
    expect(find.textContaining('7890'), findsOneWidget);
    expect(find.text('1234567890'), findsNothing);
  });
  testWidgets('welcome never auto navigates and Explore enters Home once',
      (tester) async {
    var opens = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: AccountWelcomeScreen(onExplore: () => opens++)));
    await tester.pump(const Duration(seconds: 10));
    expect(opens, 0);
    expect(find.text('Welcome to Davochain'), findsOneWidget);
    expect(find.text('Transaction PIN created'), findsOneWidget);
    await tester.tap(find.text('Explore Davochain'));
    await tester.tap(find.text('Explore Davochain'));
    expect(opens, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('welcome settles with reduced motion and large text',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
            data: const MediaQueryData(
                disableAnimations: true, textScaler: TextScaler.linear(2)),
            child: AccountWelcomeScreen(onExplore: () {}))));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Explore Davochain'));
  });
}
