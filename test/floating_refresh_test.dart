import 'dart:async';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/widgets/davo_scroll_behavior.dart';
import 'package:davochain/shared/motion/davo_refresh_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'pull assembles the brand before release and cancellation clears it',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DavoFloatingRefresh(
                onRefresh: () async {
                  calls++;
                },
                child: const SizedBox.expand(
                    key: Key('pull-target'), child: Text('Dashboard'))))));
    final gesture = await tester
        .startGesture(tester.getCenter(find.byKey(const Key('pull-target'))));
    await gesture.moveBy(const Offset(0, 22));
    await gesture.moveBy(const Offset(0, 25));
    await tester.pump();
    final artwork =
        tester.widget<DavoRefreshArtwork>(find.byType(DavoRefreshArtwork));
    expect(artwork.assembly, inExclusiveRange(0.0, 1.0));
    expect(artwork.active, isFalse);
    expect(calls, 0);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(find.byType(DavoRefreshArtwork), findsNothing);
    expect(calls, 0);
  });

  testWidgets('reduced motion keeps assembled logo static while waiting',
      (tester) async {
    final operation = Completer<void>();
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
                body: DavoFloatingRefresh(
                    onRefresh: () => operation.future,
                    child: const SizedBox.expand(
                        key: Key('reduced-target'),
                        child: Text('Dashboard')))))));
    await tester.drag(
        find.byKey(const Key('reduced-target')), const Offset(0, 160));
    await tester.pumpAndSettle();
    final first =
        tester.widget<DavoRefreshArtwork>(find.byType(DavoRefreshArtwork));
    expect(first.assembly, 1);
    expect(first.reducedMotion, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(
        tester
            .widget<DavoRefreshArtwork>(find.byType(DavoRefreshArtwork))
            .orbit,
        first.orbit);
    operation.complete();
    await tester.pumpAndSettle();
    expect(find.byType(DavoRefreshArtwork), findsNothing);
  });

  testWidgets('failed refresh clears the indicator and allows retry',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: DavoFloatingRefresh(
                onRefresh: () async {
                  calls++;
                  throw StateError('offline');
                },
                child: const SizedBox.expand(
                    key: Key('retry-target'), child: Text('Dashboard'))))));
    await tester.drag(
        find.byKey(const Key('retry-target')), const Offset(0, 160));
    await tester.pumpAndSettle();
    expect(find.byType(DavoRefreshArtwork), findsNothing);
    expect(find.text('Could not refresh. Try again.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.drag(
        find.byKey(const Key('retry-target')), const Offset(0, 160));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

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
    await tester.pump(const Duration(milliseconds: 300));
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
