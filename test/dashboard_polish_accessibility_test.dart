import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/shared/widgets/davo_main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('portfolio visibility control has a full target and correct mask',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const PortfolioScreen()));
    await tester.pumpAndSettle();
    final hide = find.byTooltip('Hide portfolio balance');
    expect(hide, findsOneWidget);
    expect(tester.getSize(hide).height, greaterThanOrEqualTo(48));
    await tester.tap(hide);
    await tester.pumpAndSettle();
    expect(find.text('\u20a6\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022'),
        findsOneWidget);
    expect(find.byTooltip('Show portfolio balance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('dashboard actions have native glyphs and accessible hit areas',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    for (final label in ['Deposit', 'Withdraw']) {
      final tap = find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(tap).height, greaterThanOrEqualTo(48));
    }
    final actionImages =
        tester.widgetList<Image>(find.byType(Image)).where((image) {
      final provider = image.image;
      return provider is AssetImage &&
          [
            'buy_action.png',
            'sell_action.png',
            'gift_action.png',
            'history_action.png',
            'notification.png',
            'eye.png'
          ].any(provider.assetName.endsWith);
    });
    expect(actionImages, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation scales labels without consuming the phone viewport',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
                bottomNavigationBar:
                    DavoMainNavigation(index: 0, onChanged: (_) {})))));
    await tester.pump();
    expect(tester.getSize(find.byType(DavoMainNavigation)).height,
        lessThanOrEqualTo(100));
    expect(tester.takeException(), isNull);
  });
  testWidgets('portfolio and naira deposit preserve 200 percent text',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in [
      const PortfolioScreen(),
      const NairaDepositScreen()
    ]) {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: screen)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
