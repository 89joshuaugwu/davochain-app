import 'package:davochain/shared/widgets/davo_naira_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('custom mark has exact grouped minor units and useful speech', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DavoNairaAmount(minorUnits: 125075)),
      ),
    );
    expect(find.bySemanticsLabel('1,250.75 Davochain Naira'), findsOneWidget);
    final text =
        tester.widget<Text>(find.byType(Text).first).textSpan! as TextSpan;
    expect(text.toPlainText(), '\ue9001,250.75');
    expect(
      (text.children!.first as TextSpan).style!.fontFamily,
      'DavochainCurrency',
    );
    semantics.dispose();
  });
  testWidgets('negative and hidden balances preserve financial meaning', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DavoNairaAmount(minorUnits: -100)),
      ),
    );
    expect(find.bySemanticsLabel('-1.00 Davochain Naira'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DavoNairaAmount(minorUnits: 125075, visible: false),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Balance hidden'), findsOneWidget);
    expect(find.bySemanticsLabel('1,250.75 Davochain Naira'), findsNothing);
    semantics.dispose();
  });
}
