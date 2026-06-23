import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'NotoSansThai';

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.25,
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      color: AppColors.textSecondary,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      height: 1.3,
    ),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      height: 1.25,
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextPrimary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      color: AppColors.darkTextPrimary,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      color: AppColors.darkTextPrimary,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      color: AppColors.darkTextSecondary,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextSecondary,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextSecondary,
      height: 1.3,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.accentContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      errorContainer: AppColors.errorContainer,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: AppColors.shadow,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      shape: Border(bottom: BorderSide(color: AppColors.primary, width: 1.5)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0.5,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider, width: 0.5),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.accentContainer,
      indicatorShape: StadiumBorder(),
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.surfaceWarm,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.accent,
      checkmarkColor: AppColors.textOnPrimary,
      backgroundColor: AppColors.surfaceWarm,
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      space: 1,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(
        color: AppColors.surface,
        fontFamily: _fontFamily,
        fontSize: 14,
      ),
      actionTextColor: AppColors.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.accentContainer,
      circularTrackColor: AppColors.accentContainer,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryContainer;
        }
        return AppColors.surfaceWarm;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryContainer;
        }
        return AppColors.border;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.border;
      }),
    ),
    extensions: const <ThemeExtension<dynamic>>[SettingsThemeExtension.light],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      error: AppColors.error,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      inverseSurface: AppColors.onInverseSurface,
      onInverseSurface: AppColors.inverseSurface,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkBorder,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _darkTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      shape: Border(
        bottom: BorderSide(color: AppColors.darkPrimaryContainer, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0.5,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.darkPrimaryContainer,
      indicatorShape: StadiumBorder(),
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimaryContainer,
        foregroundColor: AppColors.darkOnPrimaryContainer,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkOnPrimaryContainer,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.darkPrimaryContainer,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppColors.darkInputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.accent,
      checkmarkColor: AppColors.textOnPrimary,
      backgroundColor: AppColors.darkSurface,
      side: const BorderSide(color: AppColors.darkBorder),
      labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      space: 1,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkTextPrimary,
      contentTextStyle: const TextStyle(
        color: AppColors.darkBackground,
        fontFamily: _fontFamily,
        fontSize: 14,
      ),
      actionTextColor: AppColors.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkTextPrimary,
      unselectedLabelColor: AppColors.darkTextSecondary,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.accentContainer,
      circularTrackColor: AppColors.accentContainer,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkTextPrimary;
        }
        return AppColors.darkSurface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.darkSurfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.darkBorder;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.darkBorder;
      }),
    ),
    extensions: const <ThemeExtension<dynamic>>[SettingsThemeExtension.dark],
  );
}
