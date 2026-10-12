import 'dart:ui' as ui;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/navigation/app_page_route.dart';
import 'guided_face_capture_screen.dart';
import 'verification_attachment.dart';
export 'verification_attachment.dart';

abstract class VerificationMediaGateway {
  static VerificationMediaGateway instance = DeviceVerificationMediaGateway();
  Future<VerificationAttachment?> pickDocument({bool camera = false});
  Future<VerificationAttachment?> captureFace(BuildContext context);
}

class DeviceVerificationMediaGateway implements VerificationMediaGateway {
  @override
  Future<VerificationAttachment?> pickDocument({bool camera = false}) async {
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
  Future<VerificationAttachment?> captureFace(BuildContext context) =>
      Navigator.of(context).push<VerificationAttachment>(
          AppPageRoute<VerificationAttachment>(
              builder: (_) => const GuidedFaceCaptureScreen()));
}

Future<VerificationAttachment> cacheVerificationAttachment(String source,
    {required String name}) async {
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
  final root =
      Directory('${(await getTemporaryDirectory()).path}/verification');
  await root.create(recursive: true);
  final cached = await original
      .copy('${root.path}/${DateTime.now().microsecondsSinceEpoch}.$kind');
  String? preview;
  if (kind == 'pdf') {
    try {
      preview = await const MethodChannel('davochain/verification_media')
          .invokeMethod<String>('renderPdf', {'path': cached.path});
    } on PlatformException catch (error) {
      if (error.code == 'invalid_pdf') {
        await cached.delete();
        throw const FormatException(
            'This PDF could not be opened. Choose another document.');
      }
    } catch (_) {
      /* The filename remains usable when a device cannot render a PDF preview. */
    }
  }
  return VerificationAttachment(
      path: cached.path,
      name: name,
      bytes: size,
      kind: kind,
      previewPath: preview,
      ownedDirectory: root.path,
      owned: true);
}

Future<void> releaseCapturedSource(String path) async {
  try {
    final root = Directory((await getTemporaryDirectory()).path).absolute.path;
    final file = File(path).absolute;
    if (file.path.startsWith(root + Platform.pathSeparator) &&
        await file.exists()) {
      await file.delete();
    }
  } catch (_) {/* Temporary SDK cache cleanup must not interrupt capture. */}
}
