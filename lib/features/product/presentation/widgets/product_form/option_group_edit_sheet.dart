import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

Future<ProductOptionGroup?> showOptionGroupEditSheet(
  BuildContext context, {
  ProductOptionGroup? existing,
}) {
  return showModalBottomSheet<ProductOptionGroup>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _OptionGroupEditSheet(existing: existing),
  );
}

class _OptionGroupEditSheet extends StatefulWidget {
  const _OptionGroupEditSheet({this.existing});

  final ProductOptionGroup? existing;

  @override
  State<_OptionGroupEditSheet> createState() => _OptionGroupEditSheetState();
}

class _OptionGroupEditSheetState extends State<_OptionGroupEditSheet> {
  late final TextEditingController _nameCtrl;
  late OptionSelectionType _selectionType;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _selectionType =
        widget.existing?.selectionType ?? OptionSelectionType.single;
    _isRequired = widget.existing?.isRequired ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final base =
        widget.existing ??
        ProductOptionGroup(id: IdGenerator.newId(), productId: '', name: name);
    Navigator.pop(
      context,
      base.copyWith(
        name: name,
        selectionType: _selectionType,
        isRequired: _isRequired,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isEdit = widget.existing != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? l10n.editOptionGroup : l10n.addOptionGroup,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameCtrl,
              labelText: l10n.optionGroupName,
              hintText: l10n.optionGroupNameHint,
              autofocus: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            Text(l10n.optionSelectionType, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
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
              selected: {_selectionType},
              onSelectionChanged: (v) =>
                  setState(() => _selectionType = v.first),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.optionRequired),
              value: _isRequired,
              onChanged: (v) => setState(() => _isRequired = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: _save, child: Text(l10n.save)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
