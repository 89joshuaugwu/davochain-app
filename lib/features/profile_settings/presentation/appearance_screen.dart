import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/appearance_controller.dart';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/davo_toast.dart';

const _modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
const _images = [
  'assets/images/appearance/davochain_light_updated.png',
  'assets/images/appearance/davochain_dark_updated.png',
  'assets/images/appearance/davochain_iphone_app_mockup_duo.png',
];
String _label(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

/// A local draft: only Next changes the device preference.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key, this.controller});
  final AppearanceController? controller;
  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AppearanceController get _preference =>
      widget.controller ?? AppearanceController.instance;
  late ThemeMode _selected = _preference.mode;
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    value: 1,
  );
  late List<double> _from = _target;
  bool _saving = false;
  bool _reduce = false;
  bool _foreground = true;
  int? _decodeWidth;
  List<double> get _target =>
      [for (final mode in _modes) mode == _selected ? 1 : 0];
  List<double> get _weights {
    final t = Curves.easeOutCubic.transform(_motion.value);
    return [for (var i = 0; i < 3; i++) _from[i] + (_target[i] - _from[i]) * t];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = DavoMotionPolicy.reduce(context);
    if (_reduce && _motion.isAnimating) _motion.value = 1;
    final width = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(320, 1200);
    if (width != _decodeWidth) {
      _decodeWidth = width;
      for (final asset in [
        ..._images,
        'assets/images/appearance/phone_preview_background.png'
      ]) {
        precacheImage(ResizeImage(AssetImage(asset), width: width), context);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    // Finish an in-flight draft when backgrounded; no ticker survives a pause.
    if (!_foreground) _motion.value = 1;
  }

  void _select(ThemeMode mode) {
    if (_saving || mode == _selected) return;
    final visible = _weights;
    setState(() {
      _from = visible;
      _selected = mode;
    });
    if (_reduce || !_foreground) {
      _motion.value = 1;
    } else {
      _motion.forward(from: 0);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _preference.setMode(_selected);
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showDavoToast(context, 'Could not save appearance. Please try again.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final dark = _selected == ThemeMode.dark ||
        (_selected == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _saving ? null : () => Navigator.pop(context),
            icon: Image.asset('assets/figma_exact/icon_arrow_left.png',
                color: colors.ink, width: 24, height: 24),
          ),
          title: Text('Appearance',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.ink)),
        ),
        body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final mode in _modes) ...[
                    if (mode != ThemeMode.light) const SizedBox(width: 10),
                    Expanded(
                        child: _AppearanceChoice(
                            mode: mode,
                            selected: mode == _selected,
                            onTap: _saving ? null : () => _select(mode))),
                  ],
                ]),
                const SizedBox(height: 24),
                Semantics(
                    label: '${_label(_selected)} appearance preview',
                    child: ExcludeSemantics(
                      child: Container(
                        key: const ValueKey('appearance-live-preview'),
                        height: 360,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: dark
                                ? DavoColors.dark.canvas
                                : DavoColors.light.canvas,
                            borderRadius: BorderRadius.circular(6)),
                        clipBehavior: Clip.antiAlias,
                        child: RepaintBoundary(
                            child: AnimatedBuilder(
                          animation: _motion,
                          builder: (context, _) {
                            final weights = _weights;
                            return Stack(fit: StackFit.expand, children: [
                              Image.asset(
                                  'assets/images/appearance/phone_preview_background.png',
                                  fit: BoxFit.cover,
                                  cacheWidth: _decodeWidth,
                                  excludeFromSemantics: true),
                              for (var i = 0; i < 3; i++)
                                if (weights[i] > 0)
                                  Opacity(
                                      opacity: weights[i],
                                      child: Transform.translate(
                                        offset: Offset(
                                            _reduce
                                                ? 0
                                                : (1 - weights[i]) *
                                                    (i == 1 ? -8 : 8),
                                            0),
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: i == 2 ? 0 : 16),
                                            child: Transform.scale(
                                                scale: i == 2 ? 1.2 : 1,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Image.asset(_images[i],
                                                    key: ValueKey(
                                                        'appearance-image-${_modes[i].name}'),
                                                    cacheWidth: _decodeWidth,
                                                    fit: BoxFit.contain,
                                                    alignment: i == 2
                                                        ? Alignment.bottomCenter
                                                        : Alignment.center,
                                                    gaplessPlayback: true,
                                                    filterQuality:
                                                        FilterQuality.medium))),
                                      )),
                              if (!_reduce && _motion.isAnimating)
                                IgnorePointer(
                                    child: CustomPaint(
                                        painter: _LightSweep(_motion.value))),
                            ]);
                          },
                        )),
                      ),
                    )),
                const SizedBox(height: 24),
                DavoPrimaryButton(
                    label: _saving ? 'Saving…' : 'Next',
                    enabled: !_saving,
                    onPressed: _save),
              ]),
            )),
      ),
    );
  }
}

class _AppearanceChoice extends StatelessWidget {
  const _AppearanceChoice(
      {required this.mode, required this.selected, required this.onTap});
  final ThemeMode mode;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final dark = mode == ThemeMode.dark;
    final label = _label(mode);
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    return Semantics(
      label: '$label appearance',
      button: true,
      selected: selected,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: dark
            ? const Color(0xFF2B2B2B)
            : mode == ThemeMode.system
                ? const Color(0xFFF2F2F2)
                : const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFE5E5E5),
                width: selected ? 1.5 : 1)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 168 + math.max(0, scale - 1) * 24,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (mode == ThemeMode.system)
                const CustomPaint(size: Size(32, 32), painter: _SystemIcon())
              else
                Icon(
                    dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: AppColors.primary,
                    size: 32),
              const SizedBox(height: 12),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: dark ? Colors.white : const Color(0xFF1C1C1C))),
              const SizedBox(height: 24),
              Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : dark
                                  ? const Color(0xFFADADAD)
                                  : const Color(0xFF757575))),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : null),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SystemIcon extends CustomPainter {
  const _SystemIcon();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawCircle(
        rect.center,
        size.width / 2 - 1,
        Paint()
          ..color = const Color(0xFF242424)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawArc(rect.deflate(1), math.pi / 2, math.pi, true,
        Paint()..color = const Color(0xFF242424));
  }

  @override
  bool shouldRepaint(_SystemIcon oldDelegate) => false;
}

class _LightSweep extends CustomPainter {
  const _LightSweep(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final x = (-.4 + 1.8 * progress) * size.width;
    final rect =
        Rect.fromLTWH(x - size.width * .25, 0, size.width * .5, size.height);
    final strength = math.sin(progress * math.pi) * .16;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: strength),
            Colors.white.withValues(alpha: 0),
          ]).createShader(rect));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LightSweep oldDelegate) =>
      oldDelegate.progress != progress;
}
