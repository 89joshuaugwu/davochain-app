import 'package:davochain/shared/widgets/davo_success_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('waiting outcome never announces success', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
        home:
            Scaffold(body: DavoSuccessMark(kind: DavoOutcomeKind.submitted))));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Awaiting confirmation'), findsOneWidget);
    expect(find.bySemanticsLabel('Success'), findsNothing);
    await tester.pumpWidget(const MaterialApp(
        home:
            Scaffold(body: DavoSuccessMark(kind: DavoOutcomeKind.completed))));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Success'), findsOneWidget);
    semantics.dispose();
  });
}
