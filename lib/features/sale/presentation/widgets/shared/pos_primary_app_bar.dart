import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

/// Shared **primary teal** AppBar chrome for Sale shell pages.
///
/// Matches [SaleAppBar] brand colors so Open bills / cart / payment sit in the
/// same family (not default white Material bar on slate board).
///
/// Drop shadow uses [PosThemeExtension.shadowChromeDown] so lift stays visible
/// on continuous ticket paper (e.g. cart review) where Material elev alone is weak.
class PosPrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PosPrimaryAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    this.centerTitle = false,
    this.roundBottom = true,
    this.titleSpacing,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;
  final bool centerTitle;

  /// Soft bottom corners like the catalog sale bar.
  final bool roundBottom;

  /// Override AppBar title spacing (e.g. 0 when title is a search field).
  final double? titleSpacing;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pos = context.posTheme;
    final onPrimary = scheme.onPrimary;
    final bottomRadius = roundBottom
        ? BorderRadius.vertical(bottom: Radius.circular(pos.appBarBottomRadius))
        : BorderRadius.zero;

    final bar = AppBar(
      backgroundColor: scheme.primary,
      foregroundColor: onPrimary,
      surfaceTintColor: Colors.transparent,
      // Outer DecoratedBox owns chrome shadow (works on ticket paper body).
      elevation: 0,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: false,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      titleSpacing: titleSpacing,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
      iconTheme: IconThemeData(color: onPrimary),
      actionsIconTheme: IconThemeData(color: onPrimary),
      titleTextStyle: TextStyle(
        color: onPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'NotoSansThai',
      ),
      shape: roundBottom
          ? RoundedRectangleBorder(borderRadius: bottomRadius)
          : null,
    );

    // Shadow outside clip so blur is not eaten by AppBar shape.
    // Only cast chrome shadow when bottom is rounded (Sale family).
    // Square-bottom bars (Report) sit flush against body content.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: bottomRadius,
        boxShadow: roundBottom ? pos.shadowChromeDown : const [],
      ),
      child: clipIfRounded(
        bottomRadius: bottomRadius,
        roundBottom: roundBottom,
        child: bar,
      ),
    );
  }

  /// Clip only when rounded — square cart bar still casts full-width shadow.
  static Widget clipIfRounded({
    required BorderRadius bottomRadius,
    required bool roundBottom,
    required Widget child,
  }) {
    if (!roundBottom) return child;
    return ClipRRect(borderRadius: bottomRadius, child: child);
  }

  /// Subtitle / secondary line on primary bar (clock, counts, etc.).
  static TextStyle subtitleStyle(ColorScheme scheme) => TextStyle(
    color: scheme.onPrimary.withValues(alpha: 0.85),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'NotoSansThai',
  );
}
