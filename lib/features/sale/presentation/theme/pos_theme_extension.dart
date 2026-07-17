import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// POS / Sale surface tokens — mirrors [SettingsThemeExtension] pattern.
@immutable
class PosThemeExtension extends ThemeExtension<PosThemeExtension> {
  const PosThemeExtension({
    required this.catalogBackground,
    required this.cartPanelBackground,
    required this.cartStripBackground,
    required this.ctaFill,
    required this.ctaOnFill,
    required this.qtyBadgeBackground,
    required this.qtyBadgeForeground,
    required this.selectedProductBorder,
    required this.productCardRadius,
    required this.cartItemRadius,
    required this.sheetTopRadius,
    required this.stickyBarRadius,
    required this.appBarBottomRadius,
    required this.ctaMinHeight,
    required this.catalogPadding,
    required this.dockedCartWidth,
    required this.tabletSplitBreakpoint,
  });

  final Color catalogBackground;
  final Color cartPanelBackground;
  final Color cartStripBackground;
  final Color ctaFill;
  final Color ctaOnFill;
  final Color qtyBadgeBackground;
  final Color qtyBadgeForeground;
  final Color selectedProductBorder;
  final double productCardRadius;
  final double cartItemRadius;
  final double sheetTopRadius;
  final double stickyBarRadius;
  final double appBarBottomRadius;
  final double ctaMinHeight;
  final EdgeInsets catalogPadding;
  final double dockedCartWidth;
  final double tabletSplitBreakpoint;

  static const PosThemeExtension light = PosThemeExtension(
    catalogBackground: Color(0xFFE2E8F0),
    cartPanelBackground: Color(0xFFFFFFFF),
    cartStripBackground: Color(0xFFD0ECEF),
    ctaFill: Color(0xFFFF6B00),
    ctaOnFill: Color(0xFFFFFFFF),
    qtyBadgeBackground: Color(0xFFD0ECEF),
    qtyBadgeForeground: Color(0xFF0D5D6B),
    selectedProductBorder: Color(0xFF0D5D6B),
    productCardRadius: 16,
    cartItemRadius: 12,
    sheetTopRadius: 24,
    stickyBarRadius: 20,
    appBarBottomRadius: 24,
    ctaMinHeight: 52,
    catalogPadding: EdgeInsets.fromLTRB(12, 0, 12, 8),
    dockedCartWidth: 380,
    tabletSplitBreakpoint: 840,
  );

  static const PosThemeExtension dark = PosThemeExtension(
    catalogBackground: Color(0xFF121212),
    cartPanelBackground: Color(0xFF1A1A1A),
    cartStripBackground: Color(0xFF0A4A52),
    ctaFill: Color(0xFFFF6B00),
    ctaOnFill: Color(0xFFFFFFFF),
    qtyBadgeBackground: Color(0xFF0A4A52),
    qtyBadgeForeground: Color(0xFFB0E0E6),
    selectedProductBorder: Color(0xFF2A9DAD),
    productCardRadius: 16,
    cartItemRadius: 12,
    sheetTopRadius: 24,
    stickyBarRadius: 20,
    appBarBottomRadius: 24,
    ctaMinHeight: 52,
    catalogPadding: EdgeInsets.fromLTRB(12, 0, 12, 8),
    dockedCartWidth: 380,
    tabletSplitBreakpoint: 840,
  );

