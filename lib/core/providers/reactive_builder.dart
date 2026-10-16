import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'account_scope.dart';

final listenableRevisionProvider = NotifierProvider.autoDispose
    .family<ListenableRevision, int, Listenable>(ListenableRevision.new);

/// Adapts native/device services while Riverpod owns subscription lifetime.
class ListenableRevision extends Notifier<int> {
  ListenableRevision(this.source);
  final Listenable source;
  bool queued = false;
  @override
  int build() {
    void changed() {
      if (queued) return;
      queued = true;
      scheduleMicrotask(() {
        queued = false;
        if (ref.mounted) state++;
      });
    }

    source.addListener(changed);
    ref.onDispose(() => source.removeListener(changed));
    return 0;
  }
}

class DavoListenableBuilder extends StatelessWidget {
  const DavoListenableBuilder({
    super.key,
    required this.listenable,
    required this.builder,
    this.child,
  });
  final Listenable listenable;
  final Widget? child;
  final Widget Function(BuildContext, Widget?) builder;
  @override
  Widget build(BuildContext context) => AccountConsumer(
    builder: (context, ref) {
      ref.watch(listenableRevisionProvider(listenable));
      return builder(context, child);
    },
  );
}

class DavoValueListenableBuilder<T> extends StatelessWidget {
  const DavoValueListenableBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.child,
  });
  final ValueListenable<T> valueListenable;
  final Widget? child;
  final Widget Function(BuildContext, T, Widget?) builder;
  @override
  Widget build(BuildContext context) => DavoListenableBuilder(
    listenable: valueListenable,
    builder: (context, child) => builder(context, valueListenable.value, child),
    child: child,
  );
}
