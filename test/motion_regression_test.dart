import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/widgets/davo_auth_journey.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auth overlay owns Sora text without inherited yellow decoration',
      (tester) async {
    final method = ValueNotifier<AuthJourneyMethod?>(null);
    addTearDown(method.dispose);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: ValueListenableBuilder<AuthJourneyMethod?>(
            valueListenable: method,
            builder: (_, value, __) => DavoAuthJourney(
                method: value, onComplete: () {}, child: const Scaffold()))));
    method.value = AuthJourneyMethod.password;
    await tester.pump();
    final rich = tester.widget<RichText>(find.descendant(
        of: find.text('Signing in'), matching: find.byType(RichText)));
    expect(rich.text.style!.decoration, TextDecoration.none);
    expect(rich.text.style!.fontFamily, 'Sora');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'cryptocurrency sheet close button has a bounded accessible target',
      (tester) async {
    tester.view.physicalSize = const Size(360, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const BuyCryptoAssetSheet()),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final button = find.byTooltip('Close');
    expect(button, findsOneWidget);
    final rect = tester.getRect(button);
    expect(rect.width, greaterThanOrEqualTo(44));
    expect(rect.right, lessThanOrEqualTo(344));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Select Cryptocurrency'), findsNothing);
  });
}
