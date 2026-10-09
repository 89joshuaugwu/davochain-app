import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/receipt_screen.dart';
import 'package:davochain/shared/receipts/receipt_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ReceiptRecord fixture({List<ReceiptField>? fields}) => ReceiptRecord(
      id: 'tx-full-123',
      reference: 'ref-full-456',
      type: 'Crypto transfer',
      status: ReceiptStatus.pending,
      occurredAt: DateTime.utc(2026, 10, 9, 12, 30),
      amount: '0.0000000123456789 BTC',
      fields: fields ??
          const [
            ReceiptField(
                label: 'Address', value: '0xprivateaddress', sensitive: true),
            ReceiptField(label: 'Fee', value: '₦250.00'),
          ],
    );
void main() {
  test(
      'presentation masks sensitive fields and preserves precise immutable facts across styles',
      () {
    final record = fixture();
    for (final style in ReceiptStyle.values) {
      final view =
          ReceiptPresentation(record: record, style: style, note: 'Enjoy!');
      expect(view.displayFields.first.value, '••••');
      expect(view.record.amount, '0.0000000123456789 BTC');
      expect(view.record.status, ReceiptStatus.pending);
      expect(view.record.preview, isTrue);
      expect(view.displayFields.last.value, '₦250.00');
      expect(
          ReceiptPresentation(record: record, showSensitive: true)
              .displayFields
              .first
              .value,
          '0xprivateaddress');
    }
    expect(() => record.fields.add(const ReceiptField(label: 'x', value: 'x')),
        throwsUnsupportedError);
  });
  test('personal notes keep 240 complete grapheme characters', () {
    final emoji = String.fromCharCodes([0x1f44d, 0x1f3fd]);
    final note = List.filled(241, emoji).join();
    expect(ReceiptPresentation(record: fixture(), note: note).note,
        List.filled(240, emoji).join());
  });
  test('bundled receipt font cmap really supports ASCII C and Naira', () async {
    final sora =
        TtfParser(await rootBundle.load('assets/fonts/sora/Sora-Variable.ttf'));
    final noto = TtfParser(
        await rootBundle.load('assets/fonts/noto/NotoSans-Regular.ttf'));
    expect(sora.charToGlyphIndexMap.containsKey(0x43), isTrue);
    expect(noto.charToGlyphIndexMap.containsKey(0x20a6), isTrue);
  });
  test('PDF rejects unsupported note characters with an image alternative',
      () async {
    final arabicNote =
        String.fromCharCodes([0x645, 0x631, 0x62d, 0x628, 0x627]);
    await expectLater(
        ReceiptPdf.build(
            ReceiptPresentation(record: fixture(), note: arabicNote)),
        throwsA(isA<Exception>().having((error) => error.toString(),
            'actionable explanation', contains('Share as image'))));
  });
  test(
      'PDF preflight checks visible facts but keeps masked private text hidden',
      () async {
    final cjk = String.fromCharCodes([0x674e, 0x534e]);
    final visible =
        fixture(fields: [ReceiptField(label: 'Recipient', value: cjk)]);
    await expectLater(
        ReceiptPdf.build(ReceiptPresentation(record: visible)),
        throwsA(isA<Exception>().having((error) => error.toString(),
            'actionable explanation', contains('Share as image'))));
    final private = fixture(fields: [
      ReceiptField(label: 'Account name', value: cjk, sensitive: true)
    ]);
    expect(await ReceiptPdf.build(ReceiptPresentation(record: private)),
        isNotEmpty);
    await expectLater(
        ReceiptPdf.build(
            ReceiptPresentation(record: private, showSensitive: true)),
        throwsA(isA<Exception>()));
  });
  test('PDF emoji text maps to complete UTF16 for selection and copy',
      () async {
    final cake = String.fromCharCode(0x1f382);
    final bytes = await ReceiptPdf.build(
        ReceiptPresentation(record: fixture(), note: 'Birthday $cake'));
    final raw = latin1.decode(bytes);
    final streams = <String>[];
    for (final match in RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true)
        .allMatches(raw)) {
      final data = latin1.encode(match.group(1)!);
      try {
        streams.add(latin1.decode(zlib.decode(data)));
      } on FormatException {
        streams.add(match.group(1)!);
      }
    }
    expect(streams.join(), contains('<D83CDF82>'));
    expect(streams.join(), isNot(contains('<1F382>')));
  });
  test('selectable vector PDF spans pages and contains no raster image',
      () async {
    final record = fixture(
        fields: List.generate(
            95,
            (i) => ReceiptField(
                label: 'Detail $i',
                value: 'Accepted transaction information $i')));
    final bytes = await ReceiptPdf.build(ReceiptPresentation(
        record: record, style: ReceiptStyle.birthday, note: 'Happy birthday!'));
    final raw = latin1.decode(bytes);
    expect(raw, startsWith('%PDF-'));
    expect(RegExp(r'/Type\s*/Page\b').allMatches(raw).length, greaterThan(1));
    expect(raw, isNot(contains('/Subtype /Image')));
    expect(raw, contains('/Font'));
  });
  testWidgets(
      'standard receipt keeps pending and masking visible without preview at 320px with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(
                textScaler: TextScaler.linear(2), disableAnimations: true),
            child: ReceiptScreen(record: fixture()))));
    expect(find.text('Share as image').hitTestable(), findsOneWidget);
    expect(find.text('Share as PDF').hitTestable(), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.textContaining('Preview'), findsNothing);
    expect(find.text('0xprivateaddress'), findsNothing);
    expect(find.text('0.0000000123456789 BTC'), findsOneWidget);
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('0xprivateaddress'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
