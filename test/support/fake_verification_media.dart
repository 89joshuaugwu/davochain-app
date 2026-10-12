import 'package:flutter/material.dart';
import 'package:davochain/features/profile_settings/verification_media/verification_media_gateway.dart';
export 'package:davochain/features/profile_settings/verification_media/verification_media_gateway.dart';

class FakeVerificationMedia implements VerificationMediaGateway {
  bool cancelDocument = false;
  bool cancelFace = false;
  final cameraRequests = <bool>[];
  @override
  Future<VerificationAttachment?> pickDocument({bool camera = false}) async {
    cameraRequests.add(camera);
    return cancelDocument
        ? null
        : const VerificationAttachment(
            path: 'assets/figma_exact/verification_1cc51.png',
            name: 'electricity_bill.png',
            bytes: 1200000,
            kind: 'png',
            isAsset: true);
  }

  @override
  Future<VerificationAttachment?> captureFace(BuildContext context) async =>
      cancelFace
          ? null
          : const VerificationAttachment(
              path: 'assets/figma_exact/verification_901d8.png',
              name: 'selfie.jpg',
              bytes: 500000,
              kind: 'jpg',
              isAsset: true);
}
