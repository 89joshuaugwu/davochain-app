import 'package:davochain/shared/widgets/davo_naira_amount.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/shared/widgets/trade_amount_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const screens = <Widget>[
    BuyAmountScreen(
      initialOrder: BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngd,
        ngnAmount: 0,
      ),
    ),
    TradeAmountScreen(mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin),
    TradeAmountScreen(mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin),
  ];

  testWidgets('all trade cards label and right-align their amounts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in screens) {
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pumpAndSettle();
      final labels = find.text('Amount');
      expect(labels, findsNWidgets(2));
      final input = find.byType(TextField);
      expect(tester.widget<TextField>(input).textAlign, TextAlign.right);
      expect(
        tester.getTopRight(input).dx,
        closeTo(tester.getTopRight(labels.first).dx, .01),
      );
      expect(
        tester.getTopLeft(labels.first).dy,
        lessThan(tester.getTopLeft(input).dy),
      );
      // The asset group occupies the left column, alongside the amount.
      final selector =
          screen is TradeAmountScreen && screen.mode == TradeMode.convert
          ? find.text('BTC')
          : find.byType(TradeCurrencySelector).first;
      expect(
        tester.getCenter(selector).dx,
        lessThan(tester.getTopLeft(input).dx),
      );
      if (screen is BuyAmountScreen ||
          (screen is TradeAmountScreen && screen.mode == TradeMode.sell)) {
        expect(find.byType(DavoCashExchangeRate), findsOneWidget);
        expect(find.textContaining('\u20a6'), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('percentage shortcuts span card width and reflect manual edits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in screens) {
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pumpAndSettle();
      final row = find.byType(TradePercentageButtons);
      final buttons = find.descendant(
        of: row,
        matching: find.byType(OutlinedButton),
      );
      expect(buttons, findsNWidgets(5));
      expect(tester.getTopLeft(buttons.first).dx, closeTo(16, .01));
      expect(tester.getTopRight(buttons.last).dx, closeTo(377, .01));
      for (var i = 0; i < 5; i++) {
        expect(tester.getSize(buttons.at(i)).height, greaterThanOrEqualTo(48));
        expect(
          tester.getSize(buttons.at(i)).width,
          closeTo(tester.getSize(buttons.first).width, .01),
        );
      }
      await tester.ensureVisible(find.text('25%'));
      await tester.tap(find.text('25%'));
      await tester.pump();
      final selected = tester.widget<OutlinedButton>(buttons.at(1));
      expect(selected.style!.backgroundColor!.resolve({}), AppColors.primary);
      await tester.enterText(find.byType(TextField), '0.00123');
      await tester.pump();
      expect(
        tester
            .widget<OutlinedButton>(buttons.at(1))
            .style!
            .backgroundColor!
            .resolve({}),
        isNot(AppColors.primary),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('large text and long amounts fit narrow trade cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in screens) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        '123456789012345.12345678',
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Max'));
      expect(find.text('Max').hitTestable(), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: screen.runtimeType.toString(),
      );
      await tester.pumpWidget(const SizedBox());
    }
  });
}
