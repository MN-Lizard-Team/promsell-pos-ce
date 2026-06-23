import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An iOS-style bottom tab bar — full-width, anchored to the bottom,
/// with a frosted-glass background and crisp icon + label layout.
///
/// Every tab shows its icon and label at all times for clarity.
/// Active tab has a bounce animation and a subtle indicator dot.
class AnimatedNavBar extends StatefulWidget {
  const AnimatedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  int _animatingIndex = -1;

  static const double _height = 64;
  static const double _labelFontSize = 11;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animatingIndex = widget.selectedIndex;
      _bounceCtrl.reset();
      _bounceCtrl.forward();
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  void _onLongPress(int index, Offset globalPosition) {
    HapticFeedback.mediumImpact();
    final item = widget.items[index];
    final entries = item.longPressActions;
    if (entries == null || entries.isEmpty) return;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: entries.entries
          .map((e) => PopupMenuItem<String>(value: e.key, child: Text(e.value)))
          .toList(),
    ).then((value) {
      if (value != null) {
        item.onLongPressAction?.call(value);
      }
    });
  }

  void _handleNavbarSwipe(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() < 300) return;
    if (details.velocity.pixelsPerSecond.dx > 0) {
      if (widget.selectedIndex > 0) _onTap(widget.selectedIndex - 1);
    } else {
      if (widget.selectedIndex < widget.items.length - 1) {
        _onTap(widget.selectedIndex + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return GestureDetector(
      onHorizontalDragEnd: _handleNavbarSwipe,
      child: ClipRect(
        child: SizedBox(
          height: _height + bottomPadding,
          child: Stack(
            children: [
              // Frosted glass background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.88),
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Tab row
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _height,
                child: Row(
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isActive = index == widget.selectedIndex;
                    final isBouncing = index == _animatingIndex;

                    return Expanded(
                      child: Tooltip(
                        message: item.label,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _onTap(index),
                          onLongPressStart: (details) =>
                              _onLongPress(index, details.globalPosition),
                          child: Container(
                            height: _height,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? colorScheme.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _bounceAnim,
                                    builder: (context, child) {
                                      final scale = isBouncing
                                          ? _bounceAnim.value
                                          : 1.0;
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child: _IconWithBadge(
                                      icon: isActive
                                          ? item.activeIcon
                                          : item.icon,
                                      color: isActive
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.55),
                                      badgeCount: item.badgeCount,
                                      badgeColor:
                                          item.badgeColor ?? colorScheme.error,
                                      isActive: isActive,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.label,
                                    style:
                                        (theme.textTheme.labelSmall ??
                                                const TextStyle())
                                            .copyWith(
                                              fontFamily: 'NotoSansThai',
                                              color: isActive
                                                  ? colorScheme
                                                        .onPrimaryContainer
                                                  : colorScheme.onSurfaceVariant
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                              fontWeight: isActive
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              fontSize: _labelFontSize,
                                              height: 1,
                                            ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration for a single tab in [AnimatedNavBar].
class NavItem {
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
    this.badgeColor,
    this.longPressActions,
    this.onLongPressAction,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// `null` = no badge, `0` = dot only, `>0` = number badge.
  final int? badgeCount;

  /// Defaults to `ColorScheme.error` if not provided.
  final Color? badgeColor;

  /// Key-value pairs for the long-press popup menu.
  /// Key = action identifier, Value = display text.
  final Map<String, String>? longPressActions;

  /// Called with the selected action key from the long-press menu.
  final ValueChanged<String>? onLongPressAction;
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.color,
    this.badgeCount,
    required this.badgeColor,
    required this.isActive,
  });

  final IconData icon;
  final Color color;
  final int? badgeCount;
  final Color badgeColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final hasBadge = badgeCount != null;
    final showNumber = (badgeCount ?? 0) > 0;

    return SizedBox(
      width: 40,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          if (hasBadge)
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedScale(
                scale: isActive ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Container(
                  constraints: showNumber
                      ? const BoxConstraints(minWidth: 16)
                      : null,
                  padding: showNumber
                      ? const EdgeInsets.symmetric(horizontal: 4)
                      : EdgeInsets.zero,
                  height: 16,
                  width: showNumber ? null : 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: showNumber
                      ? Text(
                          badgeCount! > 99 ? '99+' : badgeCount.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
