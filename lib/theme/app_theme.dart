import 'package:flutter/material.dart';

class AppColors {
  // Background layers
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1A2235);
  static const Color card = Color(0xFF16213E);

  // Accent gradient
  static const Color accentStart = Color(0xFF6C63FF);
  static const Color accentEnd = Color(0xFF48CAE4);
  static const Color accentPink = Color(0xFFFF6584);
  static const Color accentAmber = Color(0xFFFFC857);

  // Text
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B9DC3);
  static const Color textMuted = Color(0xFF4A5568);

  // Utility
  static const Color divider = Color(0xFF1E2D4A);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // Time-of-day gradient colors
  static const Color nightStart = Color(0xFF0A0E1A);
  static const Color nightEnd = Color(0xFF1A2235);
  static const Color dawnStart = Color(0xFF1A0F2E);
  static const Color dawnEnd = Color(0xFF4A2040);
  static const Color morningStart = Color(0xFF1A2E4A);
  static const Color morningEnd = Color(0xFF2D5A7A);
  static const Color noonStart = Color(0xFF1E3A5F);
  static const Color noonEnd = Color(0xFF2E6B9E);
  static const Color eveningStart = Color(0xFF2A1A3E);
  static const Color eveningEnd = Color(0xFF5A2D60);

  static List<Color> gradientForHour(int hour) {
    if (hour >= 0 && hour < 5) {
      return [nightStart, nightEnd];
    } else if (hour >= 5 && hour < 8) {
      return [dawnStart, dawnEnd];
    } else if (hour >= 8 && hour < 12) {
      return [morningStart, morningEnd];
    } else if (hour >= 12 && hour < 17) {
      return [noonStart, noonEnd];
    } else if (hour >= 17 && hour < 21) {
      return [eveningStart, eveningEnd];
    } else {
      return [nightStart, nightEnd];
    }
  }

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [accentStart, accentEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get secondaryGradient => const LinearGradient(
        colors: [accentPink, accentAmber],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Outfit',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentStart,
        secondary: AppColors.accentEnd,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Outfit',
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Outfit',
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentStart, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontFamily: 'Outfit',
        ),
        prefixIconColor: AppColors.textMuted,
      ),
    );
  }
}
