import 'package:davochain/features/profile_settings/verification_media/face_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('front-camera detector yaw follows the user right and left instructions', () {
    final guide = FaceGuidance();
    addTearDown(guide.dispose);
    guide.frontCaptured();
    guide.updatePose(inFrame: true, yaw: frontCameraUserYaw(-20), pitch: 0);
    expect(guide.ready, isTrue);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.left);
    guide.updatePose(inFrame: true, yaw: frontCameraUserYaw(20), pitch: 0);
    expect(guide.ready, isTrue);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.nod);
  });
  test('Only the initial centered countdown captures; poses gate subsequent steps', () {
    final guide = FaceGuidance();
    guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
    guide.tick(const Duration(seconds: 8));
    expect(guide.stage, FaceGuidanceStage.front);
    guide.updatePose(inFrame: true, yaw: 0, pitch: 0);
    guide.tick(const Duration(seconds: 4));
    expect(guide.stage, FaceGuidanceStage.front);
    guide.tick(const Duration(seconds: 1));
    expect(guide.stage, FaceGuidanceStage.capturing);
    guide.frontCaptured();
    guide.tick(const Duration(seconds: 6));
    expect(guide.stage, FaceGuidanceStage.right);
    guide.updatePose(inFrame: true, yaw: 18, pitch: 0);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.left);
    guide.updatePose(inFrame: true, yaw: -18, pitch: 0);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.nod);
    guide.updatePose(inFrame: true, yaw: 0, pitch: 12);
    guide.updatePose(inFrame: true, yaw: 0, pitch: 0);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.done);
    guide.dispose();
  });
  test('losing alignment restarts the countdown and reset returns to front', () {
    final guide = FaceGuidance();
    guide.updatePose(inFrame: true, yaw: 0, pitch: 0);
    guide.tick(const Duration(seconds: 3));
    guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
    expect(guide.progress, 0);
    guide.updatePose(inFrame: true, yaw: 0, pitch: 0);
    guide.tick(const Duration(seconds: 3));
    expect(guide.stage, FaceGuidanceStage.front);
    guide.reset(); expect(guide.progress, 0);
    guide.dispose();
  });
}
