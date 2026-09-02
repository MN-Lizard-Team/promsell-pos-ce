import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

@immutable
class SettingsThemeExtension extends ThemeExtension<SettingsThemeExtension> {
  const SettingsThemeExtension({
    required this.cardBackground,
    required this.cardBorderColor,
    required this.softAccent,
    required this.softAccentContainer,
    required this.softTextPrimary,
    required this.softTextSecondary,
    required this.danger,
    required this.success,
    required this.mutedText,
    required this.iconContainerBackground,
    required this.activeAccent,
    required this.activeAccentContainer,
    required this.neutralAccent,
    required this.neutralAccentContainer,
    required this.dividerIndent,
    required this.cardRadius,
    required this.sectionGap,
    required this.tileMinHeight,
    required this.iconSize,
    required this.tilePadding,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.heroTextPrimary,
    required this.heroTextSecondary,
    required this.statusWarningText,
    required this.statusErrorText,
    required this.statusSuccessText,
    required this.accentStripeWidth,
    required this.statusBadgeRadius,
    required this.pillRadius,
    required this.actionCardMinHeight,
    required this.actionCardRadius,
    required this.badgeDotSize,
    required this.badgeBorderAlpha,
    required this.heroProgressHeight,
  });

  final Color cardBackground;
  final Color cardBorderColor;
  final Color softAccent;
  final Color softAccentContainer;
  final Color softTextPrimary;
  final Color softTextSecondary;
  final Color danger;
  final Color success;
  final Color mutedText;
  final Color iconContainerBackground;
  final Color activeAccent;
  final Color activeAccentContainer;
  final Color neutralAccent;
  final Color neutralAccentContainer;
  final double dividerIndent;
  final double cardRadius;
  final double sectionGap;
  final double tileMinHeight;
  final double iconSize;
  final EdgeInsets tilePadding;

  /// Hero card gradient (deep teal) for root overview.
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color heroTextPrimary;
  final Color heroTextSecondary;

  /// Text-safe status colors for chips/badges on tinted backgrounds.
  /// Raw [AppColors.error]/[warning] fail WCAG AA on light tints, so text
  /// must use these darker/lighter variants instead.
  final Color statusWarningText;
  final Color statusErrorText;
  final Color statusSuccessText;

  /// Left accent stripe on action cards / section cards.
  final double accentStripeWidth;

  /// Status badge corner radius (root action cards).
  final double statusBadgeRadius;

  /// Colored pill header radius (category section headers).
  final double pillRadius;

  /// Root action card geometry.
  final double actionCardMinHeight;
  final double actionCardRadius;

  /// Shared badge/chip micro-geometry (dots inside pills and status chips).
  final double badgeDotSize;

  /// Shared border alpha for pills and status chips so both read as one
  /// family instead of two different tints.
  final double badgeBorderAlpha;

  /// Readiness progress bar height on the hero card.
  final double heroProgressHeight;

  static const SettingsThemeExtension light = SettingsThemeExtension(
    cardBackground: AppColors.cardBackground,
    cardBorderColor: AppColors.divider,
    softAccent: AppColors.primary,
    softAccentContainer: AppColors.primaryContainer,
    activeAccent: AppColors.accent,
    activeAccentContainer: AppColors.accentContainer,
    neutralAccent: AppColors.neutralAccent,
    neutralAccentContainer: AppColors.neutralAccentContainer,
    softTextPrimary: AppColors.textPrimary,
    softTextSecondary: AppColors.textSecondary,
    danger: AppColors.error,
    success: AppColors.success,
    mutedText: AppColors.textSecondary,
    iconContainerBackground: AppColors.primaryContainer,
    // Divider starts after icon well (40) + gap (12) + left pad (16) ≈ 68
    dividerIndent: 68,
    // POS-native density: cards match cartItemRadius/billStubRadius (12),
    // rows match billRowMinHeight (64-68), badges are pills like StockBadge.
    cardRadius: 12,
    sectionGap: 16,
    tileMinHeight: 64,
    iconSize: 40,
    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    heroGradientStart: AppColors.primary,
    heroGradientEnd: AppColors.primaryDark,
    heroTextPrimary: AppColors.textOnPrimary,
    heroTextSecondary: AppColors.primaryContainer,
    statusWarningText: AppColors.statusWarningText,
    statusErrorText: AppColors.statusErrorText,
    statusSuccessText: AppColors.statusSuccessText,
    accentStripeWidth: 4,
    statusBadgeRadius: 20,
    pillRadius: 20,
    actionCardMinHeight: 64,
    actionCardRadius: 12,
    badgeDotSize: 8,
    badgeBorderAlpha: 0.30,
    heroProgressHeight: 8,
  );

