import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Account creation and password recovery share one strength colour scale.
abstract final class PasswordStrengthPalette {
  static const low = AppColors.primary;
  static const medium = Color(0xFF986000);
  static const strong = Color(0xFF13803D);

  static Color forScore(int score, {BuildContext? context}) {
    if (context != null && DavoColors.of(context).isDark) {
      final colors = DavoColors.of(context);
      return score <= 1 ? colors.link : score == 2 ? colors.warning : colors.success;
    }
    return score <= 1
      ? low
      : score == 2
          ? medium
          : strong;
  }
}
