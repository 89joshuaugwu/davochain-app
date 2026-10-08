import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/shared/widgets/davo_state_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'contact state sheet preserves all states, search and cancellation',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const CompleteProfileContactV12Screen()));
    await tester.pumpAndSettle();
    final picker = find.byType(DavoStatePicker);
    expect(tester.widget<DavoStatePicker>(picker).states, hasLength(37));
    expect(tester.widget<DavoStatePicker>(picker).states, contains('FCT'));
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    final search = find.widgetWithText(TextField, 'Search states');
    await tester.enterText(search, 'lag');
    await tester.pumpAndSettle();
    expect(find.text('Lagos'), findsOneWidget);
    expect(find.text('Abia'), findsNothing);
    await tester.tap(find.text('Lagos'));
    await tester.pumpAndSettle();
    expect(tester.widget<DavoStatePicker>(picker).value, 'Lagos');
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Search states'), 'not a state');
    await tester.pumpAndSettle();
    expect(find.text('No states found'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear state search'));
    await tester.pumpAndSettle();
    expect(find.text('Abia'), findsOneWidget);
    final list = tester
        .widget<ListView>(find.byKey(const ValueKey('state-picker-list')));
    expect(list.childrenDelegate.estimatedChildCount, 37);
    await tester.tap(find.byTooltip('Close state picker'));
    await tester.pumpAndSettle();
    expect(tester.widget<DavoStatePicker>(picker).value, 'Lagos');
    expect(find.text('Nigeria'), findsOneWidget);
  });
  testWidgets(
      'state field is regular 14px, keyboard opens and narrow sheet fits',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selected;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!),
        home: Scaffold(
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (context, setState) => DavoStatePicker(
                      value: selected,
                      states: const ['Abia', 'FCT', 'Lagos'],
                      onChanged: (value) => setState(() => selected = value)),
                )))));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.style!.fontSize, 14);
    expect(field.style!.fontWeight, FontWeight.w400);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close state picker'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(
        find.widgetWithText(TextField, 'Search states'), 'fct');
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('FCT').hitTestable(), findsOneWidget);
    await tester.tap(find.text('FCT'));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(selected, 'FCT');
  });
}
