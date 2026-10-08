import 'dart:async';

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('welcome-oval')), findsNothing);
    expect(find.byKey(const ValueKey('welcome-currencies')), findsOneWidget);
    expect(find.byType(BrandSplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2601));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 501));
    expect(find.byType(BrandSplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('turning reduced motion on stops the assembly immediately',
      (tester) async {
    final reduced = ValueNotifier(false);
    addTearDown(reduced.dispose);
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => ValueListenableBuilder(
            valueListenable: reduced,
            builder: (context, value, _) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: value),
                child: child!)),
        home: const BrandSplashScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    reduced.value = true;
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('welcome-upper')))
            .transform
            .getTranslation()
            .x,
        0);
    await tester.pump(const Duration(milliseconds: 701));
    await tester.pumpAndSettle();
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

  testWidgets('engine readiness gates the reveal and onboarding timer',
      (tester) async {
    final firstFrame = Completer<void>();
    await tester.pumpWidget(MaterialApp(
        home: BrandSplashScreen(firstFrameReady: firstFrame.future)));
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('welcome-upper')))
            .transform
            .getTranslation()
            .x,
        42);
    firstFrame.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2400));
    expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('welcome-upper')))
            .transform
            .getTranslation()
            .x,
        closeTo(0, .001));
    expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('welcome-lower')))
            .transform
            .getTranslation()
            .y,
        closeTo(0, .001));
    await tester.pump(const Duration(milliseconds: 501));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backgrounding pauses the introduction until return',
      (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    await tester.pumpWidget(const MaterialApp(home: BrandSplashScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(OnboardingScreen), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'static welcome fits narrow and landscape screens with large text',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: const TextScaler.linear(2)),
              child: child!),
          home: const BrandSplashScreen()));
      await tester.pump();
      expect(find.byKey(const ValueKey('welcome-currencies')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
