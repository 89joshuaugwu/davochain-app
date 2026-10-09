import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'davo_colors.dart';
export 'davo_colors.dart';

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
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colors = brightness == Brightness.dark ? DavoColors.dark : DavoColors.light;
    final isDark = brightness == Brightness.dark;
    const baseText = TextStyle(fontFamily: 'Sora', fontFamilyFallback: ['DavoNotoSans', 'DavoNotoEmoji']);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.surface,
      extensions: [colors],
      iconTheme: IconThemeData(color: colors.bodyMuted),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: colors.link)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: colors.link, side: BorderSide(color: colors.border))),
      dividerColor: colors.divider,
      disabledColor: colors.muted,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface, surfaceTintColor: Colors.transparent,
        foregroundColor: colors.ink,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: colors.elevated, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(backgroundColor: colors.elevated, surfaceTintColor: Colors.transparent),
      textSelectionTheme: TextSelectionThemeData(cursorColor: colors.link, selectionColor: colors.link.withValues(alpha: .28), selectionHandleColor: colors.link),
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: colors.surface,
        onSurface: colors.ink,
        onSurfaceVariant: colors.bodyMuted,
        outline: colors.border,
        error: colors.danger,
      ),
      fontFamily: 'Sora',
      fontFamilyFallback: const ['DavoNotoSans', 'DavoNotoEmoji'],
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
          color: colors.ink,
        ),
        titleMedium: baseText.copyWith(
          fontSize: 20,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: colors.ink,
        ),
        bodyLarge: baseText.copyWith(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.32,
          color: colors.body,
        ),
        bodyMedium: baseText.copyWith(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w400,
          color: colors.body,
        ),
        bodySmall: baseText.copyWith(
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w400,
          color: colors.bodyMuted,
        ),
        labelLarge: baseText.copyWith(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: baseText.copyWith(
          fontSize: 16,
          height: 1.35,
          color: colors.muted,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.32,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: isDark ? colors.border : const Color(0xFFD2D6DF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.25),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colors.danger, width: 1.25),
        ),
      ),
    );
  }
}