  /// Surfaces align with [AppColors] dark stack (not GitHub palette).
  static const SettingsThemeExtension dark = SettingsThemeExtension(
    cardBackground: AppColors.darkCard,
    cardBorderColor: AppColors.darkOutline,
    softAccent: AppColors.darkPrimaryContainer,
    softAccentContainer: AppColors.darkCartBackground,
    activeAccent: AppColors.accent,
    activeAccentContainer: AppColors.darkAccentContainer,
    neutralAccent: AppColors.darkNeutralAccent,
    neutralAccentContainer: AppColors.darkNeutralAccentContainer,
    softTextPrimary: AppColors.darkTextPrimary,
    softTextSecondary: AppColors.darkTextSecondary,
    danger: AppColors.darkErrorText,
    success: AppColors.darkSuccess,
    mutedText: AppColors.darkTextSecondary,
    iconContainerBackground: AppColors.darkCartBackground,
    dividerIndent: 68,
    cardRadius: 12,
    sectionGap: 16,
    tileMinHeight: 64,
    iconSize: 40,
    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    heroGradientStart: AppColors.primaryDark,
    heroGradientEnd: AppColors.primaryDeepDark,
    heroTextPrimary: AppColors.darkTextPrimary,
    heroTextSecondary: AppColors.darkOnPrimaryContainer,
    statusWarningText: AppColors.darkStatusWarningText,
    statusErrorText: AppColors.darkStatusErrorText,
    statusSuccessText: AppColors.darkStatusSuccessText,
    accentStripeWidth: 4,
    statusBadgeRadius: 20,
    pillRadius: 20,
    actionCardMinHeight: 64,
    actionCardRadius: 12,
    badgeDotSize: 8,
    badgeBorderAlpha: 0.30,
    heroProgressHeight: 8,
  );

