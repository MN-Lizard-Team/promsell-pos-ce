import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

Future<ProductOption?> showOptionEditSheet(
  BuildContext context, {
  ProductOption? existing,
}) {
  return showModalBottomSheet<ProductOption>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _OptionEditSheet(existing: existing),
  );
}

class _OptionEditSheet extends StatefulWidget {
  const _OptionEditSheet({this.existing});

  final ProductOption? existing;

  @override
  State<_OptionEditSheet> createState() => _OptionEditSheetState();
}

class _OptionEditSheetState extends State<_OptionEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existing?.priceDelta.value.toStringAsFixed(2) ?? '0.00',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    if (name.length > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.optionNameTooLong)));
      return;
    }
    final priceText = _priceCtrl.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;
    // Validate priceDelta: reject NaN/Infinity, limit to 2 decimals,
    // and cap absolute value to a reasonable maximum.
    if (price.isNaN || price.isInfinite) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.optionPriceInvalid)));
      return;
    }
    if ((price * 100).roundToDouble() / 100 != price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.optionPriceTooManyDecimals)),
      );
      return;
    }
    if (price.abs() > 999999.99) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.optionPriceTooLarge)));
      return;
    }
    final base =
        widget.existing ??
        ProductOption(id: IdGenerator.newId(), groupId: '', name: name);
    Navigator.pop(
      context,
      base.copyWith(name: name, priceDelta: Money.fromDouble(price)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currency = context.read<SettingsCubit>().state.settings.currency;
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
              isEdit ? l10n.editOption : l10n.addOption,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameCtrl,
              labelText: l10n.optionName,
              hintText: l10n.optionNameHint,
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _priceCtrl,
              labelText: l10n.optionPriceDelta,
              hintText: l10n.optionPriceDeltaHint,
              helperText: l10n.optionPriceDeltaHelper,
              suffixText: currency,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
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
