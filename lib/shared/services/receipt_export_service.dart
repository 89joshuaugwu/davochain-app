import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../receipts/receipt_record.dart';
import '../receipts/receipt_pdf.dart';

enum ReceiptExportFormat {
  image('png', 'image/png', 'Image · PNG'),
  pdf('pdf', 'application/pdf', 'Document · PDF');

  const ReceiptExportFormat(this.extension, this.mimeType, this.caption);
  final String extension, mimeType, caption;
}

class ReceiptExportFile {
  const ReceiptExportFile(
      {required this.file,
      required this.previewPng,
      required this.format,
      required this.receiptType});
  final File file;
  final Uint8List previewPng;
  final ReceiptExportFormat format;
  final String receiptType;
  String get name => file.uri.pathSegments.last;
}

/// Produces real file bytes from the complete receipt's painted boundary.
class ReceiptExportService {
  ReceiptExportService({Future<Directory> Function()? temporaryDirectory})
      : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectory;
  static const channel = MethodChannel('davochain/receipt_export');

  static String fileName(
      String receiptType, ReceiptExportFormat format, DateTime createdAt) {
    final slug = receiptType
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'davochain-${slug.isEmpty ? 'receipt' : slug}-${createdAt.toUtc().microsecondsSinceEpoch}.${format.extension}';
  }

  Future<ReceiptExportFile> export(RenderRepaintBoundary boundary,
      ReceiptExportFormat format, String receiptType) async {
    if (boundary.debugNeedsPaint || boundary.size.isEmpty) {
      throw StateError('Receipt is still loading. Try again in a moment.');
    }
    final size = boundary.size;
    // Preserve the whole template while bounding memory for very tall receipts.
    final ratio = math.min(
        2.5,
        math.min(8192 / math.max(size.width, size.height),
            math.sqrt(16000000 / (size.width * size.height))));
    final image = await boundary.toImage(pixelRatio: ratio);
    late Uint8List png;
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('Could not prepare the receipt image.');
      }
      png = bytes.buffer.asUint8List();
    } finally {
      image.dispose();
    }
    return writeFile(png, format, receiptType);
  }

  Future<ReceiptExportFile> exportRecord(RenderRepaintBoundary boundary,
      ReceiptExportFormat format, ReceiptPresentation presentation) async {
    // Validate PDF text before preparing any cache file or thumbnail.
    final bytes = format == ReceiptExportFormat.pdf
        ? await ReceiptPdf.build(presentation)
        : null;
    final image = await export(
        boundary, ReceiptExportFormat.image, presentation.record.type);
    if (bytes == null) return image;
    final file = File(
        '${image.file.parent.path}/${fileName(presentation.record.type, format, DateTime.now())}');
    await file.writeAsBytes(bytes, flush: true);
    return ReceiptExportFile(
        file: file,
        previewPng: image.previewPng,
        format: format,
        receiptType: presentation.record.type);
  }

  @visibleForTesting
  Future<ReceiptExportFile> writeFile(
      Uint8List png, ReceiptExportFormat format, String receiptType) async {
    final directory =
        Directory('${(await _temporaryDirectory()).path}/receipts');
    await directory.create(recursive: true);
    // Keep recent exports available to receiving apps; remove only old cache files.
    final oldest = DateTime.now().subtract(const Duration(days: 7));
    await for (final entry in directory.list()) {
      if (entry is File && (await entry.stat()).modified.isBefore(oldest)) {
        try {
          await entry.delete();
        } on FileSystemException {/* Cache is best effort. */}
      }
    }
    final bytes =
        format == ReceiptExportFormat.image ? png : await encodePdf(png);
    final file = File(
        '${directory.path}/${fileName(receiptType, format, DateTime.now())}');
    await file.writeAsBytes(bytes, flush: true);
    return ReceiptExportFile(
        file: file, previewPng: png, format: format, receiptType: receiptType);
  }

  @visibleForTesting
  static Future<Uint8List> encodePdf(Uint8List png) async {
    final document = pw.Document();
    document.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (_) => pw.Center(
          child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain)),
    ));
    return document.save();
  }

  Future<void> shareMore(ReceiptExportFile receipt, ui.Rect origin) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile(receipt.file.path, mimeType: receipt.format.mimeType)],
      title: '${receipt.receiptType} receipt',
      subject: 'Davochain ${receipt.receiptType} receipt',
      sharePositionOrigin: origin,
    ));
  }

  /// Opens an installed app's composer; the user decides whether to send.
  Future<void> shareTo(
      ReceiptExportFile receipt, String package, ui.Rect origin) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final opened = await channel.invokeMethod<bool>('shareTarget', {
        'path': receipt.file.path,
        'mimeType': receipt.format.mimeType,
        'name': receipt.name,
        'package': package,
        'title': 'Davochain ${receipt.receiptType} receipt',
      });
      if (opened == true) return;
    }
    await shareMore(receipt, origin);
  }

  /// Android saves to Downloads; other platforms offer the OS save/share picker.
  Future<String?> download(ReceiptExportFile receipt, ui.Rect origin) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return channel.invokeMethod<String>('download', {
        'path': receipt.file.path,
        'mimeType': receipt.format.mimeType,
        'name': receipt.name,
      });
    }
    await shareMore(receipt, origin);
    return null;
  }
}
