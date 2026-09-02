import 'package:flutter/material.dart';

/// Paleta de colores centralizada del sistema IBI
class AppColors {
  AppColors._();

  // Colores primarios de marca (Light & Dark)
  static const Color primaryLight = Color(0xFF0284C7); // Sky-600
  static const Color primaryDark = Color(0xFF38BDF8); // Sky-400

  // Superficies y Fondos
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate-50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate-900

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800

  // Contenedores y Bordes
  static const Color bubbleLightReceiver = Color(0xFFE2E8F0); // Slate-200
  static const Color bubbleDarkReceiver = Color(0xFF1E293B); // Slate-800

  // Textos y Contraste
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF64748B);

  // Estados
  static const Color micActive = Color(0xFFEF4444); // Red-500
  static const Color actionTeal = Color(0xFF0D9488); // Teal-600
  static const Color actionBlue = Color(0xFF2563EB); // Blue-600
}
