import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/navigation/app_page_route.dart';
import 'guided_face_capture_screen.dart';
import 'verification_attachment.dart';
import 'verification_cache_owner.dart';
export 'verification_attachment.dart';

VerificationCacheOwner? _cacheOwner;
Future<VerificationCacheOwner>? _openingCache;
Timer? _retentionTimer;

Future<VerificationCacheOwner> initializeVerificationCache() {
  return _openingCache ??=
      _initializeCache().whenComplete(() => _openingCache = null);
}

Future<VerificationCacheOwner> _initializeCache() async {
  final owner = _cacheOwner ??= VerificationCacheOwner(
      Directory('${(await getTemporaryDirectory()).path}/verification'));
  await owner.initializeAndReconcile();
  _retentionTimer ??= Timer.periodic(const Duration(hours: 1), (_) async {
    try {
      final result = await owner.reconcileExpired();
      if (!result.complete) debugPrint('Verification cache cleanup pending.');
    } catch (_) {
      debugPrint('Verification cache cleanup pending.');
    }
  });
  return owner;
}

abstract class VerificationMediaGateway {
  static VerificationMediaGateway instance = DeviceVerificationMediaGateway();
  Future<VerificationAttachment?> pickDocument({bool camera = false});
  Future<VerificationAttachment?> pickIdentity({bool camera = false});
  Future<VerificationAttachment?> captureFace(BuildContext context);
}

class DeviceVerificationMediaGateway implements VerificationMediaGateway {
  @override
  Future<VerificationAttachment?> pickIdentity({bool camera = false}) async {
    await initializeVerificationCache();
    final image = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: camera ? 90 : null,
        maxWidth: camera ? 1920 : null);
    if (image == null) return null;
    try {
      return await cacheVerificationAttachment(image.path,
          name: image.name, allowPdf: false);
    } finally {
      if (camera) await releaseCapturedSource(image.path);
    }
  }

  @override
  Future<VerificationAttachment?> pickDocument({bool camera = false}) async {
    await initializeVerificationCache();
    String? path, name;
    if (camera) {
      final image = await ImagePicker().pickImage(
          source: ImageSource.camera, imageQuality: 90, maxWidth: 1920);
      if (image == null) return null;
      path = image.path;
      name = image.name;
    } else {
      final result = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);
      if (result == null) return null;
      path = result.path;
      name = result.name;
    }
    if (path == null) {
      throw const FormatException(
          'This file could not be opened. Choose another file.');
    }
    try {
      return await cacheVerificationAttachment(path, name: name);
    } finally {
      if (camera) await releaseCapturedSource(path);
    }
  }

  @override
  Future<VerificationAttachment?> captureFace(BuildContext context) async {
    await initializeVerificationCache();
    if (!context.mounted) return null;
    return Navigator.of(context).push<VerificationAttachment>(
        AppPageRoute<VerificationAttachment>(
            builder: (_) => const GuidedFaceCaptureScreen()));
  }
}

Future<VerificationAttachment> cacheVerificationAttachment(String source,
    {required String name, bool allowPdf = true}) async {
  final original = File(source);
  final size = await original.length();
  if (size == 0 || size > 5 * 1024 * 1024) {
    throw const FormatException('Choose a non-empty file smaller than 5 MB.');
  }
  final reader = await original.open();
  late String kind;
  try {
    kind = verificationFileKind(await reader.read(8));
  } finally {
    await reader.close();
  }
  if (!allowPdf && kind == 'pdf') {
    throw const FormatException('Choose a JPG or PNG image of your ID.');
  }
  if (kind != 'pdf') {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    try {
      buffer = await ui.ImmutableBuffer.fromFilePath(source);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width * descriptor.height > 24 * 1000 * 1000) {
        throw const FormatException(
            'Choose an image smaller than 24 megapixels.');
      }
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(
          'This image could not be opened. Choose a clear JPG or PNG image.');
    } finally {
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
  final owner = await initializeVerificationCache();
  await owner.reconcileExpired();
  final root = owner.directory;
  final cached =
      File('${root.path}/${DateTime.now().microsecondsSinceEpoch}.$kind');
  final pdfPreview =
      '${cached.path.substring(0, cached.path.lastIndexOf('.'))}-preview.png';
  // Reserve both paths before writing/rendering so concurrent sweeps cannot
  // remove a copy or a partially written native thumbnail in use.
  owner.retain(cached.path);
  if (kind == 'pdf') owner.retain(pdfPreview);
  try {
    await original.copy(cached.path);
  } catch (_) {
    await owner.releasePaths([cached.path, if (kind == 'pdf') pdfPreview]);
    rethrow;
  }
  String? preview;
  if (kind == 'pdf') {
    try {
      preview = await const MethodChannel('davochain/verification_media')
          .invokeMethod<String>('renderPdf', {'path': cached.path});
    } on PlatformException catch (error) {
      if (error.code == 'invalid_pdf') {
        await owner.releasePaths([cached.path, pdfPreview]);
        throw const FormatException(
            'This PDF could not be opened. Choose another document.');
      }
    } catch (_) {
      /* The filename remains usable when a device cannot render a PDF preview. */
    }
    // Use the known owned sibling even if native rendering failed partway.
    if (preview == null) {
      await owner.releasePaths([pdfPreview]);
    } else if (File(preview).absolute.path != File(pdfPreview).absolute.path) {
      await owner.releasePaths([pdfPreview]);
      preview = null;
    }
  }
  return VerificationAttachment(
      path: cached.path,
      name: name,
      bytes: size,
      kind: kind,
      previewPath: preview,
      ownedDirectory: root.path,
      cacheOwner: owner,
      owned: true);
}

Future<void> releaseCapturedSource(String path) async {
  try {
    final root = await (await getTemporaryDirectory()).resolveSymbolicLinks();
    final file = File(path);
    final canonical = await file.resolveSymbolicLinks();
    if (await FileSystemEntity.type(path, followLinks: false) ==
            FileSystemEntityType.file &&
        canonical.startsWith(root + Platform.pathSeparator) &&
        await file.exists()) {
      await file.delete();
    }
  } catch (_) {/* Temporary SDK cache cleanup must not interrupt capture. */}
}
