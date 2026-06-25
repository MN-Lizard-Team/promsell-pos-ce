import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar/icon_with_badge.dart';
import 'package:promsell_pos_ce/core/widgets/nav/nav_swipe_helper.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({
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
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  int _animatingIndex = -1;
  int _pressedIndex = -1;

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
    _bounceCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _animatingIndex = -1);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() => _animatingIndex = widget.selectedIndex);
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

    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    final tabWidth = box.size.width / widget.items.length;
    final tabCenterX = origin.dx + tabWidth * index + tabWidth / 2;
    final menuTop = origin.dy;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        tabCenterX,
        menuTop,
        tabCenterX + 1,
        menuTop + 1,
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
    NavSwipeHelper.handleSwipe(
      details,
      widget.selectedIndex,
      widget.items.length,
      _onTap,
    );
  }

  Widget _buildItem(
    int index,
    NavItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isActive = index == widget.selectedIndex;
    final isBouncing = index == _animatingIndex;
    final isPressed = index == _pressedIndex;

    return Expanded(
      child: RepaintBoundary(
        child: Semantics(
          button: true,
          label: item.label,
          selected: isActive,
          child: Tooltip(
            message: item.label,
            triggerMode: TooltipTriggerMode.manual,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onTap(index),
              onTapDown: (_) => setState(() => _pressedIndex = index),
              onTapUp: (_) => setState(() => _pressedIndex = -1),
              onTapCancel: () => setState(() => _pressedIndex = -1),
              onLongPressStart: (details) =>
                  _onLongPress(index, details.globalPosition),
              child: Container(
                height: AppBottomNavigationBar._height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedOpacity(
                  opacity: isPressed ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 100),
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
                        if (isBouncing)
                          AnimatedBuilder(
                            animation: _bounceAnim,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _bounceAnim.value,
                                child: child,
                              );
                            },
                            child: IconWithBadge(
                              icon: isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.55,
                                    ),
                              badgeCount: item.badgeCount,
                              badgeColor: item.badgeColor ?? colorScheme.error,
                              isActive: isActive,
                            ),
                          )
                        else
                          IconWithBadge(
                            icon: isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.55,
                                  ),
                            badgeCount: item.badgeCount,
                            badgeColor: item.badgeColor ?? colorScheme.error,
                            isActive: isActive,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: theme.textTheme.labelSmall!.copyWith(
                            fontFamily: 'NotoSansThai',
                            color: isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.55,
                                  ),
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: AppBottomNavigationBar._labelFontSize,
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
          ),
        ),
      ),
    );
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
          height: AppBottomNavigationBar._height + bottomPadding,
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
                height: AppBottomNavigationBar._height,
                child: Row(
                  children: widget.items
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildItem(
                          entry.key,
                          entry.value,
                          theme,
                          colorScheme,
                        ),
                      )
                      .toList(),
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
