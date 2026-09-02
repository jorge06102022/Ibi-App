import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Configuración de Temas Material 3 para IBI
class AppTheme {
  AppTheme._();

  /// Tema Claro
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.primaryLight,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      surface: AppColors.backgroundLight,
      onSurface: AppColors.textPrimaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }

  /// Tema Oscuro
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.primaryDark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryDark,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.backgroundDark,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }
}
