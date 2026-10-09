import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// pdf 3.13.1 does not re-export these public stream/CMap classes.
// Keep this workaround isolated and revisit it when upgrading the pinned pdf.
// ignore: implementation_imports
import 'package:pdf/src/pdf/format/dict_stream.dart';
// ignore: implementation_imports
import 'package:pdf/src/pdf/obj/unicode_cmap.dart';

/// Preserves non-BMP characters such as emoji in selectable PDF text.
/// pdf 3.13.1 writes scalar hex in ToUnicode; PDF requires UTF-16BE pairs.
class ReceiptPdfFont extends pw.TtfFont {
  ReceiptPdfFont(super.data);
  @override
  PdfFont buildFont(PdfDocument pdfDocument) {
    final font = PdfTtfFont(pdfDocument, data);
    font.unicodeCMap = _ReceiptUnicodeCmap(pdfDocument);
    return font;
  }
}

class _ReceiptUnicodeCmap extends PdfUnicodeCmap {
  _ReceiptUnicodeCmap(PdfDocument document) : super(document, false);
  @override
  void writeContent(PdfStream stream) {
    final source = ascii.decode(buf.output());
    final corrected = source.replaceAllMapped(
      RegExp(r'(<[0-9A-F]{4}>\s*)<([0-9A-F]{5,6})>'),
      (match) {
        final scalar = int.parse(match.group(2)!, radix: 16) - 0x10000;
        String hex(int unit) =>
            unit.toRadixString(16).toUpperCase().padLeft(4, '0');
        final high = 0xd800 + (scalar >> 10);
        final low = 0xdc00 + (scalar & 0x3ff);
        return '${match.group(1)}<${hex(high)}${hex(low)}>';
      },
    );
    PdfDictStream(
            isBinary: isBinary,
            values: params.values,
            data: Uint8List.fromList(ascii.encode(corrected)))
        .output(this, stream, settings.verbose ? 0 : null);
    stream.putByte(0x0a);
  }
}
