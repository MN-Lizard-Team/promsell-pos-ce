import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme => GoogleFonts.notoSansThaiTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansThai(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.notoSansThai(fontSize: 28, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.notoSansThai(fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.notoSansThai(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.notoSansThai(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.notoSansThai(fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.notoSansThai(fontSize: 16),
        bodyMedium: GoogleFonts.notoSansThai(fontSize: 14),
        bodySmall: GoogleFonts.notoSansThai(fontSize: 12),
        labelLarge: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w600),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.divider, space: 1),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dividerTheme: const DividerThemeData(space: 1),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
