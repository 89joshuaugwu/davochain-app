import 'dart:io';

/// Paths are deliberately excluded from cleanup diagnostics.
class VerificationCleanupOutcome {
  const VerificationCleanupOutcome({this.failed = 0, this.rejected = 0});
  final int failed, rejected;
  bool get complete => failed == 0 && rejected == 0;
}

/// Owns only direct regular files in the verification cache. Session progress
/// is not persisted, so every previous-process file is an orphan at startup.
class VerificationCacheOwner {
  VerificationCacheOwner(this.directory,
      {this.retention = const Duration(hours: 24),
      Future<void> Function(File)? deleteFile})
      : _deleteFile = deleteFile ?? _delete;

  final Directory directory;
  final Duration retention;
  final Future<void> Function(File) _deleteFile;
  final Set<String> _active = {};
  Future<void>? _initializing;
  bool _initialized = false;

  static Future<void> _delete(File file) async {
    await file.delete();
  }

  Future<void> initializeAndReconcile() {
    if (_initialized) return Future.value();
    return _initializing ??=
        _initialize().whenComplete(() => _initializing = null);
  }

  Future<void> _initialize() async {
    final type =
        await FileSystemEntity.type(directory.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw StateError('Verification cache is unavailable.');
    }
    await directory.create(recursive: true);
    final outcome = await _sweep(all: true);
    if (!outcome.complete) {
      throw StateError('Verification cache cleanup could not complete.');
    }
    _initialized = true;
  }

  String _key(String path) {
    final absolute = File(path).absolute.path.replaceAll('\\', '/');
    return Platform.isWindows ? absolute.toLowerCase() : absolute;
  }

  void retain(String path) => _active.add(_key(path));

  Future<VerificationCleanupOutcome> reconcileExpired() async {
    await initializeAndReconcile();
    return _sweep(all: false);
  }

  Future<VerificationCleanupOutcome> _sweep({required bool all}) async {
    var failed = 0, rejected = 0;
    final cutoff = DateTime.now().subtract(retention);
    // Never recurse or follow a symlink into another directory.
    await for (final entity in directory.list(followLinks: false)) {
      if (_active.contains(_key(entity.path))) continue;
      final type = await FileSystemEntity.type(entity.path, followLinks: false);
      if (type != FileSystemEntityType.file) {
        rejected++;
        continue;
      }
      if (!all && (await entity.stat()).modified.isAfter(cutoff)) continue;
      final result = await releasePaths([entity.path]);
      failed += result.failed;
      rejected += result.rejected;
    }
    return VerificationCleanupOutcome(failed: failed, rejected: rejected);
  }

  Future<VerificationCleanupOutcome> releasePaths(
      Iterable<String> paths) async {
    var failed = 0, rejected = 0;
    for (final target in paths.toSet()) {
      _active.remove(_key(target));
      var removed = false;
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final file = File(target);
          final rootType =
              await FileSystemEntity.type(directory.path, followLinks: false);
          if (rootType != FileSystemEntityType.directory) {
            rejected++;
            break;
          }
          final canonicalRoot = await directory.resolveSymbolicLinks();
          // Resolve parent even when target has already disappeared.
          if (await file.parent.resolveSymbolicLinks() != canonicalRoot) {
            rejected++;
            break;
          }
          final type = await FileSystemEntity.type(target, followLinks: false);
          if (type == FileSystemEntityType.notFound) {
            removed = true;
            break;
          }
          if (type != FileSystemEntityType.file ||
              File(await file.resolveSymbolicLinks()).parent.path !=
                  canonicalRoot) {
            rejected++;
            break;
          }
          await _deleteFile(file);
          removed = true;
          break;
        } on FileSystemException {
          if (attempt == 2) failed++;
        }
      }
      // Failed copies remain on disk for the next sweep or startup retry.
      if (!removed) continue;
    }
    return VerificationCleanupOutcome(failed: failed, rejected: rejected);
  }
}
