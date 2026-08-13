import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/compact_cart_fab.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_dual_pane.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Delivery layout: catalog + cart access (bottom bar or compact FAB).
///
/// Uses [LayoutBuilder] to switch between tablet dual-pane (Phase 4) and
/// the standard Stack layout with [CartBottomBar] or [CompactCartFab].
class SaleDeliveryLayout extends StatefulWidget {
  const SaleDeliveryLayout({
    super.key,
    required this.searchController,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final TextEditingController searchController;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;

  @override
  State<SaleDeliveryLayout> createState() => _SaleDeliveryLayoutState();
}

class _SaleDeliveryLayoutState extends State<SaleDeliveryLayout> {
  void _clearFilters() {
    widget.searchController.clear();
    final bloc = context.read<ProductBloc>();
    bloc.add(const ProductSearchChanged(''));
    bloc.add(const ProductCategoryFilterChanged(null));
    bloc.add(const ProductStockFilterChanged(StockFilter.all));
    bloc.add(const ProductSortChanged(ProductSort.default_));
    bloc.add(const ProductPriceRangeChanged(null));
  }

  Widget _buildCatalog({required double bottomContentInset}) {
    return SaleCatalog(
      searchController: widget.searchController,
      viewMode: widget.viewMode,
      onViewModeChanged: widget.onViewModeChanged,
      onClearFilters: _clearFilters,
      bottomContentInset: bottomContentInset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUltra = context.select(
      (SettingsCubit c) => c.state.settings.ultraCompactMode,
    );

    if (isUltra) {
      return Stack(
        children: [
          _buildCatalog(
            bottomContentInset: 100 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          const CompactCartFab(),
        ],
      );
    }

    return SaleDualPane(
      searchController: widget.searchController,
      viewMode: widget.viewMode,
      onViewModeChanged: widget.onViewModeChanged,
      onClearFilters: _clearFilters,
    );
  }
}
