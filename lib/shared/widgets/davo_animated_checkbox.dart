import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Circular agreement control with a finite check drawing and a 44px target.
class DavoAnimatedCheckbox extends StatefulWidget {
  const DavoAnimatedCheckbox(
      {super.key,
      required this.value,
      required this.onChanged,
      this.semanticLabel,
      this.size = 20})
      : assert(size > 0);
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final double size;
  @override
  State<DavoAnimatedCheckbox> createState() => _DavoAnimatedCheckboxState();
}

class _DavoAnimatedCheckboxState extends State<DavoAnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _selection;
  bool _focused = false;
  bool _hasFocus = false;
  bool _reduceMotion = false;
  @override
  void initState() {
    super.initState();
    _selection = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
        value: widget.value ? 1 : 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (_reduceMotion) {
      _selection.stop();
      _selection.value = widget.value ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(DavoAnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (_reduceMotion) {
        _selection.value = widget.value ? 1 : 0;
      } else {
        _selection.animateTo(widget.value ? 1 : 0,
            duration: Duration(milliseconds: widget.value ? 220 : 160),
            curve: Curves.linear);
      }
    }
  }

  void _toggle() => widget.onChanged?.call(!widget.value);
  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: widget.semanticLabel,
        checked: widget.value,
        enabled: widget.onChanged != null,
        focusable: widget.onChanged != null,
        focused: widget.onChanged == null ? null : _hasFocus,
        onTap: widget.onChanged == null ? null : _toggle,
        child: ExcludeSemantics(
            child: FocusableActionDetector(
          includeFocusSemantics: false,
          enabled: widget.onChanged != null,
          onFocusChange: (value) => setState(() => _hasFocus = value),
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
              _toggle();
              return null;
            })
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onChanged == null ? null : _toggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: AnimatedBuilder(
                    animation: _selection,
                    builder: (context, _) => CustomPaint(
                          size: Size.square(widget.size),
                          painter: _CheckboxPainter(_selection.value,
                              enabled: widget.onChanged != null,
                              focused: _focused),
                        )),
              ),
            ),
          ),
        )),
      );
}

class _CheckboxPainter extends CustomPainter {
  const _CheckboxPainter(this.progress,
      {required this.enabled, required this.focused});
  final double progress;
  final bool enabled;
  final bool focused;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 1;
    final blue = enabled ? AppColors.primary : AppColors.bodyMuted;
    if (focused) {
      canvas.drawCircle(
          center,
          radius + 4,
          Paint()
            ..color = AppColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Color.lerp(AppColors.bodyMuted, blue, progress)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    if (progress > 0) {
      canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color =
                blue.withValues(alpha: (progress * 220 / 100).clamp(0, 1)));
      final path = Path()
        ..moveTo(size.width * .27, size.height * .5)
        ..lineTo(size.width * .43, size.height * .66)
        ..lineTo(size.width * .73, size.height * .35);
      final metric = path.computeMetrics().first;
      canvas.drawPath(
          metric.extractPath(
              0, metric.length * ((progress * 220 - 80) / 120).clamp(0.0, 1.0)),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.shortestSide * .1
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      enabled != oldDelegate.enabled ||
      focused != oldDelegate.focused;
}
