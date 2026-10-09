import 'dart:io';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'dart:ui' as ui;
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/security_questions/presentation/security_questions_screens.dart';
import 'package:davochain/features/security_questions/security_questions_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture security question states', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
    });
    final directory = Directory('../tmp/questions-visual')
      ..createSync(recursive: true);
    final key = GlobalKey();
    final service = SecurityQuestionsService();
    Future<void> mount(Widget page,
        {bool dark = false, bool large = false}) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => RepaintBoundary(
              key: key,
              child: large
                  ? MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                          textScaler: const TextScaler.linear(2),
                          viewInsets: const EdgeInsets.only(bottom: 240),
                          disableAnimations: true),
                      child: child!)
                  : child!),
          home: page));
      await tester.pumpAndSettle();
    }

    Future<void> tap(String label) async {
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        for (final asset in tester.widgetList<Image>(find.byType(Image))) {
          await precacheImage(asset.image, key.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image = await (key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('${directory.path}/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await mount(SecurityQuestionsSettingsScreen(service: service));
    await tap('Set up questions');
    await capture('setup-light');
    await tap('Choose a question');
    await tap(securityQuestionPresets[0]);
    await tester.enterText(
        find.byKey(const Key('security-answer')), 'memorable private answer');
    await tap('Next question');
    await tap('Choose a question');
    await capture('picker-selected-light');
    await tap(securityQuestionPresets[1]);
    await tester.enterText(
        find.byKey(const Key('security-answer')), 'memorable private answer');
    await tap('Next question');
    await tap('Choose a question');
    await tap(securityQuestionPresets[2]);
    await tester.enterText(
        find.byKey(const Key('security-answer')), 'memorable private answer');
    await tap('Review questions');
    await capture('review-light');
    await tap('Save questions');
    await capture('result-light');
    await mount(SecurityQuestionsSettingsScreen(service: service));
    await tap('Change questions');
    await capture('email-preview-light');
    await mount(
        SecurityQuestionsChallengeScreen(service: service, onVerified: () {}),
        dark: true);
    await capture('challenge-dark');
    await mount(const CountrySelectionScreen());
    await tap('Select your country');
    await capture('nigeria-country-picker');
    await tap('Nigeria');
    await capture('nigeria-country-selected');

    tester.view.physicalSize = const Size(320, 640);
    await mount(
        SecurityQuestionsSettingsScreen(service: SecurityQuestionsService()),
        dark: true,
        large: true);
    await tap('Set up questions');
    await capture('setup-dark-320-text2-keyboard');
  }, skip: !const bool.fromEnvironment('CAPTURE_SECURITY_QUESTIONS'));
}
