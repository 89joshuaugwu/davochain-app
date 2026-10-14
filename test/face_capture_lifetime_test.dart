import 'dart:async';
import 'package:davochain/features/profile_settings/verification_media/face_capture_lifetime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('camera teardown waits for actual in-flight work before closing resources', () async {
    final lifetime = FaceCaptureLifetime();
    final frame = Completer<void>();
    final capture = Completer<void>();
    var closed = false;
    final analysis = lifetime.run(() => frame.future);
    final photo = lifetime.run(() => capture.future);
    final teardown = lifetime.close(() async { closed = true; });
    await Future<void>.delayed(Duration.zero);
    expect(closed, isFalse);
    frame.complete();
    await analysis;
    expect(closed, isFalse);
    capture.complete();
    await photo;
    await teardown;
    expect(closed, isTrue);
  });
  test('failed in-flight camera work still allows teardown', () async {
    final lifetime = FaceCaptureLifetime();
    final frame = Completer<void>();
    var closed = false;
    final analysis = lifetime.run(() => frame.future);
    final failure = expectLater(analysis, throwsStateError);
    final teardown = lifetime.close(() async { closed = true; });
    frame.completeError(StateError('frame failed'));
    await failure;
    await teardown;
    expect(closed, isTrue);
    expect(() => lifetime.run(() async {}), throwsStateError);
  });
}
