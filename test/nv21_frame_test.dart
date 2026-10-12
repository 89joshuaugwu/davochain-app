import 'dart:typed_data';
import 'package:davochain/features/profile_settings/verification_media/nv21_frame.dart';
import 'package:davochain/features/profile_settings/verification_media/face_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('padded CameraX allocations preserve the packed pixels and discard trailing bytes', () {
    final bytes = Uint8List.fromList(List.generate(170, (i) => i));
    final packed = packedNv21Bytes(bytes, 10, 10);
    expect(packed.length, 150);
    expect(packed, bytes.sublist(0, 150));
    expect(() => packedNv21Bytes(Uint8List(149), 10, 10), throwsFormatException);
  });
  test('natural front pose can count down; nod returns to that captured pose', () {
    final guide = FaceGuidance();
    addTearDown(guide.dispose);
    guide.updatePose(inFrame: true, yaw: 12, pitch: 12);
    guide.tick(const Duration(seconds: 5));
    expect(guide.stage, FaceGuidanceStage.capturing);
    guide.frontCaptured();
    guide.updatePose(inFrame: true, yaw: 20, pitch: 12);
    guide.tick(const Duration(seconds: 3));
    guide.updatePose(inFrame: true, yaw: -20, pitch: 12);
    guide.tick(const Duration(seconds: 3));
    guide.updatePose(inFrame: true, yaw: 0, pitch: 28);
    guide.updatePose(inFrame: true, yaw: 0, pitch: 12);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.done);
  });
}
