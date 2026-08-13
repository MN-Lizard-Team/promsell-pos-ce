import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Report-specific visual tokens.
///
/// Kept local to the Report feature while it becomes the reference for the
/// next design-system pass. Settings and Sale can adopt these tokens later
/// without coupling this feature to their extensions.
@immutable
class ReportThemeExtension extends ThemeExtension<ReportThemeExtension> {
  const ReportThemeExtension({
    required this.cardRadius,
    required this.controlRadius,
    required this.sectionPadding,
    required this.controlHeight,
    required this.iconSize,
    required this.heroIconSize,
    required this.sectionGap,
    required this.heroSurface,
    required this.cardShadow,
    required this.heroShadow,
    required this.barShadow,
  });

  final double cardRadius;
  final EdgeInsets sectionPadding;
  final double controlRadius;
  final double controlHeight;
  final double iconSize;
  final double heroIconSize;
  final double sectionGap;
  final Color heroSurface;

  /// Soft elevation for cards (preset list, calendar card).
  final List<BoxShadow> cardShadow;

  /// Stronger elevation for the hero range summary panel.
  final List<BoxShadow> heroShadow;

  /// Subtle elevation for sticky bottom action bars.
  final List<BoxShadow> barShadow;

  static const light = ReportThemeExtension(
    cardRadius: 16,
    controlRadius: 12,
    sectionPadding: EdgeInsets.fromLTRB(16, 14, 16, 14),
    controlHeight: 52,
    iconSize: 20,
    heroIconSize: 24,
    sectionGap: 16,
    heroSurface: Color(0xFFD0ECEF),
    cardShadow: [
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 3)),
    ],
    heroShadow: [
      BoxShadow(color: Color(0x24000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
    barShadow: [
      BoxShadow(
        color: Color(0x10000000),
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  );

  static const dark = ReportThemeExtension(
    cardRadius: 16,
    controlRadius: 12,
    sectionPadding: EdgeInsets.fromLTRB(16, 14, 16, 14),
    controlHeight: 52,
    iconSize: 20,
    heroIconSize: 24,
    sectionGap: 16,
    heroSurface: Color(0xFF0A4A52),
    cardShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 3)),
    ],
    heroShadow: [
      BoxShadow(color: Color(0x44000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
    barShadow: [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  );

  @override
  ReportThemeExtension copyWith({
    double? cardRadius,
    double? controlRadius,
    EdgeInsets? sectionPadding,
    double? controlHeight,
    double? iconSize,
    double? heroIconSize,
    double? sectionGap,
    Color? heroSurface,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? heroShadow,
    List<BoxShadow>? barShadow,
  }) {
    return ReportThemeExtension(
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      sectionPadding: sectionPadding ?? this.sectionPadding,
      controlHeight: controlHeight ?? this.controlHeight,
      iconSize: iconSize ?? this.iconSize,
      heroIconSize: heroIconSize ?? this.heroIconSize,
      sectionGap: sectionGap ?? this.sectionGap,
      heroSurface: heroSurface ?? this.heroSurface,
      cardShadow: cardShadow ?? this.cardShadow,
      heroShadow: heroShadow ?? this.heroShadow,
      barShadow: barShadow ?? this.barShadow,
    );
  }

  @override
  ReportThemeExtension lerp(ReportThemeExtension? other, double t) {
    if (other == null) return this;
    return ReportThemeExtension(
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      controlRadius: lerpDouble(controlRadius, other.controlRadius, t)!,
      sectionPadding: EdgeInsets.lerp(sectionPadding, other.sectionPadding, t)!,
      controlHeight: lerpDouble(controlHeight, other.controlHeight, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      heroIconSize: lerpDouble(heroIconSize, other.heroIconSize, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
      heroSurface: Color.lerp(heroSurface, other.heroSurface, t)!,
      cardShadow: cardShadow,
      heroShadow: heroShadow,
      barShadow: barShadow,
    );
  }
}
