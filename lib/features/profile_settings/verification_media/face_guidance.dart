import 'package:flutter/foundation.dart';

enum FaceGuidanceStage { front, capturing, right, left, nod, done }

/// ML Kit reports camera-space yaw; front-camera instructions use the user's sides.
double frontCameraUserYaw(double detectorYaw) => -detectorYaw;

/// Guides local camera interaction; this is not an anti-spoofing verdict.
class FaceGuidance extends ChangeNotifier {
  FaceGuidanceStage stage = FaceGuidanceStage.front;
  Duration elapsed = Duration.zero;
  bool ready = false;
  bool _nodMoved = false, _nodReturned = false;
  double _lastPitch = 0, _frontPitch = 0;
  Duration get target =>
      Duration(seconds: stage == FaceGuidanceStage.front ? 5 : 3);
  double get progress =>
      (elapsed.inMilliseconds / target.inMilliseconds).clamp(0, 1);
  int get seconds => ((target.inMilliseconds - elapsed.inMilliseconds) / 1000)
      .ceil()
      .clamp(0, 5);
  String get instruction => switch (stage) {
        FaceGuidanceStage.front =>
          'Place your head in the frame and look straight ahead',
        FaceGuidanceStage.capturing => 'Capturing your front-facing photo',
        FaceGuidanceStage.right => 'Turn your head slightly to your right',
        FaceGuidanceStage.left => 'Turn your head slightly to your left',
        FaceGuidanceStage.nod => 'Nod your head, then look straight ahead',
        FaceGuidanceStage.done => 'All done. Review your photo',
      };
  void updatePose(
      {required bool inFrame, required double yaw, required double pitch}) {
    if (stage == FaceGuidanceStage.capturing ||
        stage == FaceGuidanceStage.done) {
      return;
    }
    _lastPitch = pitch;
    if (stage == FaceGuidanceStage.nod && inFrame) {
      final distance = (pitch - _frontPitch).abs();
      if (distance > 10) _nodMoved = true;
      if (_nodMoved && distance < 5) _nodReturned = true;
    }
    ready = inFrame &&
        switch (stage) {
          FaceGuidanceStage.front => yaw.abs() <= 15 && pitch.abs() <= 15,
          FaceGuidanceStage.right => yaw > 12 && yaw < 40,
          FaceGuidanceStage.left => yaw < -12 && yaw > -40,
          FaceGuidanceStage.nod =>
            _nodReturned && yaw.abs() < 15 && (pitch - _frontPitch).abs() < 10,
          _ => false,
        };
    if (!ready) elapsed = Duration.zero;
    notifyListeners();
  }

  void tick(Duration delta) {
    if (!ready ||
        stage == FaceGuidanceStage.capturing ||
        stage == FaceGuidanceStage.done) {
      return;
    }
    elapsed += delta;
    if (elapsed >= target) {
      stage = switch (stage) {
        FaceGuidanceStage.front => FaceGuidanceStage.capturing,
        FaceGuidanceStage.right => FaceGuidanceStage.left,
        FaceGuidanceStage.left => FaceGuidanceStage.nod,
        FaceGuidanceStage.nod => FaceGuidanceStage.done,
        _ => stage,
      };
      elapsed = Duration.zero;
      ready = false;
    }
    notifyListeners();
  }

  void frontCaptured() {
    _frontPitch = _lastPitch;
    stage = FaceGuidanceStage.right;
    ready = false;
    elapsed = Duration.zero;
    notifyListeners();
  }

  void reset() {
    stage = FaceGuidanceStage.front;
    elapsed = Duration.zero;
    ready = false;
    _nodMoved = false;
    _nodReturned = false;
    _lastPitch = 0;
    _frontPitch = 0;
    notifyListeners();
  }
}
