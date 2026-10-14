import '../wallets/wallet_repository.dart';
import 'package:flutter/foundation.dart';

enum PortfolioPerformancePeriod {
  day('1D', Duration(days: 1)),
  week('1W', Duration(days: 7)),
  month('1M', Duration(days: 30)),
  year('1Y', Duration(days: 365)),
  all('All', null);

  const PortfolioPerformancePeriod(this.wireKey, this.duration);
  final String wireKey;
  final Duration? duration;
}

@immutable
class PortfolioValuePoint {
  const PortfolioValuePoint({required this.timestamp, required this.valueKobo});
  final DateTime timestamp;
  final int valueKobo;
}

/// Only repository-supplied, cash-flow-adjusted returns belong here. A change
/// in account value alone does not distinguish investment gains from deposits.
@immutable
class PortfolioAdjustedPerformance {
  const PortfolioAdjustedPerformance({required this.changeKobo, this.percent});
  final int changeKobo;
  final double? percent;
}

@immutable
class PortfolioPerformanceSnapshot {
  PortfolioPerformanceSnapshot({
    required this.current,
    Iterable<PortfolioValuePoint> history = const [],
    Map<PortfolioPerformancePeriod, PortfolioAdjustedPerformance> performance =
        const {},
  })  : history = List.unmodifiable(history),
        performance = Map.unmodifiable(performance);

  factory PortfolioPerformanceSnapshot.currentBalance({DateTime? timestamp}) =>
      PortfolioPerformanceSnapshot(
          current: PortfolioValuePoint(
              timestamp: timestamp ?? DateTime.now(),
              valueKobo:
                  WalletAccountState.instance.snapshot.portfolioMinorUnits));

  final PortfolioValuePoint current;
  final List<PortfolioValuePoint> history;
  final Map<PortfolioPerformancePeriod, PortfolioAdjustedPerformance>
      performance;

  List<PortfolioValuePoint> pointsFor(PortfolioPerformancePeriod period) {
    final cutoff = period.duration == null
        ? null
        : current.timestamp.subtract(period.duration!);
    // The latest valuation wins if a repository includes it in both fields.
    final byTime = <DateTime, PortfolioValuePoint>{};
    for (final point in [...history, current]) {
      if (!point.timestamp.isAfter(current.timestamp) &&
          (cutoff == null || !point.timestamp.isBefore(cutoff))) {
        byTime[point.timestamp] = point;
      }
    }
    return List.unmodifiable(byTime.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
  }
}

class PortfolioPerformanceController
    extends ValueNotifier<PortfolioPerformanceSnapshot> {
  PortfolioPerformanceController([PortfolioPerformanceSnapshot? snapshot])
      : super(snapshot ?? PortfolioPerformanceSnapshot.currentBalance());
}

typedef PortfolioPerformanceLoader = Future<PortfolioPerformanceSnapshot>
    Function(PortfolioPerformancePeriod period);

String formatPortfolioNaira(int kobo) {
  final absolute = kobo.abs();
  final whole = (absolute ~/ 100)
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${kobo < 0 ? '−' : ''}₦$whole.${(absolute % 100).toString().padLeft(2, '0')}';
}
