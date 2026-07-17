import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_filter_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleFilterBar extends StatelessWidget {
  const SaleFilterBar({
    super.key,
    required this.productState,
    this.compact = false,
  });

  final ProductState productState;

  /// Prefer icon-only control (single-row chrome with category chips).
  final bool compact;

  int get _activeFilterCount {
    var count = 0;
    if (productState.stockFilter != StockFilter.all) count++;
    if (productState.productSort != ProductSort.default_) count++;
    if (productState.priceRange?.isActive ?? false) count++;
    return count;
  }

  void _openFilterSheet(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final settings = context.read<SettingsCubit>().state.settings;
    final sheetRadius = context.posTheme.sheetTopRadius;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.85,
          child: SaleFilterPage(
            currency: settings.currency,
            asSheet: true,
            lowStockThreshold: settings.lowStockThreshold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCount = _activeFilterCount;
    final hasActive = activeCount > 0;

    // Icon-only on narrow widths or compact chrome keeps tools from overflowing.
    final narrow = MediaQuery.sizeOf(context).width < 360;
    return PillButton(
      icon: Icons.tune_rounded,
      label: l10n.filterMore,
      active: hasActive,
      badgeCount: hasActive ? activeCount : null,
      iconOnly: compact || (narrow && !hasActive),
      onTap: () => _openFilterSheet(context),
    );
  }
}

/// Compact pill used by Sale filter chrome.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount,
    this.onClear,
    this.iconOnly = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? badgeCount;
  final VoidCallback? onClear;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = active
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final fgColor = active
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    final border = active
        ? BorderSide.none
        : BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
          );

    return Material(
      color: bgColor,
      elevation: active ? 1 : 0,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: border,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 10 : 12,
            vertical: 8,
          ),
          child: Row(
            // Always shrink-wrap — safe inside wireframe header Rows.
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 18, color: fgColor),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bgColor, width: 1.5),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            color: theme.colorScheme.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (!iconOnly) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: fgColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 16, color: fgColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
