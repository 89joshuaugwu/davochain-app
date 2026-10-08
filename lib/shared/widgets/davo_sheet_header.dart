import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Equal side reservations keep the title centered on narrow devices.
class DavoSheetHeader extends StatelessWidget {
  const DavoSheetHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          const SizedBox(width: 44),
          Expanded(
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      height: 1.35,
                      color: DavoColors.of(context).ink))),
          IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close_rounded, size: 24)),
        ]),
      );
}
