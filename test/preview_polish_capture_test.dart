import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/dashboard/presentation/portfolio_performance_screen.dart';
import 'package:davochain/features/dashboard/portfolio_performance.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture preview polish', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocalPreviewProfile.instance.loginSample();
    final key = GlobalKey();
    final directory = Directory('../tmp/preview-polish-review')
      ..createSync(recursive: true);
    await tester.runAsync(() async {
      final emojiFont = File('C:/Windows/Fonts/seguiemj.ttf');
      if (emojiFont.existsSync()) {
        await (FontLoader('Noto Color Emoji')
              ..addFont(
                  emojiFont.readAsBytes().then((b) => ByteData.sublistView(b))))
            .load();
      }
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
      await (FontLoader('DavoNotoMath')
            ..addFont(
                rootBundle.load('assets/fonts/noto/NotoSansMath-Regular.ttf')))
          .load();
      await (FontLoader('DavoNotoSans')
            ..addFont(
                rootBundle.load('assets/fonts/noto/NotoSans-Regular.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    Future<void> capture(String name) async {
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      await tester.runAsync(() => Future.wait(images
          .map((image) => precacheImage(image.image, key.currentContext!))));
      await tester.pump();
      await tester.runAsync(() async {
        final image = await (key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('${directory.path}/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    Future<void> mount(Widget screen, bool dark) async {
      await tester.pumpWidget(MaterialApp(
          key: UniqueKey(),
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => RepaintBoundary(key: key, child: child!),
          home: screen));
      await tester.pumpAndSettle();
    }

    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      await mount(const DavochainDashboardScreen(), dark);
      await capture('$theme-home');
      for (final slide in [2, 3]) {
        await tester.drag(find.byType(PageView), const Offset(-350, 0));
        await tester.pumpAndSettle();
        await capture('$theme-home-banner-$slide');
      }

      for (final tab in [1, 2, 3]) {
        await tester.tap(find.byKey(ValueKey('main-tab-$tab')));
        await tester.pumpAndSettle();
        await capture('$theme-tab-$tab');
      }
      await mount(const NotificationCenterScreen(), dark);
      await capture('$theme-notifications');
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();
      await capture('$theme-notifications-empty');
      await mount(const NairaWithdrawScreen(), dark);
      await capture('$theme-withdraw');
      await mount(const PortfolioScreen(), dark);
      await capture('$theme-portfolio');
      await mount(
          const TradeAmountScreen(
              mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin),
          dark);
      await capture('$theme-swap');
      await mount(
          const BuyAmountScreen(
              initialOrder: BuyCryptoOrder(
                  asset: BuyCryptoAsset.bitcoin,
                  wallet: BuyFundingWallet.ngn,
                  ngnAmount: 0)),
          dark);
      await capture('$theme-buy');
      await mount(
          const TradeAmountScreen(
              mode: TradeMode.sell, asset: BuyCryptoAsset.bitcoin),
          dark);
      await capture('$theme-sell');
      await mount(const PortfolioPerformanceScreen(), dark);
      await capture('$theme-performance-start');
      final controller = PortfolioPerformanceController(
          PortfolioPerformanceSnapshot(
              current: PortfolioValuePoint(
                  timestamp: DateTime(2026, 10, 15), valueKobo: 182458800),
              history: [
            PortfolioValuePoint(
                timestamp: DateTime(2026, 10, 1), valueKobo: 170000000),
            PortfolioValuePoint(
                timestamp: DateTime(2026, 10, 7), valueKobo: 175000000)
          ]));
      await mount(PortfolioPerformanceScreen(controller: controller), dark);
      await capture('$theme-performance-history');
      await mount(const SizedBox(), dark);
      controller.dispose();

      await mount(const CryptoDepositScreen(asset: CryptoAsset.bitcoin), dark);
      await capture('$theme-deposit');
      await mount(const FingerprintSettingsScreen(), dark);
      await capture('$theme-fingerprint-settings');
      await mount(const VerificationScreen(kind: VerificationKind.email), dark);
      await capture('$theme-otp');
      await mount(const VerifyPinCodeScreen(email: true), dark);
      await capture('$theme-payment-pin-otp');
      await mount(const AddBankScreen(), dark);
      await capture('$theme-add-bank');
    }
    LocalPreviewProfile.instance.register(
        name: 'Joshua Eze', email: 'joshua@example.com', phone: '8161780381');
    await mount(const DavochainDashboardScreen(), false);
    await capture('signup-home');
    VerificationSession.instance.reset();
    await tester.pumpWidget(const SizedBox());
    LocalPreviewProfile.instance.loginSample();
  }, skip: !const bool.fromEnvironment('CAPTURE_PREVIEW_POLISH'));
}
