import 'package:davochain/features/profile_settings/verification_media/face_frame_freshness.dart';
import 'package:davochain/features/profile_settings/verification_media/face_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slow detector results do not repeatedly erase the front hold', () {
    final guide = FaceGuidance();
    addTearDown(guide.dispose);
    guide.updatePose(inFrame: true, yaw: 0, pitch: 0);
    for (var tick = 0; tick < 25; tick++) {
      // Redmi-class processing can take longer than the former 800 ms TTL.
      final age = Duration(milliseconds: (tick % 6) * 200);
      expect(faceFrameFreshness(age), FaceFrameFreshness.fresh);
      guide.tick(const Duration(milliseconds: 200));
      if (tick % 6 == 5) {
        guide.updatePose(inFrame: true, yaw: 0, pitch: 0);
      }
    }
    expect(guide.stage, FaceGuidanceStage.capturing);
  });

  test('delayed frames pause; a stopped stream expires', () {
    expect(faceFrameFreshness(const Duration(seconds: 2)),
        FaceFrameFreshness.fresh);
    expect(faceFrameFreshness(const Duration(milliseconds: 2200)),
        FaceFrameFreshness.waiting);
    expect(faceFrameFreshness(const Duration(milliseconds: 4001)),
        FaceFrameFreshness.expired);
  });

  test('elapsed wall time alone cannot start the countdown', () {
    final guide = FaceGuidance();
    addTearDown(guide.dispose);
    guide.tick(const Duration(seconds: 10));
    expect(guide.stage, FaceGuidanceStage.front);
    expect(guide.seconds, 5);
  });
}
