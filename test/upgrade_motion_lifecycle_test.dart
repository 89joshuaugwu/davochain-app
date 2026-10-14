import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/motion/davo_working_indicator.dart';
import 'package:davochain/shared/motion/davo_motion_spec.dart';
import 'package:davochain/shared/widgets/davo_main_shell.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('working painter redraws when its tint changes', () {
    expect(const DavoWorkingPainter(DavoWorkingKind.operation, .3, Colors.blue)
        .shouldRepaint(const DavoWorkingPainter(DavoWorkingKind.operation, .3, Colors.green)), isTrue);
  });
  testWidgets('changing working kind restarts review attention with its own duration', (tester) async {
    final kind = ValueNotifier(DavoWorkingKind.operation);
    addTearDown(kind.dispose);
    await tester.pumpWidget(MaterialApp(home: ValueListenableBuilder<DavoWorkingKind>(
      valueListenable: kind, builder: (_, value, __) => DavoWorkingIndicator(kind: value))));
    await tester.pump(const Duration(milliseconds: 600));
    kind.value = DavoWorkingKind.reviewPending;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    final art = tester.widget<DavoWorkingArtwork>(find.byType(DavoWorkingArtwork));
    expect(art.progress, closeTo(.5, .02));
    await tester.pump(const Duration(milliseconds: 2000));
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('hidden main destinations disable their tickers', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const DavoMainShell()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('main-tab-3')));
    await tester.pumpAndSettle();
    final modes = tester.widgetList<TickerMode>(find.descendant(
      of: find.byType(IndexedStack), matching: find.byType(TickerMode, skipOffstage: false), skipOffstage: false));
    expect(modes.where((mode) => !mode.enabled).length, greaterThanOrEqualTo(3));
  });
  testWidgets('invisible working review pauses without consuming attention time', (tester) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    await tester.pumpWidget(MaterialApp(home: ValueListenableBuilder<bool>(
        valueListenable: visible, builder: (_, enabled, __) => TickerMode(
          enabled: enabled, child: const DavoWorkingIndicator(kind: DavoWorkingKind.reviewPending)))));
    await tester.pump(const Duration(milliseconds: 900));
    visible.value = false;
    await tester.pump();
    final before = tester.widget<DavoWorkingArtwork>(find.byType(DavoWorkingArtwork)).progress;
    await tester.pump(const Duration(seconds: 10));
    visible.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final after = tester.widget<DavoWorkingArtwork>(find.byType(DavoWorkingArtwork)).progress;
    expect(after - before, lessThan(.05));
    await tester.pumpWidget(const SizedBox());
  });
  test('meaningful input hints meet normal text contrast on their fill', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final foreground = theme.inputDecorationTheme.hintStyle!.color!.computeLuminance();
      final background = theme.inputDecorationTheme.fillColor!.computeLuminance();
      final contrast = (background > foreground ? (background + .05) / (foreground + .05) : (foreground + .05) / (background + .05));
      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });
  testWidgets('closing reachable Help Centre disposes its search controller', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const HelpCenterScreen()));
    final controller = tester.widget<TextField>(find.byType(TextField)).controller!;
    await tester.pumpWidget(const SizedBox());
    expect(() => controller.addListener(() {}), throwsFlutterError);
  });
}
