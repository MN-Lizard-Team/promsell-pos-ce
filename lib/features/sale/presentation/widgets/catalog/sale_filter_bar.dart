import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_filter_page.dart';

class SaleFilterBar extends StatelessWidget {
  const SaleFilterBar({super.key, required this.productState});

  final ProductState productState;

  int get _activeFilterCount {
    var count = 0;
    if (productState.stockFilter != StockFilter.all) count++;
    if (productState.productSort != ProductSort.default_) count++;
    if (productState.priceRange?.isActive ?? false) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCount = _activeFilterCount;
    final hasActive = activeCount > 0;

    return PillButton(
      icon: Icons.tune,
      label: l10n.filterMore,
      active: hasActive,
      badgeCount: hasActive ? activeCount : null,
      onTap: () {
        final productBloc = context.read<ProductBloc>();
        final categoryBloc = context.read<CategoryBloc>();
        final currency = context.read<SettingsCubit>().state.settings.currency;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: productBloc),
                BlocProvider.value(value: categoryBloc),
              ],
              child: SaleFilterPage(currency: currency),
            ),
          ),
        );
      },
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? badgeCount;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = active
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final fgColor = active
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 18, color: fgColor),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: fgColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
