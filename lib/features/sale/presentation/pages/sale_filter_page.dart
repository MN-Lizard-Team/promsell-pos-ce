import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

class SaleFilterPage extends StatefulWidget {
  const SaleFilterPage({super.key, this.currency = '฿'});

  final String currency;

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

  int _filteredCount(List<Product> products) {
    var result = products.where((p) => p.isActive).toList();
    if (_selectedCategory != null) {
      if (_selectedCategory == kNoCategoryFilter) {
        result = result.where((p) => p.categoryId == null).toList();
      } else {
        result = result
            .where((p) => p.categoryId == _selectedCategory)
            .toList();
      }
    }
    if (_stockFilter == StockFilter.lowStock) {
      result = result
          .where((p) => p.trackStock && p.stock > 0 && p.stock <= 5)
          .toList();
    } else if (_stockFilter == StockFilter.outOfStock) {
      result = result.where((p) => p.trackStock && p.stock == 0).toList();
    }
    if (_priceRange.min != null) {
      result = result.where((p) => p.price >= _priceRange.min!).toList();
    }
    if (_priceRange.max != null) {
      result = result.where((p) => p.price <= _priceRange.max!).toList();
    }
    return result.length;
  }

  void _applyFilters() {
    final bloc = context.read<ProductBloc>();
    bloc.add(ProductCategoryFilterChanged(_selectedCategory));
    bloc.add(ProductStockFilterChanged(_stockFilter));
    bloc.add(ProductSortChanged(_productSort));
    bloc.add(
      ProductPriceRangeChanged(_priceRange.isActive ? _priceRange : null),
    );
    Navigator.of(context).pop();
  }

  void _resetAll() {
    setState(() {
      _selectedCategory = null;
      _stockFilter = StockFilter.all;
      _productSort = ProductSort.default_;
      _priceRange = const PriceRange();
    });
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _stockFilter != StockFilter.all ||
      _productSort != ProductSort.default_ ||
      _priceRange.isActive;

  List<Widget> _activeFilterChips(AppLocalizations l10n, List categories) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    if (_selectedCategory != null) {
      final name = _selectedCategory == kNoCategoryFilter
          ? l10n.noCategory
          : categories
                    .where((c) => c.id == _selectedCategory)
                    .map((c) => c.name)
                    .firstOrNull ??
                l10n.allCategories;
      chips.add(
        _summaryChip(
          theme,
          name,
          () => setState(() => _selectedCategory = null),
        ),
      );
    }
    if (_stockFilter != StockFilter.all) {
      chips.add(
        _summaryChip(
          theme,
          _stockLabel(_stockFilter, l10n),
          () => setState(() => _stockFilter = StockFilter.all),
        ),
      );
    }
    if (_productSort != ProductSort.default_) {
      chips.add(
        _summaryChip(
          theme,
          _sortLabel(_productSort, l10n),
          () => setState(() => _productSort = ProductSort.default_),
        ),
      );
    }
    if (_priceRange.isActive) {
      final label =
          '${_priceRange.min?.toStringAsFixed(0) ?? ''} - ${_priceRange.max?.toStringAsFixed(0) ?? ''}';
      chips.add(
        _summaryChip(
          theme,
          label,
          () => setState(() => _priceRange = const PriceRange()),
        ),
      );
    }
    return chips;
  }

