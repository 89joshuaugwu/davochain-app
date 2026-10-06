import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF135CF7);
  static const primaryDark = Color(0xFF0D4FE0);
  static const primarySoft = Color(0xFFEDF2FD);
  static const primaryDisabled = Color(0xFFD0DEFD);

  static const ink = Color(0xFF1C1C1C);
  static const inkStrong = Color(0xFF1A1C20);
  static const body = Color(0xFF424242);
  static const bodyMuted = Color(0xFF686868);
  static const muted = Color(0xFFA7A7A7);
  static const border = Color(0xFFD2D2D2);
  static const mutedSoft = Color(0xFFEBEDF3);
  static const offWhite = Color(0xFFF8F9FB);
  static const fieldFill = Color(0xFFFFFFFF);

  static const success = Color(0xFF20C55D);
  static const warning = Color(0xFFCC8408);
  static const warningSurface = Color(0xFFFEF9F1);
  static const warningBorder = Color(0xFFF5F0C5);
  static const danger = Color(0xFFF44336);
}

abstract final class AppTheme {
  static ThemeData get light {
    const baseText = TextStyle(fontFamily: 'Sora');

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
        error: AppColors.danger,
      ),
      fontFamily: 'Sora',
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        headlineSmall: baseText.copyWith(
          fontSize: 24,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        titleLarge: baseText.copyWith(
          fontSize: 24,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleMedium: baseText.copyWith(
          fontSize: 20,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: baseText.copyWith(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.32,
          color: AppColors.body,
        ),
        bodyMedium: baseText.copyWith(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w400,
          color: AppColors.body,
        ),
        bodySmall: baseText.copyWith(
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w400,
          color: AppColors.bodyMuted,
        ),
        labelLarge: baseText.copyWith(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: baseText.copyWith(
          fontSize: 16,
          height: 1.35,
          color: AppColors.muted,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.32,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0x14121212)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.25),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.25),
        ),
      ),
    );
  }
}
