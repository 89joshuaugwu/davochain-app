import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:davochain/shared/services/receipt_export_service.dart';
import 'package:davochain/shared/widgets/davo_receipt_export_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final png = File('assets/images/brand/davochain_logo.png').readAsBytesSync();

class RecordingExport extends ReceiptExportService {
  ReceiptExportFormat? format;
  double height = 0;
  String? action;
  @override
  Future<ReceiptExportFile> export(RenderRepaintBoundary boundary,
      ReceiptExportFormat selected, String receiptType) async {
    format = selected;
    height = boundary.size.height;
    return ReceiptExportFile(
        file: File('receipt.${selected.extension}'),
        previewPng: png,
        format: selected,
        receiptType: receiptType);
  }

  @override
  Future<void> shareMore(ReceiptExportFile receipt, Rect origin) async {
    action = 'More';
  }

  @override
  Future<void> shareTo(
      ReceiptExportFile receipt, String package, Rect origin) async {
    action = package;
  }

  @override
  Future<String?> download(ReceiptExportFile receipt, Rect origin) async {
    action = 'Download';
    return 'Downloads/Davochain';
  }
}

void main() {
  test('exports original PNG and a real PDF with bounded safe file names',
      () async {
    final folder = await Directory.systemTemp.createTemp('davo-receipt-test-');
    try {
      final service =
          ReceiptExportService(temporaryDirectory: () async => folder);
      final image = await service.writeFile(
          png, ReceiptExportFormat.image, '../../Conversion');
      expect(await image.file.readAsBytes(), png);
      expect(image.name, startsWith('davochain-conversion-'));
      expect(image.file.parent.path, '${folder.path}/receipts');
      final pdf =
          await service.writeFile(png, ReceiptExportFormat.pdf, 'Purchase');
      final Uint8List bytes = await pdf.file.readAsBytes();
      expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
      expect(pdf.format.mimeType, 'application/pdf');
      expect(bytes.length, greaterThan(png.length));
    } finally {
      await folder.delete(recursive: true);
    }
  });

  for (final format in ReceiptExportFormat.values) {
    testWidgets(
        'whole tall receipt and ${format.name} compact actions remain reachable',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = RecordingExport();
      await tester.pumpWidget(MaterialApp(
          home: DavoReceiptExportFrame(
              service: service,
              receiptType: 'Conversion',
              receipt: const SizedBox(
                  height: 1400,
                  child: Column(children: [
                    Text('Receipt top'),
                    Spacer(),
                    Text('Receipt bottom')
                  ])))));
      final button = find.text(format == ReceiptExportFormat.image
          ? 'Share as image'
          : 'Share as PDF');
      expect(button.hitTestable(), findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(service.height, 1400);
      expect(service.format, format);
      for (final label in ['Download', 'X', 'Telegram', 'More']) {
        expect(find.text(label).hitTestable(), findsOneWidget);
      }
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(service.action, 'More');
      expect(tester.takeException(), isNull);
    });
  }
}
