import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/shared/widgets/receipt_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final external in [false, true]) {
    testWidgets(
        'withdraw form adapts and retains input when asset changes ($external)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
          MaterialApp(home: CryptoWithdrawEntryScreen(external: external)));
      await tester.pumpAndSettle();
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text('Bitcoin'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'demo-recipient');
      await tester.enterText(find.byType(TextField).at(1), '12345.678900');
      expect(
          tester
              .widget<TextField>(find.byType(TextField).at(1))
              .controller!
              .text,
          '12,345.678900');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      if (external) {
        await tester.ensureVisible(find.text('Select withdrawal network'));
        await tester.tap(find.text('Select withdrawal network'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bitcoin (BTC)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('I Understand'));
        await tester.pumpAndSettle();
        expect(find.text('Bitcoin (BTC)'), findsOneWidget);
      }
      await tester.ensureVisible(find.text('Change Asset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change Asset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ethereum'));
      await tester.pumpAndSettle();
      expect(find.text('Ethereum'), findsOneWidget);
      expect(
          tester
              .widget<TextField>(find.byType(TextField).at(0))
              .controller!
              .text,
          'demo-recipient');
      expect(
          tester
              .widget<TextField>(find.byType(TextField).at(1))
              .controller!
              .text,
          '12,345.678900');
      if (external) {
        expect(find.text('Select withdrawal network'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(tester.getBottomRight(find.text('Confirm')).dy, lessThan(568));
      } else {
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        final row = tester
            .widgetList<ReceiptDetailRow>(find.byType(ReceiptDetailRow))
            .firstWhere((r) => r.label == 'Asset');
        expect(row.value, 'Ethereum (ETH)');
        expect(row.leading, isNotNull);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('bank name checks resolve finitely and stale checks cancel',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddBankScreen()));
    await tester.tap(find.text('Select bank name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Access Bank'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0123456789');
    await tester.pump();
    expect(find.text('Checking account\u2026'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '012345678');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Callietus Ezeike Chinecherem'), findsNothing);
    await tester.enterText(find.byType(TextField), '0123456789');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Checking account\u2026'), findsNothing);
    expect(find.text('Callietus Ezeike Chinecherem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
