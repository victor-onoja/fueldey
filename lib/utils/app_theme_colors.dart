import 'package:flutter/material.dart';

class AppColors {
  // Primary color palette
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);

  // Accent colors
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color text = Color(0xFF333333);

  // Additional colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(AppColors.primary.value, {
        50: AppColors.primaryLight.withValues(alpha: 0.1),
        100: AppColors.primaryLight.withValues(alpha: 0.2),
        200: AppColors.primaryLight.withValues(alpha: 0.3),
        300: AppColors.primaryLight.withValues(alpha: 0.4),
        400: AppColors.primaryLight.withValues(alpha: 0.5),
        500: AppColors.primary,
        600: AppColors.primaryDark.withValues(alpha: 0.7),
        700: AppColors.primaryDark.withValues(alpha: 0.8),
        800: AppColors.primaryDark.withValues(alpha: 0.9),
        900: AppColors.primaryDark,
      }),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.text,
          fontSize: 16,
        ),
      ),
    );
  }
}
