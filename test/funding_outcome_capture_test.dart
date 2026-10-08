import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/account_welcome_screen.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';

void main() {
  testWidgets('capture welcome choreography and funding results',
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
    final directory = Directory('../tmp/funding-welcome-review')
      ..createSync(recursive: true);
    Future<void> capture(GlobalKey key, String name) =>
        tester.runAsync(() async {
          final image = await (key.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('${directory.path}/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: RepaintBoundary(
              key: key, child: AccountWelcomeScreen(onExplore: () {}))));
      await tester.pump();
      await tester.runAsync(() => precacheImage(
          const AssetImage('assets/images/brand/davochain_logo.png'),
          key.currentContext!));
      var previous = 0;
      for (final ms in [360, 720, 1200, 1800, 2400]) {
        await tester.pump(Duration(milliseconds: ms - previous));
        await capture(key, 'welcome-${dark ? 'dark' : 'light'}-$ms');
        previous = ms;
      }
      for (final deposit in [false, true]) {
        final resultKey = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: RepaintBoundary(
                key: resultKey,
                child: FundingOutcomeScreen(
                    record: FundingRecord(
                        id: 'capture',
                        direction: deposit
                            ? FundingDirection.deposit
                            : FundingDirection.withdrawal,
                        status: deposit
                            ? FundingStatus.completed
                            : FundingStatus.pending,
                        amount: 2000,
                        currency: deposit ? 'NGD' : 'NGN',
                        destination:
                            deposit ? 'Davochain Naira wallet' : 'Access Bank',
                        occurredAt: DateTime(2026, 10, 8))))));
        await tester.pumpAndSettle();
        await capture(resultKey,
            '${deposit ? 'deposit' : 'withdrawal'}-${dark ? 'dark' : 'light'}');
      }
    }
  }, skip: !const bool.fromEnvironment('CAPTURE_FUNDING'));
}
