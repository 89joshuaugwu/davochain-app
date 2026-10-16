import 'package:davochain/shared/widgets/davo_naira_amount.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buy funding wallet uses only the approved Davochain currency mark',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BuyFundingWalletSheet())));
    expect(find.text('Davochain Naira'), findsOneWidget);
    expect(find.text('Nigerian Naira'), findsNothing);
    expect(find.byType(DavoCurrencyMark), findsOneWidget);
  });
}
