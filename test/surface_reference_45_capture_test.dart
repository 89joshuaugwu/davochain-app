import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
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
  testWidgets('capture surface reference 45', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocalPreviewProfile.instance.loginSample();
    final key = GlobalKey();
    final directory = Directory('../tmp/surface-reference-45')
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
      await mount(const ForgotPasswordScreen(), dark);
      await tester.enterText(find.byType(TextField), 'qa@example.com');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      }
      await tester.pump();
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      await capture('$theme-password');
      await mount(const CryptoDepositScreen(asset: CryptoAsset.bitcoin), dark);
      await capture('$theme-deposit');
      await tester.tap(find.text('Show all'));
      await tester.pumpAndSettle();
      await capture('$theme-deposit-expanded');
      await mount(const NairaWithdrawScreen(), dark);
      await capture('$theme-withdrawal');
      await mount(const Scaffold(body: BuyCryptoAssetSheet()), dark);
      await capture('$theme-assets');
      for (final title in [
        'Privacy Policy',
        'Terms and Condition',
        'FAQs',
        'About Us'
      ]) {
        await mount(
            Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () => showSettingsContent(context, title),
                        child: const Text('Open')))),
            dark);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await capture('$theme-${title.replaceAll(' ', '-')}');
      }
    }
    await tester.pumpWidget(const SizedBox());
  }, skip: !const bool.fromEnvironment('CAPTURE_PREVIEW_POLISH'));
}
