import 'package:flutter/material.dart';

/// Use the supplied native celebration emoji, preferring the platform's color
/// emoji font over the app's monochrome mathematical/emoji fallbacks.
class DavoCelebrationEmoji extends StatelessWidget {
  const DavoCelebrationEmoji({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: Text('\u{1F389}',
          textScaler: TextScaler.noScaling,
          style: TextStyle(
              fontFamily: 'Noto Color Emoji',
              fontFamilyFallback: const ['Apple Color Emoji', 'Segoe UI Emoji'],
              fontSize: size,
              height: 1)));
}
