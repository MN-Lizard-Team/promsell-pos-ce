import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

/// Shared POS modal bottom sheet chrome.
///
/// Contract:
/// - Top radius from [PosThemeExtension.sheetTopRadius]
/// - **One** drag affordance: Material [showDragHandle] **or** none —
///   never pair Material handle with a hand-drawn bar
/// - Safe area + optional scroll for tall content
abstract final class PosBottomSheet {
  PosBottomSheet._();

  /// Fraction of screen height for tall sheets (filter / pickers / success).
  static double fractionHeight(BuildContext context, double fraction) {
    assert(fraction > 0 && fraction <= 1);
    return MediaQuery.sizeOf(context).height * fraction;
  }

  static const double filterFraction = 0.72;
  static const double pickerFraction = 0.68;
  static const double successFraction = 0.92;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool enableDrag = true,
    bool isDismissible = true,
    Color? backgroundColor,
    Color? barrierColor,
  }) {
    final pos = context.posTheme;
    final scheme = Theme.of(context).colorScheme;
    final radius = pos.sheetTopRadius;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor ?? scheme.surface,
      barrierColor: barrierColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      builder: builder,
    );
  }
}
