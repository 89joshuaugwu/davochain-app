import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'reduced-motion dashboard exposes content immediately without staggered ticks',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: const DavochainDashboardScreen(),
    ));
    expect(find.text('Deposit').hitTestable(), findsOneWidget);
    expect(find.text('Buy Crypto').hitTestable(), findsOneWidget);
    for (final opacity in tester.widgetList<Opacity>(find.byType(Opacity))) {
      expect(opacity.opacity, 1);
    }
    for (final fade
        in tester.widgetList<FadeTransition>(find.byType(FadeTransition))) {
      expect(fade.opacity.value, 1);
    }
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard entrance animation finishes without repeating frames',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Buy Crypto').hitTestable(), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}
