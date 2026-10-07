import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buy funding wallet uses flag for NGN and Davochain coin for NGD',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BuyFundingWalletSheet())));
    for (final entry in {
      'Nigerian Naira': 'assets/figma_exact/buy_nigeria.png',
      'Davochain Naira': 'assets/images/brand/naira_coin.png',
    }.entries) {
      final row = find
          .ancestor(of: find.text(entry.key), matching: find.byType(InkWell))
          .first;
      final image = tester.widget<Image>(
          find.descendant(of: row, matching: find.byType(Image)));
      expect((image.image as AssetImage).assetName, entry.value);
    }
  });
}
