import 'package:flutter/material.dart';

class SettingsTileData {
  const SettingsTileData({
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.statusChip,
    required this.page,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget? statusChip;
  final Widget page;
}

class SettingsSectionData {
  const SettingsSectionData({required this.title, required this.tiles});

  final String title;
  final List<SettingsTileData> tiles;
}
