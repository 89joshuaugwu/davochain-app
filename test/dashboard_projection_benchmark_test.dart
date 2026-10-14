import 'package:davochain/features/dashboard/portfolio_performance.dart';
import 'package:flutter_test/flutter_test.dart';

// Reproducible CPU-only comparison of the previous projection algorithm and
// repeated lookups on one immutable snapshot. These are not frame measurements.
void main() {
  test('report equivalent baseline and cached projection workloads', () {
    final now = DateTime.utc(2026, 10, 14);
    final snapshot = PortfolioPerformanceSnapshot(
        current: PortfolioValuePoint(timestamp: now, valueKobo: 500000),
        history: List.generate(
            1000,
            (i) => PortfolioValuePoint(
                timestamp: now.subtract(Duration(hours: 1000 - i)),
                valueKobo: 100000 + i)));
    List<PortfolioValuePoint> baseline(PortfolioPerformancePeriod period) {
      final cutoff = period.duration == null
          ? null
          : snapshot.current.timestamp.subtract(period.duration!);
      final byTime = <DateTime, PortfolioValuePoint>{};
      for (final point in [...snapshot.history, snapshot.current]) {
        if (!point.timestamp.isAfter(snapshot.current.timestamp) &&
            (cutoff == null || !point.timestamp.isBefore(cutoff))) {
          byTime[point.timestamp] = point;
        }
      }
      return List.unmodifiable(byTime.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
    }

    for (final period in [
      PortfolioPerformancePeriod.day,
      PortfolioPerformancePeriod.all
    ]) {
      final expected = baseline(period);
      final actual = snapshot.pointsFor(period);
      expect(actual.map((p) => p.valueKobo), expected.map((p) => p.valueKobo));
      int measure(List<PortfolioValuePoint> Function() lookup) {
        var checksum = 0;
        final timer = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          final points = lookup();
          checksum += points.length + points.last.valueKobo;
        }
        timer.stop();
        expect(checksum, 1000 * (actual.length + 500000));
        return timer.elapsedMicroseconds;
      }

      for (var i = 0; i < 100; i++) {
        baseline(period);
        snapshot.pointsFor(period);
      }
      final before = List.generate(5, (_) => measure(() => baseline(period)))
        ..sort();
      final after =
          List.generate(5, (_) => measure(() => snapshot.pointsFor(period)))
            ..sort();
      // ignore: avoid_print
      print(
          'projection_microbenchmark period=${period.wireKey} history=1000 lookups=1000 samples=5 baseline_median_us=${before[2]} cached_median_us=${after[2]} rows=${actual.length}');
    }
  });
}
