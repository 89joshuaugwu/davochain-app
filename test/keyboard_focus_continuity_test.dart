import 'package:davochain/app.dart';
import 'package:davochain/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openLogin(WidgetTester tester) async {
    await tester.pumpWidget(const DavochainApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.login);
    await tester.pumpAndSettle();
  }

  testWidgets('switching fields keeps the keyboard open during pointer down',
      (tester) async {
    await openLogin(tester);
    final fields = find.byType(TextField);
    await tester.tap(fields.first);
    await tester.pump();
    final firstFocus = tester.widget<TextField>(fields.first).focusNode!;
    final gesture = await tester.startGesture(tester.getCenter(fields.last));
    await tester.pump();
    expect(firstFocus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    await gesture.up();
    await tester.pump();
    expect(tester.widget<TextField>(fields.last).focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('password visibility preserves focus and keyboard connection',
      (tester) async {
    await openLogin(tester);
    final password = find.byType(TextField).last;
    await tester.tap(password);
    await tester.pump();
    final focus = tester.widget<TextField>(password).focusNode!;
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isFalse);
    expect(focus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    tester.testTextInput.enterText('typing stays responsive');
    await tester.pump();
    expect(tester.widget<TextField>(password).controller!.text,
        'typing stays responsive');
  });
}
