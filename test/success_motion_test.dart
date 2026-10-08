import 'package:davochain/shared/widgets/davo_result_screen.dart';
import 'package:davochain/shared/widgets/davo_success_mark.dart';
import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('success integrations wrap and keep actions available',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      const BuySuccessScreen(
          order: BuyCryptoOrder(
              asset: BuyCryptoAsset.bitcoin,
              wallet: BuyFundingWallet.ngn,
              ngnAmount: 720000)),
      for (final kind in TxKind.values)
        TransactionSuccessScreen(
            kind: kind,
            target: 'bc1qextendedrecipientaddressforwrapping0123456789',
            amount: .03),
      VerificationSuccessScreen(
          kind: VerificationKind.email, onContinue: () {}),
      VerificationSuccessScreen(kind: VerificationKind.sms, onContinue: () {}),
    ]) {
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
        data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5), disableAnimations: true),
        child: screen,
      )));
      await tester.pumpAndSettle();
      expect(find.byType(DavoSuccessMark), findsOneWidget);
      expect(
          find
              .text(screen is VerificationSuccessScreen
                  ? 'Continue'
                  : 'View Details')
              .hitTestable(),
          findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: screen.runtimeType.toString());
      if (screen is BuySuccessScreen) {
        expect(find.textContaining('0.0300 BTC'), findsOneWidget);
        expect(find.text('Purchase successful'), findsOneWidget);
        expect(find.text('Sold  Successful'), findsNothing);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
      'pending deposit has no success mark; submitted trade stays pending',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: DepositStatusScreen(success: false)));
    expect(find.byType(DavoSuccessMark), findsNothing);
    expect(find.text('Pending'), findsOneWidget);
    await tester.pumpWidget(
        const MaterialApp(home: DepositStatusScreen(success: true)));
    expect(find.byType(DavoSuccessMark), findsOneWidget);
    await tester
        .pumpWidget(const MaterialApp(home: GiftCardSellSubmittedScreen()));
    expect(find.text('Current Trade Status: Pending'), findsOneWidget);
    expect(find.bySemanticsLabel('Trade submitted; review pending'),
        findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  Widget host({bool reduced = false, Widget? child}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: child ?? const Center(child: DavoSuccessMark()),
        ),
      );

  testWidgets('filled confirmation builds through finite phases and then rests',
      (tester) async {
    await tester.pumpWidget(host());
    final paint = find.descendant(
        of: find.byType(DavoSuccessMark), matching: find.byType(CustomPaint));
    final initial = tester.widget<CustomPaint>(paint).painter!;
    await tester.pump(const Duration(milliseconds: 300));
    final gathered = tester.widget<CustomPaint>(paint).painter!;
    expect(gathered.shouldRepaint(initial), isTrue);
    await tester.pump(const Duration(milliseconds: 350));
    final checked = tester.widget<CustomPaint>(paint).painter!;
    expect(checked.shouldRepaint(gathered), isTrue);
    await tester.pumpAndSettle();
    final settled = tester.widget<CustomPaint>(paint).painter!;
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.widget<CustomPaint>(paint).painter!.shouldRepaint(settled),
        isFalse);
  });

  testWidgets('confirmation settles once and does not replay after rebuild',
      (tester) async {
    await tester.pumpWidget(host());
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
              of: find.byType(DavoSuccessMark),
              matching: find.byType(CustomPaint)),
        )
        .painter!;
    await tester.pumpWidget(host());
    final rebuilt = tester
        .widget<CustomPaint>(
          find.descendant(
              of: find.byType(DavoSuccessMark),
              matching: find.byType(CustomPaint)),
        )
        .painter!;
    expect(rebuilt.shouldRepaint(painter), isFalse);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion is the finished mark without a ticker',
      (tester) async {
    await tester.pumpWidget(host(reduced: true));
    expect(
        find.descendant(
            of: find.byType(DavoSuccessMark),
            matching: find.byType(AnimatedBuilder)),
        findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    expect(find.bySemanticsLabel('Success'), findsOneWidget);
    await tester.pumpWidget(host(reduced: false));
    expect(
        find.descendant(
            of: find.byType(DavoSuccessMark),
            matching: find.byType(AnimatedBuilder)),
        findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('enabling reduced motion finishes an active sequence',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpWidget(host(reduced: true));
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(host(reduced: false));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('active confirmation disposes its ticker safely', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('small screen and large text scroll while actions stay available',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var continued = false;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(2),
          disableAnimations: true,
        ),
        child: DavoResultScreen(
          title: 'Personal information updated',
          message: List.filled(8, 'Your changes have been saved.').join(' '),
          actions: FilledButton(
            onPressed: () => continued = true,
            child: const Text('Continue'),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    final buttonBeforeScroll = tester.getRect(find.byType(FilledButton));
    expect(buttonBeforeScroll.bottom, lessThanOrEqualTo(568));
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(FilledButton)), buttonBeforeScroll);
    await tester.tap(find.byType(FilledButton));
    expect(continued, isTrue);
    expect(tester.takeException(), isNull);
  });
}
