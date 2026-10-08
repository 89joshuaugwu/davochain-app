import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> showDark(WidgetTester tester, Widget screen,
      {double scale = 1}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
              disableAnimations: true, textScaler: TextScaler.linear(scale)),
          child: child!),
      home: screen,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('dark gift catalogue uses dark surface and readable headings',
      (tester) async {
    await showDark(tester, const GiftCardHomeScreen(), scale: 2);
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        const Color(0xFF101827));
    expect(tester.widget<Text>(find.text('Gift Cards')).style?.color,
        const Color(0xFFF3F6FC));
    expect(find.text('Top Gift Cards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark history titles and completed status use readable colors',
      (tester) async {
    await showDark(tester, const TransactionHistoryScreen(), scale: 2);
    expect(tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        const Color(0xFF101827));
    expect(tester.widget<Text>(find.text('Bought Bitcoin')).style?.color,
        const Color(0xFFF3F6FC));
    expect(tester.widget<Text>(find.text('Completed').first).style?.color,
        isNot(const Color(0xFF1BA44D)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark gift pending status and verification remain readable',
      (tester) async {
    await showDark(tester, const GiftCardSellSubmittedScreen(), scale: 2);
    final status = tester.widget<Text>(find.byWidgetPredicate((widget) =>
        widget is Text &&
        widget.textSpan?.toPlainText().contains('Pending') == true));
    final pending = (status.textSpan! as TextSpan).children!.last as TextSpan;
    expect(pending.style?.color, isNot(const Color(0xFF986000)));
    expect(tester.takeException(), isNull);
    await showDark(tester, const GiftCardVerificationScreen(), scale: 2);
    expect(
        tester.widget<Text>(find.text('Verifying your card...')).style?.color,
        const Color(0xFFF3F6FC));
    await tester.ensureVisible(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Copy').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
