import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';
import 'package:davochain/shared/receipts/receipt_pdf.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';

void main() {
  testWidgets('capture receipt styles, narrow dark details and vector PDF',
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
      await (FontLoader('DavoNotoSans')
            ..addFont(
                rootBundle.load('assets/fonts/noto/NotoSans-Regular.ttf')))
          .load();
      await (FontLoader('DavoNotoEmoji')
            ..addFont(rootBundle.load('assets/fonts/noto/NotoEmoji.ttf')))
          .load();
    });
    final directory = Directory('../tmp/receipt-fidelity-review')
      ..createSync(recursive: true);
    final record = ReceiptRecord(
        id: 'DC-20261009-418629',
        reference: 'REF-987654321',
        type: 'Naira withdrawal',
        status: ReceiptStatus.pending,
        occurredAt: DateTime(2026, 10, 9, 11, 30),
        amount: '₦25,000.00',
        fields: const [
          ReceiptField(label: 'Bank', value: 'Access Bank'),
          ReceiptField(
              label: 'Account number',
              value: '1234567890',
              sensitive: true,
              copyable: true),
          ReceiptField(label: 'Fee', value: '₦100.00'),
          ReceiptField(label: 'Payment channel', value: 'Bank transfer')
        ],
        events: [
          ReceiptEvent(
              label: 'Request accepted',
              description: 'Withdrawal submitted.',
              occurredAt: DateTime(2026, 10, 9, 11, 30),
              state: ReceiptEventState.complete),
          const ReceiptEvent(
              label: 'Awaiting confirmation',
              description: 'Status updates after confirmation.',
              state: ReceiptEventState.current)
        ]);
    Future<void> capture(Widget page, String name,
        {bool dark = false, bool narrow = false}) async {
      tester.view.physicalSize =
          narrow ? const Size(320, 640) : const Size(390, 844);
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(narrow ? 2 : 1)),
              child: child!),
          home: RepaintBoundary(key: key, child: page)));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (final provider in tester
            .widgetList<Image>(find.byType(Image))
            .map((image) => image.image)
            .toList()) {
          await precacheImage(provider, key.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image = await (key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${directory.path}/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }

    for (final entry in <String, List<String>>{
      'buy': ['Purchase', '0.03 BTC', 'BTC'],
      'sell': ['Sell', '0.03 ETH', 'ETH'],
      'deposit': ['Naira deposit', '\u20a610,000.00', 'NGN'],
      'withdrawal': ['Withdrawal', '0.03 SOL', 'SOL'],
      'swap': ['Conversion', '0.03 BTC', 'BTC'],
      'gift': ['Gift card purchase', '\u20a620,000.00', 'NGN'],
    }.entries) {
      final typed = ReceiptRecord(
        id: 'DC-20261009-418629',
        reference: 'DC-20261009-418629',
        type: entry.value[0],
        status: ReceiptStatus.completed,
        occurredAt: DateTime(2026, 10, 9, 11, 30),
        amount: entry.value[1],
        fields: [
          ReceiptField(label: 'Asset', value: entry.value[2]),
          if (entry.key == 'swap')
            const ReceiptField(label: 'To', value: 'USDT'),
          if (entry.key == 'gift')
            const ReceiptField(label: 'Brand', value: 'Amazon'),
        ],
      );
      final view = ReceiptPresentation(record: typed);
      await capture(
          Scaffold(
              body: SingleChildScrollView(
                  child: ReceiptPaper(presentation: view))),
          'identity-${entry.key}');
      await tester.runAsync(() async {
        File('${directory.path}/identity-${entry.key}.pdf')
            .writeAsBytesSync(await ReceiptPdf.build(view));
      });
    }
    await capture(ReceiptScreen(record: record), 'screen-light');
    await capture(ReceiptScreen(record: record), 'screen-dark', dark: true);
    await capture(
        TransactionRecordDetailsScreen(record: record), 'details-light');
    await capture(
        TransactionRecordDetailsScreen(record: record), 'details-dark-narrow',
        dark: true, narrow: true);
    await tester.runAsync(() async {
      File('${directory.path}/receipt.pdf').writeAsBytesSync(
          await ReceiptPdf.build(ReceiptPresentation(
              record: record,
              style: ReceiptStyle.birthday,
              note: 'Thank you! 🎂')));
    });
  }, skip: !const bool.fromEnvironment('CAPTURE_RECEIPT_FIDELITY'));
}
