import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

void main() {
  group('SettingsThemeExtension', () {
    test('light aligns with global app surface tokens', () {
      expect(
        SettingsThemeExtension.light.cardBackground,
        AppColors.cardBackground,
      );
      expect(SettingsThemeExtension.light.cardBorderColor, AppColors.divider);
      expect(
        SettingsThemeExtension.light.softAccentContainer,
        AppColors.primaryContainer,
      );
      // POS-native density: cards match cartItemRadius/billStubRadius.
      expect(SettingsThemeExtension.light.cardRadius, 12);
      expect(SettingsThemeExtension.light.dividerIndent, 68);
      expect(SettingsThemeExtension.light.tileMinHeight, 64);
      expect(SettingsThemeExtension.light.iconSize, 40);
      expect(SettingsThemeExtension.light.sectionGap, 16);
    });

    test('light hero gradient uses deep teal stack', () {
      expect(SettingsThemeExtension.light.heroGradientStart, AppColors.primary);
      expect(
        SettingsThemeExtension.light.heroGradientEnd,
        AppColors.primaryDark,
      );
      expect(
        SettingsThemeExtension.light.heroTextPrimary.toARGB32(),
        0xFFFFFFFF,
      );
    });

    test('light action card geometry', () {
      expect(SettingsThemeExtension.light.accentStripeWidth, 4);
      // Badges are pills (StockBadge / filter-chip language).
      expect(SettingsThemeExtension.light.statusBadgeRadius, 20);
      expect(SettingsThemeExtension.light.pillRadius, 20);
      expect(SettingsThemeExtension.light.actionCardMinHeight, 64);
      expect(SettingsThemeExtension.light.actionCardRadius, 12);
    });

    test('dark uses AppColors surface stack', () {
      expect(SettingsThemeExtension.dark.cardRadius, 12);
      expect(SettingsThemeExtension.dark.dividerIndent, 68);
      expect(SettingsThemeExtension.dark.cardBackground, AppColors.darkCard);
      expect(
        SettingsThemeExtension.dark.cardBorderColor,
        AppColors.darkOutline,
      );
      expect(SettingsThemeExtension.dark.sectionGap, 16);
      expect(SettingsThemeExtension.dark.tileMinHeight, 64);
      expect(SettingsThemeExtension.dark.iconSize, 40);
    });

    test('dark hero gradient uses dark teal stack', () {
      expect(
        SettingsThemeExtension.dark.heroGradientStart,
        const Color(0xFF094551),
      );
      expect(
        SettingsThemeExtension.dark.heroTextPrimary,
        AppColors.darkTextPrimary,
      );
    });

    test('status text colors align with AppColors WCAG-safe tokens', () {
      expect(
        SettingsThemeExtension.light.statusWarningText,
        AppColors.statusWarningText,
      );
      expect(
        SettingsThemeExtension.light.statusErrorText,
        AppColors.statusErrorText,
      );
      expect(
        SettingsThemeExtension.light.statusSuccessText,
        AppColors.statusSuccessText,
      );
      expect(
        SettingsThemeExtension.dark.statusWarningText,
        AppColors.darkStatusWarningText,
      );
      expect(
        SettingsThemeExtension.dark.statusErrorText,
        AppColors.darkStatusErrorText,
      );
      expect(
        SettingsThemeExtension.dark.statusSuccessText,
        AppColors.darkStatusSuccessText,
      );
    });

    test('badge micro-geometry tokens are shared and uniform', () {
      expect(SettingsThemeExtension.light.badgeDotSize, 8);
      expect(SettingsThemeExtension.dark.badgeDotSize, 8);
      expect(SettingsThemeExtension.light.badgeBorderAlpha, 0.30);
      expect(SettingsThemeExtension.dark.badgeBorderAlpha, 0.30);
      expect(SettingsThemeExtension.light.heroProgressHeight, 8);
      expect(SettingsThemeExtension.dark.heroProgressHeight, 8);
    });

    test('copyWith updates fields', () {
      final updated = SettingsThemeExtension.light.copyWith(
        cardRadius: 24,
        iconSize: 56,
        heroGradientStart: const Color(0xFF000000),
        accentStripeWidth: 6,
      );
      expect(updated.cardRadius, 24);
      expect(updated.iconSize, 56);
      expect(updated.heroGradientStart, const Color(0xFF000000));
      expect(updated.accentStripeWidth, 6);
      expect(
        updated.cardBackground,
        SettingsThemeExtension.light.cardBackground,
      );
    });

    test('lerp interpolates between light and dark at t=0', () {
      final result = SettingsThemeExtension.light.lerp(
        SettingsThemeExtension.dark,
        0.0,
      );
      expect(
        result.cardBackground,
        SettingsThemeExtension.light.cardBackground,
      );
      expect(
        result.heroGradientStart,
        SettingsThemeExtension.light.heroGradientStart,
      );
    });

    test('lerp interpolates between light and dark at t=1', () {
      final result = SettingsThemeExtension.light.lerp(
        SettingsThemeExtension.dark,
        1.0,
      );
      expect(result.cardBackground, SettingsThemeExtension.dark.cardBackground);
      expect(
        result.heroGradientStart,
        SettingsThemeExtension.dark.heroGradientStart,
      );
    });

    test('lerp returns self when other is not SettingsThemeExtension', () {
      final result = SettingsThemeExtension.light.lerp(null, 0.5);
      expect(result, same(SettingsThemeExtension.light));
    });
  });
}
