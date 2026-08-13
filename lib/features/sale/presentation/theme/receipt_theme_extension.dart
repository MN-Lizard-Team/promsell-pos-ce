import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// On-screen receipt preview tokens (thermal / card). PDF sizes stay domain.
@immutable
class ReceiptThemeExtension extends ThemeExtension<ReceiptThemeExtension> {
  const ReceiptThemeExtension({
    required this.paperWidth58,
    required this.paperWidth80,
    required this.paperWidthA4,
    required this.paperWidthCard,
    required this.ink,
    required this.paper,
    required this.thermalRadius,
    required this.cutDash,
    required this.cutGap,
    required this.cutStroke,
  });

  final double paperWidth58;
  final double paperWidth80;
  final double paperWidthA4;
  final double paperWidthCard;
  final Color ink;
  final Color paper;
  final double thermalRadius;
  final double cutDash;
  final double cutGap;
  final double cutStroke;

  static const ReceiptThemeExtension light = ReceiptThemeExtension(
    paperWidth58: 200,
    paperWidth80: 280,
    paperWidthA4: 380,
    paperWidthCard: 320,
    ink: Color(0xFF111111),
    paper: Color(0xFFFFFFFF),
    thermalRadius: 4,
    cutDash: 4,
    cutGap: 3,
    cutStroke: 1,
  );

  static const ReceiptThemeExtension dark = ReceiptThemeExtension(
    paperWidth58: 200,
    paperWidth80: 280,
    paperWidthA4: 380,
    paperWidthCard: 320,
    ink: Color(0xFFE8E8E8),
    paper: Color(0xFF1A1A1A),
    thermalRadius: 4,
    cutDash: 4,
    cutGap: 3,
    cutStroke: 1,
  );

  double paperWidthForSize(String receiptSize) {
    return switch (receiptSize) {
      '58mm' => paperWidth58,
      'A4' => paperWidthA4,
      _ => paperWidth80,
    };
  }

  @override
  ReceiptThemeExtension copyWith({
    double? paperWidth58,
    double? paperWidth80,
    double? paperWidthA4,
    double? paperWidthCard,
    Color? ink,
    Color? paper,
    double? thermalRadius,
    double? cutDash,
    double? cutGap,
    double? cutStroke,
  }) {
    return ReceiptThemeExtension(
      paperWidth58: paperWidth58 ?? this.paperWidth58,
      paperWidth80: paperWidth80 ?? this.paperWidth80,
      paperWidthA4: paperWidthA4 ?? this.paperWidthA4,
      paperWidthCard: paperWidthCard ?? this.paperWidthCard,
      ink: ink ?? this.ink,
      paper: paper ?? this.paper,
      thermalRadius: thermalRadius ?? this.thermalRadius,
      cutDash: cutDash ?? this.cutDash,
      cutGap: cutGap ?? this.cutGap,
      cutStroke: cutStroke ?? this.cutStroke,
    );
  }

  @override
  ReceiptThemeExtension lerp(ReceiptThemeExtension? other, double t) {
    if (other is! ReceiptThemeExtension) return this;
    return ReceiptThemeExtension(
      paperWidth58: lerpDouble(paperWidth58, other.paperWidth58, t)!,
      paperWidth80: lerpDouble(paperWidth80, other.paperWidth80, t)!,
      paperWidthA4: lerpDouble(paperWidthA4, other.paperWidthA4, t)!,
      paperWidthCard: lerpDouble(paperWidthCard, other.paperWidthCard, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      thermalRadius: lerpDouble(thermalRadius, other.thermalRadius, t)!,
      cutDash: lerpDouble(cutDash, other.cutDash, t)!,
      cutGap: lerpDouble(cutGap, other.cutGap, t)!,
      cutStroke: lerpDouble(cutStroke, other.cutStroke, t)!,
    );
  }
}

extension ReceiptThemeContext on BuildContext {
  ReceiptThemeExtension get receiptTheme {
    return Theme.of(this).extension<ReceiptThemeExtension>() ??
        ReceiptThemeExtension.light;
  }
}
