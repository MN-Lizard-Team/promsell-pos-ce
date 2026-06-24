import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/widgets/nav/animated_nav_bar/icon_with_badge.dart';

class AnimatedNavBar extends StatefulWidget {
  const AnimatedNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const double _height = 64;
  static const double _labelFontSize = 11;

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  int _animatingIndex = -1;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_bounceCtrl);
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
          height: AnimatedNavBar._height + bottomPadding,
          child: Stack(
            children: [
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
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: AnimatedNavBar._height,
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
                            height: AnimatedNavBar._height,
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
                                    child: IconWithBadge(
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
                                              fontSize:
                                                  AnimatedNavBar._labelFontSize,
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

  final int? badgeCount;

  final Color? badgeColor;

  final Map<String, String>? longPressActions;

  final ValueChanged<String>? onLongPressAction;
}
