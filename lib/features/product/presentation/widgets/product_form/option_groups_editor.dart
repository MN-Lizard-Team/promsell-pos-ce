import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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

  void _addGroup() async {
    final group = await _showGroupDialog();
    if (group == null) return;
    setState(() => _groups.add(group));
    _notify();
  }

  void _editGroup(int index) async {
    final group = await _showGroupDialog(existing: _groups[index]);
    if (group == null) return;
    setState(() => _groups[index] = group);
    _notify();
  }

  void _deleteGroup(int index) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteOptionGroup),
        content: Text(l10n.confirmDeleteOptionGroup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteOptionGroup),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _groups.removeAt(index));
    _notify();
  }

  void _addOption(int groupIndex) async {
    final option = await _showOptionDialog();
    if (option == null) return;
    setState(() {
      _groups[groupIndex] = _groups[groupIndex].copyWith(
        options: [..._groups[groupIndex].options, option],
      );
    });
    _notify();
  }

  void _editOption(int groupIndex, int optionIndex) async {
    final option = await _showOptionDialog(
      existing: _groups[groupIndex].options[optionIndex],
    );
    if (option == null) return;
    setState(() {
      final opts = List.of(_groups[groupIndex].options);
      opts[optionIndex] = option;
      _groups[groupIndex] = _groups[groupIndex].copyWith(options: opts);
    });
    _notify();
  }

  void _deleteOption(int groupIndex, int optionIndex) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteOption),
        content: Text(l10n.confirmDeleteOption),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteOption),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      final opts = List.of(_groups[groupIndex].options);
      opts.removeAt(optionIndex);
      _groups[groupIndex] = _groups[groupIndex].copyWith(options: opts);
    });
    _notify();
  }

  Future<ProductOptionGroup?> _showGroupDialog({
    ProductOptionGroup? existing,
  }) async {
    final l10n = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var selectionType = existing?.selectionType ?? OptionSelectionType.single;
    var isRequired = existing?.isRequired ?? false;

    return showDialog<ProductOptionGroup>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            existing == null ? l10n.addOptionGroup : l10n.editOptionGroup,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.optionGroupName,
                  hintText: l10n.optionGroupNameHint,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(l10n.optionSelectionType),
                    const SizedBox(width: 12),
                    SegmentedButton<OptionSelectionType>(
                      segments: [
                        ButtonSegment(
                          value: OptionSelectionType.single,
                          label: Text(l10n.optionSelectionSingle),
                        ),
                        ButtonSegment(
                          value: OptionSelectionType.multiple,
                          label: Text(l10n.optionSelectionMultiple),
                        ),
                      ],
                      selected: {selectionType},
                      onSelectionChanged: (v) =>
                          setState(() => selectionType = v.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(l10n.optionRequired),
                value: isRequired,
                onChanged: (v) => setState(() => isRequired = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                  ctx,
                  (existing ??
                          ProductOptionGroup(
                            id: IdGenerator.newId(),
                            productId: '',
                            name: name,
                          ))
                      .copyWith(
                        name: name,
                        selectionType: selectionType,
                        isRequired: isRequired,
                      ),
                );
              },
              child: Text(MaterialLocalizations.of(ctx).saveButtonLabel),
            ),
          ],
        ),
      ),
    );
  }

  Future<ProductOption?> _showOptionDialog({ProductOption? existing}) async {
    final l10n = context.l10n;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing?.priceDelta.toStringAsFixed(2) ?? '0.00',
    );

    return showDialog<ProductOption>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.addOption : l10n.editOption),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.optionName,
                hintText: l10n.optionNameHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: InputDecoration(
                labelText: l10n.optionPriceDelta,
                hintText: l10n.optionPriceDeltaHint,
                border: const OutlineInputBorder(),
                prefixText: '${_currencySymbol()} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              Navigator.pop(
                ctx,
                (existing ??
                        ProductOption(
                          id: IdGenerator.newId(),
                          groupId: '',
                          name: name,
                        ))
                    .copyWith(name: name, priceDelta: price),
              );
            },
            child: Text(MaterialLocalizations.of(ctx).saveButtonLabel),
          ),
        ],
      ),
    );
  }

  String _currencySymbol() {
    final settings = context.read<SettingsCubit>().state.settings;
    return settings.currency;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FormSectionCard(
      icon: Icons.tune_outlined,
      title: l10n.optionGroups,
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
              icon: const Icon(Icons.add),
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
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.editOptionGroup),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 18),
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
                      if (group.options[i].priceDelta > 0)
                        Text(
                          '+$currency ${group.options[i].priceDelta.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => onEditOption(i),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
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
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addOption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
