import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Decorative double scan of an attachment preview, without changing its data.
/// Keep this widget keyed by attachment identity so ordinary rebuilds retain it.
class AttachmentScanPreview extends StatefulWidget {
  const AttachmentScanPreview({super.key, required this.child});
  final Widget child;
  @override
  State<AttachmentScanPreview> createState() => _AttachmentScanPreviewState();
}

class _AttachmentScanPreviewState extends State<AttachmentScanPreview>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));
  bool started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = 1;
      started = true;
    } else if (!started) {
      started = true;
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        final complete = controller.value == 1;
        final progress = Curves.easeInOut.transform((controller.value * 2) % 1);
        return ClipRect(
            child: Stack(fit: StackFit.passthrough, children: [
          child!,
          if (!complete) ...[
            Positioned.fill(
                child: IgnorePointer(
                    child: ClipRect(
                        clipper: _ScanShade(progress),
                        child: const ColoredBox(color: Color(0x261C2230))))),
            Positioned.fill(
                child: IgnorePointer(
                    child: Align(
                        alignment: Alignment(0, progress * 2 - 1),
                        child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .7),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: .3),
                                      blurRadius: 8,
                                      spreadRadius: 1)
                                ])))))
          ]
        ]));
      });
}

class _ScanShade extends CustomClipper<Rect> {
  const _ScanShade(this.progress);
  final double progress;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * progress, size.width, size.height);
  @override
  bool shouldReclip(_ScanShade oldClipper) => progress != oldClipper.progress;
}
