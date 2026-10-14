import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davo_refresh_region.dart';
import '../portfolio_performance.dart';

class PortfolioPerformanceScreen extends StatefulWidget {
  const PortfolioPerformanceScreen(
      {super.key,
      this.initialValueVisible = true,
      this.controller,
      this.loader});
  final bool initialValueVisible;
  final PortfolioPerformanceController? controller;
  final PortfolioPerformanceLoader? loader;
  @override
  State<PortfolioPerformanceScreen> createState() =>
      _PortfolioPerformanceScreenState();
}

class _PortfolioPerformanceScreenState
    extends State<PortfolioPerformanceScreen> {
  late PortfolioPerformanceController _controller;
  late bool _visible;
  var _period = PortfolioPerformancePeriod.month;
  int? _selected;
  int _loadGeneration = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _visible = widget.initialValueVisible;
    _controller = widget.controller ?? PortfolioPerformanceController();
    _controller.addListener(_snapshotChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  void _snapshotChanged() {
    if (mounted) setState(() => _selected = null);
  }

  @override
  void didUpdateWidget(PortfolioPerformanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loader != widget.loader) {
      _loadGeneration++;
      _loading = false;
      _error = null;
    }
    if (oldWidget.controller != widget.controller) {
      _loadGeneration++;
      _controller.removeListener(_snapshotChanged);
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? PortfolioPerformanceController();
      _controller.addListener(_snapshotChanged);
      _selected = null;
      _loading = false;
      _error = null;
    }
    if (oldWidget.loader != widget.loader) {
      _loadGeneration++;
      _loading = false;
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    _controller.removeListener(_snapshotChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loader = widget.loader;
    final generation = ++_loadGeneration;
    final period = _period;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (loader == null) {
        await DavoRefreshScope.refresh(
            context, DavoRefreshTarget.portfolioPerformance,
            period: period.wireKey);
      } else {
        final snapshot = await loader(period);
        if (mounted && generation == _loadGeneration) {
          _controller.value = snapshot;
        }
      }
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(() =>
            _error = 'Couldn’t update your portfolio. Pull down to try again.');
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  void _changePeriod(PortfolioPerformancePeriod period) {
    if (_period == period) return;
    setState(() {
      _period = period;
      _selected = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final snapshot = _controller.value;
    final points = snapshot.pointsFor(_period);
    final selected = _selected == null
        ? null
        : points[_selected!.clamp(0, points.length - 1)];
    final change = points.length > 1
        ? points.last.valueKobo - points.first.valueKobo
        : null;
    final performance = snapshot.performance[_period];
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
          title: const Text('Portfolio performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
                tooltip: _visible
                    ? 'Hide portfolio values'
                    : 'Show portfolio values',
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(_visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined))
          ]),
      body: DavoRefreshRegion(
          target: DavoRefreshTarget.portfolioPerformance,
          period: _period.wireKey,
          onRefresh: _load,
          builder: (context) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total portfolio value',
                        style:
                            TextStyle(color: colors.bodyMuted, fontSize: 14)),
                    const SizedBox(height: 10),
                    Text(
                        _visible
                            ? formatPortfolioNaira(snapshot.current.valueKobo)
                            : '••••••',
                        key: const ValueKey('portfolio-total'),
                        style: TextStyle(
                            color: colors.ink,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1)),
                    const SizedBox(height: 28),
                    Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.divider)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Portfolio value',
                                  style: TextStyle(
                                      color: colors.ink,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: PortfolioPerformancePeriod.values
                                      .map((period) => ChoiceChip(
                                          key: ValueKey(
                                              'portfolio-period-${period.wireKey}'),
                                          label: Text(period.wireKey),
                                          selected: _period == period,
                                          showCheckmark: false,
                                          selectedColor: colors.primarySoft,
                                          labelStyle: TextStyle(
                                              color: _period == period
                                                  ? colors.link
                                                  : colors.bodyMuted),
                                          onSelected: (_) =>
                                              _changePeriod(period)))
                                      .toList()),
                              const SizedBox(height: 20),
                              if (_loading)
                                const LinearProgressIndicator(minHeight: 2),
                              const SizedBox(height: 12),
                              Text(
                                  selected == null
                                      ? 'Latest valuation'
                                      : 'Selected valuation',
                                  style: TextStyle(
                                      fontSize: 12, color: colors.bodyMuted)),
                              const SizedBox(height: 6),
                              Text(
                                  _visible
                                      ? formatPortfolioNaira(
                                          (selected ?? snapshot.current)
                                              .valueKobo)
                                      : '••••••',
                                  key: const ValueKey(
                                      'portfolio-inspected-value'),
                                  style: TextStyle(
                                      color: colors.ink,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                  _timestamp(
                                      (selected ?? snapshot.current).timestamp),
                                  key: const ValueKey(
                                      'portfolio-inspected-date'),
                                  style: TextStyle(
                                      color: colors.bodyMuted, fontSize: 12)),
                              const SizedBox(height: 16),
                              if (_visible)
                                LayoutBuilder(
                                    builder: (context, constraints) => Semantics(
                                        label:
                                            'Portfolio value chart. ${points.length} valuations. Tap or drag to inspect.',
                                        child: GestureDetector(
                                            key: const ValueKey(
                                                'portfolio-chart'),
                                            behavior: HitTestBehavior.opaque,
                                            onTapDown: (details) => _inspect(
                                                details.localPosition.dx,
                                                constraints.maxWidth,
                                                points),
                                            onHorizontalDragStart: (details) => _inspect(
                                                details.localPosition.dx,
                                                constraints.maxWidth,
                                                points),
                                            onHorizontalDragUpdate: (details) =>
                                                _inspect(
                                                    details.localPosition.dx,
                                                    constraints.maxWidth,
                                                    points),
                                            child: SizedBox(
                                                height: 180,
                                                width: double.infinity,
                                                child: CustomPaint(
                                                    painter: _PortfolioChartPainter(
                                                        points: points,
                                                        selected: _selected,
                                                        line: colors.link,
                                                        grid: colors.divider))))))
                              else
                                Container(height: 180, alignment: Alignment.center, child: Text('Portfolio values hidden', style: TextStyle(color: colors.bodyMuted))),
                              const SizedBox(height: 12),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_shortDate(points.first.timestamp),
                                        style: TextStyle(
                                            color: colors.bodyMuted,
                                            fontSize: 12)),
                                    Text(
                                        points.length == 1
                                            ? 'Now'
                                            : _shortDate(points.last.timestamp),
                                        style: TextStyle(
                                            color: colors.bodyMuted,
                                            fontSize: 12)),
                                  ]),
                              if (_visible && points.length > 1) ...[
                                const SizedBox(height: 12),
                                Text('Inspect a valuation',
                                    style: TextStyle(
                                        color: colors.bodyMuted, fontSize: 12)),
                                Slider(
                                    value: (_selected ?? points.length - 1)
                                        .toDouble(),
                                    min: 0,
                                    max: (points.length - 1).toDouble(),
                                    divisions: points.length - 1,
                                    label: _timestamp(
                                        (selected ?? points.last).timestamp),
                                    semanticFormatterCallback: (value) =>
                                        '${formatPortfolioNaira(points[value.round()].valueKobo)}, ${_timestamp(points[value.round()].timestamp)}',
                                    onChanged: (value) => setState(
                                        () => _selected = value.round())),
                              ],
                            ])),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Text(_error!, style: TextStyle(color: colors.danger)),
                      const SizedBox(height: 16)
                    ],
                    if (points.length == 1) ...[
                      Text('Performance history starts here',
                          style: TextStyle(
                              color: colors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          'Your current valuation is recorded above. Future valuations will show how your portfolio changes over time.',
                          style:
                              TextStyle(color: colors.bodyMuted, height: 1.5)),
                    ] else ...[
                      _metric(
                          context,
                          'Value change · ${_period.wireKey}',
                          _visible
                              ? '${change! > 0 ? '+' : ''}${formatPortfolioNaira(change)}'
                              : '••••••'),
                      const SizedBox(height: 8),
                      Text('Includes deposits and withdrawals.',
                          style:
                              TextStyle(color: colors.bodyMuted, fontSize: 12)),
                    ],
                    const SizedBox(height: 20),
                    _metric(
                        context,
                        'Investment performance',
                        !_visible
                            ? '••••••'
                            : performance == null
                                ? '—'
                                : '${performance.changeKobo > 0 ? '+' : ''}${formatPortfolioNaira(performance.changeKobo)}${performance.percent == null ? '' : ' (${performance.percent! > 0 ? '+' : ''}${performance.percent!.toStringAsFixed(2)}%)'}'),
                    const SizedBox(height: 8),
                    Text(
                        performance == null
                            ? 'Investment gains are shown separately from money you add or withdraw.'
                            : 'Adjusted for deposits and withdrawals.',
                        style: TextStyle(
                            color: colors.bodyMuted,
                            fontSize: 12,
                            height: 1.5)),
                  ]))),
    );
  }

  Widget _metric(BuildContext context, String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: DavoColors.of(context).bodyMuted, fontSize: 13)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: DavoColors.of(context).ink,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ]);

  void _inspect(double x, double width, List<PortfolioValuePoint> points) {
    if (points.length == 1) {
      setState(() => _selected = 0);
      return;
    }
    final fraction = ((x - 12) / math.max(1, width - 24)).clamp(0.0, 1.0);
    final time = points.first.timestamp.microsecondsSinceEpoch +
        fraction *
            (points.last.timestamp.microsecondsSinceEpoch -
                points.first.timestamp.microsecondsSinceEpoch);
    var nearest = 0;
    for (var i = 1; i < points.length; i++) {
      if ((points[i].timestamp.microsecondsSinceEpoch - time).abs() <
          (points[nearest].timestamp.microsecondsSinceEpoch - time).abs()) {
        nearest = i;
      }
    }
    setState(() => _selected = nearest);
  }
}

