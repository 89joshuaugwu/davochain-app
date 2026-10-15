import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';

void main() {
  testWidgets(
      'country selection can redirect to Login without continuing signup',
      (tester) async {
    await tester
        .pumpWidget(MaterialApp(home: const CountrySelectionScreen(), routes: {
      '/login': (_) => const Scaffold(body: Text('Login destination')),
    }));
    await tester.pumpAndSettle();
    expect(find.text('Already have an account?'), findsOneWidget);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
    expect(find.byType(CountrySelectionScreen), findsNothing);
  });
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
