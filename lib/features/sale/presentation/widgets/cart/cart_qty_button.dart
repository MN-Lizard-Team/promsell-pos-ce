import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

/// Compact qty control.
///
/// [bare] true = icon-only for use inside [_QtyCluster] (no own border).
class CartQtyButton extends StatelessWidget {
  const CartQtyButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.bare = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// When true, no border/background — parent cluster provides chrome.
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: IconButton(
        tooltip: tooltip,
        onPressed: enabled
            ? () {
                HapticFeedback.selectionClick();
                onPressed!();
              }
            : null,
        style: IconButton.styleFrom(
          minimumSize: Size(bare ? 32 : 36, bare ? 32 : 36),
          maximumSize: Size(bare ? 32 : 36, bare ? 32 : 36),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          foregroundColor: enabled
              ? pos.activeBillRail
              : theme.colorScheme.onSurfaceVariant,
          side: bare
              ? BorderSide.none
              : BorderSide(
                  color: enabled
                      ? pos.billStubBorder
                      : theme.colorScheme.outlineVariant,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(bare ? 0 : 8),
          ),
        ),
        icon: Icon(icon, size: 18),
      ),
    );
  }
}
