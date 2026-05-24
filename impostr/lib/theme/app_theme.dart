import 'package:flutter/material.dart';

import 'app_text_styles.dart';

class AppColors {
  static const Color bgPrimary = Color(0xFF060810);
  static const Color bgSurface = Color(0xFF111827);
  static const Color bgInput = Color(0xFF172033);

  static const Color detectiveBlue = Color(0xFF60A5FA);
  static const Color suspectRed = Color(0xFFEF4444);
  static const Color darkRed = Color(0xFF7F1D1D);
  static const Color navy = Color(0xFF09111F);
  static const Color overlay = Color(0xCC05070B);

  static const Color accentPurple = detectiveBlue;
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = suspectRed;
  static const Color accentAmber = Color(0xFFF59E0B);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFB6C2D0);

  // Subtle border helper
  static const BorderSide borderSide = BorderSide(color: Color(0xFF243144), width: 0.5);
  static const BorderSide borderSideActive = BorderSide(color: detectiveBlue, width: 1.5);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      primaryColor: AppColors.detectiveBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.detectiveBlue,
        secondary: AppColors.suspectRed,
        surface: AppColors.bgSurface,
        error: AppColors.suspectRed,
      ),
      textTheme: AppTextStyles.darkTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: AppColors.borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: AppColors.borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentPurple, width: 1.5),
        ),
        hintStyle: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    );
  }
}
