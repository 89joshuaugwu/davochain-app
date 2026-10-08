import 'package:davochain/shared/widgets/davo_receipt_export_frame.dart';
import 'package:flutter/services.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sell percentages use available units and tabs preserve asset',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TradeAmountScreen(
            mode: TradeMode.sell, asset: BuyCryptoAsset.ethereum)));
    await tester.tap(find.text('25%'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '1.25');
    await tester.tap(find.text('Swap').last);
    await tester.pumpAndSettle();
    expect(
        tester.widget<TradeAmountScreen>(find.byType(TradeAmountScreen)).asset,
        BuyCryptoAsset.ethereum);
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<BuyAmountScreen>(find.byType(BuyAmountScreen))
            .initialOrder
            .asset,
        BuyCryptoAsset.ethereum);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trade forms remain usable on a short screen with keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      const BuyAmountScreen(
          initialOrder: BuyCryptoOrder(
              asset: BuyCryptoAsset.bitcoin,
              wallet: BuyFundingWallet.ngd,
              ngnAmount: 0)),
      const TradeAmountScreen(
          mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin),
      const TradeAmountScreen(
          mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin),
    ]) {
      await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  viewInsets: const EdgeInsets.only(bottom: 250),
                  textScaler: const TextScaler.linear(1.3)),
              child: child!),
          home: screen));
      await tester.pumpAndSettle();
      final action = find.text(
          screen is TradeAmountScreen && screen.mode == TradeMode.convert
              ? 'Preview'
              : 'Continue');
      expect(tester.getBottomRight(action).dy, lessThan(318));
      await tester.ensureVisible(find.text('Max'));
      await tester.tap(find.text('Max'));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: screen is TransactionDetailsScreen
              ? '${screen.kind}, receipt: ${screen.receipt}'
              : '${screen.runtimeType}');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('receipts and deposit details scroll at larger text sizes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      for (final kind in TxKind.values) ...[
        TransactionDetailsScreen(
            kind: kind,
            target: 'bc1qverylongwalletaddressforreceiptlayout',
            amount: .03),
        TransactionDetailsScreen(
            kind: kind,
            target: 'bc1qverylongwalletaddressforreceiptlayout',
            amount: .03,
            receipt: true),
      ],
      const DepositStatusScreen(success: true),
      const DepositStatusScreen(success: false),
    ]) {
      await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!),
          home: screen));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: screen is TransactionDetailsScreen
              ? '${screen.kind}, receipt: ${screen.receipt}'
              : '${screen.runtimeType}');
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('conversion summary selectors and swap arrows retain live values',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TradeAmountScreen(
            mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin)));
    expect(find.text('0.00 BTC'), findsOneWidget);
    expect(find.text('\u2248 0.00 USD'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(3));
    expect(find.byTooltip('Swap assets'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0.2');
    await tester.pump();
    expect(find.text('0.20 BTC'), findsOneWidget);
    await tester.tap(find.text('0.20 BTC'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum'));
    await tester.pumpAndSettle();
    expect(find.text('0.20 ETH'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '0.2');
    await tester.ensureVisible(find.byTooltip('Swap assets'));
    await tester.tap(find.byTooltip('Swap assets'));
    await tester.pump();
    expect(find.text('675.32 USDT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'conversion review shares value edges and wraps on narrow screens',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fontLoader = FontLoader('Sora')
      ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(393, 852);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: 'Sora'),
        home: const TradeReviewScreen(kind: TxKind.conversion, amount: .03)));
    await tester.pumpAndSettle();
    final rate = find.text('1 USDT \u2248 0.00006417 BTC');
    expect(rate, findsOneWidget);
    expect(tester.getSize(rate).height, lessThan(30));
    expect(tester.getTopRight(rate).dx,
        closeTo(tester.getTopRight(find.text('Free')).dx, .01));
    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!),
        home: const TradeReviewScreen(kind: TxKind.conversion, amount: .03)));
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(find.text('Confirm conversion')).dy,
        lessThan(568));
    expect(tester.takeException(), isNull);
  });
  testWidgets('conversion receipt contains branded card summary and footer',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TransactionDetailsScreen(
            kind: TxKind.conversion,
            target: 'USDT',
            amount: .03,
            receipt: true)));
    await tester.pumpAndSettle();
    expect(find.text('Davochain'), findsOneWidget);
    expect(find.text('Conversion Receipt'), findsOneWidget);
    final card = find
        .ancestor(of: find.text('Completed'), matching: find.byType(Container))
        .last;
    expect(
        find.descendant(
            of: card, matching: find.text('Thank you for using Davochain')),
        findsOneWidget);
    expect(
        find.descendant(of: card, matching: find.text('From')), findsOneWidget);
    expect(
        find.descendant(of: card, matching: find.text('To')), findsOneWidget);
    expect(
        find.descendant(
            of: card, matching: find.byIcon(Icons.open_in_new_rounded)),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('sell input and proceeds are centered with computed balance USD',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: TradeAmountScreen(
            mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin)));
    await tester.pumpAndSettle();
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.style!.fontSize, 24);
    expect(input.decoration!.hintStyle!.fontSize, 24);
    expect(tester.getCenter(find.byType(TextField)).dx, closeTo(393 / 2, .01));
    expect(find.text('\u2248 \u20a60.00'), findsOneWidget);
    expect(find.textContaining('\u2248 (\$'), findsOneWidget);
    expect(find.text('1 USDT \u2248 (\u20a61,540.00)'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0.03045');
    await tester.pump();
    expect(find.text('\u2248 \u20a6730,800.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'sell review includes naira receive card and aligned quote summary',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TradeReviewScreen(kind: TxKind.sell, amount: .03045)));
    await tester.pumpAndSettle();
    expect(find.text('You are Selling'), findsOneWidget);
    expect(find.text('To (You will receive)'), findsOneWidget);
    expect(find.text('Nigerian Naira'), findsOneWidget);
    expect(find.text('\u20a6730,800.00'), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    final rate = find.text('1 USDT \u2248 \u20a61,540.00');
    expect(rate, findsOneWidget);
    expect(tester.getTopRight(rate).dx,
        closeTo(tester.getTopRight(find.text('Free')).dx, .01));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'completed sell details expose amount and computed received total',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TransactionDetailsScreen(
            kind: TxKind.sell, target: 'NGN', amount: .03045)));
    await tester.pumpAndSettle();
    expect(find.text('Nigerian Naira'), findsOneWidget);
    expect(find.text('Asset'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('0.0304500'), findsOneWidget);
    expect(find.text('Total Received'), findsOneWidget);
    expect(find.text('\u20a6730,800.00'), findsNWidgets(2));
    expect(find.text('1 USDT \u2248 \u20a61,540.00'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Share Receipt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('each crypto receipt retains its type in export frame',
      (tester) async {
    const types = {
      TxKind.internal: 'Transfer',
      TxKind.external: 'External Transfer',
      TxKind.sell: 'Sell',
      TxKind.conversion: 'Conversion'
    };
    for (final entry in types.entries) {
      await tester.pumpWidget(MaterialApp(
          home: TransactionDetailsScreen(
              kind: entry.key,
              target:
                  entry.key == TxKind.conversion ? 'USDT' : 'demo-recipient',
              amount: .03,
              receipt: true)));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<DavoReceiptExportFrame>(
                  find.byType(DavoReceiptExportFrame))
              .receiptType,
          entry.value);
      expect(find.text('${entry.value} Receipt'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
