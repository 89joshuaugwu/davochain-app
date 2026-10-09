import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const order = BuyCryptoOrder(
      asset: BuyCryptoAsset.bitcoin,
      wallet: BuyFundingWallet.ngn,
      ngnAmount: 731540);

  testWidgets(
      'buy review retains complete rate and aligned values on narrow screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!),
        home: const BuyReviewScreen(order: order)));
    await tester.pumpAndSettle();
    final rate = find.text('1 USDT ≈ ₦1,540.00');
    expect(rate, findsOneWidget);
    final edge = tester.getBottomRight(rate).dx;
    expect(tester.getBottomRight(find.text('Free')).dx, closeTo(edge, .01));
    final total = find.text('₦731,540.00').last;
    expect(tester.getBottomRight(total).dx, closeTo(edge, .01));
    await tester.ensureVisible(total);
    await tester.pumpAndSettle();
    expect(total.hitTestable(), findsOneWidget);
    expect(find.text('Confirm').hitTestable(), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buy share opens its own purchase receipt with the same order',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const BuyTransactionDetailsScreen(order: order)));
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyReceiptScreen), findsOneWidget);
    expect(find.text('Purchase Receipt'), findsNothing);
    expect(find.text('Amount paid'), findsOneWidget);
    expect(find.text('731,540.00 NGN'), findsOneWidget);
    expect(find.text('Paid from'), findsOneWidget);
    expect(find.text('Receipt ready to share'), findsNothing);
    expect(
        find.descendant(
            of: find.byKey(const ValueKey('buy-receipt-card')),
            matching: find.text('Completed')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