  @override
  SettingsThemeExtension copyWith({
    Color? cardBackground,
    Color? cardBorderColor,
    Color? softAccent,
    Color? softAccentContainer,
    Color? softTextPrimary,
    Color? softTextSecondary,
    Color? danger,
    Color? success,
    Color? mutedText,
    Color? iconContainerBackground,
    Color? activeAccent,
    Color? activeAccentContainer,
    Color? neutralAccent,
    Color? neutralAccentContainer,
    double? dividerIndent,
    double? cardRadius,
    double? sectionGap,
    double? tileMinHeight,
    double? iconSize,
    EdgeInsets? tilePadding,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? heroTextPrimary,
    Color? heroTextSecondary,
    Color? statusWarningText,
    Color? statusErrorText,
    Color? statusSuccessText,
    double? accentStripeWidth,
    double? statusBadgeRadius,
    double? pillRadius,
    double? actionCardMinHeight,
    double? actionCardRadius,
    double? badgeDotSize,
    double? badgeBorderAlpha,
    double? heroProgressHeight,
  }) {
    return SettingsThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      softAccent: softAccent ?? this.softAccent,
      softAccentContainer: softAccentContainer ?? this.softAccentContainer,
      softTextPrimary: softTextPrimary ?? this.softTextPrimary,
      softTextSecondary: softTextSecondary ?? this.softTextSecondary,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      mutedText: mutedText ?? this.mutedText,
      iconContainerBackground:
          iconContainerBackground ?? this.iconContainerBackground,
      activeAccent: activeAccent ?? this.activeAccent,
      activeAccentContainer:
          activeAccentContainer ?? this.activeAccentContainer,
      neutralAccent: neutralAccent ?? this.neutralAccent,
      neutralAccentContainer:
          neutralAccentContainer ?? this.neutralAccentContainer,
      dividerIndent: dividerIndent ?? this.dividerIndent,
      cardRadius: cardRadius ?? this.cardRadius,
      sectionGap: sectionGap ?? this.sectionGap,
      tileMinHeight: tileMinHeight ?? this.tileMinHeight,
      iconSize: iconSize ?? this.iconSize,
      tilePadding: tilePadding ?? this.tilePadding,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      heroTextPrimary: heroTextPrimary ?? this.heroTextPrimary,
      heroTextSecondary: heroTextSecondary ?? this.heroTextSecondary,
      statusWarningText: statusWarningText ?? this.statusWarningText,
      statusErrorText: statusErrorText ?? this.statusErrorText,
      statusSuccessText: statusSuccessText ?? this.statusSuccessText,
      accentStripeWidth: accentStripeWidth ?? this.accentStripeWidth,
      statusBadgeRadius: statusBadgeRadius ?? this.statusBadgeRadius,
      pillRadius: pillRadius ?? this.pillRadius,
      actionCardMinHeight: actionCardMinHeight ?? this.actionCardMinHeight,
      actionCardRadius: actionCardRadius ?? this.actionCardRadius,
      badgeDotSize: badgeDotSize ?? this.badgeDotSize,
      badgeBorderAlpha: badgeBorderAlpha ?? this.badgeBorderAlpha,
      heroProgressHeight: heroProgressHeight ?? this.heroProgressHeight,
    );
  }

  @override
  SettingsThemeExtension lerp(SettingsThemeExtension? other, double t) {
    if (other is! SettingsThemeExtension) return this;
    return SettingsThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      softAccent: Color.lerp(softAccent, other.softAccent, t)!,
      softAccentContainer: Color.lerp(
        softAccentContainer,
        other.softAccentContainer,
        t,
      )!,
      softTextPrimary: Color.lerp(softTextPrimary, other.softTextPrimary, t)!,
      softTextSecondary: Color.lerp(
        softTextSecondary,
        other.softTextSecondary,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      iconContainerBackground: Color.lerp(
        iconContainerBackground,
        other.iconContainerBackground,
        t,
      )!,
      activeAccent: Color.lerp(activeAccent, other.activeAccent, t)!,
      activeAccentContainer: Color.lerp(
        activeAccentContainer,
        other.activeAccentContainer,
        t,
      )!,
      neutralAccent: Color.lerp(neutralAccent, other.neutralAccent, t)!,
      neutralAccentContainer: Color.lerp(
        neutralAccentContainer,
        other.neutralAccentContainer,
        t,
      )!,
      dividerIndent: lerpDouble(dividerIndent, other.dividerIndent, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
      tileMinHeight: lerpDouble(tileMinHeight, other.tileMinHeight, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      tilePadding: EdgeInsets.lerp(tilePadding, other.tilePadding, t)!,
      heroGradientStart: Color.lerp(
        heroGradientStart,
        other.heroGradientStart,
        t,
      )!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      heroTextPrimary: Color.lerp(heroTextPrimary, other.heroTextPrimary, t)!,
      heroTextSecondary: Color.lerp(
        heroTextSecondary,
        other.heroTextSecondary,
        t,
      )!,
      statusWarningText: Color.lerp(
        statusWarningText,
        other.statusWarningText,
        t,
      )!,
      statusErrorText: Color.lerp(statusErrorText, other.statusErrorText, t)!,
      statusSuccessText: Color.lerp(
        statusSuccessText,
        other.statusSuccessText,
        t,
      )!,
      accentStripeWidth: lerpDouble(
        accentStripeWidth,
        other.accentStripeWidth,
        t,
      )!,
      statusBadgeRadius: lerpDouble(
        statusBadgeRadius,
        other.statusBadgeRadius,
        t,
      )!,
      pillRadius: lerpDouble(pillRadius, other.pillRadius, t)!,
      actionCardMinHeight: lerpDouble(
        actionCardMinHeight,
        other.actionCardMinHeight,
        t,
      )!,
      actionCardRadius: lerpDouble(
        actionCardRadius,
        other.actionCardRadius,
        t,
      )!,
      badgeDotSize: lerpDouble(badgeDotSize, other.badgeDotSize, t)!,
      badgeBorderAlpha: lerpDouble(
        badgeBorderAlpha,
        other.badgeBorderAlpha,
        t,
      )!,
      heroProgressHeight: lerpDouble(
        heroProgressHeight,
        other.heroProgressHeight,
        t,
      )!,
    );
  }
}

extension SettingsThemeContext on BuildContext {
  SettingsThemeExtension get settingsTheme {
    return Theme.of(this).extension<SettingsThemeExtension>() ??
        SettingsThemeExtension.light;
  }
}
