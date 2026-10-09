import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';

void main() {
  testWidgets(
      'signup picker offers only Nigeria and renders its flag without emoji',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CountrySelectionScreen()));
    await tester.tap(find.text('Select your country'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Nigeria'), findsOneWidget);
    expect(find.text('Ghana'), findsNothing);
    expect(find.byKey(const Key('nigeria-flag')), findsOneWidget);
    await tester.tap(find.text('Nigeria'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nigeria-flag')), findsOneWidget);
  });
}
