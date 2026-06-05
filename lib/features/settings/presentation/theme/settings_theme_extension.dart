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
  final double dividerIndent;
  final double cardRadius;
  final double sectionGap;
  final double tileMinHeight;
  final double iconSize;
  final EdgeInsets tilePadding;

  static const SettingsThemeExtension light = SettingsThemeExtension(
    cardBackground: Color(0xFFFFFFFF),
    cardBorderColor: Color(0xFFE0E0E0),
    softAccent: Color(0xFF00C853),
    softAccentContainer: Color(0xFFE6F9ED),
    softTextPrimary: Color(0xFF212121),
    softTextSecondary: Color(0xFF757575),
    danger: Color(0xFFC75B5B),
    success: Color(0xFF00C853),
    mutedText: Color(0xFF757575),
    iconContainerBackground: Color(0xFFE6F9ED),
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
    softAccent: Color(0xFF00E676),
    softAccentContainer: Color(0xFF00C853),
    softTextPrimary: Color(0xFFF0F6FC),
    softTextSecondary: Color(0xFF8B949E),
    danger: Color(0xFFE57373),
    success: Color(0xFF00E676),
    mutedText: Color(0xFF8B949E),
    iconContainerBackground: Color(0xFF0D2B1A),
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
