import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta calcada de static/chat/css/main.css (tema oscuro de la web),
/// para que la app nativa se vea consistente con tu marca.
class AppColors {
  static const bg0 = Color(0xFF0A0A14);
  static const bg1 = Color(0xFF0F0F1E);
  static const bg2 = Color(0xFF14142A);
  static const bg3 = Color(0xFF1A1A38);
  static const bg4 = Color(0xFF22224A);
  static const bg5 = Color(0xFF2A2A58);

  static const accent = Color(0xFF00D4FF);
  static const accent2 = Color(0xFF7C3AED);
  static const accent3 = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warn = Color(0xFFF59E0B);

  static const tx1 = Color(0xFFF0F0FF);
  static const tx2 = Color(0xFF9090BB);
  static const tx3 = Color(0xFF55557A);

  static const border = Color(0x12FFFFFF);
  static const border2 = Color(0x1EFFFFFF);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
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
      backgroundColor: AppColors.bg1,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r3)),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.r3),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r3),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed == null ? null : AppColors.brandGradient,
            color: onPressed == null ? AppColors.bg4 : null,
            borderRadius: BorderRadius.circular(AppRadius.r3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}