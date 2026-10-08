import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../motion/davo_motion_policy.dart';

class DavoCopyButton extends StatefulWidget {
  const DavoCopyButton(
      {super.key, required this.value, required this.label, this.onCopied});
  final String value, label;
  final VoidCallback? onCopied;
  @override
  State<DavoCopyButton> createState() => _CopyState();
}

class _CopyState extends State<DavoCopyButton> {
  bool copied = false, busy = false;
  Timer? timer;
  Future<void> copy() async {
    if (busy) return;
    busy = true;
    try {
      await Clipboard.setData(ClipboardData(text: widget.value));
      if (!mounted) return;
      timer?.cancel();
      setState(() => copied = true);
      widget.onCopied?.call();
      timer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => copied = false);
      });
    } on PlatformException {
      /* A failed write must never display a check. */
    } finally {
      busy = false;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
      label: copied ? 'Copied ${widget.label}' : 'Copy ${widget.label}',
      button: true,
      child: InkWell(
          onTap: copy,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
              width: 32,
              height: 40,
              child: AnimatedSwitcher(
                  duration: DavoMotionPolicy.reduce(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 120),
                  child: Icon(
                      copied ? Icons.check_rounded : Icons.copy_outlined,
                      key: ValueKey(copied),
                      size: 16,
                      color:
                          copied ? DavoColors.of(context).link : DavoColors.of(context).bodyMuted)))));
}
