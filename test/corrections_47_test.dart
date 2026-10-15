import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/profile_settings/presentation/settings_content_overlay.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('search sheet height remains stable for results and no results',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: BuyCryptoAssetSheet())));
    await tester.pumpAndSettle();
    final body = find.byKey(const ValueKey('asset-sheet-body'));
    final height = tester.getSize(body).height;
    final search = find.byKey(const ValueKey('asset-search'));
    for (final query in ['btc', 'nothing-matches', 'ada', '']) {
      await tester.enterText(search, query);
      await tester.pumpAndSettle();
      expect(tester.getSize(body).height, height);
      expect(tester.takeException(), isNull);
    }
    await tester.enterText(search, 'ada');
    await tester.pumpAndSettle();
    expect(find.text('Cardano'), findsOneWidget);
    expect(find.text('0 ADA'), findsOneWidget);
    expect(find.text('Unavailable'), findsNothing);
  });
  testWidgets('article paragraphs use requested justification', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () =>
                        showSettingsContent(context, 'Privacy Policy'),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final paragraph =
        tester.widget<Text>(find.textContaining('Account details include'));
    expect(paragraph.textAlign, TextAlign.justify);
    expect(tester.takeException(), isNull);
  });
  for (final screen in <Widget>[
    const PrivacyScreen(),
    const VerificationOverviewScreen(),
    const GiftCardBuyReviewScreen(
        brand: GiftCardBrand(
            name: 'Amazon', asset: 'assets/figma_exact/amazon.png'),
        amount: 50,
        quantity: 1),
    const GiftCardSellReviewScreen(
        brand: GiftCardBrand(
            name: 'Amazon', asset: 'assets/figma_exact/amazon.png'),
        amount: 50)
  ]) {
    testWidgets('no added policy blocks on ${screen.runtimeType}',
        (tester) async {
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
      await tester.pumpAndSettle();
      expect(find.text('Read Privacy Policy'), findsNothing);
      expect(find.text('Terms and Conditions'), findsNothing);
      expect(find.text('Privacy Policy'), findsNothing);
    });
  }
}
