import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/docked_cart_panel.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog.dart';

/// Dual-pane layout for tablet/landscape: catalog left + docked cart right.
///
/// Falls back to [SaleCatalog] + [CartBottomBar] Stack when width is below
/// [PosThemeExtension.tabletSplitBreakpoint].
class SaleDualPane extends StatelessWidget {
  const SaleDualPane({
    super.key,
    required this.searchController,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onClearFilters,
  });

  final TextEditingController searchController;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final VoidCallback onClearFilters;

  Widget _buildCatalog({required double bottomContentInset}) {
    return SaleCatalog(
      searchController: searchController,
      viewMode: viewMode,
      onViewModeChanged: onViewModeChanged,
      onClearFilters: onClearFilters,
      bottomContentInset: bottomContentInset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.posTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= pos.tabletSplitBreakpoint) {
          return Row(
            children: [
              Expanded(flex: 5, child: _buildCatalog(bottomContentInset: 16)),
              SizedBox(
                width: pos.dockedCartWidth,
                child: const DockedCartPanel(),
              ),
            ],
          );
        }

        // Fallback: Stack layout with bottom bar.
        return Stack(
          children: [
            _buildCatalog(
              bottomContentInset: CartBottomBar.contentInset(context),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CartBottomBar(),
            ),
          ],
        );
      },
    );
  }
}