  @override
  PosThemeExtension copyWith({
    Color? catalogBackground,
    Color? cartPanelBackground,
    Color? cartStripBackground,
    Color? ctaFill,
    Color? ctaOnFill,
    Color? qtyBadgeBackground,
    Color? qtyBadgeForeground,
    Color? selectedProductBorder,
    double? productCardRadius,
    double? cartItemRadius,
    double? sheetTopRadius,
    double? stickyBarRadius,
    double? appBarBottomRadius,
    double? ctaMinHeight,
    EdgeInsets? catalogPadding,
    double? dockedCartWidth,
    double? tabletSplitBreakpoint,
  }) {
    return PosThemeExtension(
      catalogBackground: catalogBackground ?? this.catalogBackground,
      cartPanelBackground: cartPanelBackground ?? this.cartPanelBackground,
      cartStripBackground: cartStripBackground ?? this.cartStripBackground,
      ctaFill: ctaFill ?? this.ctaFill,
      ctaOnFill: ctaOnFill ?? this.ctaOnFill,
      qtyBadgeBackground: qtyBadgeBackground ?? this.qtyBadgeBackground,
      qtyBadgeForeground: qtyBadgeForeground ?? this.qtyBadgeForeground,
      selectedProductBorder:
          selectedProductBorder ?? this.selectedProductBorder,
      productCardRadius: productCardRadius ?? this.productCardRadius,
      cartItemRadius: cartItemRadius ?? this.cartItemRadius,
      sheetTopRadius: sheetTopRadius ?? this.sheetTopRadius,
      stickyBarRadius: stickyBarRadius ?? this.stickyBarRadius,
      appBarBottomRadius: appBarBottomRadius ?? this.appBarBottomRadius,
      ctaMinHeight: ctaMinHeight ?? this.ctaMinHeight,
      catalogPadding: catalogPadding ?? this.catalogPadding,
      dockedCartWidth: dockedCartWidth ?? this.dockedCartWidth,
      tabletSplitBreakpoint:
          tabletSplitBreakpoint ?? this.tabletSplitBreakpoint,
    );
  }

  @override
  PosThemeExtension lerp(PosThemeExtension? other, double t) {
    if (other is! PosThemeExtension) return this;
    return PosThemeExtension(
      catalogBackground: Color.lerp(
        catalogBackground,
        other.catalogBackground,
        t,
      )!,
      cartPanelBackground: Color.lerp(
        cartPanelBackground,
        other.cartPanelBackground,
        t,
      )!,
      cartStripBackground: Color.lerp(
        cartStripBackground,
        other.cartStripBackground,
        t,
      )!,
      ctaFill: Color.lerp(ctaFill, other.ctaFill, t)!,
      ctaOnFill: Color.lerp(ctaOnFill, other.ctaOnFill, t)!,
      qtyBadgeBackground: Color.lerp(
        qtyBadgeBackground,
        other.qtyBadgeBackground,
        t,
      )!,
      qtyBadgeForeground: Color.lerp(
        qtyBadgeForeground,
        other.qtyBadgeForeground,
        t,
      )!,
      selectedProductBorder: Color.lerp(
        selectedProductBorder,
        other.selectedProductBorder,
        t,
      )!,
      productCardRadius: lerpDouble(
        productCardRadius,
        other.productCardRadius,
        t,
      )!,
      cartItemRadius: lerpDouble(cartItemRadius, other.cartItemRadius, t)!,
      sheetTopRadius: lerpDouble(sheetTopRadius, other.sheetTopRadius, t)!,
      stickyBarRadius: lerpDouble(stickyBarRadius, other.stickyBarRadius, t)!,
      appBarBottomRadius: lerpDouble(
        appBarBottomRadius,
        other.appBarBottomRadius,
        t,
      )!,
      ctaMinHeight: lerpDouble(ctaMinHeight, other.ctaMinHeight, t)!,
      catalogPadding: EdgeInsets.lerp(catalogPadding, other.catalogPadding, t)!,
      dockedCartWidth: lerpDouble(dockedCartWidth, other.dockedCartWidth, t)!,
      tabletSplitBreakpoint: lerpDouble(
        tabletSplitBreakpoint,
        other.tabletSplitBreakpoint,
        t,
      )!,
    );
  }
}

extension PosThemeContext on BuildContext {
  PosThemeExtension get posTheme {
    return Theme.of(this).extension<PosThemeExtension>() ??
        PosThemeExtension.light;
  }
}
