import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_screen.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/shared/widgets/receipt_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address =
      'bc1qverylongwalletaddressforreceiptlayout01234567890123456789';
  testWidgets('receipt columns keep one value edge and copy the complete value',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
      child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            ReceiptDetailRow(label: 'Network', value: 'BTC'),
            ReceiptDetailRow(
                label: 'Asset',
                value: 'Bitcoin (BTC)',
                leading: Icon(Icons.currency_bitcoin)),
            ReceiptDetailRow(
                label: 'Deposit Address', value: address, copyable: true),
          ])),
    ))));
    final edge = tester.getBottomRight(find.text('BTC')).dx;
    for (final value in ['Bitcoin (BTC)', address]) {
      expect(tester.getBottomRight(find.text(value)).dx, closeTo(edge, .01));
    }
    final paragraph = tester.renderObject<RenderParagraph>(find.text(address));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(paragraph.size.height, greaterThan(40));
    expect(tester.getCenter(find.bySemanticsLabel('Copy Deposit Address')).dx,
        greaterThan(tester.getBottomRight(find.text(address)).dx));
    await tester.tap(find.bySemanticsLabel('Copy Deposit Address'));
    await tester.pump();
    expect(copied, address);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'all detail and receipt variants wrap and retain reachable actions',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      for (final wallet in BuyFundingWallet.values)
        BuyReceiptScreen(
            order: BuyCryptoOrder(
                asset: BuyCryptoAsset.bitcoin,
                wallet: wallet,
                ngnAmount: 720000),
            date: DateTime(2026, 10, 8, 12),
            transactionId: address),
      const BuyTransactionDetailsScreen(
          order: BuyCryptoOrder(
              asset: BuyCryptoAsset.bitcoin,
              wallet: BuyFundingWallet.ngn,
              ngnAmount: 720000)),
      for (final kind in TxKind.values) ...[
        TransactionDetailsScreen(kind: kind, target: address, amount: .03),
        TransactionDetailsScreen(
            kind: kind, target: address, amount: .03, receipt: true),
      ],
      const DepositStatusScreen(success: true),
      const DepositStatusScreen(success: false),
      const GiftCardSellSubmittedScreen(),
      const GiftCardBuySuccessScreen(amount: 500, naira: 432500),
    ]) {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!),
          home: screen));
      await tester.pumpAndSettle();
      for (final row in tester
          .widgetList<ReceiptDetailRow>(find.byType(ReceiptDetailRow))) {
        final text = find.descendant(
            of: find.byWidget(row), matching: find.text(row.value));
        final paragraph = tester.renderObject<RenderParagraph>(text);
        expect(paragraph.didExceedMaxLines, isFalse, reason: row.label);
      }
      if (screen is BuyTransactionDetailsScreen ||
          screen is TransactionDetailsScreen && !screen.receipt) {
        expect(find.text('Done').hitTestable(), findsOneWidget);
        expect(find.text('Share Receipt').hitTestable(), findsOneWidget);
      }
      if (screen is GiftCardBuySuccessScreen ||
          screen is GiftCardSellSubmittedScreen) {
        expect(find.text('Start New Trade').hitTestable(), findsOneWidget);
        expect(find.text('View Receipt').hitTestable(), findsOneWidget);
      }
      if (find.byType(ReceiptDetailRow).evaluate().isNotEmpty) {
        final lastRow = find.byType(ReceiptDetailRow).last;
        await tester.ensureVisible(lastRow);
        await tester.pumpAndSettle();
        expect(lastRow.hitTestable(), findsOneWidget);
      } else if (find.text('Share as image').evaluate().isNotEmpty) {
        expect(find.text('Share as image').hitTestable(), findsOneWidget);
        expect(find.text('Share as PDF').hitTestable(), findsOneWidget);
        await tester.drag(
            find.byType(SingleChildScrollView).first, const Offset(0, -2400));
        await tester.pumpAndSettle();
        expect(find.text('Your Davochain transaction record').hitTestable(),
            findsOneWidget);
      }
      expect(tester.takeException(), isNull,
          reason: screen.runtimeType.toString());
      await tester.pumpWidget(const SizedBox());
    }
  });
}
