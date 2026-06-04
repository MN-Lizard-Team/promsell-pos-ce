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
    cardBackground: Color(0xFFF8F7F2),
    cardBorderColor: Color(0xFFE0E0E0),
    softAccent: Color(0xFF5C8D6B),
    softAccentContainer: Color(0xFFE8F0EA),
    softTextPrimary: Color(0xFF212121),
    softTextSecondary: Color(0xFF616161),
    danger: Color(0xFFC75B5B),
    success: Color(0xFF5C8D6B),
    mutedText: Color(0xFF757575),
    iconContainerBackground: Color(0xFFE8F0EA),
    dividerIndent: 16,
    cardRadius: 20,
    sectionGap: 32,
    tileMinHeight: 64,
    iconSize: 48,
    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static const SettingsThemeExtension dark = SettingsThemeExtension(
    cardBackground: Color(0xFF1A221A),
    cardBorderColor: Color(0xFF2A3A2E),
    softAccent: Color(0xFF8FBC8F),
    softAccentContainer: Color(0xFF1B3A24),
    softTextPrimary: Color(0xFFE8E8E8),
    softTextSecondary: Color(0xFFB0B0B0),
    danger: Color(0xFFE57373),
    success: Color(0xFF8FBC8F),
    mutedText: Color(0xFF9E9E9E),
    iconContainerBackground: Color(0xFF1B3A24),
    dividerIndent: 16,
    cardRadius: 20,
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
