import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/onboarding/presentation/brand_splash_screen.dart';
import 'package:davochain/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SplashObserver extends NavigatorObserver {
  Route<dynamic>? destination;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    destination = newRoute;
  }
}

void main() {
  testWidgets(
      'reduced-motion splash is static and opens onboarding without a route animation',
      (tester) async {
    final observer = _SplashObserver();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      navigatorObservers: [observer],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: const BrandSplashScreen(),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Davochain'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pump(const Duration(milliseconds: 1101));
    await tester.pump();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(
        (observer.destination as TransitionRoute<dynamic>).transitionDuration,
        Duration.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('normal brand reveal advances after a brisk finite introduction',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const BrandSplashScreen()));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('welcome-oval')), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome-currencies')), findsOneWidget);
    expect(find.byType(BrandSplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2601));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 501));
    expect(find.byType(BrandSplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing splash cancels its pending navigation',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BrandSplashScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const MaterialApp(home: Text('Another screen')));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Another screen'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}
