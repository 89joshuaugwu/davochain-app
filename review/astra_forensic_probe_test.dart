import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/auth/presentation/verification_flow.dart';

void main() {
  testWidgets('audit: selector text collisions and OTP keyboard constraints', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await (FontLoader('Sora')..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf'))).load();
    });
    final boundary = GlobalKey();
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)), child: child!),
      home: Scaffold(body: RepaintBoundary(key: boundary, child: const BuyCryptoAssetSheet()))));
    await tester.pumpAndSettle();
    final name = tester.getRect(find.text('Bitcoin'));
    final fiat = tester.getRect(find.text('0.00 USD').first);
    final symbol = tester.getRect(find.text('BTC'));
    debugPrint('AUDIT selector name=$name fiat=$fiat symbol=$symbol horizontalCollision=${name.overlaps(fiat)} verticalCollision=${name.overlaps(symbol)}');
    expect(name.overlaps(fiat), isTrue, reason: 'Reproduce the current fixed-coordinate collision');
    await tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('../review/evidence/selector-320-text200.png');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(viewInsets: const EdgeInsets.only(bottom: 250), textScaler: const TextScaler.linear(1.3)), child: child!),
      home: const VerificationScreen(kind: VerificationKind.email)));
    await tester.pump(const Duration(seconds: 1));
    final errors = <String>[];
    Object? error;
    while ((error = tester.takeException()) != null) { errors.add(error.toString()); }
    debugPrint('AUDIT OTP errors: $errors');
    await tester.pumpWidget(const SizedBox());
  });
}
