import 'dart:async';
import 'dart:io';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_pdf.dart';
import 'package:davochain/shared/services/receipt_export_service.dart';
import 'package:davochain/shared/widgets/davo_receipt_export_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class PendingCapture extends ReceiptExportService {
  final started = Completer<void>();
  final finish = Completer<ReceiptExportFile>();
  int calls = 0;
  ReceiptPresentation? received;
  @override
  Future<ReceiptExportFile> exportRecord(RenderRepaintBoundary boundary,
      ReceiptExportFormat format, ReceiptPresentation presentation) {
    calls++;
    received = presentation;
    if (!started.isCompleted) started.complete();
    return finish.future;
  }
}

class UnsupportedTextCapture extends ReceiptExportService {
  @override
  Future<ReceiptExportFile> exportRecord(RenderRepaintBoundary boundary,
      ReceiptExportFormat format, ReceiptPresentation presentation) async {
    await ReceiptPdf.build(presentation);
    throw StateError('Unsupported text should not produce a PDF');
  }
}

void main() {
  testWidgets('provider replacement cannot change the receipt being captured',
      (tester) async {
    final service = PendingCapture();
    final gate = Completer<void>();
    final key = GlobalKey();
    ReceiptRecord record(String id, String amount) => ReceiptRecord(
        id: id,
        reference: id,
        type: 'Transfer',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.utc(2026),
        amount: amount,
        fields: const []);
    final old = ReceiptPresentation(record: record('old-id', '100'));
    final replacement = ReceiptPresentation(record: record('new-id', '200'));
    Widget page(ReceiptPresentation view, String label) => MaterialApp(
        home: DavoReceiptExportFrame(
            key: key,
            service: service,
            receiptType: 'Transfer',
            presentation: view,
            beforeCapture: () => gate.future,
            receipt: SizedBox(height: 100, child: Text(label))));
    addTearDown(() async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      if (!gate.isCompleted) gate.complete();
      if (!service.finish.isCompleted) {
        service.finish.complete(ReceiptExportFile(
            file: File('unused.png'),
            previewPng: File('assets/images/brand/davochain_logo.png')
                .readAsBytesSync(),
            format: ReceiptExportFormat.image,
            receiptType: 'Transfer'));
      }
      await tester.pumpAndSettle();
    });
    await tester.pumpWidget(page(old, 'Old receipt'));
    await tester.tap(find.text('Share as image'));
    await tester.pump();
    await tester.pumpWidget(page(replacement, 'New receipt'));
    await tester.pump();
    expect(find.text('Old receipt'), findsOneWidget);
    expect(find.text('New receipt'), findsNothing);
    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(service.started.isCompleted, isTrue);
    expect(service.received?.record.id, 'old-id');
    expect(service.received?.record.amount, '100');
    expect(find.text('Old receipt'), findsOneWidget);
    expect(service.calls, 1);
  });

  testWidgets(
      'PDF text failure explains image alternative and keeps actions enabled',
      (tester) async {
    final note = String.fromCharCodes([0x645, 0x631, 0x62d, 0x628, 0x627]);
    final record = ReceiptRecord(
        id: 'tx',
        reference: 'ref',
        type: 'Transfer',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.utc(2026),
        amount: '100',
        fields: const []);
    await tester.pumpWidget(MaterialApp(
        home: DavoReceiptExportFrame(
            service: UnsupportedTextCapture(),
            receiptType: 'Transfer',
            presentation: ReceiptPresentation(record: record, note: note),
            receipt: const SizedBox(height: 100, child: Text('Receipt')))));
    await tester.tap(find.text('Share as PDF'));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    expect(find.textContaining('Share as image to keep all characters'),
        findsOneWidget);
    expect(find.text('Share as image').hitTestable(), findsOneWidget);
    expect(find.text('Share as PDF').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();
  });
  testWidgets(
      'receipt controls stay frozen during capture and duplicate export is ignored',
      (tester) async {
    final service = PendingCapture();
    var changed = 0;
    final record = ReceiptRecord(
        id: 'tx',
        reference: 'ref',
        type: 'Transfer',
        status: ReceiptStatus.pending,
        occurredAt: DateTime.utc(2026),
        amount: '₦100',
        fields: const []);
    await tester.pumpWidget(MaterialApp(
        home: DavoReceiptExportFrame(
            service: service,
            receiptType: 'Transfer',
            presentation: ReceiptPresentation(record: record),
            controls: TextButton(
                onPressed: () => changed++, child: const Text('Change style')),
            receipt: const SizedBox(height: 200, child: Text('Receipt')))));
    await tester.tap(find.text('Share as image'));
    await tester.tap(find.text('Share as PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(service.started.isCompleted, isTrue);
    await tester.tap(find.text('Change style'), warnIfMissed: false);
    await tester.pump();
    expect(changed, 0);
    expect(service.calls, 1);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    service.finish.complete(ReceiptExportFile(
        file: File('unused.png'),
        previewPng:
            File('assets/images/brand/davochain_logo.png').readAsBytesSync(),
        format: ReceiptExportFormat.image,
        receiptType: 'Transfer'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
