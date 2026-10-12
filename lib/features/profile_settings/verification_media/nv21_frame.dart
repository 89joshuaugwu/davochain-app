import 'dart:typed_data';

/// CameraX packs rows but can retain extra trailing allocation bytes.
Uint8List packedNv21Bytes(Uint8List bytes, int width, int height) {
  final expected = width * height * 3 ~/ 2;
  if (width <= 0 || height <= 0 || bytes.length < expected) {
    throw const FormatException('Camera NV21 frame is incomplete.');
  }
  return Uint8List.sublistView(bytes, 0, expected);
}
