import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const sizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(393, 852),
    Size(480, 960)
  ];
  const screens = <String, Widget>{
    'dashboard': DavochainDashboardScreen(),
    'portfolio': PortfolioScreen(),
    'history': TransactionHistoryScreen(),
    'notifications': NotificationCenterScreen(),
    'catalogue': GiftCardHomeScreen(),
    'settings': ProfileSettingsScreen(),
    'buy': BuyAmountScreen(
        initialOrder: BuyCryptoOrder(
            asset: BuyCryptoAsset.bitcoin,
            wallet: BuyFundingWallet.ngd,
            ngnAmount: 0)),
    'sell':
        TradeAmountScreen(mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin),
  };
  for (final size in sizes) {
    for (final scale in [1.0, 2.0]) {
      for (final entry in screens.entries) {
        testWidgets(
            '${entry.key} ${size.width.toInt()}x${size.height.toInt()} text $scale',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          if (!fontsLoaded) {
            await tester.runAsync(() async {
              for (final font in {
                'Sora': 'assets/fonts/sora/Sora-Variable.ttf',
                'DavoNotoMath': 'assets/fonts/noto/NotoSansMath-Regular.ttf',
                'DavoNotoSans': 'assets/fonts/noto/NotoSans-Regular.ttf',
                'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
              }.entries) {
                await (FontLoader(font.key)
                      ..addFont(rootBundle.load(font.value)))
                    .load();
              }
            });
            fontsLoaded = true;
          }
          LocalPreviewProfile.instance.loginSample();
          final captureKey = GlobalKey();
          await tester.pumpWidget(MaterialApp(
              theme: scale == 1 ? AppTheme.light : AppTheme.dark,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      viewPadding: const EdgeInsets.only(top: 24, bottom: 24)),
                  child: RepaintBoundary(key: captureKey, child: child!)),
              home: entry.value));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('CAPTURE_PHONE_MATRIX') &&
              (size.width == 320 || size.width == 480) &&
              ['dashboard', 'portfolio', 'catalogue'].contains(entry.key)) {
            final images =
                tester.widgetList<Image>(find.byType(Image)).toList();
            await tester.runAsync(() => Future.wait(images.map((image) =>
                precacheImage(image.image, captureKey.currentContext!))));
            await tester.pump();
            await tester.runAsync(() async {
              final directory = Directory('../tmp/phone-size-review')
                ..createSync(recursive: true);
              final image = await (captureKey.currentContext!
                      .findRenderObject()! as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
              try {
                final bytes =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                await File(
                        '${directory.path}/${entry.key}-${size.width.toInt()}-${scale.toInt()}x.png')
                    .writeAsBytes(bytes!.buffer.asUint8List());
              } finally {
                image.dispose();
              }
            });
          }
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            await tester.drag(scrollables.first, const Offset(0, -900));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
