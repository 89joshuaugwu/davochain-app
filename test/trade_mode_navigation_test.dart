import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Buy Sell Swap modes switch without leaving the trade flow',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: BuyAmountScreen(
            initialOrder: BuyCryptoOrder(
                asset: BuyCryptoAsset.bitcoin,
                wallet: BuyFundingWallet.ngd,
                ngnAmount: 0))));
    expect(find.text('Buy'), findsNWidgets(2));
    await tester.tap(find.text('Sell'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TradeAmountScreen>(find.byType(TradeAmountScreen)).mode,
        TradeMode.sell);
    await tester.tap(find.text('Convert'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TradeAmountScreen>(find.byType(TradeAmountScreen)).mode,
        TradeMode.convert);
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyAmountScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
