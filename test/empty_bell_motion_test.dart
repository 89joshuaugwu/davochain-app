import 'package:davochain/shared/motion/davo_empty_bell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bell =
      DavoEmptyBell(asset: 'assets/figma_exact/icon_notification_bell.png');
  testWidgets('empty bell gently moves then rests without moving its layout',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: bell)));
    final before = tester.getRect(find.byType(DavoEmptyBell));
    await tester.pump(const Duration(milliseconds: 700));
    final transform = tester.widget<Transform>(find
        .descendant(
            of: find.byType(DavoEmptyBell), matching: find.byType(Transform))
        .first);
    expect(transform.transform.storage[13], lessThan(0));
    expect(tester.getRect(find.byType(DavoEmptyBell)), before);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion leaves empty bell still', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: bell))));
    await tester.pumpAndSettle();
    final transform = tester.widget<Transform>(find
        .descendant(
            of: find.byType(DavoEmptyBell), matching: find.byType(Transform))
        .first);
    expect(transform.transform.storage[13], 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
