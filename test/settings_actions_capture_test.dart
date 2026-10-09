import 'dart:io';
import 'dart:ui' as ui;

import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/settings_action_flows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture settings actions in light and dark themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(SettingsPreviewSession.instance.reset);
    await tester.runAsync(() async {
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
    });
    final directory = Directory('../tmp/settings-actions-review')
      ..createSync(recursive: true);
    final pages = <String, Widget Function()>{
      'linked-accounts': () => const LinkedAccountsScreen(),
      'change-password': () => const ChangePasswordScreen(),
      'email-support': () => const EmailSupportScreen(),
      'davo-points': () => const DavoPointsScreen(),
      'delete-account': () => DeleteAccountScreen(onSignOut: () {}),
    };
    for (final dark in [false, true]) {
      for (final page in pages.entries) {
        SettingsPreviewSession.instance.reset();
        final key = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: RepaintBoundary(key: key, child: page.value()),
        ));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          for (final asset in tester.widgetList<Image>(find.byType(Image))) {
            await precacheImage(asset.image, key.currentContext!);
          }
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image = await (key.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
                  '${directory.path}/${page.key}-${dark ? 'dark' : 'light'}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  }, skip: !const bool.fromEnvironment('CAPTURE_SETTINGS'));
}
