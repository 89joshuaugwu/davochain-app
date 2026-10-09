import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/core/theme/appearance_controller.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';

void main() {
  testWidgets('capture supplied settings fidelity and appearance transition',
      (tester) async {
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
    final directory = Directory('../tmp/settings-fidelity-review')
      ..createSync(recursive: true);
    Future<void> capture(GlobalKey key, String name) =>
        tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('${directory.path}/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
    Future<GlobalKey> host(Widget page, bool dark) async {
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: RepaintBoundary(key: key, child: page)));
      await tester.pumpAndSettle();
      final providers = tester
          .widgetList<Image>(find.byType(Image))
          .map((i) => i.image)
          .toList();
      await tester.runAsync(() async {
        for (final provider in providers) {
          await precacheImage(provider, key.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      return key;
    }

    for (final dark in [false, true]) {
      final themeName = dark ? 'dark' : 'light';
      for (final entry in <String, Widget>{
        'email': const EmailSupportScreen(),
        'messages': const SupportMessagesScreen(),
        'chat': const SupportChatScreen(),
        'crypto-security': const CryptoSecurityScreen(),
        'privacy': const PrivacyScreen(),
        'notifications': const NotificationsPreferencesScreen(),
      }.entries) {
        final key = await host(entry.value, dark);
        await capture(key, '${entry.key}-$themeName');
      }
      for (final mode in ThemeMode.values) {
        final controller = AppearanceController(
            read: () async => mode.name, write: (_) async {});
        await controller.restore();
        final key = await host(AppearanceScreen(controller: controller), dark);
        await capture(key, 'appearance-${mode.name}-$themeName');
      }
    }
    final controller =
        AppearanceController(read: () async => 'light', write: (_) async {});
    await controller.restore();
    final key = await host(AppearanceScreen(controller: controller), false);
    await tester.tap(find.text('Dark'));
    await tester.pump();
    var previous = 0;
    for (final ms in [120, 240, 480]) {
      await tester.pump(Duration(milliseconds: ms - previous));
      await capture(key, 'appearance-transition-$ms');
      previous = ms;
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  }, skip: !const bool.fromEnvironment('CAPTURE_SETTINGS_FIDELITY'));
}
