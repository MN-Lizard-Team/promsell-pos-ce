import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleFilterBar extends StatelessWidget {
  const SaleFilterBar({
    super.key,
    required this.productState,
    this.compact = false,
  });

  final ProductState productState;

  /// Denser layout in the catalog tools row. Label still shows when filters
  /// are on, or when width is comfortable.
  final bool compact;

  /// Badge = stock + price only (sort is not a filter).
  int get _activeFilterCount {
    var count = 0;
    if (productState.stockFilter != StockFilter.all) count++;
    if (productState.priceRange?.isActive ?? false) count++;
    return count;
  }

  void _openFilterSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final settings = context.read<SettingsCubit>().state.settings;
    PosBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final maxH = PosBottomSheet.fractionHeight(
          context,
          PosBottomSheet.filterFraction,
        );
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SaleFilterSheet(
              currency: settings.currency,
              lowStockThreshold: settings.lowStockThreshold,
            ),
          ),
        );
      },
    );
  }

  void _clearFilters(BuildContext context) {
    HapticFeedback.selectionClick();
    context.read<ProductBloc>().add(
      const ProductListFiltersApplied(
        stockFilter: StockFilter.all,
        productSort: ProductSort.default_,
        priceRange: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCount = _activeFilterCount;
    final hasFilters = activeCount > 0;
    final width = MediaQuery.sizeOf(context).width;
    // Icon-only only when idle + truly narrow. Filters on → always show "กรอง".
    final iconOnly = !hasFilters && width < (compact ? 360 : 340);

    final semanticLabel = hasFilters
        ? '${l10n.filterPageTitle}, $activeCount'
        : l10n.filterPageTitle;

    return FilterPillButton(
      icon: Icons.filter_list_rounded,
      label: l10n.filterMore,
      semanticLabel: semanticLabel,
      active: hasFilters,
      badgeCount: hasFilters ? activeCount : null,
      iconOnly: iconOnly,
      onTap: () => _openFilterSheet(context),
      onClear: hasFilters ? () => _clearFilters(context) : null,
    );
  }
}

/// Catalog filter trigger — paper when idle; soft primary when filters on.
///
/// Avoids full teal tank + error-red badge (reads as Pay / alarm, not filter).
class FilterPillButton extends StatelessWidget {
  const FilterPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.active,
    required this.onTap,
    this.badgeCount,
    this.onClear,
    this.iconOnly = false,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final bool active;
  final VoidCallback onTap;
  final int? badgeCount;
  final VoidCallback? onClear;
  final bool iconOnly;

  /// Match catalog tool row (~36), not full 48 CTA height.
  static const _radius = 10.0;
  static const double _height = 36;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    final bgColor = active ? scheme.primaryContainer : pos.billStubPaper;
    final fgColor = active
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final border = active
        ? BorderSide(color: scheme.primary, width: 1.5)
        : BorderSide(color: pos.billStubBorder);

    return Semantics(
      button: true,
      selected: active,
      label: semanticLabel,
      enabled: true,
      child: Tooltip(
        message: semanticLabel,
        child: Material(
          color: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: border,
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: onClear,
            borderRadius: BorderRadius.circular(_radius),
            child: SizedBox(
              height: _height,
              child: Padding(
                padding: EdgeInsets.only(
                  left: iconOnly ? 8 : 10,
                  right: onClear != null ? 4 : (iconOnly ? 8 : 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(icon, size: 18, color: fgColor),
                        if (badgeCount != null && badgeCount! > 0)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: ExcludeSemantics(
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: bgColor,
                                    width: 1.25,
                                  ),
                                ),
                                child: Text(
                                  '$badgeCount',
                                  style: TextStyle(
                                    color: scheme.onPrimary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (!iconOnly) ...[
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: fgColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (onClear != null) ...[
                      const SizedBox(width: 2),
                      // Compact × — long-press on pill also clears.
                      Tooltip(
                        message: l10n.filterReset,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onClear,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.close, size: 14, color: fgColor),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
