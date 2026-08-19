import 'package:flutter/material.dart';

/// Colores de la aplicación Evora.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1a2332);
  static const Color primaryLight = Color(0xFF2d3748);
  static const Color accent = Color(0xFF3182ce);
  static const Color accentLight = Color(0xFFebf8ff);

  static const Color success = Color(0xFF38a169);
  static const Color successLight = Color(0xFFf0fff4);
  static const Color warning = Color(0xFFdd6b20);
  static const Color warningLight = Color(0xFFfefcbf);
  static const Color error = Color(0xFFe53e3e);
  static const Color errorLight = Color(0xFFfed7d7);

  static const Color background = Color(0xFFf7fafc);
  static const Color surface = Color(0xFFffffff);
  static const Color border = Color(0xFFe2e8f0);
  static const Color borderLight = Color(0xFFedf2f7);

  static const Color textPrimary = Color(0xFF1a2332);
  static const Color textSecondary = Color(0xFF4a5568);
  static const Color textMuted = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFa0aec0);
  static const Color textPlaceholder = Color(0xFFcbd5e0);

  static const Color postIt = Color(0xFFfffff0);
  static const Color postItBorder = Color(0xFFfefcbf);
  static const Color postItText = Color(0xFF744210);
}

/// Espaciado.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Border radius.
class AppRadius {
  AppRadius._();
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
}

/// Tamaño mínimo de elementos táctiles (accesibilidad).
const double kMinTouchSize = 44;

/// Tema global de la aplicación.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textDisabled,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.accent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
