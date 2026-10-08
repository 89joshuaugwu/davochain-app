import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dark dashboard resolves canvas and readable asset heading',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark, home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(milliseconds: 900));
    final context = tester.element(find.text('Assets'));
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        DavoColors.of(context).canvas);
    expect(tester.widget<Text>(find.text('Assets')).style!.color,
        DavoColors.of(context).ink);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark dashboard remains usable at doubled text', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!),
        home: const DavochainDashboardScreen()));
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Assets'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark scanner keeps white camera overlays on black',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark, home: const ScanPasteAddressScreen()));
    for (final asset in ['scanner_frame.png', 'flashlight.png']) {
      final image = find.byWidgetPredicate((widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName.endsWith(asset));
      expect(image, findsOneWidget);
      final backdrop = tester.widget<Container>(
          find.ancestor(of: image, matching: find.byType(Container)).first);
      expect((backdrop.decoration as BoxDecoration).color, Colors.black);
      expect(tester.widget<Image>(image).color, isNull);
    }
    expect(
        tester
            .widget<Text>(find.text('Align the QR code within the frame'))
            .style!
            .color,
        Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark financial forms retain readable fields at doubled text',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in <Widget>[
      const BuyAmountScreen(
          initialOrder: BuyCryptoOrder(
              asset: BuyCryptoAsset.bitcoin,
              wallet: BuyFundingWallet.ngd,
              ngnAmount: 0)),
      const TradeAmountScreen(
          mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin),
      const TradeAmountScreen(
          mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin),
    ]) {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!),
          home: screen));
      await tester.pumpAndSettle();
      final field =
          tester.widget<EditableText>(find.byType(EditableText).first);
      final colors =
          DavoColors.of(tester.element(find.byType(TextField).first));
      expect(field.style.color, colors.ink);
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
