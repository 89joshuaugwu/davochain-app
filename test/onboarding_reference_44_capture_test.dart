import 'package:davochain/features/onboarding/presentation/onboarding_screen.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'package:davochain/features/auth/presentation/create_password_screen.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_flow.dart';
import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture onboarding reference 44', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocalPreviewProfile.instance.loginSample();
    final key = GlobalKey();
    final directory = Directory('../tmp/onboarding-reference-44')
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
      await mount(const OnboardingScreen(), dark);
      for (var page = 1; page <= 3; page++) {
        await capture('$theme-onboarding-$page');
        if (page < 3) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
      }
      await mount(const CountrySelectionScreen(), dark);
      await capture('$theme-country');
      await mount(const CreatePasswordScreen(), dark);
      await tester.enterText(find.byType(TextField).first, 'abcdefgh1');
      await tester.pumpAndSettle();
      await capture('$theme-password-medium');
      await tester.enterText(find.byType(TextField).first, 'Abcdefgh1');
      await tester.pumpAndSettle();
      await capture('$theme-password-strong');
      await mount(const VerificationScreen(kind: VerificationKind.email), dark);
      await capture('$theme-otp');
      await mount(
          const GiftCardSellReviewScreen(
              brand: GiftCardBrand(
                  name: 'iTunes/Apple', asset: 'assets/figma_exact/apple.png'),
              amount: 100),
          dark);
      await tester.tap(
          find.bySemanticsLabel('I have read and accepted the terms').first);
      await tester.pumpAndSettle();
      await capture('$theme-gift-terms');
    }
    VerificationSession.instance.reset();
    await tester.pumpWidget(const SizedBox());
    LocalPreviewProfile.instance.loginSample();
  }, skip: !const bool.fromEnvironment('CAPTURE_PREVIEW_POLISH'));
}
