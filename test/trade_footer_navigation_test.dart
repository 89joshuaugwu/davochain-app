import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('footer Trade opens existing Buy Sell Swap flow and returns home',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trade'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyAmountScreen), findsOneWidget);
    expect(find.text('Swap'), findsOneWidget);
    await tester.tap(find.text('Sell'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TradeAmountScreen>(find.byType(TradeAmountScreen)).mode,
        TradeMode.sell);
    await tester.tap(find.text('Swap'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TradeAmountScreen>(find.byType(TradeAmountScreen)).mode,
        TradeMode.convert);
    Navigator.of(tester.element(find.byType(TradeAmountScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(DavochainDashboardScreen), findsOneWidget);
    expect(find.byType(TradeAmountScreen), findsNothing);
  });
}
