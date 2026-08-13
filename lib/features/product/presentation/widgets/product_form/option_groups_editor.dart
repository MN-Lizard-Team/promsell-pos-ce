import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/option_edit_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/option_group_edit_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class OptionGroupsEditor extends StatefulWidget {
  const OptionGroupsEditor({
    required this.initialGroups,
    required this.onChanged,
    super.key,
  });

  final List<ProductOptionGroup> initialGroups;
  final ValueChanged<List<ProductOptionGroup>> onChanged;

  @override
  State<OptionGroupsEditor> createState() => _OptionGroupsEditorState();
}

class _OptionGroupsEditorState extends State<OptionGroupsEditor> {
  late List<ProductOptionGroup> _groups;

  @override
  void initState() {
    super.initState();
    _groups = List.of(widget.initialGroups);
  }

  void _notify() => widget.onChanged(List.of(_groups));

  Future<void> _addGroup() async {
    final group = await showOptionGroupEditSheet(context);
    if (group == null || !mounted) return;
    setState(() => _groups.add(group));
    _notify();
  }

  Future<void> _editGroup(int index) async {
    final group = await showOptionGroupEditSheet(
      context,
      existing: _groups[index],
    );
    if (group == null || !mounted) return;
    setState(() => _groups[index] = group);
    _notify();
  }

  Future<void> _deleteGroup(int index) async {
    final l10n = context.l10n;
    final name = _groups[index].name;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.deleteOptionGroup,
      message: l10n.confirmDeleteOptionGroup,
      detail: name.isNotEmpty ? name : null,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
      confirmIcon: TablerIcons.trash,
    );
    if (!confirmed || !mounted) return;
    setState(() => _groups.removeAt(index));
    _notify();
  }

  Future<void> _addOption(int groupIndex) async {
    final option = await showOptionEditSheet(context);
    if (option == null || !mounted) return;
    setState(() {
      _groups[groupIndex] = _groups[groupIndex].copyWith(
        options: [..._groups[groupIndex].options, option],
      );
    });
    _notify();
  }

  Future<void> _editOption(int groupIndex, int optionIndex) async {
    final option = await showOptionEditSheet(
      context,
      existing: _groups[groupIndex].options[optionIndex],
    );
    if (option == null || !mounted) return;
    setState(() {
      final opts = List.of(_groups[groupIndex].options);
      opts[optionIndex] = option;
      _groups[groupIndex] = _groups[groupIndex].copyWith(options: opts);
    });
    _notify();
  }

  Future<void> _deleteOption(int groupIndex, int optionIndex) async {
    final l10n = context.l10n;
    final name = _groups[groupIndex].options[optionIndex].name;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.deleteOption,
      message: l10n.confirmDeleteOption,
      detail: name.isNotEmpty ? name : null,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
      confirmIcon: TablerIcons.trash,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      final opts = List.of(_groups[groupIndex].options);
      opts.removeAt(optionIndex);
      _groups[groupIndex] = _groups[groupIndex].copyWith(options: opts);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FormSectionCard(
      title: l10n.optionGroups,
      subtitle: l10n.optionGroupsSubtitle,
      trailing: _groups.isEmpty
          ? null
          : Text(
              '${_groups.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.noOptionGroups,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (int i = 0; i < _groups.length; i++) ...[
            _GroupCard(
              group: _groups[i],
              onEdit: () => _editGroup(i),
              onDelete: () => _deleteGroup(i),
              onAddOption: () => _addOption(i),
              onEditOption: (j) => _editOption(i, j),
              onDeleteOption: (j) => _deleteOption(i, j),
            ),
            if (i < _groups.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: _addGroup,
              icon: const Icon(TablerIcons.plus),
              label: Text(l10n.addOptionGroup),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onAddOption,
    required this.onEditOption,
    required this.onDeleteOption,
  });

  final ProductOptionGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddOption;
  final void Function(int) onEditOption;
  final void Function(int) onDeleteOption;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.read<SettingsCubit>().state.settings.currency;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (group.isRequired)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      label: Text(
                        l10n.optionRequired,
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                Chip(
                  label: Text(
                    group.selectionType == OptionSelectionType.multiple
                        ? l10n.optionSelectionMultiple
                        : l10n.optionSelectionSingle,
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(TablerIcons.dotsVertical, size: 20),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(TablerIcons.edit, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.editOptionGroup),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(TablerIcons.trash, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.deleteOptionGroup),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (group.options.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (int i = 0; i < group.options.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(group.options[i].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (group.options[i].priceDelta > Money.zero)
                        Text(
                          '+$currency ${group.options[i].priceDelta.value.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      IconButton(
                        icon: const Icon(TablerIcons.edit, size: 18),
                        onPressed: () => onEditOption(i),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(TablerIcons.trash, size: 18),
                        onPressed: () => onDeleteOption(i),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddOption,
                icon: const Icon(TablerIcons.plus, size: 18),
                label: Text(l10n.addOption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