  Widget _summaryChip(ThemeData theme, String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = context.watch<CategoryBloc>().state.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterPageTitle),
        actions: [
          TextButton(onPressed: _resetAll, child: Text(l10n.filterReset)),
        ],
      ),
      body: Column(
        children: [
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _activeFilterChips(l10n, categories),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SectionTitle(title: l10n.filterCategory),
                _CategorySelector(
                  categories: categories,
                  selectedId: _selectedCategory,
                  onSelected: (id) => setState(() => _selectedCategory = id),
                ),
                const Divider(height: 32),
                _SectionTitle(title: l10n.filterSort),
                RadioGroup<ProductSort>(
                  groupValue: _productSort,
                  onChanged: (v) =>
                      setState(() => _productSort = v ?? ProductSort.default_),
                  child: Column(
                    children: ProductSort.values
                        .map(
                          (sort) => _RadioList<ProductSort>(
                            value: sort,
                            label: _sortLabel(sort, l10n),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(height: 32),
                _SectionTitle(title: l10n.filterStock),
                RadioGroup<StockFilter>(
                  groupValue: _stockFilter,
                  onChanged: (v) =>
                      setState(() => _stockFilter = v ?? StockFilter.all),
                  child: Column(
                    children: StockFilter.values
                        .map(
                          (filter) => _RadioList<StockFilter>(
                            value: filter,
                            label: _stockLabel(filter, l10n),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(height: 32),
                _SectionTitle(title: l10n.filterPriceRange),
                _PriceRangeEditor(
                  priceRange: _priceRange,
                  currency: widget.currency,
                  onChanged: (range) => setState(() => _priceRange = range),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: BlocBuilder<ProductBloc, ProductState>(
                buildWhen: (prev, curr) => prev.products != curr.products,
                builder: (ctx, state) {
                  return FilledButton(
                    onPressed: _applyFilters,
                    child: Text(
                      l10n.filterShowResultsCount(
                        _filteredCount(state.products),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(ProductSort sort, AppLocalizations l10n) {
    return switch (sort) {
      ProductSort.default_ => l10n.sortDefault,
      ProductSort.nameAsc => l10n.sortNameAsc,
      ProductSort.priceLowHigh => l10n.sortPriceLowHigh,
      ProductSort.priceHighLow => l10n.sortPriceHighLow,
      ProductSort.stockLowHigh => l10n.sortStockLowHigh,
    };
  }

  String _stockLabel(StockFilter filter, AppLocalizations l10n) {
    return switch (filter) {
      StockFilter.all => l10n.filterAll,
      StockFilter.lowStock => l10n.lowStock,
      StockFilter.outOfStock => l10n.outOfStock,
    };
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _RadioList<T> extends StatelessWidget {
  const _RadioList({required this.value, required this.label, this.count});

  final T value;
  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioListTile<T>(
      value: value,
      title: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _PriceRangeEditor extends StatefulWidget {
  const _PriceRangeEditor({
    required this.priceRange,
    required this.currency,
    required this.onChanged,
  });

  final PriceRange priceRange;
  final String currency;
  final ValueChanged<PriceRange> onChanged;

  @override
  State<_PriceRangeEditor> createState() => _PriceRangeEditorState();
}

class _PriceRangeEditorState extends State<_PriceRangeEditor> {
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(
      text: widget.priceRange.min?.toStringAsFixed(2) ?? '',
    );
    _maxCtrl = TextEditingController(
      text: widget.priceRange.max?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _onPriceRangeChanged() {
    final min = double.tryParse(_minCtrl.text);
    final max = double.tryParse(_maxCtrl.text);
    if (min != null && max != null && min > max) {
      widget.onChanged(PriceRange(min: max, max: min));
    } else {
      widget.onChanged(PriceRange(min: min, max: max));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.filterPriceMin,
                prefixText: widget.currency,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _onPriceRangeChanged(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('—', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            child: TextField(
              controller: _maxCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.filterPriceMax,
                prefixText: widget.currency,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _onPriceRangeChanged(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final allTiles = <Widget>[
      _categoryTile(
        theme: theme,
        label: l10n.allCategories,
        icon: Icons.apps,
        iconColor: theme.colorScheme.primary,
        selected: selectedId == null,
        onTap: () => onSelected(null),
      ),
      _categoryTile(
        theme: theme,
        label: l10n.noCategory,
        icon: Icons.block_outlined,
        iconColor: theme.colorScheme.onSurfaceVariant,
        selected: selectedId == kNoCategoryFilter,
        onTap: () => onSelected(kNoCategoryFilter),
      ),
      ...categories.map(
        (c) => _categoryTile(
          theme: theme,
          label: c.name,
          icon: Icons.label_outline,
          iconColor: theme.colorScheme.primary,
          selected: selectedId == c.id,
          onTap: () => onSelected(c.id),
        ),
      ),
    ];

    return Column(
      children: allTiles
          .map(
            (tile) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: tile,
            ),
          )
          .toList(),
    );
  }

  Widget _categoryTile({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      selected: selected,
    );
  }
}
