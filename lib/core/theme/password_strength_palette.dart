import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Account creation and password recovery share one strength colour scale.
abstract final class PasswordStrengthPalette {
  static const low = Color(0xFFB42318);
  static const medium = Color(0xFFFF9800);
  static const strong = Color(0xFF19C55D);

  static Color forScore(int score, {BuildContext? context}) {
    if (context != null && DavoColors.of(context).isDark) {
      final colors = DavoColors.of(context);
      return score <= 1
          ? colors.danger
          : score == 2
              ? colors.warning
              : colors.success;
    }
    return score <= 1
        ? low
        : score == 2
            ? medium
            : strong;
  }
}
