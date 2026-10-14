import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../profile_settings/verification_media/verification_cache_owner.dart';

/// Gift-code evidence has an independent account scope and session-only
/// lifetime. Every previous-process copy is reclaimed before another pick.
/// The generic deletion primitive is reused, not the verification cache policy.
class GiftEvidenceCache {
  GiftEvidenceCache(this.directory);
  final Directory directory;
  static const retention = Duration(hours: 1);
  final Map<String, VerificationCacheOwner> _owners = {};
  Future<void>? _starting;
  bool _started = false;
  static Future<GiftEvidenceCache>? _device;

  static Future<GiftEvidenceCache> device() => _device ??= () async {
        final temporary = await getTemporaryDirectory();
        return GiftEvidenceCache(Directory('${temporary.path}/gift_evidence'));
      }();

  static Future<void> reconcileDeviceStartup() async =>
      (await device()).reconcileStartup();

  Future<void> reconcileStartup() {
    if (_started) return Future.value();
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  Future<void> _start() async {
    final type =
        await FileSystemEntity.type(directory.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.directory) {
      throw StateError('Gift evidence storage is unavailable.');
    }
    await directory.create(recursive: true);
    await for (final entry in directory.list(followLinks: false)) {
      // Cache ownership stops at the known account directories. Never follow
      // links or recursively delete a tree based on an untrusted picked path.
      final childType =
          await FileSystemEntity.type(entry.path, followLinks: false);
      if (childType != FileSystemEntityType.directory) {
        throw StateError('Gift evidence cleanup could not complete.');
      }
      final owner =
          VerificationCacheOwner(Directory(entry.path), retention: retention);
      await owner.initializeAndReconcile();
      _owners[entry.absolute.path] = owner;
    }
    _started = true;
  }

  Future<VerificationCacheOwner> ownerFor(String accountId) async {
    if (accountId.isEmpty) {
      throw StateError('Select an account before adding gift evidence.');
    }
    await reconcileStartup();
    final key = base64Url.encode(utf8.encode(accountId)).replaceAll('=', '');
    final accountDirectory = Directory('${directory.path}/$key').absolute;
    final owner = _owners.putIfAbsent(accountDirectory.path,
        () => VerificationCacheOwner(accountDirectory, retention: retention));
    await owner.initializeAndReconcile();
    final outcome = await owner.reconcileExpired();
    if (!outcome.complete) {
      throw StateError('Gift evidence cleanup could not complete.');
    }
    return owner;
  }
}
