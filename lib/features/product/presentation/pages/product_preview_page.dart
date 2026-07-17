import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/bottom_action_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/detail_header.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/history_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/info_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/price_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/stock_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/summary_card.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/widgets/dialogs/adjust_stock_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductPreviewPage extends StatefulWidget {
  const ProductPreviewPage({
    super.key,
    required this.product,
    required this.generateBarcode,
    required this.watchInventoryLogs,
  });

  final Product product;
  final GenerateBarcode generateBarcode;
  final WatchInventoryLogs watchInventoryLogs;

  @override
  State<ProductPreviewPage> createState() => _ProductPreviewPageState();
}

class _ProductPreviewPageState extends State<ProductPreviewPage>
    with SingleTickerProviderStateMixin {
  late Product _currentProduct;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Product _latestProduct() {
    final products = context.read<ProductBloc>().state.products;
    return products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => _currentProduct,
    );
  }

  Future<void> _showEdit(BuildContext context) async {
    final latest = _latestProduct();
    final saved = await showProductEditPage(context, latest);
    if (!mounted) return;
    // Prefer list entry from bloc (updated on save); fall back to refresh.
    if (saved) {
      setState(() => _currentProduct = _latestProduct());
    }
  }

  /// Same path as product form edit: inventory adjust sheet + reason log.
  Future<void> _editStock(BuildContext context) async {
    final latest = _latestProduct();
    if (!latest.trackStock) return;
    final newStock = await showAdjustStockDialog(
      context,
      productId: latest.id,
      productName: latest.name,
      currentStock: latest.stock,
      unit: latest.unit,
    );
    if (!mounted || newStock == null) return;
    // AdjustStock already persisted stock + inventory log; refresh local view.
    // Product stream / list will reconcile; optimistically update preview.
    setState(() {
      _currentProduct = latest.copyWith(stock: newStock);
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final deleted = await confirmDeleteProduct(
      context,
      widget.product,
      popOnConfirm: true,
    );
    if (deleted && context.mounted) {
      AppSnackBar.info(context, l10n.productDeleted);
    }
  }

  Future<void> _toggleActive(BuildContext context) async {
    final l10n = context.l10n;
    final latest = _latestProduct();
    final deactivating = latest.isActive;

    final confirmed = await showConfirmationDialog(
      context,
      title: deactivating ? l10n.deactivate : l10n.activate,
      message: deactivating
          ? l10n.productDeactivateConfirm(latest.name)
          : l10n.productActivateConfirm(latest.name),
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
    );
    if (!context.mounted || !confirmed) return;

    final updated = latest.copyWith(isActive: !latest.isActive);
    context.read<ProductBloc>().add(ProductUpdated(updated));
    setState(() => _currentProduct = updated);
    AppSnackBar.info(
      context,
      latest.isActive ? l10n.productDeactivated : l10n.productActivated,
    );
  }

  Future<void> _toggleRecommended(BuildContext context) async {
    final l10n = context.l10n;
    final latest = _latestProduct();
    final enabling = !latest.isRecommended;

    // Hard block: recommended requires visible (active) product.
    if (enabling && !latest.isActive) {
      AppSnackBar.warning(context, l10n.productRecommendedNeedsVisible);
      return;
    }

    final updated = latest.copyWith(isRecommended: !latest.isRecommended);
    context.read<ProductBloc>().add(ProductUpdated(updated));
    setState(() => _currentProduct = updated);
    AppSnackBar.info(
      context,
      updated.isRecommended
          ? l10n.productSettingsOutcomeRecommended
          : l10n.productSettingsOutcomeNotRecommended,
    );
  }

  Future<void> _generateBarcode(BuildContext context) async {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;
    final prefix = settings.barcodeAutoGeneratePrefix;
    try {
      final barcode = await widget.generateBarcode(
        prefix: prefix,
        excludeId: widget.product.id,
      );
      if (!context.mounted) return;
      final updated = _currentProduct.copyWith(barcode: barcode);
      context.read<ProductBloc>().add(ProductUpdated(updated));
      setState(() => _currentProduct = updated);
      AppSnackBar.success(context, l10n.barcodeGenerated);
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, l10n.errorOccurred);
      }
    }
  }

  void _showMenu(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editProduct),
              onTap: () {
                Navigator.pop(ctx);
                _showEdit(context);
              },
            ),
            ListTile(
              leading: Icon(
                _latestProduct().isRecommended
                    ? Icons.star
                    : Icons.star_outline,
              ),
              title: Text(
                _latestProduct().isRecommended
                    ? l10n.productSettingsOutcomeNotRecommended
                    : l10n.productSettingsOutcomeRecommended,
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleRecommended(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                l10n.deleteProduct,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final headerHeight =
        viewPadding.top + kToolbarHeight + DetailHeader.cardOverlapOffset;

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomActionBar(
        onAdjustStock: () => _editStock(context),
        onEdit: () => _showEdit(context),
        showAdjustStock: _currentProduct.trackStock,
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listenWhen: (prev, curr) {
          if ((curr.saveStatus == ProductSaveStatus.saved &&
                  prev.saveStatus != ProductSaveStatus.saved) ||
              (curr.saveStatus == ProductSaveStatus.error &&
                  prev.saveStatus != ProductSaveStatus.error)) {
            return true;
          }
          // Also refresh when this product's row in the list changes
          // (stream reconcile after save, or external updates).
          final id = widget.product.id;
          Product? pick(List<Product> list) =>
              list.where((p) => p.id == id).firstOrNull;
          return pick(prev.products) != pick(curr.products);
        },
        listener: (context, state) {
          if (state.saveStatus == ProductSaveStatus.error &&
              state.error != null &&
              mounted) {
            AppSnackBar.error(
              context,
              state.error!.displayMessage(context.l10n),
            );
            return;
          }
          final updated = state.products
              .where((p) => p.id == widget.product.id)
              .firstOrNull;
          if (updated != null && mounted && updated != _currentProduct) {
            setState(() => _currentProduct = updated);
          }
        },
        child: Builder(
          builder: (context) {
            final product = _currentProduct;
            // Rebuild only when currency changes — not every settings field.
            final currency = context.select(
              (SettingsCubit c) => c.state.settings.currency,
            );
            final cat = context
                .read<CategoryBloc>()
                .state
                .categories
                .where((c) => c.id == product.categoryId)
                .firstOrNull;
            return _buildContent(
              context,
              l10n: l10n,
              product: product,
              category: cat,
              currency: currency,
              headerHeight: headerHeight,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required AppLocalizations l10n,
    required Product product,
    required Category? category,
    required String currency,
    required double headerHeight,
  }) {
    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DetailHeader(
              title: l10n.productDetailTitle,
              subtitle: product.name,
              isActive: product.isActive,
              onBack: () => Navigator.pop(context),
              onToggleActive: () => _toggleActive(context),
              onMenu: () => _showMenu(context),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: headerHeight),
              RepaintBoundary(
                child: SummaryCard(
                  product: product,
                  category: category,
                  currency: currency,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: TabBar(
                      controller: _tabController,
                      tabAlignment: TabAlignment.fill,
                      dividerColor: Colors.transparent,
                      // Icon-only on very narrow widths avoids RenderFlex overflow.
                      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      labelStyle: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: Theme.of(
                        context,
                      ).textTheme.labelMedium,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.article_outlined, size: 18),
                          text: l10n.tabInfo,
                          iconMargin: const EdgeInsets.only(bottom: 2),
                        ),
                        Tab(
                          icon: const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                          ),
                          text: l10n.tabStock,
                          iconMargin: const EdgeInsets.only(bottom: 2),
                        ),
                        Tab(
                          icon: const Icon(
                            Icons.price_check_outlined,
                            size: 18,
                          ),
                          text: l10n.tabPrice,
                          iconMargin: const EdgeInsets.only(bottom: 2),
                        ),
                        Tab(
                          icon: const Icon(Icons.history_outlined, size: 18),
                          text: l10n.productTabHistory,
                          iconMargin: const EdgeInsets.only(bottom: 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    InfoTab(
                      product: product,
                      category: category,
                      onGenerateBarcode:
                          product.barcode == null || product.barcode!.isEmpty
                          ? () => _generateBarcode(context)
                          : null,
                    ),
                    StockTab(
                      product: product,
                      currency: currency,
                      watchInventoryLogs: widget.watchInventoryLogs,
                      onAdjustStock: product.trackStock
                          ? () => _editStock(context)
                          : null,
                      onViewFullHistory: () => _tabController.animateTo(3),
                    ),
                    PriceTab(product: product, currency: currency),
                    HistoryTab(
                      productId: product.id,
                      watchInventoryLogs: widget.watchInventoryLogs,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
