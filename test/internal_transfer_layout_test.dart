import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';

void main() {
  testWidgets(
    'recipient input has a comfortable height and moves focus to amount',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CryptoWithdrawEntryScreen(external: false)),
      );
      await tester.pumpAndSettle();
      final recipient = find.byType(TextField).first;
      expect(tester.getSize(recipient).height, greaterThanOrEqualTo(48));
      expect(
        tester.widget<TextField>(recipient).textInputAction,
        TextInputAction.next,
      );
      await tester.tap(recipient);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(1))
            .focusNode!
            .hasFocus,
        isTrue,
      );
      expect(find.text('Send to a Davochain user'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'internal transfer remains readable at double text with keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              viewInsets: const EdgeInsets.only(bottom: 230),
            ),
            child: child!,
          ),
          home: const CryptoWithdrawEntryScreen(external: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byType(TextField).at(1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Continue').hitTestable(), findsOneWidget);
    },
  );
  testWidgets(
    'an account change invalidates an open transfer despite new account funds',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      addTearDown(wallet.reset);
      wallet.applyEffect(
        'btc-before',
        wallet.effect(credits: {'BTC': '10'}),
        completed: true,
        failed: false,
      );
      await tester.pumpWidget(
        const MaterialApp(home: CryptoWithdrawEntryScreen(external: false)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'demo-recipient');
      await tester.enterText(find.byType(TextField).at(1), '1');
      wallet.startSimulation(empty: true);
      wallet.applyEffect(
        'btc-after',
        wallet.effect(credits: {'BTC': '10'}),
        completed: true,
        failed: false,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Review withdrawal'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
