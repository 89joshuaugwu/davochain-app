import 'dart:io';
import 'package:davochain/features/profile_settings/verification_media/verification_media_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  const paths = MethodChannel('plugins.flutter.io/path_provider');
  setUpAll(() async {
    temporary = await Directory.systemTemp.createTemp('native-verification-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(paths, (call) async {
      if (call.method == 'getTemporaryDirectory') return temporary.path;
      throw MissingPluginException('Unsupported path-provider test request');
    });
  });
  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(paths, null);
    await temporary.delete(recursive: true);
  });
  test('ID gallery uses native image selection and handles cancellation',
      () async {
    final original = ImagePickerPlatform.instance;
    final picker = _ImageSelection();
    ImagePickerPlatform.instance = picker;
    addTearDown(() => ImagePickerPlatform.instance = original);
    expect(await DeviceVerificationMediaGateway().pickIdentity(), isNull);
    expect(picker.sources, [ImageSource.gallery]);
    expect(await DeviceVerificationMediaGateway().pickIdentity(camera: true),
        isNull);
    expect(picker.sources, [ImageSource.gallery, ImageSource.camera]);
  });
  test('ID rejects a PDF signature even when filename says PNG', () async {
    final dir = await Directory.systemTemp.createTemp('id-signature-test');
    addTearDown(() => dir.delete(recursive: true));
    final file =
        await File('${dir.path}/id.png').writeAsBytes('%PDF-1.7'.codeUnits);
    await expectLater(
        cacheVerificationAttachment(file.path, name: 'id.png', allowPdf: false),
        throwsFormatException);
  });
  test('ID rejects empty files and files beyond 5 MiB before decoding',
      () async {
    final dir = await Directory.systemTemp.createTemp('id-size-test');
    addTearDown(() => dir.delete(recursive: true));
    final file = await File('${dir.path}/id.jpg').writeAsBytes([]);
    await expectLater(
        cacheVerificationAttachment(file.path, name: 'id.jpg', allowPdf: false),
        throwsFormatException);
    await file.writeAsBytes(List<int>.filled(5 * 1024 * 1024 + 1, 0));
    await expectLater(
        cacheVerificationAttachment(file.path, name: 'id.jpg', allowPdf: false),
        throwsFormatException);
  });
  test('document type comes from its signature rather than a filename', () {
    expect(
        verificationFileKind([0x89, 0x50, 0x4e, 0x47, 13, 10, 26, 10]), 'png');
    expect(verificationFileKind([0xff, 0xd8, 0xff, 0]), 'jpg');
    expect(verificationFileKind('%PDF-1.7'.codeUnits), 'pdf');
    expect(() => verificationFileKind('not a document'.codeUnits),
        throwsFormatException);
    expect(() => verificationFileKind([]), throwsFormatException);
  });
}

class _ImageSelection extends ImagePickerPlatform {
  final sources = <ImageSource>[];
  @override
  Future<XFile?> getImageFromSource(
      {required ImageSource source,
      ImagePickerOptions options = const ImagePickerOptions()}) async {
    sources.add(source);
    return null;
  }
}
