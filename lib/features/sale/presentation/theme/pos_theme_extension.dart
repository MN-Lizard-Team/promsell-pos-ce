import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// POS / Sale surface tokens — mirrors [SettingsThemeExtension] pattern.
///
/// Multi-bill (park / open bills) uses stub/rail/park tokens so bills UI
/// matches Counter Receipt Dock language. Orange [ctaFill] = money Pay only.
///
/// ## Elevation (Sale hierarchy — do not freestyle)
/// - **0 flat:** board, cart lines, bill stubs, filter chrome, chips
/// - **paper / paperActive:** resting vs in-cart product / draft tiles
/// - **chrome:** AppBar (one top caster)
/// - **fab / fabActive:** floating tools / pay
/// - **modal:** sheets & success climax
///
/// Prefer [shadowDockUp] / [shadowChromeDown] factories over ad-hoc BoxShadows.
/// At most **one top + one bottom** ambient caster on the main sale canvas.
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
    required this.parkCtaForeground,
    required this.parkCtaBorder,
    required this.billStubPaper,
    required this.billStubBorder,
    required this.billStubRadius,
    required this.activeBillFill,
    required this.activeBillRail,
    required this.billRowMinHeight,
    required this.elevFlat,
    required this.elevPaper,
    required this.elevPaperActive,
    required this.elevChrome,
    required this.elevFab,
    required this.elevFabActive,
    required this.elevModal,
    required this.shadowKey,
    required this.shadowChromeAlpha,
    required this.shadowDockFarAlpha,
    required this.shadowDockNearAlpha,
    required this.shadowFabNeutralAlpha,
    required this.shadowFabCtaAlpha,
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

  /// Park / hold bill outline control (never orange).
  final Color parkCtaForeground;
  final Color parkCtaBorder;

  /// Parked / open bill ticket stubs.
  final Color billStubPaper;
  final Color billStubBorder;
  final double billStubRadius;
  final Color activeBillFill;
  final Color activeBillRail;
  final double billRowMinHeight;

  // --- Elevation ladder (Sale) -----------------------------------------------

  /// Board / ticket / chips — always 0.
  final double elevFlat;

  /// Resting product / draft paper.
  final double elevPaper;

  /// In-cart / active bill tile.
  final double elevPaperActive;

  /// Top AppBar chrome.
  final double elevChrome;

  /// Resting float (empty cart FAB, secondary).
  final double elevFab;

  /// Pay / hot cart FAB.
  final double elevFabActive;

  /// Modal / success climax (cap on main canvas).
  final double elevModal;

  // --- Shadow recipes (alphas + key; lists via getters) -----------------------

  /// Base ink for shadows (usually black); alpha applied per recipe.
  final Color shadowKey;

  final double shadowChromeAlpha;
  final double shadowDockFarAlpha;
  final double shadowDockNearAlpha;
  final double shadowFabNeutralAlpha;
  final double shadowFabCtaAlpha;

  /// AppBar — soft shadow downward into catalog.
  List<BoxShadow> get shadowChromeDown => [
    BoxShadow(
      color: shadowKey.withValues(alpha: shadowChromeAlpha),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  /// Cart dock + bottom nav — shared upward lift (one bottom-caster language).
  List<BoxShadow> get shadowDockUp => [
    BoxShadow(
      color: shadowKey.withValues(alpha: shadowDockFarAlpha),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
    BoxShadow(
      color: shadowKey.withValues(alpha: shadowDockNearAlpha),
      blurRadius: 6,
      offset: const Offset(0, -1),
    ),
  ];

  /// Neutral floating control (empty bag FAB).
  List<BoxShadow> get shadowFabNeutral => [
    BoxShadow(
      color: shadowKey.withValues(alpha: shadowFabNeutralAlpha),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Money CTA glow — tinted from [ctaFill], not freehand.
  List<BoxShadow> get shadowFabCta => [
    BoxShadow(
      color: ctaFill.withValues(alpha: shadowFabCtaAlpha),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static const PosThemeExtension light = PosThemeExtension(
    // Cool slate board — tickets stay pure paper white on top.
    catalogBackground: Color(0xFFF1F5F9),
    cartPanelBackground: Color(0xFFFFFFFF),
    cartStripBackground: Color(0xFFD0ECEF),
    ctaFill: Color(0xFFFF6B00),
    ctaOnFill: Color(0xFFFFFFFF),
    qtyBadgeBackground: Color(0xFFD0ECEF),
    qtyBadgeForeground: Color(0xFF0D5D6B),
    selectedProductBorder: Color(0xFF0D5D6B),
    productCardRadius: 8,
    cartItemRadius: 12,
    sheetTopRadius: 24,
    stickyBarRadius: 20,
    appBarBottomRadius: 24,
    ctaMinHeight: 52,
    catalogPadding: EdgeInsets.fromLTRB(12, 10, 12, 8),
    dockedCartWidth: 380,
    tabletSplitBreakpoint: 840,
    parkCtaForeground: Color(0xFF0D5D6B),
    parkCtaBorder: Color(0xFF0D5D6B),
    billStubPaper: Color(0xFFFFFFFF),
    billStubBorder: Color(0xFFD8E0EA),
    billStubRadius: 12,
    activeBillFill: Color(0xFFF7FBFC),
    activeBillRail: Color(0xFF0D5D6B),
    billRowMinHeight: 68,
    elevFlat: 0,
    elevPaper: 0.5,
    elevPaperActive: 2,
    elevChrome: 3,
    elevFab: 4,
    elevFabActive: 8,
    elevModal: 8,
    shadowKey: Color(0xFF000000),
    shadowChromeAlpha: 0.18,
    shadowDockFarAlpha: 0.10,
    shadowDockNearAlpha: 0.06,
    shadowFabNeutralAlpha: 0.22,
    shadowFabCtaAlpha: 0.40,
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
    productCardRadius: 8,
    cartItemRadius: 12,
    sheetTopRadius: 24,
    stickyBarRadius: 20,
    appBarBottomRadius: 24,
    ctaMinHeight: 52,
    catalogPadding: EdgeInsets.fromLTRB(12, 4, 12, 8),
    dockedCartWidth: 380,
    tabletSplitBreakpoint: 840,
    parkCtaForeground: Color(0xFFB0E0E6),
    parkCtaBorder: Color(0xFF2A9DAD),
    billStubPaper: Color(0xFF1E1E1E),
    billStubBorder: Color(0xFF3A3A3A),
    billStubRadius: 12,
    activeBillFill: Color(0xFF222A2C),
    activeBillRail: Color(0xFF2A9DAD),
    billRowMinHeight: 68,
    elevFlat: 0,
    elevPaper: 0.5,
    elevPaperActive: 2,
    elevChrome: 3,
    elevFab: 4,
    elevFabActive: 8,
    elevModal: 8,
    shadowKey: Color(0xFF000000),
    // Slightly stronger ambient on dark / OLED so chrome still reads.
    shadowChromeAlpha: 0.28,
    shadowDockFarAlpha: 0.16,
    shadowDockNearAlpha: 0.10,
    shadowFabNeutralAlpha: 0.32,
    shadowFabCtaAlpha: 0.45,
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
    Color? parkCtaForeground,
    Color? parkCtaBorder,
    Color? billStubPaper,
    Color? billStubBorder,
    double? billStubRadius,
    Color? activeBillFill,
    Color? activeBillRail,
    double? billRowMinHeight,
    double? elevFlat,
    double? elevPaper,
    double? elevPaperActive,
    double? elevChrome,
    double? elevFab,
    double? elevFabActive,
    double? elevModal,
    Color? shadowKey,
    double? shadowChromeAlpha,
    double? shadowDockFarAlpha,
    double? shadowDockNearAlpha,
    double? shadowFabNeutralAlpha,
    double? shadowFabCtaAlpha,
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
      parkCtaForeground: parkCtaForeground ?? this.parkCtaForeground,
      parkCtaBorder: parkCtaBorder ?? this.parkCtaBorder,
      billStubPaper: billStubPaper ?? this.billStubPaper,
      billStubBorder: billStubBorder ?? this.billStubBorder,
      billStubRadius: billStubRadius ?? this.billStubRadius,
      activeBillFill: activeBillFill ?? this.activeBillFill,
      activeBillRail: activeBillRail ?? this.activeBillRail,
      billRowMinHeight: billRowMinHeight ?? this.billRowMinHeight,
      elevFlat: elevFlat ?? this.elevFlat,
      elevPaper: elevPaper ?? this.elevPaper,
      elevPaperActive: elevPaperActive ?? this.elevPaperActive,
      elevChrome: elevChrome ?? this.elevChrome,
      elevFab: elevFab ?? this.elevFab,
      elevFabActive: elevFabActive ?? this.elevFabActive,
      elevModal: elevModal ?? this.elevModal,
      shadowKey: shadowKey ?? this.shadowKey,
      shadowChromeAlpha: shadowChromeAlpha ?? this.shadowChromeAlpha,
      shadowDockFarAlpha: shadowDockFarAlpha ?? this.shadowDockFarAlpha,
      shadowDockNearAlpha: shadowDockNearAlpha ?? this.shadowDockNearAlpha,
      shadowFabNeutralAlpha:
          shadowFabNeutralAlpha ?? this.shadowFabNeutralAlpha,
      shadowFabCtaAlpha: shadowFabCtaAlpha ?? this.shadowFabCtaAlpha,
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
      parkCtaForeground: Color.lerp(
        parkCtaForeground,
        other.parkCtaForeground,
        t,
      )!,
      parkCtaBorder: Color.lerp(parkCtaBorder, other.parkCtaBorder, t)!,
      billStubPaper: Color.lerp(billStubPaper, other.billStubPaper, t)!,
      billStubBorder: Color.lerp(billStubBorder, other.billStubBorder, t)!,
      billStubRadius: lerpDouble(billStubRadius, other.billStubRadius, t)!,
      activeBillFill: Color.lerp(activeBillFill, other.activeBillFill, t)!,
      activeBillRail: Color.lerp(activeBillRail, other.activeBillRail, t)!,
      billRowMinHeight: lerpDouble(
        billRowMinHeight,
        other.billRowMinHeight,
        t,
      )!,
      elevFlat: lerpDouble(elevFlat, other.elevFlat, t)!,
      elevPaper: lerpDouble(elevPaper, other.elevPaper, t)!,
      elevPaperActive: lerpDouble(elevPaperActive, other.elevPaperActive, t)!,
      elevChrome: lerpDouble(elevChrome, other.elevChrome, t)!,
      elevFab: lerpDouble(elevFab, other.elevFab, t)!,
      elevFabActive: lerpDouble(elevFabActive, other.elevFabActive, t)!,
      elevModal: lerpDouble(elevModal, other.elevModal, t)!,
      shadowKey: Color.lerp(shadowKey, other.shadowKey, t)!,
      shadowChromeAlpha: lerpDouble(
        shadowChromeAlpha,
        other.shadowChromeAlpha,
        t,
      )!,
      shadowDockFarAlpha: lerpDouble(
        shadowDockFarAlpha,
        other.shadowDockFarAlpha,
        t,
      )!,
      shadowDockNearAlpha: lerpDouble(
        shadowDockNearAlpha,
        other.shadowDockNearAlpha,
        t,
      )!,
      shadowFabNeutralAlpha: lerpDouble(
        shadowFabNeutralAlpha,
        other.shadowFabNeutralAlpha,
        t,
      )!,
      shadowFabCtaAlpha: lerpDouble(
        shadowFabCtaAlpha,
        other.shadowFabCtaAlpha,
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
