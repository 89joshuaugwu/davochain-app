import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/core/money/money.dart';
import 'package:davochain/core/preview/preview_account_state.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/shared/widgets/davo_refresh_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [const Size(411, 914), const Size(360, 820)]) {
    testWidgets(
        'compact carousel leaves readable leading assets at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding =
          FakeViewPadding(top: 32, bottom: size.width == 360 ? 0 : 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      WalletAccountState.instance.startSimulation(empty: true);
      addTearDown(WalletAccountState.instance.reset);
      PreviewAccountState.setupComplete.value = false;
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light, home: const DavochainDashboardScreen()));
      await tester.pumpAndSettle();
      final carousel = tester
          .getRect(find.byKey(const ValueKey('dashboard-feature-carousel')));
      expect(carousel.height, lessThanOrEqualTo(121));
      final viewport =
          tester.getRect(find.byKey(const ValueKey('dashboard-assets')));
      final nav =
          tester.getTopLeft(find.byKey(const ValueKey('main-tab-0'))).dy;
      for (final asset in ['BTC', 'USDT']) {
        final row =
            tester.getRect(find.byKey(ValueKey('dashboard-asset-$asset')));
        expect(row.bottom, lessThanOrEqualTo(viewport.bottom + .1));
        expect(row.bottom, lessThanOrEqualTo(nav + .1));
        final name =
            {'BTC': 'Bitcoin', 'ETH': 'Ethereum', 'USDT': 'Tether'}[asset]!;
        expect(find.text(name).hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
      'portfolio sync prevents duplicate requests and reports completed reads',
      (tester) async {
    final completion = Completer<void>();
    var reads = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: DavoRefreshScope(
            onRefresh: (request) {
              reads++;
              return completion.future;
            },
            child: const PortfolioScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Refresh portfolio'));
    await tester.pump();
    expect(find.text('Updating'), findsOneWidget);
    await tester.tap(find.byTooltip('Refresh portfolio'));
    await tester.pump();
    expect(reads, 1);
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.text('Updated'), findsOneWidget);
  });
  testWidgets(
      'withdrawal blocks above the displayed limit despite sufficient balance',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = WalletAccountState.instance;
    state.reset();
    addTearDown(state.reset);
    SettingsPreviewSession.instance.acceptBank(const LinkedBank(
        bank: 'Kuda Bank', number: '1234567890', name: 'Customer'));
    addTearDown(SettingsPreviewSession.instance.reset);
    state.publish(
        WalletSnapshot(
            accountId: state.snapshot.accountId,
            version: 2,
            available: {'NGN': AssetAmount.parse('10000000', 'NGN', 2)},
            pricesMinorUnits: {'NGN': 100}),
        generation: state.generation);
    await tester.pumpWidget(const MaterialApp(home: NairaWithdrawScreen()));
    await tester.tap(find.text('Select a payment method'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kuda Bank - 1234567890'), 100,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuda Bank - 1234567890'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5000000.01');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Withdrawal'), findsNothing);
    await tester.enterText(find.byType(TextField), '5000000');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Withdrawal'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
