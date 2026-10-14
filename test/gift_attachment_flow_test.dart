import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'support/gift_evidence_fixture.dart';

void main() {
  testWidgets(
      'reselecting the current card type preserves a valid uploaded trade',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final selected = (await tester.runAsync(giftEvidenceFixture))!;
    addTearDown(selected.release);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: GiftCardSellFormScreen(
            brand: const GiftCardBrand(
                name: 'Steam', asset: 'assets/figma_exact/steam.png'),
            evidencePicker: (_) async => selected)));
    await tester.tap(find.text('Select Gift Card Sub Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('France Steam'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '50');
    await tester.tap(find.text('Upload Card Image(s)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Physical'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNotNull);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardSellReviewScreen), findsOneWidget);
  });
  testWidgets(
      'uploaded evidence explains missing product and invalid denomination',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final selected = (await tester.runAsync(giftEvidenceFixture))!;
    addTearDown(selected.release);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: GiftCardSellFormScreen(
            brand: const GiftCardBrand(
                name: 'Steam', asset: 'assets/figma_exact/steam.png'),
            evidencePicker: (_) async => selected)));
    await tester.tap(find.text('Upload Card Image(s)').last);
    await tester.pumpAndSettle();
    expect(find.text('Select a gift card subcategory to continue.'),
        findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull);
    await tester.tap(find.text('Select Gift Card Sub Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('France Steam'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '49');
    await tester.pump();
    expect(find.text('Enter a card amount of at least 50.'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull);
    await tester.enterText(find.byType(TextField), '50');
    await tester.pump();
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNotNull);
    await tester.tap(find.text('E-code'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull);
    expect(find.text('Select a gift card subcategory to continue.'),
        findsOneWidget);
  });
  testWidgets('selected evidence reaches review and removal disables continue',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final selected = (await tester.runAsync(giftEvidenceFixture))!;
    addTearDown(selected.release);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: GiftCardSellFormScreen(
            brand: const GiftCardBrand(
                name: 'Steam', asset: 'assets/figma_exact/steam.png'),
            evidencePicker: (_) async => selected)));
    await tester.tap(find.text('Select Gift Card Sub Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('France Steam'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '75');
    await tester.tap(find.text('Upload Card Image(s)').last);
    await tester.pumpAndSettle();
    expect(find.text('chosen-steam.png'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final review = tester.widget<GiftCardSellReviewScreen>(
        find.byType(GiftCardSellReviewScreen));
    expect(review.draft!.evidence!.path, selected.path);
    expect(review.draft!.product.brandName, 'Steam');
    Navigator.of(tester.element(find.byType(GiftCardSellReviewScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('chosen-steam.png'), findsNothing);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull);
  });
  testWidgets('cancelled native pick never invents Apple evidence',
      (tester) async {
    var pickerRequests = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: GiftCardSellFormScreen(
            brand: const GiftCardBrand(
                name: 'Amazon', asset: 'assets/figma_exact/amazon.png'),
            evidencePicker: (_) async {
              pickerRequests++;
              return null;
            })));
    await tester.ensureVisible(find.text('Upload Card Image(s)').last);
    await tester.tap(find.text('Upload Card Image(s)').last);
    await tester.pumpAndSettle();
    expect(pickerRequests, 1);
    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => i.image)
        .whereType<AssetImage>();
    expect(assets.any((i) => i.assetName.endsWith('apple_card_photo.png')),
        isFalse);
    expect(find.text('Remove'), findsNothing);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull);
  });
  testWidgets('Amazon review uses Amazon terms', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const GiftCardSellReviewScreen(
            brand: GiftCardBrand(
                name: 'Amazon', asset: 'assets/figma_exact/amazon.png'),
            amount: 50)));
    expect(find.textContaining('iTunes gift card codes'), findsNothing);
  });
}
