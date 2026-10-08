import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

OverlayEntry? _activeToast;

/// One top notice at a time, below the status bar, independent of the keyboard.
void showDavoToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  final previous = _activeToast;
  if (previous != null) {
    previous.remove();
    previous.dispose();
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
      builder: (_) => _ToastNotice(
            message: message,
            onClose: () {
              if (entry.mounted) {
                entry.remove();
                entry.dispose();
              }
              if (identical(_activeToast, entry)) _activeToast = null;
            },
            onDisposed: () {
              if (identical(_activeToast, entry)) _activeToast = null;
            },
          ));
  _activeToast = entry;
  overlay.insert(entry);
}

class _ToastNotice extends StatefulWidget {
  const _ToastNotice(
      {required this.message, required this.onClose, required this.onDisposed});
  final String message;
  final VoidCallback onClose, onDisposed;
  @override
  State<_ToastNotice> createState() => _ToastNoticeState();
}

class _ToastNoticeState extends State<_ToastNotice> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), widget.onClose);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Semantics(
            liveRegion: true,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: reduced ? 1 : 0, end: 1),
              duration:
                  reduced ? Duration.zero : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                      offset: Offset(0, -8 * (1 - value)), child: child)),
              child: Center(
                  child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Material(
                  color: AppColors.inkStrong,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Text(widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white)),
                  ),
                ),
              )),
            )),
      ),
    );
  }
}
