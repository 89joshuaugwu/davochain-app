import 'package:davochain/shared/widgets/davo_naira_amount.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> mount(WidgetTester tester, Widget screen,
    {double textScale = 2}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(() => (FontLoader('Sora')
        ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
      .load());
  await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!),
      home: screen));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('small phone promotion keeps its badge clear of the headline',
      (tester) async {
    await mount(tester, const DavochainDashboardScreen(), textScale: 1);
    final headline =
        find.text('Turn your Crypto and\nGift Cards into cash\ninstantly');
    final badge = find.text('Fast \u2022 Secure \u2022 Reliable');
    expect(headline, findsOneWidget);
    if (badge.evaluate().isNotEmpty) {
      expect(tester.getRect(headline).overlaps(tester.getRect(badge)), isFalse);
    }
    final description = find.text(
        'Trade top crypto and gift card at good rates with fast payment.');
    expect(tester.getRect(headline).overlaps(tester.getRect(description)),
        isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'small phone portfolio keeps heading and monetary amount on one line',
      (tester) async {
    await mount(tester, const PortfolioScreen());
    expect(tester.getRect(find.text('Portfolio')).height, lessThan(60));
    final amount = find.byType(DavoNairaAmount).first;
    expect(tester.getRect(amount).height, lessThan(70));
    expect(tester.getRect(amount).right, lessThanOrEqualTo(300));
    expect(tester.takeException(), isNull);
  });
  testWidgets('small phone dashboard keeps full deposit and withdrawal labels',
      (tester) async {
    await mount(tester, const DavochainDashboardScreen());
    for (final label in ['Deposit', 'Withdraw']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.didExceedMaxLines, isFalse,
          reason: '$label must remain readable');
      expect(find.text(label).hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
