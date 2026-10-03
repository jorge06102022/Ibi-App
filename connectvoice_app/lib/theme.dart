import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

/// Nuevo Tema: Negro y Azul Neón
class AppColors {
  static const bg0 = Color(0xFF03030A); // Deepest void
  static const bg1 = Color(0xFF080816); // Surface 1
  static const bg2 = Color(0xFF0D0D22); // Surface 2
  static const bg3 = Color(0xFF131330); // Elevated
  static const bg4 = Color(0xFF191940);
  static const bg5 = Color(0xFF202050);

  // God-tier Neon Palette
  static const accent = Color(0xFF00F0FF); // Cyber Blue
  static const accent2 = Color(0xFF7000FF); // Deep Purple
  static const accent3 = Color(0xFF00FF88); // Mint Neon
  static const accent4 = Color(0xFFFF007F); // Neon Pink
  
  static const danger = Color(0xFFFF2A55); 
  static const warn = Color(0xFFFFC000); 

  static const tx1 = Color(0xFFFFFFFF);
  static const tx2 = Color(0xFF8B93A5);
  static const tx3 = Color(0xFF5A6175);

  static const border = Color(0x2200F0FF); 
  static const borderLight = Color(0x44FFFFFF);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  static const holographicGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [accent, accent4],
  );
}

class AppRadius {
  static const r1 = 6.0;
  static const r2 = 12.0;
  static const r3 = 18.0;
  static const r4 = 24.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
    bodyColor: AppColors.tx1,
    displayColor: AppColors.tx1,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg0,
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.bg1,
      error: AppColors.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg0,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: AppColors.tx1,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.tx2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg2,
      hintStyle: const TextStyle(color: AppColors.tx3),
      labelStyle: const TextStyle(color: AppColors.tx2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r3),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r3),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r3),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bg1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r3), side: const BorderSide(color: AppColors.border)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r4)),
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: AppColors.accent,
      thumbColor: AppColors.accent,
      inactiveTrackColor: AppColors.bg4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.accent : AppColors.tx3,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent.withOpacity(0.4)
            : AppColors.bg4,
      ),
    ),
    dividerColor: AppColors.border,
  );
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const GradientButton({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.brandGradient,
        color: onPressed == null ? AppColors.bg3 : null,
        borderRadius: BorderRadius.circular(AppRadius.r3),
        boxShadow: onPressed == null ? null : [
          BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 4)),
          BoxShadow(color: AppColors.accent2.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.r3),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.r3),
          onTap: onPressed,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  label, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1.2,
                    fontSize: 15,
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Glassmorphism Utility ──
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = AppRadius.r3,
    this.padding = const EdgeInsets.all(16),
    this.blur = 20.0,
    this.opacity = 0.05,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}