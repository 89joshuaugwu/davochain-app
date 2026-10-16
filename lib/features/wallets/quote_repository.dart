import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simulation_quotes.dart';

class QuoteSnapshot {
  QuoteSnapshot({
    required this.id,
    required this.asOf,
    this.expiresAt,
    required Map<String, int> pricesMinorUnits,
    required this.usdNgnMinorUnits,
  }) : pricesMinorUnits = Map.unmodifiable(pricesMinorUnits) {
    if (id.isEmpty ||
        usdNgnMinorUnits <= 0 ||
        pricesMinorUnits.values.any((v) => v <= 0))
      throw const FormatException('Invalid quote');
  }
  factory QuoteSnapshot.offline() => QuoteSnapshot(
    id: 'coingecko-${SimulationQuotes.observedAtSeconds}',
    asOf: DateTime.fromMillisecondsSinceEpoch(
      SimulationQuotes.observedAtSeconds * 1000,
      isUtc: true,
    ),
    pricesMinorUnits: SimulationQuotes.pricesMinorUnits,
    usdNgnMinorUnits: SimulationQuotes.usdNgnMinorUnits,
  );
  final String id;
  final DateTime asOf;
  final DateTime? expiresAt;
  final Map<String, int> pricesMinorUnits;
  final int usdNgnMinorUnits;
  bool isExpired(DateTime now) =>
      expiresAt != null && !now.isBefore(expiresAt!);
  bool matches(QuoteSnapshot current, DateTime now) =>
      id == current.id && !isExpired(now) && !current.isExpired(now);
}

abstract interface class QuoteSource {
  QuoteSnapshot get current;
  Stream<QuoteSnapshot> watch();
  Future<void> refresh();
}

/// Offline source is intentionally steady. Real adapters push observed prices.
class MutableQuoteSource implements QuoteSource {
  MutableQuoteSource([QuoteSnapshot? initial])
    : _current = initial ?? QuoteSnapshot.offline();
  QuoteSnapshot _current;
  final _updates = StreamController<QuoteSnapshot>.broadcast(sync: true);
  @override
  QuoteSnapshot get current => _current;
  bool publish(QuoteSnapshot next) {
    if (next.asOf.isBefore(_current.asOf) || next.id == _current.id)
      return false;
    _current = next;
    _updates.add(next);
    return true;
  }

  @override
  Stream<QuoteSnapshot> watch() => _updates.stream;
  @override
  Future<void> refresh() async {}
  Future<void> dispose() => _updates.close();
}

class QuoteRepository {
  QuoteRepository(this.source);
  final QuoteSource source;
  QuoteSnapshot get current => source.current;
  Stream<QuoteSnapshot> watch() => source.watch();
  Future<void> refresh() => source.refresh();
}

final quoteSourceProvider = Provider<QuoteSource>((ref) {
  final source = MutableQuoteSource();
  ref.onDispose(source.dispose);
  return source;
});
final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => QuoteRepository(ref.watch(quoteSourceProvider)),
);
final quoteUpdatesProvider = StreamProvider<QuoteSnapshot>(
  (ref) => ref.watch(quoteRepositoryProvider).watch(),
);
final quoteProvider = Provider<QuoteSnapshot>(
  (ref) =>
      ref.watch(quoteUpdatesProvider).value ??
      ref.watch(quoteRepositoryProvider).current,
);
