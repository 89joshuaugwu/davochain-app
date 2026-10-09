import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/core/theme/appearance_controller.dart';
import 'package:davochain/features/profile_settings/presentation/appearance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppearanceController> _controller(
    {Future<void> Function(String)? write}) async {
  final controller = AppearanceController(
      read: () async => 'light', write: write ?? (_) async {});
  await controller.restore();
  return controller;
}

Widget _host(AppearanceController controller,
        {bool reduce = false, double scale = 1}) =>
    MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                disableAnimations: reduce,
                textScaler: TextScaler.linear(scale),
                platformBrightness: Brightness.dark),
            child: child!),
        home: AppearanceScreen(controller: controller));

Finder _image(String mode) => find.byKey(ValueKey('appearance-image-$mode'));

void main() {
  testWidgets(
      'rapid switches retain a visible preview and settle on the final draft',
      (tester) async {
    final controller = await _controller();
    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(_image('light'), findsOneWidget);
    expect(_image('dark'), findsOneWidget);
    await tester.tap(find.text('System'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(find.text('Light'));
    await tester.pump();
    expect(
        find.descendant(
            of: find.byKey(const ValueKey('appearance-live-preview')),
            matching: find.byType(Image)),
        findsWidgets);
    await tester.pumpAndSettle();
    expect(_image('light'), findsOneWidget);
    expect(_image('dark'), findsNothing);
    expect(_image('system'), findsNothing);
    final backdrop = find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is ResizeImage &&
        ((w.image as ResizeImage).imageProvider as AssetImage).assetName ==
            'assets/images/appearance/phone_preview_background.png');
    expect(backdrop, findsOneWidget);
    expect(tester.widget<Image>(backdrop).fit, BoxFit.cover);
    expect(controller.mode, ThemeMode.light);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets(
      'reduced motion cuts instantly and System shows both phones regardless of OS',
      (tester) async {
    final controller = await _controller();
    await tester.pumpWidget(_host(controller, reduce: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System'));
    await tester.pump();
    expect(_image('system'), findsOneWidget);
    expect(_image('light'), findsNothing);
    expect(_image('dark'), findsNothing);
    final image = tester.widget<Image>(_image('system'));
    expect(image.fit, BoxFit.contain);
    expect(image.alignment, Alignment.bottomCenter);
    expect(image.image, isA<ResizeImage>());
    final resized = image.image as ResizeImage;
    expect((resized.imageProvider as AssetImage).assetName,
        'assets/images/appearance/davochain_iphone_app_mockup_duo.png');
    expect(resized.width, lessThanOrEqualTo(1200));
    expect(controller.mode, ThemeMode.light);
  });

  testWidgets('backgrounding finishes a switch without a running ticker',
      (tester) async {
    final controller = await _controller();
    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(_image('dark'), findsOneWidget);
    expect(_image('light'), findsNothing);
    final builder = tester.widget<AnimatedBuilder>(find.descendant(
      of: find.byKey(const ValueKey('appearance-live-preview')),
      matching: find.byType(AnimatedBuilder),
    ));
    expect((builder.animation as AnimationController).isAnimating, false);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets(
      'save failure retains the draft and pending persistence disables choices and back',
      (tester) async {
    final pending = Completer<void>();
    final controller = await _controller(write: (_) => pending.future);
    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(
        tester
            .widget<IconButton>(find
                .ancestor(
                    of: find.byTooltip('Back'),
                    matching: find.byType(IconButton))
                .first)
            .onPressed,
        isNull);
    final dark = tester.widget<Semantics>(find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.label == 'Dark appearance'));
    expect(dark.properties.enabled, false);
    expect(controller.mode, ThemeMode.light);
    pending.completeError(StateError('disk unavailable'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Could not save appearance. Please try again.'),
        findsOneWidget);
    expect(_image('dark'), findsOneWidget);
    expect(controller.mode, ThemeMode.light);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets(
      '320 width and double text preserve all labels and a reachable Next',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller();
    await tester.pumpWidget(_host(controller, scale: 2));
    await tester.pumpAndSettle();
    for (final label in ['Light', 'Dark', 'System']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.ensureVisible(find.text('Next'));
    expect(tester.takeException(), isNull);
    expect(
        tester
            .getSize(find.byKey(const ValueKey('appearance-live-preview')))
            .height,
        360);
  });
}