String _shortDate(DateTime timestamp) {
  final local = timestamp.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${local.day} ${months[local.month - 1]}';
}

String _timestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  return '${_shortDate(local)} ${local.year}, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

class _PortfolioChartPainter extends CustomPainter {
  _PortfolioChartPainter(
      {required this.points,
      required this.selected,
      required this.line,
      required this.grid});
  final List<PortfolioValuePoint> points;
  final int? selected;
  final Color line;
  final Color grid;
  static final _geometryCache = Expando<_PortfolioChartGeometry>();
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = 12 + (size.height - 24) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final geometry = (_geometryCache[points] ??=
            _PortfolioChartGeometry(points))
        .forSize(size);
    final offsets = geometry.$1;
    if (offsets.length > 1) {
      canvas.drawPath(
          geometry.$2,
          Paint()
            ..color = line
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
    final point =
        offsets[(selected ?? offsets.length - 1).clamp(0, offsets.length - 1)];
    if (selected != null) {
      canvas.drawLine(
          Offset(point.dx, 0),
          Offset(point.dx, size.height),
          Paint()
            ..color = line.withValues(alpha: .3)
            ..strokeWidth = 1);
    }
    canvas.drawCircle(point, 9, Paint()..color = line.withValues(alpha: .15));
    canvas.drawCircle(point, 4.5, Paint()..color = line);
  }

  @override
  bool shouldRepaint(_PortfolioChartPainter oldDelegate) =>
      !identical(points, oldDelegate.points) ||
      selected != oldDelegate.selected ||
      line != oldDelegate.line ||
      grid != oldDelegate.grid;
}

/// One size projection per immutable point list; inspecting a different point
/// reuses the line geometry. Expando releases it when the snapshot is discarded.
class _PortfolioChartGeometry {
  _PortfolioChartGeometry(this.points);
  final List<PortfolioValuePoint> points;
  Size? _size;
  (List<Offset>, Path)? _projection;
  (List<Offset>, Path) forSize(Size size) {
    if (_size == size && _projection != null) return _projection!;
    final minValue = points.map((point) => point.valueKobo).reduce(math.min);
    final maxValue = points.map((point) => point.valueKobo).reduce(math.max);
    final span = maxValue - minValue;
    final timeSpan =
        points.last.timestamp.difference(points.first.timestamp).inMicroseconds;
    final offsets = points
        .map((point) => Offset(
            timeSpan == 0
                ? size.width / 2
                : 12 +
                    (size.width - 24) *
                        point.timestamp
                            .difference(points.first.timestamp)
                            .inMicroseconds /
                        timeSpan,
            span == 0
                ? size.height / 2
                : size.height -
                    16 -
                    (size.height - 32) * (point.valueKobo - minValue) / span))
        .toList();
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    _size = size;
    return _projection = (offsets, path);
  }
}
