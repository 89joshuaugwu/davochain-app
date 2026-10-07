import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sell percentages use available units and tabs preserve asset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TradeAmountScreen(mode: TradeMode.sell, asset: BuyCryptoAsset.ethereum)));
    await tester.tap(find.text('25%'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '1.25');
    await tester.tap(find.text('Swap'));
    await tester.pumpAndSettle();
    expect(tester.widget<TradeAmountScreen>(find.byType(TradeAmountScreen)).asset, BuyCryptoAsset.ethereum);
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(tester.widget<BuyAmountScreen>(find.byType(BuyAmountScreen)).initialOrder.asset, BuyCryptoAsset.ethereum);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trade forms remain usable on a short screen with keyboard', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      const BuyAmountScreen(initialOrder: BuyCryptoOrder(asset: BuyCryptoAsset.bitcoin, wallet: BuyFundingWallet.ngd, ngnAmount: 0)),
      const TradeAmountScreen(mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin),
      const TradeAmountScreen(mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin),
    ]) {
      await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: const EdgeInsets.only(bottom: 250), textScaler: const TextScaler.linear(1.3)), child: child!), home: screen));
      await tester.pumpAndSettle();
      final action = find.text(screen is TradeAmountScreen && screen.mode == TradeMode.convert ? 'Preview' : 'Continue');
      expect(tester.getBottomRight(action).dy, lessThan(318));
      await tester.ensureVisible(find.text('Max'));
      await tester.tap(find.text('Max'));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: screen is TransactionDetailsScreen ? '${screen.kind}, receipt: ${screen.receipt}' : '${screen.runtimeType}');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('receipts and deposit details scroll at larger text sizes', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      for (final kind in TxKind.values) ...[
        TransactionDetailsScreen(kind: kind, target: 'bc1qverylongwalletaddressforreceiptlayout', amount: .03),
        TransactionDetailsScreen(kind: kind, target: 'bc1qverylongwalletaddressforreceiptlayout', amount: .03, receipt: true),
      ],
      const DepositStatusScreen(success: true),
      const DepositStatusScreen(success: false),
    ]) {
      await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)), child: child!), home: screen));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: screen is TransactionDetailsScreen ? '${screen.kind}, receipt: ${screen.receipt}' : '${screen.runtimeType}');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
