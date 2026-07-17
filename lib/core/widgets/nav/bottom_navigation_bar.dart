import 'dart:math' as math;
import 'dart:ui';
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

  static const double _height = 72;
  static const double _labelFontSize = 12;

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  int _animatingIndex = -1;

  int get _centerIndex => widget.items.length ~/ 2;

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
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
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

  Widget _withBounce(bool isBouncing, Widget child) {
    if (!isBouncing) return child;
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.scale(scale: _bounceAnim.value, child: child);
      },
      child: child,
    );
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  void _onLongPress(int index) {
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

  Widget _buildRegularItem(
    int index,
    NavItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isActive = index == widget.selectedIndex;
    final isBouncing = index == _animatingIndex;

    return Expanded(
      child: RepaintBoundary(
        child: Semantics(
          button: true,
          label: item.label,
          selected: isActive,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onTap(index),
              onLongPress: () => _onLongPress(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: AppBottomNavigationBar._height,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _withBounce(
                      isBouncing,
                      IconWithBadge(
                        icon: isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                        badgeCount: item.badgeCount,
                        badgeColor: item.badgeColor ?? colorScheme.error,
                        isActive: isActive,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: theme.textTheme.labelSmall!.copyWith(
                        fontFamily: 'NotoSansThai',
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
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
    );
  }

  Widget _buildCenterButton(
    NavItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isActive = widget.selectedIndex == _centerIndex;
    final isBouncing = _animatingIndex == _centerIndex;

    return SizedBox(
      width: 80,
      height: AppBottomNavigationBar._height + 24,
      child: Center(
        child: Semantics(
          button: true,
          label: item.label,
          selected: isActive,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(_centerIndex),
            onLongPress: () => _onLongPress(_centerIndex),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _withBounce(
                  isBouncing,
                  _buildCenterDiamond(item, colorScheme, isActive),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall!.copyWith(
                    fontFamily: 'NotoSansThai',
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
    );
  }

  Widget _buildCenterDiamond(
    NavItem item,
    ColorScheme colorScheme,
    bool isActive,
  ) {
    return Container(
      width: 56,
      height: 56,
      transform: Matrix4.rotationZ(math.pi / 4),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: -math.pi / 4,
        child: Icon(
          isActive ? item.activeIcon : item.icon,
          color: colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: AppBottomNavigationBar._height + bottomPadding + 4,
      child: GestureDetector(
        onHorizontalDragEnd: _handleNavbarSwipe,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: AppBottomNavigationBar._height + bottomPadding,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          for (int i = 0; i < _centerIndex; i++)
                            _buildRegularItem(
                              i,
                              widget.items[i],
                              theme,
                              colorScheme,
                            ),
                          const SizedBox(width: 80),
                          for (
                            int i = _centerIndex + 1;
                            i < widget.items.length;
                            i++
                          )
                            _buildRegularItem(
                              i,
                              widget.items[i],
                              theme,
                              colorScheme,
                            ),
                        ],
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
              child: Center(
                child: RepaintBoundary(
                  child: _buildCenterButton(
                    widget.items[_centerIndex],
                    theme,
                    colorScheme,
                  ),
                ),
              ),
            ),
          ],
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
