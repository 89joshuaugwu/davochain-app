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
  testWidgets('capture corrections reference 47', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocalPreviewProfile.instance.loginSample();
    final key = GlobalKey();
    final directory = Directory('../tmp/corrections-reference-47')
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
      await mount(const Scaffold(body: BuyCryptoAssetSheet()), dark);
      await capture('$theme-search-all');
      await tester.enterText(find.byKey(const ValueKey('asset-search')), 'btc');
      await tester.pumpAndSettle();
      await capture('$theme-search-btc');
      await tester.enterText(find.byKey(const ValueKey('asset-search')), 'ada');
      await tester.pumpAndSettle();
      await capture('$theme-search-ada');
      await mount(const ProfileSettingsScreen(), dark);
      await capture('$theme-settings-accounts');
      await tester.ensureVisible(find.text('Fingerprint'));
      await tester.pumpAndSettle();
      await capture('$theme-settings-fingerprint');
      await tester.ensureVisible(find.text('About Us'));
      await tester.pumpAndSettle();
      await capture('$theme-settings-general');
      await mount(const GiftCardBrandScreen(mode: GiftCardMode.buy), dark);
      await tester.enterText(find.byType(TextField), 'Xbox');
      await tester.pumpAndSettle();
      await capture('$theme-xbox');
      await tester.enterText(find.byType(TextField), 'Spotify');
      await tester.pumpAndSettle();
      await capture('$theme-spotify');
      await mount(const CountrySelectionScreen(), dark);
      await tester.tapOnText(find.textRange.ofSubstring('Privacy policy'));
      await tester.pumpAndSettle();
      await capture('$theme-signup-privacy');
      await mount(
          const BasicIdentityNumberScreen(method: BasicIdentityMethod.bvn),
          dark);
      await capture('$theme-identity-policy');
      await mount(
          const GiftCardBuyReviewScreen(
              brand: GiftCardBrand(
                  name: 'iTunes/Apple', asset: 'assets/figma_exact/apple.png'),
              amount: 100,
              quantity: 1),
          dark);
      await capture('$theme-gift-buy-policy');
      await mount(
          const GiftCardSellReviewScreen(
              brand: GiftCardBrand(
                  name: 'iTunes/Apple', asset: 'assets/figma_exact/apple.png'),
              amount: 100),
          dark);
      await capture('$theme-gift-sell-policy');
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
