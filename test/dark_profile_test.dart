import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/core/theme/appearance_controller.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/advanced_verification_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.dark,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);

Future<void> _open(WidgetTester tester, AppearanceController controller) async {
  await tester.pumpWidget(_host(Builder(builder: (context) => Scaffold(
    body: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => AppearanceScreen(controller: controller),
    )), child: const Text('Open appearance')),
  ))));
  await tester.tap(find.text('Open appearance'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => VerificationSession.instance.reset());

  testWidgets('Appearance draft previews dark, saves, and reopens selected mode', (tester) async {
    String? persisted = 'light';
    final controller = AppearanceController(read: () async => persisted, write: (value) async { persisted = value; });
    await controller.restore();
    await _open(tester, controller);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Light appearance'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.light);
    final preview = tester.widget<Container>(find.byKey(const ValueKey('appearance-live-preview')));
    expect((preview.decoration! as BoxDecoration).color, DavoColors.dark.canvas);
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.dark);
    expect(persisted, 'dark');
    expect(find.text('Open appearance'), findsOneWidget);
    await tester.tap(find.text('Open appearance'));
    await tester.pumpAndSettle();
    final selected = tester.widget<Semantics>(find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == 'Dark appearance'));
    expect(selected.properties.selected, isTrue);
    semantics.dispose();
  });

  testWidgets('Appearance Back cancels draft and failed save retains mode', (tester) async {
    var writes = 0;
    final controller = AppearanceController(read: () async => 'light', write: (_) async { writes++; throw StateError('Storage unavailable'); });
    await controller.restore();
    await _open(tester, controller);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(writes, 0);
    expect(controller.mode, ThemeMode.light);
    await tester.tap(find.text('Open appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(writes, 1);
    expect(controller.mode, ThemeMode.light);
    expect(find.text('Could not save appearance. Please try again.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Appearance blocks toolbar and system Back while save is pending', (tester) async {
    final pending = Completer<void>();
    final controller = AppearanceController(read: () async => 'light', write: (_) => pending.future);
    await controller.restore();
    await _open(tester, controller);
    await tester.tap(find.text('Dark'));
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Saving…'), findsOneWidget);
    expect(tester.widget<IconButton>(find.ancestor(of: find.byTooltip('Back'), matching: find.byType(IconButton)).first).onPressed, isNull);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(controller.mode, ThemeMode.light);
    pending.complete();
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.dark);
    expect(find.text('Open appearance'), findsOneWidget);
  });

  testWidgets('Profile and verification use dark surfaces and retain readable text at 2x', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(const ProfileSettingsScreen()));
    await tester.pumpAndSettle();
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, DavoColors.dark.surface);
    expect(tester.widget<Text>(find.text('Vincent Chukwu')).style!.color, DavoColors.dark.ink);
    expect(tester.takeException(), isNull, reason: 'ProfileSettingsScreen');
    for (final screen in <Widget>[const ProfileSettingsScreen(), const AppearanceScreen(), const VerificationOverviewScreen(), const BasicIdentityChoiceScreen(), const AdvancedVerificationFlowScreen()]) {
      await tester.pumpWidget(_host(screen, scale: 2));
      await tester.pumpAndSettle();
      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, DavoColors.dark.surface);
      expect(tester.takeException(), isNull, reason: screen.runtimeType.toString());
    }
  });
}

