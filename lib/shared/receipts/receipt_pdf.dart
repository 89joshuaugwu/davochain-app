import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'receipt_record.dart';
import 'receipt_pdf_font.dart';
import 'receipt_identity.dart';

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

/// Vector text and decoration, with repeatable status on every page.
abstract final class ReceiptPdf {
  static Future<Uint8List> build(ReceiptPresentation view) async {
    final identity = ReceiptIdentity(view.record);
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
      identity.headline,
      identity.action.glyph,
      for (final asset in view.record.assets) ...[asset.label, asset.glyph],
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
    final assetSvgs = <ReceiptAsset, String>{};
    final brandImage = identity.brandImage == null
        ? null
        : pw.MemoryImage(
            (await rootBundle.load(identity.brandImage!)).buffer.asUint8List());
    for (final asset in view.record.assets) {
      if (asset.svgPath != null) {
        assetSvgs[asset] = await rootBundle.loadString(asset.svgPath!);
      }
    }
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
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                  width: 36,
                                  height: 36,
                                  decoration: pw.BoxDecoration(
                                      color: PdfColors.white,
                                      borderRadius:
                                          pw.BorderRadius.circular(10)),
                                  child: pw.Center(
                                      child: pw.Text(identity.action.glyph,
                                          style: pw.TextStyle(
                                              font: math,
                                              fontFallback: [fallback],
                                              fontSize: 21,
                                              color: blue)))),
                              pw.SizedBox(width: 10),
                              pw.Expanded(
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                    pw.Text('Transaction receipt',
                                        style: const pw.TextStyle(
                                            fontSize: 9,
                                            color: PdfColors.grey700)),
                                    pw.SizedBox(height: 3),
                                    pw.Text(identity.headline,
                                        style: pw.TextStyle(
                                            fontSize: 17, color: blue)),
                                  ])),
                              if (brandImage != null) ...[
                                pw.SizedBox(width: 8),
                                pw.Image(brandImage, width: 32, height: 32),
                              ],
                            ]),
                        pw.SizedBox(height: 14),
                        if (view.record.assets.isNotEmpty) ...[
                          pw.Wrap(spacing: 8, runSpacing: 8, children: [
                            for (final asset in view.record.assets)
                              pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: pw.BoxDecoration(
                                      color: PdfColors.white,
                                      borderRadius:
                                          pw.BorderRadius.circular(18)),
                                  child: pw.Row(
                                      mainAxisSize: pw.MainAxisSize.min,
                                      children: [
                                        pw.Container(
                                            width: 28,
                                            height: 28,
                                            padding: const pw.EdgeInsets.all(5),
                                            decoration: pw.BoxDecoration(
                                                color: asset == ReceiptAsset.sol
                                                    ? PdfColors.black
                                                    : PdfColors.white,
                                                shape: pw.BoxShape.circle),
                                            child: assetSvgs.containsKey(asset)
                                                ? pw.SvgImage(
                                                    svg: assetSvgs[asset]!,
                                                    width: 18,
                                                    height: 18)
                                                : pw.Center(
                                                    child: pw.Text(asset.glyph,
                                                        style: pw.TextStyle(
                                                            font: fallback,
                                                            fontSize: 17,
                                                            color: blue)))),
                                        pw.SizedBox(width: 6),
                                        pw.Text(asset.label,
                                            style: const pw.TextStyle(
                                                fontSize: 10)),
                                      ])),
                          ]),
                          pw.SizedBox(height: 12),
                        ],
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
