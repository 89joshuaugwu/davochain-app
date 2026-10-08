import 'package:davochain/core/theme/appearance_controller.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

void main() {
  test('overlapping writes preserve selection order', () async {
    final first = Completer<void>();
    final writes = <String>[];
    final controller = AppearanceController(read: () async => null, write:(value) async {
      writes.add(value);
      if (value == 'dark') await first.future;
    });
    final dark = controller.setMode(ThemeMode.dark);
    final light = controller.setMode(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);
    expect(writes,['dark']);
    first.complete();
    await Future.wait([dark,light]);
    expect(writes,['dark','light']);
    expect(controller.mode,ThemeMode.light);
  });
  test('restore defaults System and preserves explicit choice', () async {
    String? stored;
    final controller = AppearanceController(
      read: () async => stored,
      write: (value) async => stored = value,
    );
    await controller.restore();
    expect(controller.mode, ThemeMode.system);
    await controller.setMode(ThemeMode.dark);
    expect(stored, 'dark');
    final restored = AppearanceController(
      read: () async => stored, write: (_) async {},
    );
    await restored.restore();
    expect(restored.mode, ThemeMode.dark);
    stored = 'unexpected';
    await restored.restore();
    expect(restored.mode, ThemeMode.system);
  });

  test('failed save leaves previous mode and emits no change', () async {
    final controller = AppearanceController(
      read: () async => 'light',
      write: (_) async => throw StateError('disk unavailable'),
    );
    await controller.restore();
    var changes = 0;
    controller.addListener(() => changes++);
    await expectLater(controller.setMode(ThemeMode.dark), throwsStateError);
    expect(controller.mode, ThemeMode.light);
    expect(changes, 0);
  });

  testWidgets('nested light theme has independent receipt tokens', (tester) async {
    DavoColors? outer, paper;
    await tester.pumpWidget(MaterialApp(theme: AppTheme.dark, home: Builder(
      builder: (context) {
        outer = DavoColors.of(context);
        return Theme(data: AppTheme.light, child: Builder(builder: (context) {
          paper = DavoColors.of(context);
          return const SizedBox();
        }));
      },
    )));
    expect(outer!.surface, const Color(0xFF101827));
    expect(paper!.surface, Colors.white);
    expect(paper!.ink, AppColors.ink);
  });

  testWidgets('System follows OS changes; explicit Light stays light', (tester) async {
    final platform = tester.platformDispatcher;
    addTearDown(platform.clearPlatformBrightnessTestValue);
    Brightness? brightness;
    Widget app(ThemeMode mode) => MaterialApp(theme: AppTheme.light,
      darkTheme: AppTheme.dark, themeMode: mode, themeAnimationDuration: Duration.zero,
      home: Builder(builder: (context) {
        brightness = Theme.of(context).brightness;
        return const SizedBox();
      }));
    platform.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(app(ThemeMode.system));
    expect(brightness, Brightness.light);
    platform.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(brightness, Brightness.dark);
    await tester.pumpWidget(app(ThemeMode.light));
    expect(brightness, Brightness.light);
  });
}
