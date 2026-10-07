import 'package:davochain/core/navigation/app_page_route.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app routes use platform Material transitions', () {
    expect(AppPageRoute<void>(builder: (_) => const SizedBox()),
        isA<MaterialPageRoute<void>>());
  });

  testWidgets('button scales on press, activates once with one haptic',
      (tester) async {
    var taps = 0;
    final haptics = <MethodCall>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DavoPrimaryButton(
                label: 'Continue', onPressed: () => taps++))));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Continue')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        lessThan(1));
    expect(taps, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(haptics, hasLength(1));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('loading and disabled buttons cannot activate', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      DavoPrimaryButton(
          label: 'Loading', loading: true, onPressed: () => taps++),
      DavoPrimaryButton(
          label: 'Disabled', enabled: false, onPressed: () => taps++),
    ]))));
    await tester.tap(find.byType(DavoPrimaryButton).first);
    await tester.tap(find.text('Disabled'));
    await tester.pump();
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Loading, loading'), findsOneWidget);
  });

  testWidgets('cancelled button press does not activate or vibrate',
      (tester) async {
    var taps = 0;
    var haptics = 0;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics++;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DavoPrimaryButton(
                label: 'Continue', onPressed: () => taps++))));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Continue')));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(haptics, 0);
  });

  testWidgets('iOS route supports edge swipe back', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: Builder(
          builder: (context) => Scaffold(
                  body: TextButton(
                onPressed: () => pushAppPage<void>(
                    context, (_) => const Scaffold(body: Text('Details'))),
                child: const Text('Open'),
              ))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(1, 200), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Details'), findsNothing);
  });

  testWidgets('reduced motion bypasses route visual transitions',
      (tester) async {
    const child = Text('Details');
    final route = AppPageRoute<void>(builder: (_) => child);
    Widget? transition;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Builder(builder: (context) {
        transition = route.buildTransitions(
            context,
            const AlwaysStoppedAnimation(.5),
            const AlwaysStoppedAnimation(0),
            child);
        return transition!;
      }),
    )));
    expect(identical(transition, child), isTrue);
  });

  testWidgets('reduced motion keeps button still and loading indicator static',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Scaffold(
          body: Column(children: [
        DavoPrimaryButton(label: 'Continue', onPressed: () {}),
        const DavoPrimaryButton(
            label: 'Loading', loading: true, onPressed: null),
      ])),
    )));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Continue')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).scale,
        1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await gesture.cancel();
  });
}
