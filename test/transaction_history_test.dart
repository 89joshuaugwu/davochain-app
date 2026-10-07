import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';

void main() {
  testWidgets('history clearly displays five sample transaction types',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const TransactionHistoryScreen(),
    ));
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Sample transactions'), findsOneWidget);
    for (final title in [
      'Bought Bitcoin',
      'Sold Bitcoin',
      'Converted Bitcoin',
      'Withdrew Bitcoin',
      'Deposited Bitcoin'
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('sample buy opens details and Android back returns to history',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const TransactionHistoryScreen(),
    ));
    await tester.tap(find.text('Bought Bitcoin'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyTransactionDetailsScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
