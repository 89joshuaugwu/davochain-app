import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';

const brand = GiftCardBrand(name: 'Amazon', asset: 'assets/figma_exact/amazon.png');
void main() {
  testWidgets('recipient delivery survives review and payment', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home:
      const GiftCardDeliveryScreen(brand: brand, amount: 50, quantity: 2)));
    await tester.tap(find.text('Send Gift'));
    await tester.enterText(find.byType(TextField).first, 'recipient@example.com');
    await tester.enterText(find.byType(TextField).last, '+2348012345678');
    await tester.ensureVisible(find.text('Email Delivery'));
    await tester.tap(find.text('Email Delivery'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('recipient@example.com'), findsOneWidget);
    expect(find.text('+2348012345678'), findsOneWidget);
    expect(find.text('Email Delivery'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('recipient@example.com'), findsOneWidget);
  });
  testWidgets('malformed recipient cannot advance', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home:
      const GiftCardDeliveryScreen(brand: brand, amount: 50, quantity: 1)));
    await tester.tap(find.text('Send Gift'));
    await tester.enterText(find.byType(TextField).first, 'invalid');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(GiftCardBuyReviewScreen), findsNothing);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
