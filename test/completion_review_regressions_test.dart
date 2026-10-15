import 'package:davochain/core/money/money.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invalid funding quantities cannot throw or enter accepted activity',
      () {
    FundingActivity.reset();
    addTearDown(FundingActivity.reset);
    for (final amount in [double.nan, double.infinity, 'invalid', '-1', '0']) {
      final record = FundingRecord(
          id: 'bad',
          direction: FundingDirection.deposit,
          status: FundingStatus.completed,
          amount: amount,
          currency: 'NGN',
          destination: 'wallet',
          occurredAt: DateTime.utc(2026));
      expect(() => FundingActivity.accept(record), returnsNormally);
      expect(FundingActivity.records.value, isEmpty);
    }
  });

  testWidgets('trade cannot advance when destination rounds to zero units',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: TradeAmountScreen(
            mode: TradeMode.convert, asset: BuyCryptoAsset.tether)));
    await tester.enterText(find.byType(TextField), '0.000001');
    await tester.pump();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.byType(TradeReviewScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MaterialApp(
        home: TradeAmountScreen(
            mode: TradeMode.sell, asset: BuyCryptoAsset.solana)));
    await tester.enterText(find.byType(TextField), '0.000000001');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(TradeReviewScreen), findsNothing);
  });

  for (final coversFee in [true, false]) {
    testWidgets(
        coversFee
            ? 'valid Naira withdrawal passes review and PIN while busy'
            : 'Naira withdrawal rechecks fee coverage after PIN',
        (tester) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      WalletAccountState.instance.reset();
      SettingsPreviewSession.instance.reset();
      addTearDown(WalletAccountState.instance.reset);
      addTearDown(SettingsPreviewSession.instance.reset);
      SettingsPreviewSession.instance.acceptBank(const LinkedBank(
          bank: 'Kuda Bank', number: '1234567890', name: 'Customer'));
      await tester.pumpWidget(const MaterialApp(home: NairaWithdrawScreen()));
      await tester.tap(find.text('Select a payment method'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Kuda Bank - 1234567890'), 100,
          scrollable: find
              .descendant(
                  of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kuda Bank - 1234567890'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1000');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Read terms and conditions'));
      await tester.pumpAndSettle();
      expect(find.text('Using Davochain'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I agree to the terms and condition'));
      await tester.pump();
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();
      expect(find.byType(CryptoPinScreen), findsOneWidget);
      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit));
      }
      await tester.pump();
      if (!coversFee) {
        final state = WalletAccountState.instance;
        state.publish(
            WalletSnapshot(
                accountId: state.snapshot.accountId,
                version: 2,
                available: {'NGN': AssetAmount.parse('1050', 'NGN', 2)},
                pricesMinorUnits: {'NGN': 100}),
            generation: state.generation);
      }
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      expect(find.byType(NairaWithdrawalProgressScreen),
          coversFee ? findsOneWidget : findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  }
}
