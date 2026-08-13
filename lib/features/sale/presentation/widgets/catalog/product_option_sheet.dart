import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductOptionSheet extends StatefulWidget {
  const ProductOptionSheet({
    required this.product,
    required this.onConfirm,
    super.key,
  });

  final Product product;
  final void Function(List<SelectedProductOption> options) onConfirm;

  static void show(
    BuildContext context, {
    required Product product,
    required void Function(List<SelectedProductOption> options) onConfirm,
  }) {
    // Modal routes sit under MaterialApp; re-provide SettingsCubit so tests
    // (and any navigator that isn't under the root app provider) still work.
    final settingsCubit = context.read<SettingsCubit>();
    PosBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: settingsCubit,
        child: ProductOptionSheet(product: product, onConfirm: onConfirm),
      ),
    );
  }

  @override
  State<ProductOptionSheet> createState() => _ProductOptionSheetState();
}

class _ProductOptionSheetState extends State<ProductOptionSheet> {
  final Map<String, Set<String>> _selected = {};

  bool get _allRequiredSatisfied {
    for (final group in widget.product.optionGroups) {
      if (group.isRequired && !_selected.containsKey(group.id)) return false;
    }
    return true;
  }

  void _toggleOption(ProductOptionGroup group, ProductOption option) {
    setState(() {
      if (group.selectionType == OptionSelectionType.single) {
        _selected[group.id] = {option.id};
      } else {
        final current = _selected[group.id] ?? {};
        if (current.contains(option.id)) {
          current.remove(option.id);
          if (current.isEmpty) {
            _selected.remove(group.id);
          }
        } else {
          current.add(option.id);
          _selected[group.id] = current;
        }
      }
    });
  }

  List<SelectedProductOption> _buildSelected() {
    final result = <SelectedProductOption>[];
    for (final group in widget.product.optionGroups) {
      final selectedIds = _selected[group.id];
      if (selectedIds == null) continue;
      for (final opt in group.options) {
        if (selectedIds.contains(opt.id)) {
          result.add(
            SelectedProductOption(
              optionId: opt.id,
              optionName: opt.name,
              groupId: group.id,
              groupName: group.name,
              priceDelta: opt.priceDelta,
            ),
          );
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currency = context.read<SettingsCubit>().state.settings.currency;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Material handle from PosBottomSheet — no hand-drawn bar.
            Text(
              l10n.optionsFor(widget.product.name),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.product.optionGroups.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final group = widget.product.optionGroups[index];
                  return _OptionGroupSection(
                    group: group,
                    currency: currency,
                    selectedIds: _selected[group.id] ?? {},
                    onToggle: (opt) => _toggleOption(group, opt),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Price summary — base + options = total.
            _PriceSummary(
              basePrice: widget.product.price,
              selected: _buildSelected(),
              currency: currency,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _allRequiredSatisfied
                  ? () {
                      Navigator.pop(context);
                      widget.onConfirm(_buildSelected());
                    }
                  : null,
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionGroupSection extends StatelessWidget {
  const _OptionGroupSection({
    required this.group,
    required this.currency,
    required this.selectedIds,
    required this.onToggle,
  });

  final ProductOptionGroup group;
  final String currency;
  final Set<String> selectedIds;
  final void Function(ProductOption) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              group.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (group.isRequired)
              Text(
                '*${l10n.optionRequired}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else
              Text(
                l10n.optionOptional,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const Spacer(),
            Text(
              group.selectionType == OptionSelectionType.multiple
                  ? l10n.optionSelectionMultiple
                  : l10n.optionSelectionSingle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (group.selectionType == OptionSelectionType.single)
          RadioGroup<String>(
            groupValue: selectedIds.isNotEmpty ? selectedIds.first : null,
            onChanged: (v) {
              if (v == null) return;
              final opt = group.options.where((o) => o.id == v).firstOrNull;
              if (opt != null) onToggle(opt);
            },
            child: Column(
              children: [
                for (final option in group.options)
                  ListTile(
                    leading: Radio<String>(value: option.id),
                    title: Text(option.name),
                    subtitle: option.priceDelta.isPositive
                        ? Text(
                            '+$currency ${option.priceDelta.value.toStringAsFixed(2)}',
                          )
                        : null,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        if (group.selectionType == OptionSelectionType.multiple)
          for (final option in group.options)
            CheckboxListTile(
              value: selectedIds.contains(option.id),
              onChanged: (_) => onToggle(option),
              title: Text(option.name),
              subtitle: option.priceDelta.isPositive
                  ? Text(
                      '+$currency ${option.priceDelta.value.toStringAsFixed(2)}',
                    )
                  : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
      ],
    );
  }
}

/// Sticky price summary: Base + Options = Total.
class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.basePrice,
    required this.selected,
    required this.currency,
  });
  final Money basePrice;
  final List<SelectedProductOption> selected;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final optionsTotal = selected.fold<double>(
      0,
      (sum, o) => sum + o.priceDelta.value,
    );
    final total = basePrice.value + optionsTotal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.basePrice}: $currency ${basePrice.value.toStringAsFixed(2)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (optionsTotal > 0)
                  Text(
                    '${l10n.optionsLabel}: +$currency ${optionsTotal.toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '$currency ${total.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
