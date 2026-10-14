import 'dart:io';
import 'package:flutter/services.dart';
import 'package:davochain/features/gift_cards/gift_evidence_picker.dart';

Future<GiftEvidence> giftEvidenceFixture() async {
  final directory = await Directory.systemTemp.createTemp('gift-test-');
  final data = await rootBundle.load('assets/figma_exact/steam.png');
  final file = await File('${directory.path}/chosen-steam.png').writeAsBytes(data.buffer.asUint8List());
  return GiftEvidence(path: file.path, name: 'chosen-steam.png', bytes: data.lengthInBytes,
    kind: 'png', ownedDirectory: directory.path);
}
