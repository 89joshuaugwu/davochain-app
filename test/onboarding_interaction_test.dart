import 'package:davochain/core/navigation/app_routes.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openWelcome(WidgetTester tester,
    {Size size = const Size(411, 914),
    double textScale = 1,
    bool reduced = false}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale), disableAnimations: reduced),
      child: child!,
    ),
    routes: {
      AppRoutes.dashboard: (_) => const Scaffold(body: Text('Demo dashboard')),
      AppRoutes.login: (_) => const Scaffold(body: Text('Login destination')),
      AppRoutes.signup: (_) => const Scaffold(body: Text('Signup destination')),
    },
    home: const OnboardingScreen(),
  ));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('landscape welcome keeps navigation reachable', (tester) async {
    await openWelcome(tester, size: const Size(568, 320), textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Create Account').hitTestable(), findsOneWidget);
  });

  testWidgets('slow swipe advances and Android back returns to previous page',
      (tester) async {
    await openWelcome(tester);
    await tester.timedDrag(find.byType(PageView), const Offset(-290, 0),
        const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Simple. Fast. Secure.').hitTestable(), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Trade Crypto, Your Way').hitTestable(), findsOneWidget);
  });

  testWidgets('compact large-text welcome keeps actions reachable',
      (tester) async {
    await openWelcome(tester, size: const Size(320, 568), textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Create Account').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Signup destination'), findsOneWidget);
  });

  testWidgets('reduced motion settles and demo opens without credentials',
      (tester) async {
    await openWelcome(tester, reduced: true);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.tap(find.text('Explore demo'));
    await tester.pumpAndSettle();
    expect(find.text('Demo dashboard'), findsOneWidget);
  });

  testWidgets('skip reaches final page and login is available', (tester) async {
    await openWelcome(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(
        find.text('Turn Gift Cards Into Cash').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
  });
}
