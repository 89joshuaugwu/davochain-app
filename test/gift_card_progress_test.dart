import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const brand =
    GiftCardBrand(name: 'Amazon', asset: 'assets/figma_exact/amazon.png');

double progress(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .value!;

Future<void> mount(WidgetTester tester, Widget screen,
    {bool reducedMotion = false}) async {
  tester.view.physicalSize = const Size(430, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
      child: child!,
    ),
    home: screen,
  ));
  await tester.pumpAndSettle();
}

Future<void> fillDetails(WidgetTester tester, {bool sell = false}) async {
  await tester.tap(find.text('Select Gift Card Sub Category'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('France Amazon'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), '100');
  if (sell) {
    await tester.tap(find.text('Upload Card Image(s)').last);
  }
  await tester.pumpAndSettle();
}

Future<void> acceptTerms(WidgetTester tester) async {
  final terms = find.text('I have read and accepted the terms');
  await tester.ensureVisible(terms);
  await tester.tap(terms);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'buy routes advance the blue line and back restores the prior step',
      (tester) async {
    await mount(tester, const GiftCardBuyFormScreen(brand: brand));
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(progress(tester), closeTo(1 / 3, .001));
    await fillDetails(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardDeliveryScreen), findsOneWidget);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(progress(tester), closeTo(2 / 3, .001));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardBuyReviewScreen), findsOneWidget);
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(progress(tester), 1);
    Navigator.of(tester.element(find.byType(GiftCardBuyReviewScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(progress(tester), closeTo(2 / 3, .001));
  });

  testWidgets('sell routes advance through details, review and confirmation',
      (tester) async {
    await mount(tester, const GiftCardSellFormScreen(brand: brand));
    expect(progress(tester), closeTo(1 / 3, .001));
    await fillDetails(tester, sell: true);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardSellReviewScreen), findsOneWidget);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(progress(tester), closeTo(2 / 3, .001));
    await acceptTerms(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(progress(tester), 1);
  });

  for (final reduced in [false, true]) {
    testWidgets('confirmation progress settles within 250ms, reduced=$reduced',
        (tester) async {
      await mount(
          tester, const GiftCardSellReviewScreen(brand: brand, amount: 100),
          reducedMotion: reduced);
      await acceptTerms(tester);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Step 3 of 3'), findsOneWidget);
      if (reduced) {
        expect(progress(tester), 1);
      } else {
        await tester.pump(const Duration(milliseconds: 100));
        expect(progress(tester), greaterThan(2 / 3));
        expect(progress(tester), lessThan(1));
        await tester.pump(const Duration(milliseconds: 150));
        expect(progress(tester), 1);
      }
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
