import 'support/fake_verification_media.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/verification/advanced_verification_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => VerificationMediaGateway.instance = FakeVerificationMedia());
  tearDown(() =>
      VerificationMediaGateway.instance = DeviceVerificationMediaGateway());
  testWidgets('capture updated verification stages in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    final session = VerificationSession.instance;
    addTearDown(session.reset);
    await tester.runAsync(() async {
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    });
    final directory = Directory('../tmp/updated-verification-review')
      ..createSync(recursive: true);
    for (final dark in [false, true]) {
      final key = GlobalKey();
      final prefix = dark ? 'dark' : 'light';
      Future<void> mount(Widget screen, {double textScale = 1}) async {
        await tester.pumpWidget(MaterialApp(
            key: UniqueKey(),
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => RepaintBoundary(
                key: key,
                child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(textScale)),
                    child: child!)),
            home: screen));
        await tester.pumpAndSettle();
      }

      Future<void> capture(String name) => tester.runAsync(() async {
            final image = await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            await File('${directory.path}/$prefix-$name.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
      Future<void> tap(String label, {bool loading = false}) async {
        final target = label == 'Upload Document'
            ? find.widgetWithText(InkWell, label).first
            : find.text(label).first;
        await tester.ensureVisible(target);
        await tester.tap(target);
        if (loading) {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
        } else {
          await tester.pumpAndSettle();
        }
      }

      session.reset();
      await mount(const VerificationOverviewScreen());
      await tester.runAsync(() async {
        for (final file in ['95bf2.png', '901d8.png', '1cc51.png']) {
          await precacheImage(
              AssetImage('assets/figma_exact/verification_$file'),
              key.currentContext!);
        }
      });
      await mount(const VerificationOverviewScreen());
      await capture('overview');
      await mount(const BasicVerificationIntroScreen());
      await capture('basic-requirements');
      session.completeProfile();
      await mount(
          const BasicIdentityNumberScreen(method: BasicIdentityMethod.bvn));
      await tester.enterText(find.byType(TextField), '12345678901');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await capture('number-complete');
      session.submitBasic(BasicIdentityMethod.bvn, '12345678901');
      await mount(const BasicVerificationSubmittedScreen());
      await capture('basic-result');
      await mount(const AdvancedVerificationFlowScreen());
      await capture('advanced-intro');
      await tap('Start');
      await capture('advanced-overview');
      await tap('ID Verification');
      await capture('id-choice');
      await tap('Start');
      await capture('id-upload');
      await tap('Take Photo');
      await capture('id-camera-choice');
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tap('Upload ID Front');
      await capture('id-uploaded');
      await tap('Continue');
      await capture('selfie');
      await tap('Start live face detection');
      await capture('photo-review');
      await tap('Submit photo', loading: true);
      await capture('matching');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await capture('id-result');
      await tap('Continue to Address Verification');
      await capture('address-ready');
      await tap('Address Verification');
      await capture('address-choice');
      await tap('Continue');
      await capture('address-upload');
      await tap('Upload Document');
      await capture('address-uploaded');
      await tap('Continue');
      await capture('address-review');
      await tap('Continue', loading: true);
      await capture('address-verifying');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await capture('fully-verified');
      tester.view.physicalSize = const Size(320, 640);
      session.reset();
      session.completeProfile();
      session.submitBasic(BasicIdentityMethod.nin, '12345678901');
      session.chooseDocument('National ID card');
      session.addIdentitySide(front: true);
      await mount(const AdvancedVerificationFlowScreen(), textScale: 1.6);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await capture('id-uploaded-small-large-text');
      await tap('Take Photo');
      await capture('id-camera-choice-small-large-text');
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  }, skip: !const bool.fromEnvironment('CAPTURE_UPDATED_VERIFICATION'));
}
