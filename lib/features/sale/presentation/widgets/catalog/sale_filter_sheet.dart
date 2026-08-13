import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_sheet_sections.dart';

/// Compact POS filter sheet — live apply, stock-first, no e-com draft theater.
///
/// Category stays on horizontal chips. Material handle from [PosBottomSheet] only.
class SaleFilterSheet extends StatefulWidget {
  const SaleFilterSheet({
    super.key,
    this.currency = '฿',
    this.lowStockThreshold = 5,
  });

  final String currency;
  final int lowStockThreshold;

  @override
  State<SaleFilterSheet> createState() => _SaleFilterSheetState();
}

class _SaleFilterSheetState extends State<SaleFilterSheet> {
  late StockFilter _stockFilter;
  late ProductSort _productSort;
  late PriceRange _priceRange;
  bool _customPriceOpen = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProductBloc>().state;
    _stockFilter = state.stockFilter;
    _productSort = state.productSort;
    _priceRange = state.priceRange ?? const PriceRange();
    // Open custom editor if range is active but not a preset.
    _customPriceOpen = _priceRange.isActive && !_isPreset(_priceRange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  static bool _isPreset(PriceRange r) {
    for (final p in SaleFilterPriceQuickChips.presets) {
      if (r.min == p.min && r.max == p.max) return true;
    }
    return false;
  }

  ProductListFilterSpec _spec(ProductState live) {
    return ProductListFilterSpec(
      categoryFilter: live.categoryFilter,
      stockFilter: _stockFilter,
      productSort: _productSort,
      priceRange: _priceRange.isActive ? _priceRange.normalized() : null,
      searchQuery: live.searchQuery,
      lowStockThreshold: widget.lowStockThreshold,
      pauseFiltersOnSearch: false,
      activeOnly: true,
    );
  }

  int _previewCount(ProductState live) =>
      applyProductListFilters(live.products, _spec(live)).length;

  /// Live-apply stock/sort/price so catalog behind the sheet updates immediately.
  /// Debounced 300ms to avoid jank on rapid filter changes with large catalogs.
  void _commitLive() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final range = _priceRange.isActive ? _priceRange.normalized() : null;
      context.read<ProductBloc>().add(
        ProductListFiltersApplied(
          stockFilter: _stockFilter,
          productSort: _productSort,
          priceRange: range,
        ),
      );
    });
  }

  void _setStock(StockFilter v) {
    setState(() => _stockFilter = v);
    _commitLive();
  }

  void _setSort(ProductSort v) {
    setState(() => _productSort = v);
    _commitLive();
  }

  void _setPrice(PriceRange v, {bool fromCustom = false}) {
    setState(() {
      _priceRange = v;
      if (!fromCustom && v.isActive) _customPriceOpen = false;
    });
    _commitLive();
  }

  void _clearAll() {
    HapticFeedback.selectionClick();
    setState(() {
      _stockFilter = StockFilter.all;
      _productSort = ProductSort.default_;
      _priceRange = const PriceRange();
      _customPriceOpen = false;
    });
    _commitLive();
  }

  bool get _hasActiveFilters =>
      _stockFilter != StockFilter.all ||
      _productSort != ProductSort.default_ ||
      _priceRange.isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: title + live count + clear + close
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    buildWhen: (p, c) =>
                        p.products != c.products ||
                        p.categoryFilter != c.categoryFilter ||
                        p.searchQuery != c.searchQuery ||
                        p.stockFilter != c.stockFilter ||
                        p.productSort != c.productSort ||
                        p.priceRange != c.priceRange,
                    builder: (context, state) {
                      // Prefer live bloc state for count after commit; local
                      // draft used for in-flight before emit settles.
                      final count = _previewCount(state);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.filterPageTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.filterRemainingCount(count),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: _hasActiveFilters ? _clearAll : null,
                  child: Text(l10n.filterReset),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          // Content — single scroll owner (keyboard-safe)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1) Stock first (POS primary job)
                  SaleFilterSectionLabel(title: l10n.filterStock),
                  const SizedBox(height: 8),
                  BlocBuilder<ProductBloc, ProductState>(
                    buildWhen: (p, c) =>
                        p.products != c.products ||
                        p.categoryFilter != c.categoryFilter ||
                        p.searchQuery != c.searchQuery,
                    builder: (context, state) {
                      return SaleFilterStockChips(
                        value: _stockFilter,
                        lowStockThreshold: widget.lowStockThreshold,
                        products: state.products,
                        categoryFilter: state.categoryFilter,
                        searchQuery: state.searchQuery,
                        onChanged: _setStock,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 2) Price presets (custom behind expansion)
                  SaleFilterSectionLabel(title: l10n.filterPriceRange),
                  const SizedBox(height: 8),
                  SaleFilterPriceQuickChips(
                    currency: widget.currency,
                    selected: _customPriceOpen
                        ? const PriceRange()
                        : _priceRange,
                    onSelected: (range) => _setPrice(range),
                  ),
                  const SizedBox(height: 4),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _customPriceOpen,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 4),
                      title: Text(
                        l10n.filterPriceCustom,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onExpansionChanged: (open) {
                        setState(() => _customPriceOpen = open);
                      },
                      children: [
                        SaleFilterPriceRangeEditor(
                          key: ValueKey(
                            'custom_${_priceRange.min?.satang}_${_priceRange.max?.satang}',
                          ),
                          priceRange: _priceRange,
                          currency: widget.currency,
                          onChanged: (range) =>
                              _setPrice(range, fromCustom: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 3) Sort last (secondary)
                  SaleFilterSectionLabel(title: l10n.filterSort),
                  const SizedBox(height: 8),
                  SaleFilterSortSegmented(
                    value: _productSort,
                    onChanged: _setSort,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Done = dismiss only (filters already live)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(pos.ctaMinHeight),
                  // Teal primary — not Pay orange (ctaFill reserved for money CTAs).
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(pos.billStubRadius),
                  ),
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  // Ensure latest draft committed (e.g. custom price still typing).
                  _commitLive();
                  Navigator.pop(context);
                },
                child: Text(l10n.filterDone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
