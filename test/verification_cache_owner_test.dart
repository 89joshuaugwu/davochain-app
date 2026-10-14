import 'dart:io';

import 'package:davochain/features/profile_settings/verification_media/verification_cache_owner.dart';
import 'package:davochain/features/profile_settings/verification_media/verification_attachment.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory sandbox;
  late Directory root;
  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('verification-owner-');
    root = await Directory('${sandbox.path}/verification').create();
  });
  tearDown(() async {
    await VerificationSession.instance.reset();
    await sandbox.delete(recursive: true);
  });

  test('restart removes orphan original, PDF thumbnail and interrupted copy only', () async {
    final source = await File('${sandbox.path}/picked.pdf').writeAsString('source');
    for (final name in ['123.pdf', '123-preview.png', '123.partial']) {
      await File('${root.path}/$name').writeAsString('sensitive');
    }
    await VerificationCacheOwner(root).initializeAndReconcile();
    expect(await root.list().toList(), isEmpty);
    expect(await source.readAsString(), 'source');
  });

  test('repeated initialization preserves an active capture; expiry removes only abandoned copies', () async {
    final owner = VerificationCacheOwner(root, retention: Duration.zero);
    await owner.initializeAndReconcile();
    final active = await File('${root.path}/live.pdf').writeAsString('live');
    final preview = await File('${root.path}/live-preview.png').writeAsString('preview');
    owner.retain(active.path);
    owner.retain(preview.path);
    await File('${root.path}/abandoned.partial').writeAsString('old');
    await owner.initializeAndReconcile();
    await owner.reconcileExpired();
    expect(await active.exists(), isTrue);
    expect(await preview.exists(), isTrue);
    expect(await File('${root.path}/abandoned.partial').exists(), isFalse);
  });

  test('release is awaitable and preserves source and outside preview', () async {
    final original = await File('${sandbox.path}/picked.pdf').writeAsString('source');
    final cached = await File('${root.path}/123.pdf').writeAsString('copy');
    final preview = await File('${root.path}/123-preview.png').writeAsString('preview');
    final attachment = VerificationAttachment(path: cached.path, name: 'picked.pdf',
      bytes: 4, kind: 'pdf', owned: true, ownedDirectory: root.path, previewPath: preview.path);
    final result = await attachment.release();
    expect(result.complete, isTrue);
    expect(await cached.exists(), isFalse);
    expect(await preview.exists(), isFalse);
    expect(await original.exists(), isTrue);
    final outside = VerificationAttachment(path: original.path, name: 'picked.pdf',
      bytes: 4, kind: 'pdf', owned: true, ownedDirectory: root.path);
    expect((await outside.release()).complete, isFalse);
    expect(await original.exists(), isTrue);
  });

  test('canonical traversal target cannot delete the picked original', () async {
    final source = await File('${sandbox.path}/picked.pdf').writeAsString('source');
    final owner = VerificationCacheOwner(root);
    await owner.initializeAndReconcile();
    final outcome = await owner.releasePaths(['${root.path}/../picked.pdf']);
    expect(outcome.complete, isFalse);
    expect(await source.exists(), isTrue);
  });

  test('failed startup deletion retries and blocks new capture until reconciled', () async {
    final orphan = await File('${root.path}/orphan.pdf').writeAsString('sensitive');
    var blocked = true;
    var attempts = 0;
    final owner = VerificationCacheOwner(root, deleteFile: (file) async {
      attempts++;
      if (blocked) throw const FileSystemException('busy');
      await file.delete();
    });
    await expectLater(owner.initializeAndReconcile(), throwsStateError);
    expect(attempts, 3);
    expect(await orphan.exists(), isTrue);
    blocked = false;
    await owner.initializeAndReconcile();
    expect(await orphan.exists(), isFalse);
  });

  test('account reset waits for owned ID and selfie cleanup', () async {
    final session = VerificationSession.instance;
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
    session.chooseDocument('National ID');
    final id = await File('${root.path}/id.jpg').writeAsString('id');
    final selfie = await File('${root.path}/selfie.jpg').writeAsString('selfie');
    VerificationAttachment attachment(File file) => VerificationAttachment(
      path: file.path, name: 'image.jpg', bytes: 2, kind: 'jpg', owned: true, ownedDirectory: root.path);
    session.attachIdentity(attachment(id), front: true);
    session.attachSelfie(attachment(selfie));
    await session.reset();
    expect(await id.exists(), isFalse);
    expect(await selfie.exists(), isFalse);
    expect(session.identityFront, isNull);
    expect(session.selfie, isNull);
  });

  test('account reset reports failed cleanup even when a later copy deletes', () async {
    final session = VerificationSession.instance;
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
    session.chooseDocument('National ID');
    final owner = VerificationCacheOwner(root, deleteFile: (file) async {
      if (file.path.endsWith('locked.jpg')) throw const FileSystemException('busy');
      await file.delete();
    });
    await owner.initializeAndReconcile();
    final id = await File('${root.path}/locked.jpg').writeAsString('id');
    final selfie = await File('${root.path}/selfie.jpg').writeAsString('selfie');
    VerificationAttachment attachment(File file) => VerificationAttachment(
      path: file.path, name: 'image.jpg', bytes: 2, kind: 'jpg', owned: true,
      ownedDirectory: root.path, cacheOwner: owner);
    session.attachIdentity(attachment(id), front: true);
    session.attachSelfie(attachment(selfie));
    await session.reset();
    expect(session.lastCleanupOutcome.complete, isFalse);
    expect(await id.exists(), isTrue);
    expect(await selfie.exists(), isFalse);
  });
}
