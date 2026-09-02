import 'package:flutter/material.dart';

class SettingsTileData {
  const SettingsTileData({
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.statusChip,
    this.emphasized = false,
    this.searchKeywords = const [],
    required this.page,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget? statusChip;

  /// Readiness-critical tiles (shop info, PromptPay, backup) render a
  /// stronger icon well so they stand out within the restrained 2-tone
  /// palette.
  final bool emphasized;

  /// Extra tokens for root search (e.g. VAT / ภาษี).
  final List<String> searchKeywords;
  final Widget page;
}

class SettingsSectionData {
  const SettingsSectionData({
    required this.title,
    required this.tiles,
    this.accent,
  });

  final String title;
  final List<SettingsTileData> tiles;

  /// Per-category accent color for pill header + action card stripes.
  /// Falls back to [SettingsThemeExtension.softAccent] when null.
  final Color? accent;
}
