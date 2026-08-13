import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_sheet.dart';

export 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_sheet.dart';

/// Legacy entry for filter UI.
///
/// Sale catalog opens [SaleFilterSheet] via [SaleFilterBar]. Full-page mode
/// (`asSheet: false`) remains for tests / rare push routes and still owns
/// category selection.
class SaleFilterPage extends StatefulWidget {
  const SaleFilterPage({
    super.key,
    this.currency = '฿',
    this.asSheet = false,
    this.lowStockThreshold = 5,
  });

  final String currency;

  /// When true, embeds [SaleFilterSheet] (no Scaffold; Material handle outside).
  final bool asSheet;

  final int lowStockThreshold;

  @override
  State<SaleFilterPage> createState() => _SaleFilterPageState();
}

class _SaleFilterPageState extends State<SaleFilterPage> {
  late String? _selectedCategory;
  late StockFilter _stockFilter;
  late ProductSort _productSort;
  late PriceRange _priceRange;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProductBloc>().state;
    _selectedCategory = state.categoryFilter;
    _stockFilter = state.stockFilter;
    _productSort = state.productSort;
    _priceRange = state.priceRange ?? const PriceRange();
  }

  void _applyFullPage() {
    final bloc = context.read<ProductBloc>();
    // Category only on full-page path; stock/sort/price atomic.
    bloc.add(ProductCategoryFilterChanged(_selectedCategory));
    bloc.add(
      ProductListFiltersApplied(
        stockFilter: _stockFilter,
        productSort: _productSort,
        priceRange: _priceRange.isActive ? _priceRange.normalized() : null,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asSheet) {
      return SaleFilterSheet(
        currency: widget.currency,
        lowStockThreshold: widget.lowStockThreshold,
      );
    }

    final l10n = context.l10n;
    final categories = context.select<CategoryBloc, List<Category>>(
      (b) => b.state.categories,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterPageTitle),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _stockFilter = StockFilter.all;
                _productSort = ProductSort.default_;
                _priceRange = const PriceRange();
              });
            },
            child: Text(l10n.filterReset),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Text(
                    l10n.filterCategory,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(l10n.allCategories),
                  selected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ListTile(
                  title: Text(l10n.noCategory),
                  selected: _selectedCategory == kNoCategoryFilter,
                  onTap: () =>
                      setState(() => _selectedCategory = kNoCategoryFilter),
                ),
                ...categories.map(
                  (c) => ListTile(
                    title: Text(c.name),
                    selected: _selectedCategory == c.id,
                    onTap: () => setState(() => _selectedCategory = c.id),
                  ),
                ),
                const Divider(),
                // Reuse ticket sheet body sections via nested sheet widget
                // without its sticky CTA — apply from scaffold bottom.
                SizedBox(
                  height: 420,
                  child: _FullPageFilterDraft(
                    stockFilter: _stockFilter,
                    productSort: _productSort,
                    priceRange: _priceRange,
                    currency: widget.currency,
                    lowStockThreshold: widget.lowStockThreshold,
                    onStock: (v) => setState(() => _stockFilter = v),
                    onSort: (v) => setState(() => _productSort = v),
                    onPrice: (v) => setState(() => _priceRange = v),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _applyFullPage,
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    final count = applyProductListFilters(
                      state.products,
                      ProductListFilterSpec(
                        categoryFilter: _selectedCategory,
                        stockFilter: _stockFilter,
                        productSort: _productSort,
                        priceRange: _priceRange.isActive
                            ? _priceRange.normalized()
                            : null,
                        lowStockThreshold: widget.lowStockThreshold,
                        pauseFiltersOnSearch: true,
                        activeOnly: true,
                      ),
                    ).length;
                    return Text(l10n.filterShowResultsCount(count));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal full-page draft controls (radios kept simple for admin route).
class _FullPageFilterDraft extends StatelessWidget {
  const _FullPageFilterDraft({
    required this.stockFilter,
    required this.productSort,
    required this.priceRange,
    required this.currency,
    required this.lowStockThreshold,
    required this.onStock,
    required this.onSort,
    required this.onPrice,
  });

  final StockFilter stockFilter;
  final ProductSort productSort;
  final PriceRange priceRange;
  final String currency;
  final int lowStockThreshold;
  final ValueChanged<StockFilter> onStock;
  final ValueChanged<ProductSort> onSort;
  final ValueChanged<PriceRange> onPrice;

  @override
  Widget build(BuildContext context) {
    // Embed the ticket sheet for visual parity on full page body.
    // Local state is owned by parent via a one-shot approach: use sheet only
    // when asSheet; here keep compact radios for category+filters page.
    final l10n = context.l10n;
    return ListView(
      children: [
        RadioGroup<ProductSort>(
          groupValue: productSort,
          onChanged: (v) {
            if (v != null) onSort(v);
          },
          child: Column(
            children: [
              for (final s in ProductSort.values)
                RadioListTile<ProductSort>(
                  value: s,
                  title: Text(switch (s) {
                    ProductSort.default_ => l10n.sortDefault,
                    ProductSort.nameAsc => l10n.sortNameAsc,
                    ProductSort.priceLowHigh => l10n.sortPriceLowHigh,
                    ProductSort.priceHighLow => l10n.sortPriceHighLow,
                    ProductSort.stockLowHigh => l10n.sortStockLowHigh,
                  }),
                ),
            ],
          ),
        ),
        const Divider(),
        RadioGroup<StockFilter>(
          groupValue: stockFilter,
          onChanged: (v) {
            if (v != null) onStock(v);
          },
          child: Column(
            children: [
              for (final f in StockFilter.values)
                RadioListTile<StockFilter>(
                  value: f,
                  title: Text(switch (f) {
                    StockFilter.all => l10n.filterAll,
                    StockFilter.lowStock => l10n.lowStock,
                    StockFilter.outOfStock => l10n.outOfStock,
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
