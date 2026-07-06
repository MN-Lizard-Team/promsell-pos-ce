import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ProductOptionSheet(product: product, onConfirm: onConfirm),
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                    subtitle: option.priceDelta > 0
                        ? Text(
                            '+$currency ${option.priceDelta.toStringAsFixed(2)}',
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
              subtitle: option.priceDelta > 0
                  ? Text('+$currency ${option.priceDelta.toStringAsFixed(2)}')
                  : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
      ],
    );
  }
}
