import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Wrapper widget for custom SVG icons from `assets/icons/`.
///
/// Usage:
/// ```dart
/// SvgIcon('search', size: 20, color: scheme.onPrimary)
/// ```
///
/// Add SVG files to `assets/icons/` and they are auto-discovered
/// (the directory is already declared in pubspec.yaml).
class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticsLabel,
  });

  /// Icon file name without extension (e.g. 'search' → 'assets/icons/search.svg').
  final String name;

  /// Icon width and height in logical pixels.
  final double size;

  /// Tint color. If null, uses the SVG's original colors.
  /// Set to `currentColor` in the SVG to enable tinting.
  final Color? color;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticsLabel,
    );
  }
}
