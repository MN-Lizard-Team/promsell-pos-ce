import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_item_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_total_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartPanel extends StatefulWidget {
  const CartPanel({
    super.key,
    required this.expanded,
    this.sizePreset,
    this.onSizePresetChanged,
    this.widthPreset,
    this.onWidthPresetChanged,
  });

  final bool expanded;
  final double? sizePreset;
  final ValueChanged<double>? onSizePresetChanged;
  final double? widthPreset;
  final ValueChanged<double>? onWidthPresetChanged;

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<String> _selectedProductIds = {};
  bool _isSelecting = false;
  bool _isFlatView = false;

  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
        if (_selectedProductIds.isEmpty) {
          _isSelecting = false;
        }
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _enterSelectionMode(String productId) {
    HapticFeedback.selectionClick();
    setState(() {
      _isSelecting = true;
      _selectedProductIds.clear();
      _selectedProductIds.add(productId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelecting = false;
      _selectedProductIds.clear();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isThai(String text) {
    final thaiRegex = RegExp(r'[\u0E00-\u0E7F]');
    return thaiRegex.hasMatch(text);
  }

  List<CartItem> _filterItems(List<CartItem> items) {
    if (_query.isEmpty) return items;
    final lower = _query.toLowerCase();
    return items
        .where((i) => i.product.name.toLowerCase().contains(lower))
        .toList();
  }

  Map<String, List<CartItem>> _groupByCategory(List<CartItem> items) {
    final groups = <String, List<CartItem>>{};
    final fallback = context.l10n.noCategory;
    for (final item in items) {
      final key = item.product.category?.isNotEmpty == true
          ? item.product.category!
          : fallback;
      groups.putIfAbsent(key, () => []).add(item);
    }
    final sortedKeys = groups.keys.toList()..sort();
    return {for (final k in sortedKeys) k: groups[k]!};
  }

  Widget _buildGroupedList(List<CartItem> items, String currency) {
    final groups = _groupByCategory(items);
    final settings = context.watch<SettingsCubit>().state.settings;
    final compact = settings.cartCompactMode;
    final ultraCompact = settings.ultraCompactMode;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: groups.values.fold<int>(0, (sum, g) => sum + g.length + 1),
      itemBuilder: (_, index) {
        var current = 0;
        for (final entry in groups.entries) {
          final headerIndex = current;
          final itemStart = current + 1;
          final itemEnd = itemStart + entry.value.length;
          if (index == headerIndex) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isThai(entry.key) ? entry.key : entry.key.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: _isThai(entry.key) ? 0.0 : 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${entry.value.length})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          if (index >= itemStart && index < itemEnd) {
            final item = entry.value[index - itemStart];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CartItemRow(
                item: item,
                currency: currency,
                compact: compact,
                ultraCompact: ultraCompact,
                isSelecting: _isSelecting,
                isSelected: _selectedProductIds.contains(item.product.id),
                onTap: () => _toggleSelection(item.product.id),
                onLongPress: () => _enterSelectionMode(item.product.id),
              ),
            );
          }
          current = itemEnd;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFlatReorderableList(List<CartItem> items, String currency) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final compact = settings.cartCompactMode;
    final ultraCompact = settings.ultraCompactMode;
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final reordered = List<CartItem>.from(items);
        final moved = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, moved);
        context.read<SaleBloc>().add(
          SaleCartItemsReordered(reordered.map((i) => i.product.id).toList()),
        );
      },
      itemBuilder: (_, index) {
        final item = items[index];
        return Padding(
          key: ValueKey(item.product.id),
          padding: const EdgeInsets.only(bottom: 8),
          child: CartItemRow(
            item: item,
            currency: currency,
            compact: compact,
            ultraCompact: ultraCompact,
            isSelecting: _isSelecting,
            isSelected: _selectedProductIds.contains(item.product.id),
            onTap: () => _toggleSelection(item.product.id),
            onLongPress: () => _enterSelectionMode(item.product.id),
            dragHandleIndex: _isSelecting ? null : index,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (prev, curr) => curr.status == SaleStatus.success,
      listener: (ctx, state) {
        final settings = ctx.read<SettingsCubit>().state.settings;
        if (settings.autoPrintPrompt && state.lastSale != null) {
          final sale = state.lastSale!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) SaleReceiptDialog.show(ctx, sale, settings);
          });
        } else {
          AppSnackBar.success(ctx, ctx.l10n.saleSavedSuccess);
          ctx.read<SaleBloc>().add(const SaleReset());
        }
      },
      child: BlocBuilder<SaleBloc, SaleState>(
        builder: (ctx, state) {
          if (state.isEmpty && _isSelecting) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _exitSelectionMode();
            });
          }

          final items = _filterItems(state.items);
          final showSearch = state.items.length > 5;

          final content = Card(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartHeader(
                  state: state,
                  expanded: widget.expanded,
                  sizePreset: widget.sizePreset,
                  onSizePresetChanged: widget.onSizePresetChanged,
                  widthPreset: widget.widthPreset,
                  onWidthPresetChanged: widget.onWidthPresetChanged,
                ),
                if (showSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: context.l10n.searchCartItems,
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        if (_query.isEmpty)
                          IconButton(
                            icon: Icon(
                              _isFlatView ? Icons.folder_outlined : Icons.list,
                              size: 20,
                            ),
                            tooltip: _isFlatView
                                ? context.l10n.groupView
                                : context.l10n.listView,
                            onPressed: () =>
                                setState(() => _isFlatView = !_isFlatView),
                          ),
                      ],
                    ),
                  ),
                if (state.isEmpty)
                  Expanded(
                    child: AppEmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: ctx.l10n.tapProductToAdd,
                    ),
                  )
                else if (items.isEmpty)
                  Expanded(
                    child: AppEmptyState(
                      icon: Icons.search_off,
                      title: context.l10n.noMatchingItems,
                    ),
                  )
                else ...[
                  Expanded(
                    child: _query.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, index) {
                              final item = items[index];
                              return Dismissible(
                                key: ValueKey(item.product.id),
                                direction: DismissDirection.horizontal,
                                confirmDismiss: (direction) async {
                                  final bloc = ctx.read<SaleBloc>();
                                  final allowOversell = ctx
                                      .read<SettingsCubit>()
                                      .state
                                      .settings
                                      .allowOversell;
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    bloc.add(
                                      SaleItemQtyChanged(
                                        productId: item.product.id,
                                        qty: 0,
                                        allowOversell: allowOversell,
                                      ),
                                    );
                                    AppSnackBar.withAction(
                                      ctx,
                                      ctx.l10n.itemRemoved,
                                      actionLabel: ctx.l10n.undo,
                                      onAction: () => bloc.add(
                                        SaleCartRestored(
                                          items: [...bloc.state.items, item],
                                        ),
                                      ),
                                    );
                                  } else {
                                    bloc.add(
                                      SaleItemQtyChanged(
                                        productId: item.product.id,
                                        qty: item.qty + 1,
                                        allowOversell: allowOversell,
                                      ),
                                    );
                                  }
                                  return false;
                                },
                                background: Container(
                                  color: Theme.of(
                                    ctx,
                                  ).colorScheme.errorContainer,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Icon(
                                    Icons.delete,
                                    color: Theme.of(ctx).colorScheme.error,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Theme.of(
                                    ctx,
                                  ).colorScheme.primaryContainer,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.add,
                                    color: Theme.of(ctx).colorScheme.primary,
                                  ),
                                ),
                                child: CartItemRow(
                                  item: item,
                                  currency: currency,
                                  compact: context
                                      .watch<SettingsCubit>()
                                      .state
                                      .settings
                                      .cartCompactMode,
                                  ultraCompact: context
                                      .watch<SettingsCubit>()
                                      .state
                                      .settings
                                      .ultraCompactMode,
                                  isSelecting: _isSelecting,
                                  isSelected: _selectedProductIds.contains(
                                    item.product.id,
                                  ),
                                  onTap: () =>
                                      _toggleSelection(item.product.id),
                                  onLongPress: () =>
                                      _enterSelectionMode(item.product.id),
                                ),
                              );
                            },
                          )
                        : _isFlatView
                        ? _buildFlatReorderableList(items, currency)
                        : _buildGroupedList(items, currency),
                  ),
                  _isSelecting
                      ? _buildBulkActionsBar(ctx)
                      : CartTotalBar(state: state, currency: currency),
                ],
              ],
            ),
          );

          return content;
        },
      ),
    );
  }

  Widget _buildBulkActionsBar(BuildContext context) {
    final theme = Theme.of(context);
    final count = _selectedProductIds.length;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        12,
        14,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.bulkSelected(count),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: count > 0
                ? () {
                    context.read<SaleBloc>().add(
                      SaleBulkItemDiscountsCleared(
                        _selectedProductIds.toList(),
                      ),
                    );
                    _exitSelectionMode();
                  }
                : null,
            icon: const Icon(Icons.money_off, size: 18),
            label: Text(context.l10n.bulkClearDiscount),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: count > 0
                ? () {
                    context.read<SaleBloc>().add(
                      SaleBulkItemsRemoved(_selectedProductIds.toList()),
                    );
                    _exitSelectionMode();
                  }
                : null,
            icon: const Icon(Icons.delete, size: 18),
            label: Text(context.l10n.bulkDelete),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _exitSelectionMode,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
