import 'dart:async';

/// Keeps native resources alive until their last asynchronous user completes.
class FaceCaptureLifetime {
  final Set<Future<void>> _pending = {};
  bool _accepting = true;
  Future<void>? _closing;
  bool get accepting => _accepting;

  Future<T> run<T>(Future<T> Function() work) {
    if (!_accepting) throw StateError('Face capture is closing.');
    final result = Future<T>.sync(work);
    late final Future<void> finished;
    finished = result.then<void>((_) {
      _pending.remove(finished);
    }, onError: (Object error, StackTrace stack) {
      _pending.remove(finished);
    });
    _pending.add(finished);
    return result;
  }

  Future<void> drain() async {
    while (_pending.isNotEmpty) {
      await Future.wait(_pending.toList());
    }
  }

  Future<void> close(Future<void> Function() closeResources) {
    _accepting = false;
    return _closing ??= _finishClose(closeResources);
  }

  Future<void> _finishClose(Future<void> Function() closeResources) async {
    await drain();
    await closeResources();
  }
}
