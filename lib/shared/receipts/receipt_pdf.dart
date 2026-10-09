import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'receipt_record.dart';
import 'receipt_pdf_font.dart';

/// Explicitly preserve the user's text by declining an incomplete PDF.
class ReceiptPdfTextException implements Exception {
  const ReceiptPdfTextException({this.unsupportedCodePoint});
  final int? unsupportedCodePoint;
  String get message =>
      'This PDF cannot preserve some characters in your receipt. Share as image to keep all characters.';
  @override
  String toString() =>
      '$message${unsupportedCodePoint == null ? '' : ' (U+${unsupportedCodePoint!.toRadixString(16).toUpperCase()})'}';
}

/// Vector text and decoration, with repeatable status/preview on every page.
abstract final class ReceiptPdf {
  static Future<Uint8List> build(ReceiptPresentation view) async {
    // Asset bundles can return SynchronousFuture; normalize to regular futures
    // so downstream rendering errors follow the caller's await/catch chain.
    final fontData = <ByteData>[
      await _loadFont('assets/fonts/sora/Sora-Variable.ttf'),
      await _loadFont('assets/fonts/noto/NotoSans-Regular.ttf'),
      await _loadFont('assets/fonts/noto/NotoEmoji.ttf'),
      await _loadFont('assets/fonts/noto/NotoSansMath-Regular.ttf'),
    ];
    final supported = <int>{};
    for (final data in fontData) {
      supported.addAll(TtfParser(data)
          .charToGlyphIndexMap
          .entries
          .where((entry) => entry.value != 0)
          .map((entry) => entry.key));
    }
    final visibleText = [
      view.record.type,
      view.record.amount,
      view.record.status.label,
      view.style.heading,
      for (final field in view.allDisplayFields) ...[field.label, field.value],
      view.note,
    ];
    for (final text in visibleText) {
      for (final rune in text.runes) {
        // Line breaks and tabs arrange text rather than request a glyph.
        if (rune == 10 || rune == 13 || rune == 9) continue;
        if (!supported.contains(rune)) {
          throw ReceiptPdfTextException(unsupportedCodePoint: rune);
        }
      }
    }
    final font = ReceiptPdfFont(fontData[0]);
    final fallback = ReceiptPdfFont(fontData[1]);
    final emoji = ReceiptPdfFont(fontData[2]);
    final math = ReceiptPdfFont(fontData[3]);
    final blue = PdfColor.fromHex('#135CF7');
    final pale = PdfColor.fromHex('#EDF2FD');
    final document = pw.Document(
        title: 'Davochain ${view.record.type} receipt',
        author: 'Davochain',
        theme: pw.ThemeData.withFont(
            base: font, bold: font, fontFallback: [fallback, emoji, math]));
    document.addPage(pw.MultiPage(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 200,
        header: (_) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(children: [
                          pw.SvgImage(svg: _brandLogo, width: 28, height: 24),
                          pw.SizedBox(width: 7),
                          pw.Text('Davochain',
                              style: pw.TextStyle(
                                  color: blue,
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold))
                        ]),
                        pw.Text(view.record.status.label,
                            style: pw.TextStyle(color: blue, fontSize: 11)),
                      ]),
                  if (view.record.preview)
                    pw.Container(
                        margin: const pw.EdgeInsets.only(top: 8),
                        padding: const pw.EdgeInsets.all(8),
                        color: pale,
                        child: pw.Text('Preview · Local transaction record',
                            style: const pw.TextStyle(fontSize: 10))),
                ])),
        footer: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
                'Davochain · ${view.record.status.label} · ${context.pageNumber}/${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9))),
        build: (_) => [
              pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  color: pale,
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (view.style != ReceiptStyle.standard)
                          pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 12),
                              child: pw.SvgImage(
                                  svg: _motif(view.style),
                                  width: 140,
                                  height: 55)),
                        pw.Text(view.style.heading,
                            style: pw.TextStyle(fontSize: 17, color: blue)),
                        pw.SizedBox(height: 14),
                        pw.Text(view.record.amount,
                            style: const pw.TextStyle(
                                fontSize: 21, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text(view.record.type,
                            style: const pw.TextStyle(fontSize: 11)),
                      ])),
              pw.SizedBox(height: 18),
              for (final field in view.allDisplayFields)
                pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 9),
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            bottom: pw.BorderSide(
                                color: PdfColors.grey300, width: .5))),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(field.label,
                              style: const pw.TextStyle(
                                  fontSize: 9, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(field.value,
                              style: const pw.TextStyle(fontSize: 11)),
                        ])),
              if (view.note.trim().isNotEmpty) ...[
                pw.SizedBox(height: 18),
                pw.Text('Personal note',
                    style: pw.TextStyle(fontSize: 10, color: blue)),
                pw.SizedBox(height: 6),
                pw.Text(view.note, style: const pw.TextStyle(fontSize: 11)),
              ],
            ]));
    return document.save();
  }

  static Future<ByteData> _loadFont(String path) =>
      Future<ByteData>(() => rootBundle.load(path));

  static const _brandLogo =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="40 65 290 210"><path fill="#135CF7" d="M52 69H250C294 69 324 104 328 149Q328 156 320 156H52Q44 156 44 148V77Q44 69 52 69Z"/><circle fill="#135CF7" cx="83" cy="231" r="39"/><path fill="#61ADFF" d="M139 183H324C326 226 310 259 277 268H139Q131 268 131 260V191Q131 183 139 183Z"/></svg>';
  static String _motif(ReceiptStyle style) {
    final art = switch (style) {
      ReceiptStyle.appreciation =>
        '<path d="M70 47C12 16 42 -5 70 17C98 -5 128 16 70 47Z"/>',
      ReceiptStyle.birthday =>
        '<rect x="43" y="23" width="54" height="30" rx="4"/><path d="M53 21V10M70 21V6M87 21V10" stroke="#135CF7" stroke-width="3"/><path d="M70 23V53" stroke="white" stroke-width="4"/>',
      _ =>
        '<circle cx="20" cy="16" r="5"/><circle cx="50" cy="35" r="4"/><circle cx="80" cy="12" r="5"/><circle cx="113" cy="34" r="5"/><path d="M30 45L38 51M105 5L116 14M65 19L69 27" stroke="#135CF7" stroke-width="3"/>',
    };
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 140 55"><g fill="#135CF7">$art</g></svg>';
  }
}
