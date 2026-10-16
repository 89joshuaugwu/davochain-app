import 'package:davochain/core/money/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/shared/widgets/davo_naira_amount.dart';

void main() {
  testWidgets('Home contains five ranked assets and no bottom deposit banner', (
    tester,
  ) async {
    final wallet = WalletAccountState.instance..startSimulation(empty: true);
    addTearDown(wallet.reset);
    wallet.applyEffect(
      'doge-funded',
      wallet.effect(credits: {'DOGE': '100'}),
      completed: true,
      failed: false,
    );
    await tester.pumpWidget(
      const MaterialApp(home: DavochainDashboardScreen()),
    );
    await tester.pumpAndSettle();
    final list = tester.widget<ListView>(
      find.byKey(const ValueKey('dashboard-assets')),
    );
    final rows = (list.childrenDelegate as SliverChildListDelegate).children;
    expect(rows.length, 5);
    expect(rows.first.key, const ValueKey('dashboard-asset-DOGE'));
    expect(find.byType(DepositActivityBanner), findsNothing);
    expect(find.byType(DavoNairaAmount), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Portfolio searches the full catalog and hides amounts together',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      addTearDown(wallet.reset);
      await tester.pumpWidget(const MaterialApp(home: PortfolioScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cardano');
      await tester.pumpAndSettle();
      expect(find.text('Cardano'), findsOneWidget);
      expect(find.text('Bitcoin'), findsNothing);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.ensureVisible(find.byTooltip('Hide portfolio balance'));
      await tester.tap(find.byTooltip('Hide portfolio balance'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<DavoNairaAmount>(find.byType(DavoNairaAmount))
            .every((amount) => !amount.visible),
        isTrue,
      );
      expect(find.textContaining('USD'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'hide portfolio also conceals funded allocation values and semantics',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: false);
      addTearDown(wallet.reset);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(const MaterialApp(home: PortfolioScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Hide portfolio balance'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('.*Davochain Naira.*')),
        findsNothing,
      );
      expect(find.textContaining('%'), findsNothing);
      expect(find.text('Allocation hidden'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'crypto-only portfolio and missing constituent quotes render safely',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      addTearDown(wallet.reset);
      wallet.publish(
        WalletSnapshot(
          accountId: wallet.snapshot.accountId,
          version: 2,
          available: {'BTC': AssetAmount.parse('2', 'BTC', 8)},
          pricesMinorUnits: {'BTC': 10000},
          usdNgnMinorUnits: 100000,
        ),
        generation: wallet.generation,
      );
      await tester.pumpWidget(const MaterialApp(home: PortfolioScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      wallet.publish(
        WalletSnapshot(
          accountId: wallet.snapshot.accountId,
          version: 3,
          available: {'BTC': AssetAmount.parse('2', 'BTC', 8)},
          pricesMinorUnits: {},
          usdNgnMinorUnits: 100000,
        ),
        generation: wallet.generation,
      );
      await tester.pumpAndSettle();
      expect(find.text('Value unavailable'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
