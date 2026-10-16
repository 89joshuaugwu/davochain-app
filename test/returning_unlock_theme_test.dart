import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/returning_unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'unlock card and text share the ${dark ? 'dark' : 'light'} palette',
      (tester) async {
        final colors = dark ? DavoColors.dark : DavoColors.light;
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final capture = const bool.fromEnvironment('CAPTURE_UNLOCK');
        final key = GlobalKey();
        if (capture) {
          await tester.runAsync(() async {
            await (FontLoader('Sora')..addFont(
                  rootBundle.load('assets/fonts/sora/Sora-Variable.ttf'),
                ))
                .load();
            await (FontLoader('MaterialIcons')
                  ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
                .load();
          });
        }
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: RepaintBoundary(
              key: key,
              child: const ReturningUnlockScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (capture) {
          await tester.runAsync(() async {
            for (final image in tester.widgetList<Image>(find.byType(Image))) {
              await precacheImage(image.image, key.currentContext!);
            }
          });
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final directory = Directory('../../review/evidence/unlock-theme-52')
              ..createSync(recursive: true);
            final image =
                await (key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            File(
              '${directory.path}/unlock-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        final card = tester
            .widgetList<Container>(
              find.ancestor(
                of: find.byType(TextField),
                matching: find.byType(Container),
              ),
            )
            .firstWhere(
              (c) =>
                  c.decoration is BoxDecoration &&
                  (c.decoration as BoxDecoration).borderRadius ==
                      BorderRadius.circular(28),
            );
        expect((card.decoration as BoxDecoration).color, colors.surface);
        final heading = tester.widget<Text>(
          find.textContaining('Welcome back,'),
        );
        expect(heading.style!.color, colors.ink);
        final message = tester.widget<Text>(
          find.text('Enter your password to unlock your account.'),
        );
        expect(message.style!.color, colors.bodyMuted);
        final fieldSurface = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(
          (fieldSurface.decoration as BoxDecoration).color,
          colors.fieldFill,
        );
        await tester.enterText(find.byType(TextField), 'example-password');
        await tester.pump();
        expect(find.text('Unlock').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
