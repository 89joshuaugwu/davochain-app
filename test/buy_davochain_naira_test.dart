import 'package:davochain/features/buy_crypto/presentation/buy_crypto_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Buy selects crypto then directly opens the single Davochain source',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => startBuyCryptoFlow(context),
                child: const Text('Buy crypto'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Buy crypto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle();
      expect(find.byType(BuyAmountScreen), findsOneWidget);
      expect(find.text('Select wallet to buy from'), findsNothing);
      expect(find.text('Davochain Naira'), findsOneWidget);
      expect(find.text('Nigerian Naira'), findsNothing);
      expect(find.text('Add money'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      wallet.reset();
    },
  );
  testWidgets('legacy funding sheet only offers one branded wallet', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BuyFundingWalletSheet())),
    );
    expect(find.text('Davochain Naira'), findsOneWidget);
    expect(find.text('Nigerian Naira'), findsNothing);
    expect(BuyFundingWallet.ngd.symbol, 'NGN');
  });
}
