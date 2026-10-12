enum FaceFrameFreshness { fresh, waiting, expired }

/// A short detector delay pauses progress instead of erasing a valid hold.
/// A stopped stream still expires; no countdown starts without a detected pose.
FaceFrameFreshness faceFrameFreshness(Duration age) {
  if (age <= const Duration(seconds: 2)) return FaceFrameFreshness.fresh;
  if (age <= const Duration(seconds: 4)) return FaceFrameFreshness.waiting;
  return FaceFrameFreshness.expired;
}
