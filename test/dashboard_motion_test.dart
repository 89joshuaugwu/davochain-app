import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/shared/widgets/davo_auth_journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'hiding balance removes readable value immediately and never restarts entrance',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pumpAndSettle();
    expect(find.text('\u20a61,284,500.35'), findsOneWidget);
    await tester.tap(find.text('Available Balance'));
    await tester.pump();
    expect(find.text('\u20a61,284,500.35'), findsNothing);
    for (final opacity in tester.widgetList<Opacity>(find.byType(Opacity))) {
      expect(opacity.opacity, greaterThan(0));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('\u20a61,284,500.35'), findsNothing);
  });
  testWidgets(
      'both auth methods keep large text within a stable readable region',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final fingerprint in [false, true]) {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: DavoAuthScene(fingerprint: fingerprint, progress: 1))));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.text('Welcome back')).height, greaterThan(60));
      expect(tester.takeException(), isNull);
    }
  });
}
