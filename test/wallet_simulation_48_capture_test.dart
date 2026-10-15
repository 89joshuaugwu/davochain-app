import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/features/profile_settings/presentation/settings_content_overlay.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(() {
    session.reset();
  });
  tearDown(() {
    session.reset();
  });
  testWidgets('capture wallet simulation 48', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocalPreviewProfile.instance.loginSample();
    final key = GlobalKey();
    final directory =
        Directory('../../review/evidence/wallet-simulation-48/widgets')
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
      WalletAccountState.instance.startSimulation(empty: true);
      await mount(const DavochainDashboardScreen(), dark);
      await capture('$theme-zero-dashboard');
      await mount(const PortfolioScreen(), dark);
      await capture('$theme-zero-portfolio');
      await mount(const Scaffold(body: BuyCryptoAssetSheet()), dark);
      await tester.enterText(find.byKey(const ValueKey('asset-search')), 'ada');
      await tester.pumpAndSettle();
      await capture('$theme-zero-search');
      await mount(const ProfileSettingsScreen(), dark);
      await tester.ensureVisible(find.text('Fingerprint'));
      await tester.pumpAndSettle();
      await capture('$theme-security-icons');
      await mount(const NairaDepositScreen(), dark);
      await tester.tap(find.text('Add funds'));
      await tester.pumpAndSettle();
      await capture('$theme-deposit-entry');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      final wallet = WalletAccountState.instance;
      ReceiptActivity.accept(ReceiptRecord(
          id: 'capture-$theme',
          reference: 'capture-$theme',
          type: 'Deposit',
          status: ReceiptStatus.completed,
          occurredAt: DateTime(2026),
          amount: '0.01 BTC',
          fields: const [],
          walletEffect: wallet.effect(credits: {'BTC': '0.01', 'ADA': '10'})));
      await tester.pump();
      await mount(const PortfolioScreen(), dark);
      await capture('$theme-funded-portfolio');
      ReceiptActivity.reset();
    }
    await tester.pumpWidget(const SizedBox());
  }, skip: !const bool.fromEnvironment('CAPTURE_PREVIEW_POLISH'));
}
