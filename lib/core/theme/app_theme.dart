import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/brand.dart';
import 'app_spacing.dart';

/// Tema Material 3 derivado de design/DESIGN.md.
/// Regla: las pantallas usan `Theme.of(context)`; no hardcodear colores ni fuentes.
class AppTheme {
  const AppTheme._();

  static const Color _hairline = Color(0x73E8C8C4); // rgba(232,200,196,.45)

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Brand.primary,
      onPrimary: Brand.canvas,
      secondary: Brand.secondary,
      onSecondary: Brand.primary,
      tertiary: Brand.tertiary,
      onTertiary: Brand.foreground,
      error: Brand.error,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Brand.foreground,
      onSurfaceVariant: Brand.muted,
      outline: Brand.secondary,
      outlineVariant: _hairline,
      surfaceContainerHighest: Brand.inputFill,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final sans = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = sans
        .copyWith(
          displayLarge: GoogleFonts.bodoniModa(fontSize: 40, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: -0.8),
          headlineLarge: GoogleFonts.bodoniModa(fontSize: 30, height: 1.27, fontWeight: FontWeight.w600, letterSpacing: -0.3),
          headlineMedium: GoogleFonts.bodoniModa(fontSize: 22, height: 1.27, fontWeight: FontWeight.w500),
          headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 18, height: 1.33, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.37, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.5),
          bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.43),
          bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.5),
          labelLarge: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          labelSmall: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
        )
        .apply(bodyColor: Brand.foreground, displayColor: Brand.foreground);

    const pill = StadiumBorder();
    OutlineInputBorder border(Color? color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: color == null ? BorderSide.none : BorderSide(color: color),
        );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: Brand.canvas,
      dividerColor: Brand.secondary,
      appBarTheme: AppBarTheme(
        backgroundColor: Brand.canvas,
        foregroundColor: Brand.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: const BorderSide(color: _hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTap),
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTap),
          shape: pill,
          foregroundColor: Brand.foreground,
          side: const BorderSide(color: Brand.secondary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Brand.primary, shape: pill),
      ),
      chipTheme: ChipThemeData(
        shape: pill,
        backgroundColor: Colors.white,
        selectedColor: Brand.primary,
        side: const BorderSide(color: Brand.secondary),
        labelStyle: textTheme.labelLarge?.copyWith(color: Brand.muted),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Brand.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(null),
        enabledBorder: border(null),
        focusedBorder: border(Brand.primary),
        errorBorder: border(Brand.error),
        focusedErrorBorder: border(Brand.error),
        labelStyle: textTheme.bodyMedium?.copyWith(color: Brand.muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Brand.secondary,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
