import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selector content does not intersect at double text size', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: MediaQuery(
      data: MediaQueryData(size: Size(320, 568), textScaler: TextScaler.linear(2)),
      child: Scaffold(body: BuyCryptoAssetSheet()))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final name = tester.getRect(find.text('Bitcoin'));
    final symbol = tester.getRect(find.text('BTC'));
    expect(name.overlaps(symbol), isFalse);
  });
  testWidgets('OTP wraps and scrolls above keyboard at enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3),
        viewInsets: const EdgeInsets.only(bottom: 250)), child: child!),
      home: const VerificationScreen(kind: VerificationKind.email)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Submit'));
    await tester.pump();
    expect(tester.getBottomRight(find.text('Submit')).dy, lessThan(318));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('selected Ethereum reaches withdrawal entry from home action', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(onPressed: () => startWithdrawFlow(context), child: const Text('Withdraw'))))));
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('To Davochain User'));
    await tester.pumpAndSettle();
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('Bitcoin'), findsNothing);
  });
}
