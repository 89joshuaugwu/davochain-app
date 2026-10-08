import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brand =
      GiftCardBrand(name: 'Steam', asset: 'assets/figma_exact/steam.png');
  for (final sell in [false, true]) {
    testWidgets(
        '${sell ? 'sell' : 'buy'} subcategory has brand logo and preserves selection',
        (tester) async {
      tester.view.physicalSize = const Size(360, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: sell
              ? const GiftCardSellFormScreen(brand: brand)
              : const GiftCardBuyFormScreen(brand: brand)));
      if (sell) {
        await tester.tap(find.text('E-code'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Select Gift Card Sub Category'));
      await tester.pumpAndSettle();
      expect(find.text('Select subcategory'), findsOneWidget);
      final option = find.widgetWithText(ListTile, 'France Steam');
      final leading = tester.widget<ListTile>(option).leading! as Image;
      expect((leading.image as AssetImage).assetName, brand.asset);
      expect(find.text('${sell ? 'E-code' : 'Physical'} (50 above)'),
          findsOneWidget);
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(
          find.text('France Steam, ${sell ? 'E-code' : 'Physical'} (50 above)'),
          findsOneWidget);
      expect(find.text('Select subcategory'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
