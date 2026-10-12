import 'dart:io';
import 'dart:async';

class VerificationAttachment {
  const VerificationAttachment(
      {required this.path,
      required this.name,
      required this.bytes,
      required this.kind,
      this.previewPath,
      this.ownedDirectory,
      this.isAsset = false,
      this.owned = false});
  final String path, name, kind;
  final int bytes;
  final String? previewPath, ownedDirectory;
  final bool isAsset, owned;
  String get sizeLabel => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).ceil()} KB';
  void release() {
    if (!owned || isAsset || ownedDirectory == null) return;
    unawaited(_remove(path));
    if (previewPath != null && previewPath != path) {
      unawaited(_remove(previewPath!));
    }
  }

  Future<void> _remove(String target) async {
    try {
      final file = File(target);
      if (file.absolute.parent.path !=
          Directory(ownedDirectory!).absolute.path) {
        return;
      }
      if (await file.exists()) await file.delete();
    } catch (_) {/* Cache cleanup can retry on the next session. */}
  }
}

String verificationFileKind(List<int> bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 13 &&
      bytes[5] == 10 &&
      bytes[6] == 26 &&
      bytes[7] == 10) {
    return 'png';
  }
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return 'jpg';
  }
  if (bytes.length >= 5 && String.fromCharCodes(bytes.take(5)) == '%PDF-') {
    return 'pdf';
  }
  throw const FormatException('Choose a valid JPG, PNG or PDF file.');
}
