import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Shared POS filter choice chip — one visual dialect for sort/stock/price.
class SaleFilterChoiceChip extends StatelessWidget {
  const SaleFilterChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? semanticLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pos.billStubRadius),
          side: BorderSide(
            color: selected ? scheme.primary : pos.billStubBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(pos.billStubRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 6),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SaleFilterSectionLabel extends StatelessWidget {
  const SaleFilterSectionLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

String saleFilterSortLabel(ProductSort sort, AppLocalizations l10n) {
  return switch (sort) {
    ProductSort.default_ => l10n.sortDefault,
    ProductSort.nameAsc => l10n.sortNameAsc,
    ProductSort.priceLowHigh => l10n.sortPriceLowHigh,
    ProductSort.priceHighLow => l10n.sortPriceHighLow,
    ProductSort.stockLowHigh => l10n.sortStockLowHigh,
  };
}

String saleFilterStockLabel(StockFilter filter, AppLocalizations l10n) {
  return switch (filter) {
    StockFilter.all => l10n.filterAll,
    StockFilter.lowStock => l10n.lowStock,
    StockFilter.outOfStock => l10n.outOfStock,
  };
}

/// Primary sorts for POS (3) — no wrap of five long labels.
class SaleFilterSortSegmented extends StatelessWidget {
  const SaleFilterSortSegmented({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = <(ProductSort, String, String)>[
      (ProductSort.default_, l10n.sortChipDefault, l10n.sortDefault),
      (ProductSort.nameAsc, l10n.sortChipName, l10n.sortNameAsc),
      (ProductSort.priceLowHigh, l10n.sortChipPriceAsc, l10n.sortPriceLowHigh),
    ];

    // Legacy priceHighLow / stockLowHigh still highlight closest primary chip.
    bool selectedFor(ProductSort chip) {
      if (value == chip) return true;
      if (chip == ProductSort.priceLowHigh &&
          value == ProductSort.priceHighLow) {
        return true;
      }
      return false;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            SaleFilterChoiceChip(
              label: items[i].$2,
              semanticLabel: items[i].$3,
              selected: selectedFor(items[i].$1),
              onTap: () => onChanged(items[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class SaleFilterStockChips extends StatelessWidget {
  const SaleFilterStockChips({
    super.key,
    required this.value,
    required this.onChanged,
    required this.products,
    required this.lowStockThreshold,
    this.categoryFilter,
    this.searchQuery = '',
  });

  final StockFilter value;
  final ValueChanged<StockFilter> onChanged;
  final List<Product> products;
  final int lowStockThreshold;
  final String? categoryFilter;
  final String searchQuery;

  int _count(StockFilter f) {
    // Same pipeline as preview, excluding the stock dimension being counted.
    final list = applyProductListFilters(
      products,
      ProductListFilterSpec(
        categoryFilter: categoryFilter,
        stockFilter: f,
        searchQuery: searchQuery,
        lowStockThreshold: lowStockThreshold,
        pauseFiltersOnSearch: false,
        activeOnly: true,
      ),
    );
    return list.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget chip(StockFilter f, String label) {
      final count = _count(f);
      return SaleFilterChoiceChip(
        label: label,
        semanticLabel: '$label, $count',
        selected: value == f,
        onTap: () => onChanged(f),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(StockFilter.all, l10n.filterAll),
        chip(StockFilter.lowStock, l10n.lowStock),
        chip(StockFilter.outOfStock, l10n.outOfStock),
      ],
    );
  }
}

class SaleFilterPriceQuickChips extends StatelessWidget {
  const SaleFilterPriceQuickChips({
    super.key,
    required this.currency,
    required this.selected,
    required this.onSelected,
  });

  final String currency;
  final PriceRange selected;
  final ValueChanged<PriceRange> onSelected;

  static final presets = <PriceRange>[
    PriceRange(max: Money.fromDouble(50)),
    PriceRange(min: Money.fromDouble(51), max: Money.fromDouble(100)),
    PriceRange(min: Money.fromDouble(101), max: Money.fromDouble(200)),
    PriceRange(min: Money.fromDouble(201)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.filterPriceQuickUnder50(currency),
      l10n.filterPriceQuick51to100(currency),
      l10n.filterPriceQuick101to200(currency),
      l10n.filterPriceQuickOver200(currency),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < presets.length; i++)
          Builder(
            builder: (context) {
              final preset = presets[i];
              final isOn =
                  selected.isActive &&
                  selected.min == preset.min &&
                  selected.max == preset.max;
              return SaleFilterChoiceChip(
                label: labels[i],
                selected: isOn,
                onTap: () => onSelected(isOn ? const PriceRange() : preset),
              );
            },
          ),
      ],
    );
  }
}

class SaleFilterPriceRangeEditor extends StatefulWidget {
  const SaleFilterPriceRangeEditor({
    super.key,
    required this.priceRange,
    required this.currency,
    required this.onChanged,
  });

  final PriceRange priceRange;
  final String currency;
  final ValueChanged<PriceRange> onChanged;

  @override
  State<SaleFilterPriceRangeEditor> createState() =>
      _SaleFilterPriceRangeEditorState();
}

class _SaleFilterPriceRangeEditorState
    extends State<SaleFilterPriceRangeEditor> {
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  bool _inverted = false;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(
      text: widget.priceRange.min?.value.toStringAsFixed(2) ?? '',
    );
    _maxCtrl = TextEditingController(
      text: widget.priceRange.max?.value.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Money? _parse(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final v = double.tryParse(t);
    if (v == null) return null;
    return Money.fromDouble(v);
  }

  void _emit() {
    final min = _parse(_minCtrl.text);
    final max = _parse(_maxCtrl.text);
    final inverted = min != null && max != null && min > max;
    setState(() => _inverted = inverted);
    widget.onChanged(PriceRange(min: min, max: max));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pos = context.posTheme;

    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      prefixText: widget.currency,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(pos.billStubRadius),
      ),
      isDense: true,
      errorText: _inverted ? l10n.filterPriceOrderHint : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: deco(l10n.filterPriceMin),
                onChanged: (_) => _emit(),
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
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: deco(l10n.filterPriceMax),
                onChanged: (_) => _emit(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
