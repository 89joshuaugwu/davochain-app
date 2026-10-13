import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A decorative reveal of the real captured frontal photo, after pose checks.
class FaceCaptureReveal extends StatefulWidget {
  const FaceCaptureReveal(
      {super.key, required this.image, required this.onDone});
  final ImageProvider image;
  final VoidCallback onDone;
  @override
  State<FaceCaptureReveal> createState() => _FaceCaptureRevealState();
}

class _FaceCaptureRevealState extends State<FaceCaptureReveal>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 850));
  bool started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) {
        await controller.forward();
      }
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Captured front-facing photo',
      child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final progress = MediaQuery.disableAnimationsOf(context)
                    ? 1.0
                    : Curves.easeInOutCubic.transform(controller.value);
                return Stack(fit: StackFit.expand, children: [
                  Image(image: widget.image, fit: BoxFit.cover),
                  ClipRect(
                      clipper: _UnrevealedPhoto(progress),
                      child: const ColoredBox(color: Color(0xB31C2230))),
                  if (progress < 1)
                    Positioned(
                        top: constraints.maxHeight * progress,
                        left: 0,
                        right: 0,
                        child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: .5),
                                      blurRadius: 14,
                                      spreadRadius: 3)
                                ]))),
                ]);
              })));
}

class _UnrevealedPhoto extends CustomClipper<Rect> {
  const _UnrevealedPhoto(this.progress);
  final double progress;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * progress, size.width, size.height);
  @override
  bool shouldReclip(_UnrevealedPhoto oldClipper) =>
      progress != oldClipper.progress;
}
