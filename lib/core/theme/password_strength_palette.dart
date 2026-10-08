import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Account creation and password recovery share one strength colour scale.
abstract final class PasswordStrengthPalette {
  static const low = AppColors.primary;
  static const medium = Color(0xFF986000);
  static const strong = Color(0xFF13803D);

  static Color forScore(int score) => score <= 1
      ? low
      : score == 2
          ? medium
          : strong;
}
