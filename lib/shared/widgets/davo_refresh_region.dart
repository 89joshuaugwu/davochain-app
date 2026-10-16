import 'package:flutter/material.dart';
import 'davo_scroll_behavior.dart';

enum DavoRefreshTarget {
  dashboard,
  transactionHistory,
  portfolio,
  portfolioPerformance,
  walletBalances,
  notifications,
  settings,
  giftCardCatalogue,
  transaction,
}

@immutable
class DavoRefreshRequest {
  const DavoRefreshRequest(this.target, {this.recordId, this.period});
  final DavoRefreshTarget target;
  final String? recordId;
  final String? period;
}

typedef DavoRefreshDelegate = Future<void> Function(DavoRefreshRequest request);

/// App-wide read-only refresh binding. Repositories publish fetched state before
/// completing. Transaction requests refer to an existing ID, never execution.
class DavoRefreshScope extends InheritedWidget {
  const DavoRefreshScope(
      {super.key, required this.onRefresh, required super.child});
  final DavoRefreshDelegate onRefresh;
  static Future<void> refresh(BuildContext context, DavoRefreshTarget target,
      {String? recordId, String? period}) async {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DavoRefreshScope>();
    await scope?.onRefresh(
        DavoRefreshRequest(target, recordId: recordId, period: period));
  }

  @override
  bool updateShouldNotify(DavoRefreshScope old) => old.onRefresh != onRefresh;
}

class DavoRefreshRegion extends StatefulWidget {
  const DavoRefreshRegion(
      {super.key,
      required this.builder,
      required this.target,
      this.recordId,
      this.period,
      this.onRefresh});
  final WidgetBuilder builder;
  final DavoRefreshTarget target;
  final String? recordId;
  final String? period;
  final Future<void> Function()? onRefresh;
  @override
  State<DavoRefreshRegion> createState() => _DavoRefreshRegionState();
}

class _DavoRefreshRegionState extends State<DavoRefreshRegion> {
  Future<void> refresh() async {
    if (widget.onRefresh case final loader?) {
      await loader();
    } else {
      await DavoRefreshScope.refresh(context, widget.target,
          recordId: widget.recordId, period: widget.period);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => DavoFloatingRefresh(
      onRefresh: refresh, child: Builder(builder: widget.builder));
}
