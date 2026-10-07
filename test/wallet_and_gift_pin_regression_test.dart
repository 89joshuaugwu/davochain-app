import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
 testWidgets('gift PIN keypad is consistent and input remains masked', (tester) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const GiftCardPinScreen()));
  expect(find.text('ABC'), findsOneWidget);
  expect(find.text('Confirm'), findsNothing);
  for (final digit in ['1','2','3','4']) {
   await tester.ensureVisible(find.text(digit));
   await tester.tap(find.text(digit));
   await tester.pump();
  }
  expect(find.byIcon(Icons.circle), findsNWidgets(4));
  expect(find.text('Confirm'), findsOneWidget);
  expect(tester.takeException(), isNull);
  await tester.ensureVisible(find.byIcon(Icons.backspace_outlined));
  await tester.tap(find.byIcon(Icons.backspace_outlined));
  await tester.pump();
  expect(find.text('Confirm'), findsNothing);
 });
 testWidgets('withdraw wallet add action fits narrow sheet', (tester) async {
  tester.view.physicalSize = const Size(320, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => startWithdrawFlow(context), child: const Text('Open'))))));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  expect(find.text('Add crypto asset'), findsOneWidget);
  expect(tester.takeException(), isNull);
 });
}
