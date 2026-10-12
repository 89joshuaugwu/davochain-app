import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PIN eyes reveal each field independently and matching PIN saves',
      (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
        home: const NewTransactionPinScreen()));
    final first = find.byKey(const ValueKey('New PIN'));
    final confirm = find.byKey(const ValueKey('Confirm New PIN'));
    expect(tester.widget<TextField>(first).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show New PIN'));
    await tester.pump();
    expect(tester.widget<TextField>(first).obscureText, isFalse);
    expect(tester.widget<TextField>(confirm).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show Confirm New PIN'));
    await tester.pump();
    expect(tester.widget<TextField>(confirm).obscureText, isFalse);
    await tester.tap(find.byTooltip('Hide New PIN'));
    await tester.pump();
    expect(tester.widget<TextField>(first).obscureText, isTrue);

    await tester.enterText(first, '12a3456');
    await tester.pump();
    expect(tester.widget<TextField>(first).controller!.text, '1234');
    await tester.enterText(confirm, '1235');
    await tester.pump();
    expect(find.text('PINs do not match. Check both entries.'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save'))
        .onPressed, isNull);
    await tester.enterText(confirm, '1234');
    await tester.pump();
    expect(find.text('PINs match'), findsOneWidget);
    final controllers = [tester.widget<TextField>(first).controller!,
      tester.widget<TextField>(confirm).controller!];
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(PinSuccessScreen), findsOneWidget);
    expect(controllers.every((controller) => controller.text.isEmpty), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incomplete PIN cannot save and form scrolls above a keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
        home: const NewTransactionPinScreen()));
    await tester.enterText(find.byKey(const ValueKey('New PIN')), '123');
    await tester.enterText(find.byKey(const ValueKey('Confirm New PIN')), '123');
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save'))
        .onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
