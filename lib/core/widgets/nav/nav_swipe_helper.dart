import 'package:flutter/widgets.dart';

abstract final class NavSwipeHelper {
  static const double threshold = 300.0;

  static void handleSwipe(
    DragEndDetails details,
    int selectedIndex,
    int itemCount,
    ValueChanged<int> onTap,
  ) {
    if (details.velocity.pixelsPerSecond.dx.abs() < threshold) return;
    if (details.velocity.pixelsPerSecond.dx > 0) {
      if (selectedIndex > 0) onTap(selectedIndex - 1);
    } else {
      if (selectedIndex < itemCount - 1) onTap(selectedIndex + 1);
    }
  }
}
