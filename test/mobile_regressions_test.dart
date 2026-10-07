import 'package:davochain/core/navigation/app_page_route.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Android dashboard cannot be pulled past its scroll limits',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    final scrollable =
        tester.state<ScrollableState>(find.byType(Scrollable).first);
    final gesture = await tester.startGesture(const Offset(200, 200));
    await gesture.moveBy(const Offset(0, 180));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    expect(scrollable.position.pixels,
        greaterThanOrEqualTo(scrollable.position.minScrollExtent));
    await gesture.up();
    await tester.pumpAndSettle();
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    final bottomGesture = await tester.startGesture(const Offset(200, 350));
    await bottomGesture.moveBy(const Offset(0, -180));
    await bottomGesture.moveBy(const Offset(0, -80));
    await tester.pump();
    expect(scrollable.position.pixels,
        lessThanOrEqualTo(scrollable.position.maxScrollExtent));
    await bottomGesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('Trade navigation opens the existing portfolio trade screen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Trade'));
    await tester.pumpAndSettle();
    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Swap'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <String, Type>{
    'History': TransactionHistoryScreen,
    'Finish setting up your account': KycTierOverviewScreen,
    'Earn \$5': ReferralDashboardScreen,
  }.entries) {
    testWidgets('${entry.key} opens its preview destination', (tester) async {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light, home: const DavochainDashboardScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final mode in TradeMode.values) {
    testWidgets('$mode amount has one frame when idle and focused',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: TradeAmountScreen(mode: mode, asset: BuyCryptoAsset.bitcoin),
      ));
      final field = find.byType(TextField).first;
      void expectNoInnerFrame() {
        final decorator = tester.widget<InputDecorator>(find.descendant(
          of: field,
          matching: find.byType(InputDecorator),
        ));
        expect(decorator.decoration.enabledBorder, InputBorder.none);
        expect(decorator.decoration.focusedBorder, InputBorder.none);
        expect(decorator.decoration.filled, isFalse);
      }

      expectNoInnerFrame();
      await tester.tap(field);
      await tester.enterText(field, '0.01');
      await tester.pump();
      expectNoInnerFrame();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('deposit actions stay visible on a short phone', (tester) async {
    tester.view.physicalSize = const Size(390, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const CryptoDepositScreen(asset: CryptoAsset.bitcoin),
    ));
    final copy = find.text('Copy Address');
    expect(copy.hitTestable(), findsOneWidget);
    final before = tester.getRect(copy);
    await tester.tap(
        find.text('Please review these guidelines before making a deposit.'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(copy.hitTestable(), findsOneWidget);
    expect(tester.getRect(copy), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page navigation respects reduced motion', (tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Builder(
          builder: (context) => TextButton(
                onPressed: () => pushAppPage<void>(
                    context, (_) => const Scaffold(body: Text('Destination'))),
                child: const Text('Open'),
              )),
    ));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('Destination').hitTestable(), findsOneWidget);
    expect(
        find.ancestor(
            of: find.text('Destination'),
            matching: find.byType(SlideTransition)),
        findsNothing);
    await tester.pumpAndSettle();
  });
}
