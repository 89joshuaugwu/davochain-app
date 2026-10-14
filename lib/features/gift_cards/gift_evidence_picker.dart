import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import '../profile_settings/verification_media/verification_attachment.dart'
    show verificationFileKind;
import '../profile_settings/verification_media/verification_cache_owner.dart';
import 'gift_evidence_cache.dart';

typedef GiftEvidencePicker = Future<GiftEvidence?> Function(String accountId);

class GiftEvidence {
  const GiftEvidence(
      {required this.path,
      required this.name,
      required this.bytes,
      required this.kind,
      this.ownedDirectory,
      this.cacheOwner});
  final String path, name, kind;
  final int bytes;
  final String? ownedDirectory;
  final VerificationCacheOwner? cacheOwner;
  Future<void> release() async {
    if (cacheOwner != null) {
      await cacheOwner!.releasePaths([path]);
      return;
    }
    if (ownedDirectory == null) return;
    final file = File(path);
    if (file.absolute.parent.path != Directory(ownedDirectory!).absolute.path) {
      return;
    }
    if (await file.exists()) await file.delete();
  }
}

/// Gift evidence has its own account cache and lifetime. Never put redeemable
/// gift codes into verification storage or delete the user's picked original.
Future<GiftEvidence?> pickGiftEvidence(String accountId) async {
  final selection = await FilePicker.pickFile(
      type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png']);
  if (selection == null) return null;
  final source = selection.path;
  if (source == null) {
    throw const FormatException(
        'Choose a JPG or PNG file saved on this device.');
  }
  return cacheGiftEvidence(source, name: selection.name, accountId: accountId);
}

Future<GiftEvidence> cacheGiftEvidence(String source,
    {required String name,
    required String accountId,
    Directory? cacheRoot}) async {
  final cache = cacheRoot == null
      ? await GiftEvidenceCache.device()
      : GiftEvidenceCache(Directory('${cacheRoot.path}/gift_evidence'));
  final owner = await cache.ownerFor(accountId);
  final original = File(source);
  final size = await original.length();
  if (size == 0 || size > 5 * 1024 * 1024) {
    throw const FormatException('Choose a non-empty image smaller than 5 MB.');
  }
  final reader = await original.open();
  late String kind;
  try {
    kind = verificationFileKind(await reader.read(8));
  } finally {
    await reader.close();
  }
  if (kind == 'pdf') {
    throw const FormatException('Choose a JPG or PNG image of your gift card.');
  }
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  try {
    buffer = await ui.ImmutableBuffer.fromFilePath(source);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    if (descriptor.width * descriptor.height > 24000000) {
      throw const FormatException(
          'Choose an image smaller than 24 megapixels.');
    }
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException(
        'This image could not be opened. Choose another JPG or PNG.');
  } finally {
    descriptor?.dispose();
    buffer?.dispose();
  }
  final root = owner.directory;
  final destination = await original
      .copy('${root.path}/${DateTime.now().microsecondsSinceEpoch}.$kind');
  owner.retain(destination.path);
  return GiftEvidence(
      path: destination.path,
      name: name,
      bytes: size,
      kind: kind,
      ownedDirectory: root.path,
      cacheOwner: owner);
}
