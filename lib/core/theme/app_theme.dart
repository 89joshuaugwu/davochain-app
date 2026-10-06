import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF135CF7);
  static const primaryDark = Color(0xFF0D4FE0);
  static const primarySoft = Color(0xFFEDF2FD);
  static const ink = Color(0xFF04070C);
  static const body = Color(0xFF424242);
  static const muted = Color(0xFFC4C5CA);
  static const mutedSoft = Color(0xFFEBEDF3);
  static const offWhite = Color(0xFFF8F9FB);
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      // Figma uses Sora. The project keeps the family name centralized so
      // licensed Sora font files can be dropped in later without UI rewrites.
      fontFamily: 'Sora',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.32,
          color: AppColors.body,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
