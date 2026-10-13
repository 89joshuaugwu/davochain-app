import 'package:flutter/material.dart';
import 'davo_scroll_behavior.dart';

enum DavoRefreshTarget {
  dashboard,
  transactionHistory,
  portfolio,
  walletBalances,
  notifications,
  giftCardCatalogue,
  transaction,
}

@immutable
class DavoRefreshRequest {
  const DavoRefreshRequest(this.target, {this.recordId});
  final DavoRefreshTarget target;
  final String? recordId;
}

typedef DavoRefreshDelegate = Future<void> Function(DavoRefreshRequest request);

/// App-wide read-only refresh binding. Repositories publish fetched state before
/// completing. Transaction requests refer to an existing ID, never execution.
class DavoRefreshScope extends InheritedWidget {
  const DavoRefreshScope(
      {super.key, required this.onRefresh, required super.child});
  final DavoRefreshDelegate onRefresh;
  static Future<void> refresh(BuildContext context, DavoRefreshTarget target,
      {String? recordId}) async {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DavoRefreshScope>();
    await scope?.onRefresh(DavoRefreshRequest(target, recordId: recordId));
  }

  @override
  bool updateShouldNotify(DavoRefreshScope old) => old.onRefresh != onRefresh;
}

class DavoRefreshRegion extends StatefulWidget {
  const DavoRefreshRegion(
      {super.key, required this.builder, required this.target, this.recordId});
  final WidgetBuilder builder;
  final DavoRefreshTarget target;
  final String? recordId;
  @override
  State<DavoRefreshRegion> createState() => _DavoRefreshRegionState();
}

class _DavoRefreshRegionState extends State<DavoRefreshRegion> {
  Future<void> refresh() async {
    await DavoRefreshScope.refresh(context, widget.target,
        recordId: widget.recordId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => DavoFloatingRefresh(
      onRefresh: refresh, child: Builder(builder: widget.builder));
}
