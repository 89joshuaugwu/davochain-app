import '../../../shared/widgets/davo_blue_balance_card.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DavoBlueBalanceCard(
                        key: const ValueKey('portfolio-total'),
                        label: 'Total portfolio value',
                        amount: _visible
                            ? formatPortfolioNaira(snapshot.current.valueKobo)
                            : '\u2022\u2022\u2022\u2022\u2022\u2022',
                        caption:
                            'As of ${_timestamp(snapshot.current.timestamp)}'),
                    const SizedBox(height: 20),
                    Text('Value over time',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.ink)),
                    const SizedBox(height: 10),
                    Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: PortfolioPerformancePeriod.values
                            .map((period) => ChoiceChip(
                                key: ValueKey(
                                    'portfolio-period-${period.wireKey}'),
                                label: Text(period.wireKey),
                                selected: _period == period,
                                showCheckmark: false,
                                selectedColor: AppColors.primary,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _period == period
                                        ? Colors.white
                                        : colors.body),
                                onSelected: (_) => _changePeriod(period)))
                            .toList()),
                    const SizedBox(height: 16),
                    if (_loading) const LinearProgressIndicator(minHeight: 2),
                    Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  selected == null
                                      ? 'Latest valuation'
                                      : 'Selected valuation',
                                  style: TextStyle(
                                      fontSize: 12, color: colors.body)),
                              const SizedBox(height: 6),
                              Text(
                                  _visible
                                      ? formatPortfolioNaira(
                                          (selected ?? snapshot.current)
                                              .valueKobo)
                                      : '\u2022\u2022\u2022\u2022\u2022\u2022',
                                  key: const ValueKey(
                                      'portfolio-inspected-value'),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: colors.ink)),
                              const SizedBox(height: 4),
                              Text(
                                  _timestamp(
                                      (selected ?? snapshot.current).timestamp),
                                  key: const ValueKey(
                                      'portfolio-inspected-date'),
                                  style: TextStyle(
                                      fontSize: 12, color: colors.body)),
                              const SizedBox(height: 20),
                              if (!_visible)
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Text('Portfolio values hidden',
                                        style: TextStyle(color: colors.body)))
                              else if (points.length == 1) ...[
                                Divider(color: colors.divider),
                                const SizedBox(height: 14),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.timeline_rounded,
                                          color: colors.link, size: 28),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text('Your first valuation',
                                                style: TextStyle(
                                                    color: colors.ink,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            const SizedBox(height: 6),
                                            Text(
                                                'A trend appears when more valuations are available. Pull down to refresh.',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    height: 1.5,
                                                    color: colors.body)),
                                          ])),
                                    ]),
                              ] else ...[
                                LayoutBuilder(
                                    builder: (context, constraints) => Semantics(
                                        label:
                                            'Portfolio value chart. ${points.length} valuations. Tap or drag to inspect.',
                                        child: GestureDetector(
                                            key: const ValueKey(
                                                'portfolio-chart'),
                                            behavior: HitTestBehavior.opaque,
                                            onTapDown: (d) => _inspect(
                                                d.localPosition.dx,
                                                constraints.maxWidth,
                                                points),
                                            onHorizontalDragStart: (d) => _inspect(
                                                d.localPosition.dx,
                                                constraints.maxWidth,
                                                points),
                                            onHorizontalDragUpdate: (d) =>
                                                _inspect(
                                                    d.localPosition.dx,
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
                                                        grid: colors.divider)))))),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_shortDate(points.first.timestamp),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: colors.body)),
                                      Text(_shortDate(points.last.timestamp),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: colors.body)),
                                    ]),
                                const SizedBox(height: 12),
                                Text('Inspect a valuation',
                                    style: TextStyle(
                                        fontSize: 12, color: colors.body)),
                                Slider(
                                    value: (_selected ?? points.length - 1)
                                        .toDouble(),
                                    min: 0,
                                    max: (points.length - 1).toDouble(),
                                    divisions: points.length - 1,
                                    label: _timestamp(
                                        (selected ?? points.last).timestamp),
                                    semanticFormatterCallback: (v) =>
                                        '${formatPortfolioNaira(points[v.round()].valueKobo)}, ${_timestamp(points[v.round()].timestamp)}',
                                    onChanged: (v) =>
                                        setState(() => _selected = v.round())),
                              ],
                            ])),
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_error!,
                              style: TextStyle(color: colors.danger))),
                    const SizedBox(height: 20),
                    Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _metric(
                                  context,
                                  'Value change \u00b7 ${_period.wireKey}',
                                  !_visible
                                      ? '\u2022\u2022\u2022\u2022\u2022\u2022'
                                      : change == null
                                          ? 'Awaiting history'
                                          : '${change > 0 ? '+' : ''}${formatPortfolioNaira(change)}'),
                              const SizedBox(height: 6),
                              Text('Includes deposits and withdrawals.',
                                  style: TextStyle(
                                      fontSize: 12, color: colors.body)),
                              const SizedBox(height: 14),
                              Divider(color: colors.divider),
                              const SizedBox(height: 14),
                              _metric(
                                  context,
                                  'Investment performance',
                                  !_visible
                                      ? '\u2022\u2022\u2022\u2022\u2022\u2022'
                                      : performance == null
                                          ? 'Not available yet'
                                          : '${performance.changeKobo > 0 ? '+' : ''}${formatPortfolioNaira(performance.changeKobo)}${performance.percent == null ? '' : ' (${performance.percent! > 0 ? '+' : ''}${performance.percent!.toStringAsFixed(2)}%)'}'),
                              const SizedBox(height: 6),
                              Text(
                                  performance == null
                                      ? 'Investment gains exclude money you add or withdraw.'
                                      : 'Adjusted for deposits and withdrawals.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colors.body,
                                      height: 1.5)),
                            ])),
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
      final area = Path.from(geometry.$2)
        ..lineTo(offsets.last.dx, size.height)
        ..lineTo(offsets.first.dx, size.height)
        ..close();
      canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  line.withValues(alpha: .18),
                  line.withValues(alpha: 0)
                ]).createShader(Offset.zero & size));
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
