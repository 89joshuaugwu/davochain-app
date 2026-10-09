import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/shared/widgets/davo_animated_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brand = GiftCardBrand(
      name: 'iTunes/Apple', asset: 'assets/figma_exact/apple.png');
  testWidgets(
      'gift home referral stays compact and leaves trading cards visible',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const GiftCardHomeScreen()));
    await tester.pumpAndSettle();
    expect(
        tester.getSize(find.byKey(const ValueKey('gift-referral-card'))).height,
        lessThan(120));
    expect(find.text('Top Gift Cards').hitTestable(), findsOneWidget);
    expect(find.text('Refer').hitTestable(), findsOneWidget);
    expect(find.text('Tap to trade'), findsNWidgets(2));
    await tester.ensureVisible(find.text('View All'));
    await tester.pumpAndSettle();
    expect(find.text('View All').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('purchase form and review keep actions usable on a short phone',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const GiftCardBuyFormScreen(brand: brand)));
    await tester.enterText(find.byType(TextField), '10000.25');
    await tester.pumpAndSettle();
    expect(find.text('10,000.25'), findsOneWidget);
    expect(find.text('Continue').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const GiftCardBuyReviewScreen(
            brand: brand, amount: 20, quantity: 1)));
    await tester.pumpAndSettle();
    final total = find.text('₦17,300').last;
    final fee = find.text('₦0');
    expect(tester.getBottomRight(total).dx,
        closeTo(tester.getBottomRight(fee).dx, .01));
    await tester.ensureVisible(total);
    await tester.pumpAndSettle();
    expect(total.hitTestable(), findsOneWidget);
    expect(find.text('Continue').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'gift review keeps value edges, centered image and both agreements',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const GiftCardSellReviewScreen(brand: brand, amount: 500)));
    await tester.pumpAndSettle();
    final edge = tester.getBottomRight(find.text('₦0')).dx;
    expect(tester.getBottomRight(find.text('₦865/\$1')).dx, closeTo(edge, .01));
    expect(tester.getBottomRight(find.text('₦432,500').last).dx,
        closeTo(edge, .01));
    final image = find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName.endsWith('apple_card_photo.png'));
    expect(tester.getCenter(image).dx, closeTo(160, .01));
    await tester.ensureVisible(find.byType(DavoAnimatedCheckbox));
    await tester.tap(find.byType(DavoAnimatedCheckbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('I have read and accepted the terms'), findsNothing);
    expect(find.text('I confirm this card is valid'), findsOneWidget);
    final submit = find.widgetWithText(FilledButton, 'Submit');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await tester.ensureVisible(find.byType(DavoAnimatedCheckbox));
    await tester.tap(find.byType(DavoAnimatedCheckbox));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'gift verification timeline stays readable and static for reduced motion',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                disableAnimations: true,
                textScaler: const TextScaler.linear(1.3)),
            child: child!),
        home: const GiftCardVerificationScreen()));
    await tester.pumpAndSettle();
    final title = tester.getRect(find.text('Submitted'));
    final meta =
        tester.getRect(find.textContaining('Submitted; review is pending.'));
    expect(meta.top, greaterThan(title.bottom));
    expect(meta.left, closeTo(title.left, .01));
    await tester.ensureVisible(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Reference'), findsOneWidget);
    expect(find.text('Copy').hitTestable(), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.textContaining('mins'), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
