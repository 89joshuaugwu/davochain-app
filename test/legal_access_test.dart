import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/features/profile_settings/presentation/verification/advanced_verification_flow.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(() {
    session.reset();
  });
  tearDown(() {
    session.reset();
  });
  testWidgets(
      'privacy reader preserves an entered BVN and does not submit verification',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home:
            const BasicIdentityNumberScreen(method: BasicIdentityMethod.bvn)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '12345678901');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Read Privacy Policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Your information, your choices'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '12345678901');
    expect(VerificationSession.instance.basicVerified, isFalse);
  });
  testWidgets(
      'advanced verification offers privacy before collection without advancing',
      (tester) async {
    VerificationSession.instance.completeProfile();
    VerificationSession.instance
        .submitBasic(BasicIdentityMethod.nin, '12345678901');
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const AdvancedVerificationFlowScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Read Privacy Policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Your information, your choices'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AdvancedVerificationFlowScreen), findsOneWidget);
    expect(VerificationSession.instance.advancedSubmitted, isFalse);
  });
  for (final sell in [false, true]) {
    testWidgets(
        'gift ${sell ? "sell" : "buy"} policies leave the trade on review',
        (tester) async {
      const brand = GiftCardBrand(
          name: 'iTunes/Apple', asset: 'assets/figma_exact/apple.png');
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: sell
              ? const GiftCardSellReviewScreen(brand: brand, amount: 100)
              : const GiftCardBuyReviewScreen(
                  brand: brand, amount: 100, quantity: 1)));
      await tester.pumpAndSettle();
      for (final entry in {
        'Terms and Conditions': 'Using Davochain',
        'Privacy Policy': 'Your information, your choices'
      }.entries) {
        await tester.ensureVisible(find.text(entry.key));
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget);
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Trade Breakdown'), findsOneWidget);
      expect(find.byType(GiftCardPaymentScreen), findsNothing);
      if (sell) expect(find.text('Trade Terms'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'signup policies open without accepting consent or leaving signup',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const CountrySelectionScreen()));
    await tester.pumpAndSettle();
    for (final entry in {
      'Terms and conditions': 'Using Davochain',
      'Privacy policy': 'Your information, your choices'
    }.entries) {
      await tester.tapOnText(find.textRange.ofSubstring(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(CountrySelectionScreen), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('privacy controls link to the same policy reader',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const PrivacyScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Read Privacy Policy'), 250);
    await tester.tap(find.text('Read Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Your information, your choices'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyScreen), findsOneWidget);
  });
  testWidgets('Help legal category links to both policies', (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HelpCenterScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Legal');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Legal & Compliance'));
    await tester.pumpAndSettle();
    for (final entry in {
      'Terms and Conditions': 'Using Davochain',
      'Privacy Policy': 'Your information, your choices'
    }.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
