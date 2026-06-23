import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

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
    required this.dividerIndent,
    required this.cardRadius,
    required this.sectionGap,
    required this.tileMinHeight,
    required this.iconSize,
    required this.tilePadding,
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
  final double dividerIndent;
  final double cardRadius;
  final double sectionGap;
  final double tileMinHeight;
  final double iconSize;
  final EdgeInsets tilePadding;

  static const SettingsThemeExtension light = SettingsThemeExtension(
    cardBackground: Color(0xFFFFFFFF),
    cardBorderColor: Color(0xFFE2E8F0),
    softAccent: Color(0xFF0E7C8A),
    softAccentContainer: Color(0xFFB8E6EC),
    activeAccent: Color(0xFFFF6B00),
    activeAccentContainer: Color(0xFFFFE0CC),
    softTextPrimary: Color(0xFF0F172A),
    softTextSecondary: Color(0xFF64748B),
    danger: Color(0xFFDC2626),
    success: Color(0xFF22C55E),
    mutedText: Color(0xFF64748B),
    iconContainerBackground: Color(0xFFB8E6EC),
    dividerIndent: 16,
    cardRadius: 16,
    sectionGap: 32,
    tileMinHeight: 64,
    iconSize: 48,
    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static const SettingsThemeExtension dark = SettingsThemeExtension(
    cardBackground: Color(0xFF161B22),
    cardBorderColor: Color(0xFF30363D),
    softAccent: Color(0xFF0E7C8A),
    softAccentContainer: Color(0xFF0A4A52),
    activeAccent: Color(0xFFFF6B00),
    activeAccentContainer: Color(0xFF4A2A00),
    softTextPrimary: Color(0xFFF0F6FC),
    softTextSecondary: Color(0xFF8B949E),
    danger: Color(0xFFEF4444),
    success: Color(0xFF22C55E),
    mutedText: Color(0xFF8B949E),
    iconContainerBackground: Color(0xFF0A4A52),
    dividerIndent: 16,
    cardRadius: 16,
    sectionGap: 32,
    tileMinHeight: 64,
    iconSize: 48,
    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    double? dividerIndent,
    double? cardRadius,
    double? sectionGap,
    double? tileMinHeight,
    double? iconSize,
    EdgeInsets? tilePadding,
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
      dividerIndent: dividerIndent ?? this.dividerIndent,
      cardRadius: cardRadius ?? this.cardRadius,
      sectionGap: sectionGap ?? this.sectionGap,
      tileMinHeight: tileMinHeight ?? this.tileMinHeight,
      iconSize: iconSize ?? this.iconSize,
      tilePadding: tilePadding ?? this.tilePadding,
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
      dividerIndent: lerpDouble(dividerIndent, other.dividerIndent, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
      tileMinHeight: lerpDouble(tileMinHeight, other.tileMinHeight, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      tilePadding: EdgeInsets.lerp(tilePadding, other.tilePadding, t)!,
    );
  }
}

extension SettingsThemeContext on BuildContext {
  SettingsThemeExtension get settingsTheme {
    return Theme.of(this).extension<SettingsThemeExtension>() ??
        SettingsThemeExtension.light;
  }
}
