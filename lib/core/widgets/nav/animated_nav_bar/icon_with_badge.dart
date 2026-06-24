import 'package:flutter/material.dart';

class IconWithBadge extends StatelessWidget {
  const IconWithBadge({
    super.key,
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
