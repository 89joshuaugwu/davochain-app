import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/widgets/davo_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'refresh floats without shifting content and waits for its operation',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final completed = Completer<void>();
    int calls = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: DavoFloatingRefresh(
                onRefresh: () {
                  calls++;
                  return completed.future;
                },
                child: const SizedBox.expand(
                    key: Key('content'), child: Text('Dashboard'))))));
    final before = tester.getRect(find.byKey(const Key('content')));
    await tester.drag(find.byKey(const Key('content')), const Offset(0, 160));
    await tester.pump();
    expect(calls, 1);
    expect(find.bySemanticsLabel('Refreshing dashboard'), findsOneWidget);
    expect(tester.getRect(find.byKey(const Key('content'))), before);
    await tester.drag(find.byKey(const Key('content')), const Offset(0, 160));
    await tester.pump();
    expect(calls, 1);
    completed.complete();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Refreshing dashboard'), findsNothing);
    semantics.dispose();
  });
  testWidgets('edge response keeps the scroll position clamped',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
        scrollBehavior: const DavoScrollBehavior(),
        home: Scaffold(
            body: ListView(
                controller: controller,
                children: List.generate(
                    30, (i) => SizedBox(height: 48, child: Text('Row $i')))))));
    await tester.drag(find.byType(ListView), const Offset(0, 140));
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    expect(tester.takeException(), isNull);
  });
}
