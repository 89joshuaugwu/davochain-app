import 'package:davochain/core/money/money.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('open Naira withdrawal updates and blocks after balance decreases', (tester) async {
    final state = WalletAccountState.instance;
    state.reset();
    addTearDown(state.reset);
    SettingsPreviewSession.instance.acceptBank(const LinkedBank(bank: 'Kuda Bank', number: '1234567890', name: 'Customer'));
    addTearDown(SettingsPreviewSession.instance.reset);
    await tester.pumpWidget(const MaterialApp(home: NairaWithdrawScreen()));
    await tester.tap(find.text('Select a payment method'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kuda Bank - 1234567890'), 100, scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuda Bank - 1234567890'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1000');
    await tester.pump();
    final next = WalletSnapshot(accountId: state.snapshot.accountId, version: 2,
      available: {'NGN': AssetAmount.parse('50', 'NGN', 2)}, pricesMinorUnits: {'NGN':100});
    state.publish(next, generation: state.generation);
    await tester.pump();
    expect(find.text('\u20a650.00'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Review withdrawal'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Naira withdrawal remains readable with double text and keyboard', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2), viewInsets: const EdgeInsets.only(bottom: 250)), child: child!),
      home: const NairaWithdrawScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Continue'));
    expect(tester.getBottomRight(find.text('Continue')).dy, lessThan(318));
  });
}
