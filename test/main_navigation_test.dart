import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/shared/widgets/davo_main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main destinations retain navigation and details cover it',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-assets-soft-edge')),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('main-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('Nigerian Naira'), findsOneWidget);
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    await tester.tap(find.text('Sell').first);
    await tester.pumpAndSettle();
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    await tester.tap(find.text('Swap').first);
    await tester.pumpAndSettle();
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    await tester.tap(find.text('Buy').first);
    await tester.pumpAndSettle();
    expect(find.text('Nigerian Naira'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('main-tab-2')));
    await tester.pumpAndSettle();
    expect(find.text('Buy and sell gift cards instantly'), findsOneWidget);
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('main-tab-3')));
    await tester.pumpAndSettle();
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    await tester.tap(find.text('Personal Information'));
    await tester.pumpAndSettle();
    expect(find.byType(DavoMainNavigation), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(DavoMainNavigation), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('main-tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('Available Balance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
