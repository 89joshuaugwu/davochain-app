import 'package:davochain/core/money/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/wallets/presentation/wallet_picker_sheet.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';

void main() {
  testWidgets(
    'wallet search includes cash and zero-balance catalog without add flow',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      addTearDown(wallet.reset);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WalletPickerSheet())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Davochain Naira'), findsOneWidget);
      expect(find.text('Add crypto asset'), findsNothing);
      await tester.enterText(find.byType(TextField), 'xrp');
      await tester.pumpAndSettle();
      expect(find.text('XRP'), findsWidgets);
      expect(find.text('Bitcoin'), findsNothing);
      await tester.enterText(find.byType(TextField), 'davochain');
      await tester.pumpAndSettle();
      expect(find.text('Davochain Naira'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'receiving search shows unsupported networks without enabling them',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      addTearDown(wallet.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WalletPickerSheet(networkOnly: true)),
        ),
      );
      await tester.enterText(find.byType(TextField), 'cardano');
      await tester.pumpAndSettle();
      expect(find.text('Cardano'), findsOneWidget);
      expect(find.text('Network receiving unavailable'), findsOneWidget);
      expect(
        tester
            .widget<InkWell>(find.byKey(const ValueKey('wallet-option-ADA')))
            .onTap,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('an unpriced holding keeps its actual quantity', (tester) async {
    final wallet = WalletAccountState.instance..startSimulation(empty: true);
    addTearDown(wallet.reset);
    wallet.publish(
      WalletSnapshot(
        accountId: wallet.snapshot.accountId,
        version: 2,
        available: {'BTC': AssetAmount.parse('2', 'BTC', 8)},
        pricesMinorUnits: {},
      ),
      generation: wallet.generation,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WalletPickerSheet(includeCash: false)),
      ),
    );
    await tester.enterText(find.byType(TextField), 'bitcoin');
    await tester.pumpAndSettle();
    expect(find.text('2 BTC'), findsOneWidget);
    expect(find.text('Value unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
