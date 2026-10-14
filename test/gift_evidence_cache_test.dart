import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/gift_cards/gift_evidence_cache.dart';

void main() {
  test('startup reclaims gift-code copies and preserves picked original', () async {
    final temporary = await Directory.systemTemp.createTemp('gift-retention-');
    addTearDown(() => temporary.delete(recursive: true));
    final original = await File('${temporary.path}/original.png').writeAsBytes([1, 2, 3]);
    final root = await Directory('${temporary.path}/gift_evidence').create();
    final account = await Directory('${root.path}/account-a').create();
    final orphan = await File('${account.path}/orphan.png').writeAsBytes([1, 2, 3]);
    await GiftEvidenceCache(root).reconcileStartup();
    expect(await orphan.exists(), isFalse);
    expect(await original.readAsBytes(), [1, 2, 3]);
  });
}
