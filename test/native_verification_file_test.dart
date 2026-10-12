import 'package:davochain/features/profile_settings/verification_media/verification_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
