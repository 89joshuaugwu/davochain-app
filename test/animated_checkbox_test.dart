import 'package:davochain/shared/widgets/davo_animated_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('checkbox has aligned 44px target and exposes agreement state',
      (tester) async {
    var value = false;
    var changes = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: StatefulBuilder(
      builder: (context, setState) => Center(
          child: DavoAnimatedCheckbox(
        value: value,
        semanticLabel: 'Agree',
        onChanged: (next) => setState(() {
          value = next;
          changes++;
        }),
      )),
    ))));
    final semantics = tester.ensureSemantics();
    try {
      expect(tester.getSize(find.byType(DavoAnimatedCheckbox)),
          const Size(44, 44));
      final paint = find.descendant(
          of: find.byType(DavoAnimatedCheckbox),
          matching: find.byType(CustomPaint));
      expect(tester.getSize(paint), const Size(20, 20));
      expect(tester.getCenter(paint),
          tester.getCenter(find.byType(DavoAnimatedCheckbox)));
      expect(
          tester.getSemantics(find.byType(DavoAnimatedCheckbox)),
          matchesSemantics(
              label: 'Agree',
              hasCheckedState: true,
              isChecked: false,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true));
      await tester.tap(find.byType(DavoAnimatedCheckbox));
      await tester.pump();
      expect(changes, 1);
      expect(value, isTrue);
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(
          tester.getSemantics(find.byType(DavoAnimatedCheckbox)),
          matchesSemantics(
              label: 'Agree',
              hasCheckedState: true,
              isChecked: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true));
    } finally {
      semantics.dispose();
    }
  });
  testWidgets('rapid toggles settle to latest state and keyboard toggles once',
      (tester) async {
    var value = false;
    var changes = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: StatefulBuilder(
      builder: (context, setState) => DavoAnimatedCheckbox(
          value: value,
          onChanged: (next) => setState(() {
                value = next;
                changes++;
              })),
    ))));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(DavoAnimatedCheckbox));
      await tester.pump(const Duration(milliseconds: 40));
    }
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(changes, 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, isFalse);
    expect(changes, 4);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(changes, 5);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'initial and reduced selection stays static; disabled cannot toggle',
      (tester) async {
    var value = true;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: StatefulBuilder(
          builder: (context, setState) => Center(
              child: DavoAnimatedCheckbox(
                  value: value,
                  onChanged: (next) => setState(() => value = next)))),
    )));
    expect(tester.binding.transientCallbackCount, 0);
    await tester.tap(find.byType(DavoAnimatedCheckbox));
    await tester.pump();
    expect(value, isFalse);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(const MaterialApp(
        home: Center(
            child: DavoAnimatedCheckbox(
                value: true, onChanged: null, semanticLabel: 'Disabled'))));
    final semantics = tester.ensureSemantics();
    try {
      expect(
          tester.getSemantics(find.byType(DavoAnimatedCheckbox)),
          matchesSemantics(
              label: 'Disabled',
              hasCheckedState: true,
              isChecked: true,
              hasEnabledState: true,
              isEnabled: false));
      expect(tester.binding.transientCallbackCount, 0);
      await tester.tap(find.byType(DavoAnimatedCheckbox));
      expect(
          tester
              .widget<DavoAnimatedCheckbox>(find.byType(DavoAnimatedCheckbox))
              .value,
          isTrue);
    } finally {
      semantics.dispose();
    }
  });
}
