import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(Widget screen) => MaterialApp(theme: AppTheme.light, home: screen);
  testWidgets('asset search filters by ticker, handles no result and clears',
      (tester) async {
    await tester.pumpWidget(app(const Scaffold(body: BuyCryptoAssetSheet())));
    final search = find.byKey(const ValueKey('asset-search'));
    await tester.enterText(search, ' eTh ');
    await tester.pump();
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('Bitcoin'), findsNothing);
    await tester.enterText(search, 'no-such-coin');
    await tester.pump();
    expect(find.textContaining('No matching assets'), findsOneWidget);
    await tester.enterText(search, '');
    await tester.pump();
    expect(find.text('Bitcoin'), findsOneWidget);
  });
  for (final buy in [true, false]) {
    testWidgets(
        '${buy ? 'buy' : 'sell'} has a visible searchable coin selector',
        (tester) async {
      await tester.pumpWidget(app(buy
          ? const BuyAmountScreen(
              initialOrder: BuyCryptoOrder(
                  asset: BuyCryptoAsset.bitcoin,
                  wallet: BuyFundingWallet.ngn,
                  ngnAmount: 0))
          : const TradeAmountScreen(
              mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin)));
      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('asset-search')), 'eth');
      await tester.pump();
      await tester.tap(find.text('Ethereum'));
      await tester.pumpAndSettle();
      expect(find.byType(BuyCryptoAssetSheet), findsNothing);
      expect(find.text('Ethereum'), findsOneWidget);
      await tester.enterText(find.byType(TextField), buy ? '5200' : '0.01');
      await tester.pump();
      expect(find.text(buy ? '0.001 ETH' : '\u2248 \u20a652,000.00'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final mode in ['Buy', 'Sell', 'Swap']) {
    testWidgets('portfolio $mode opens its amount flow without an extra picker',
        (tester) async {
      await tester.pumpWidget(app(const PortfolioScreen()));
      await tester.tap(find.text(mode));
      await tester.pumpAndSettle();
      expect(find.byType(BuyCryptoAssetSheet), findsNothing);
      if (mode == 'Buy') {
        expect(find.byType(BuyAmountScreen), findsOneWidget);
      } else {
        expect(
            tester
                .widget<TradeAmountScreen>(find.byType(TradeAmountScreen))
                .mode,
            mode == 'Sell' ? TradeMode.sell : TradeMode.convert);
      }
    });
  }
  testWidgets('Naira action stays at the bottom and balance can be hidden',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const NairaWithdrawScreen()));
    expect(tester.getCenter(find.text('Continue')).dy, greaterThan(740));
    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pump();
    expect(find.textContaining('1,284,500'), findsNothing);
    expect(find.text('Balance hidden'), findsOneWidget);
  });
  testWidgets('featured banners rotate with dots and no playback buttons',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Your crypto.\nOne clear view.').hitTestable(),
        findsOneWidget);
    expect(find.byTooltip('Pause featured banners'), findsNothing);
    expect(find.byTooltip('Play featured banners'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Show featured banner 3'));
    await tester.tap(find.byTooltip('Show featured banner 3'));
    await tester.pumpAndSettle();
    expect(find.text('Refer & Earn \u20a65,000').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('reduced motion keeps banners still and manual dots usable',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 18));
    expect(
        find.byKey(const ValueKey('dashboard-coins-and-cards')).hitTestable(),
        findsOneWidget);
    expect(find.byTooltip('Pause featured banners'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Show featured banner 2'));
    await tester.tap(find.byTooltip('Show featured banner 2'));
    await tester.pumpAndSettle();
    expect(find.text('Your crypto.\nOne clear view.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('all banners fit a small phone at double text size',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: true),
            child: child!),
        home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 3; i++) {
      final control = find.byTooltip('Show featured banner $i');
      await tester.ensureVisible(control);
      await tester.tap(control);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('carousel waits while inactive, covered, or on another main tab',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    final controller =
        tester.widget<PageView>(find.byType(PageView)).controller!;
    final original = controller.page;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(seconds: 12));
    expect(controller.page, original);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final navigator = Navigator.of(tester.element(find.byType(PageView)));
    navigator.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Covering page'))));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 12));
    expect(controller.page, original);
    navigator.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('main-tab-1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 12));
    expect(controller.page, original);
    await tester.tap(find.byKey(const ValueKey('main-tab-0')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(controller.page, greaterThan(original!));
    await tester.pumpWidget(const SizedBox());
  });
}
