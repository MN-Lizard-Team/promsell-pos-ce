import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/stable_listenable_builder.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/stock_status_resolver.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_shared.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

/// Stock-tab widgets extracted from [ProductFormView].

class ProductFormStockQuantitySection extends StatelessWidget {
  const ProductFormStockQuantitySection({
    super.key,
    required this.stockCtrl,
    required this.unitCtrl,
    required this.trackStock,
    required this.isEditing,
    required this.lowStockThreshold,
    required this.onStockChanged,
    required this.onAdjustStock,
  });

  final TextEditingController stockCtrl;
  final TextEditingController unitCtrl;
  final bool trackStock;
  final bool isEditing;
  final int lowStockThreshold;
  final ValueChanged<int> onStockChanged;
  final VoidCallback onAdjustStock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (!trackStock) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.stockTrackingDisabled,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }

    return StableListenableBuilder(
      listenables: [stockCtrl, unitCtrl],
      builder: (context, _) {
        final stock = int.tryParse(stockCtrl.text) ?? 0;
        final unit = unitCtrl.text.trim();
        final unitLabel = unit.isEmpty ? l10n.quantityLabel : unit;
        final qtyText = CurrencyFormatter.formatGroupedInt(stock);
        final status = resolveStockStatus(
          trackStock: true,
          stock: stock,
          lowStockThreshold: lowStockThreshold,
          l10n: l10n,
          cs: cs,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.quantityLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: qtyText,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' $unitLabel',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('product-form-adjust-stock'),
                    onPressed: onAdjustStock,
                    icon: const Icon(Icons.tune_outlined),
                    label: Text(l10n.adjustStock),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.editStockAdjustHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  StockStepper(
                    value: stock,
                    onChanged: onStockChanged,
                    onQtyTap: () => showStockDialog(
                      context,
                      current: stock,
                      onChanged: onStockChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      unitLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ProductFormStockStatusBanner(
              status: status,
              lowStockThreshold: lowStockThreshold,
            ),
          ],
        );
      },
    );
  }
}

class ProductFormStockStatusBanner extends StatelessWidget {
  const ProductFormStockStatusBanner({
    super.key,
    required this.status,
    required this.lowStockThreshold,
  });

  final ResolvedStockStatus status;
  final int lowStockThreshold;

  Future<void> _editThreshold(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          ProductFormLowStockThresholdSheet(initial: lowStockThreshold),
    );
    if (result == null || !context.mounted) return;
    if (result == lowStockThreshold) return;
    cubit.updateField((s) => s.copyWith(lowStockThreshold: result));
    AppSnackBar.success(context, l10n.lowStockThresholdSaved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final thresholdHint = l10n.lowStockThresholdHint(lowStockThreshold);

    return Material(
      color: status.containerColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: const ValueKey('product-form-stock-status'),
        onTap: () => _editThreshold(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: status.color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(status.icon, size: 20, color: status.onContainerColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.productPreviewStatus}: ${status.label}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: status.onContainerColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      thresholdHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.onContainerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.tune, size: 18, color: status.onContainerColor),
              const SizedBox(width: 2),
              Text(
                l10n.editLowStockThreshold,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: status.onContainerColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edit app-wide low-stock threshold (same setting as Stock settings page).
class ProductFormLowStockThresholdSheet extends StatefulWidget {
  const ProductFormLowStockThresholdSheet({super.key, required this.initial});

  final int initial;

  @override
  State<ProductFormLowStockThresholdSheet> createState() =>
      ProductFormLowStockThresholdSheetState();
}

class ProductFormLowStockThresholdSheetState
    extends State<ProductFormLowStockThresholdSheet> {
  late final TextEditingController _ctrl;
  late int _value;

  static const _presets = [3, 5, 10, 20];

  @override
  void initState() {
    super.initState();
    _value = widget.initial.clamp(1, 100);
    _ctrl = TextEditingController(text: '$_value');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setValue(int n) {
    final v = n.clamp(1, 100);
    setState(() {
      _value = v;
      _ctrl.text = '$v';
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.lowStockThreshold,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.lowStockThresholdHint(_value),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _ctrl,
              labelText: l10n.lowStockThreshold,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              onChanged: (t) {
                final n = int.tryParse(t.trim());
                if (n != null) setState(() => _value = n.clamp(1, 100));
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _presets)
                  ChoiceChip(
                    label: Text(
                      '$p',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _value == p ? cs.onPrimary : cs.onSurface,
                      ),
                    ),
                    selected: _value == p,
                    selectedColor: cs.primary,
                    backgroundColor: cs.surface,
                    side: BorderSide(
                      color: _value == p ? cs.primary : cs.outline,
                    ),
                    showCheckmark: false,
                    onSelected: (_) => _setValue(p),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.outline),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('low-stock-threshold-save'),
                    onPressed: () {
                      final n = int.tryParse(_ctrl.text.trim()) ?? _value;
                      Navigator.pop(context, n.clamp(1, 100));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onWarning,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only inventory value: cost · sale · potential profit.
class ProductFormStockValueCard extends StatelessWidget {
  const ProductFormStockValueCard({
    super.key,
    required this.priceCtrl,
    required this.costCtrl,
    required this.stockCtrl,
    required this.currency,
  });

  final TextEditingController priceCtrl;
  final TextEditingController costCtrl;
  final TextEditingController stockCtrl;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StableListenableBuilder(
      listenables: [priceCtrl, costCtrl, stockCtrl],
      builder: (context, _) {
        final price = double.tryParse(priceCtrl.text) ?? 0;
        final cost = double.tryParse(costCtrl.text) ?? 0;
        final stock = int.tryParse(stockCtrl.text) ?? 0;
        if (stock <= 0) return const SizedBox.shrink();

        final stockValue = cost * stock;
        final saleValue = price * stock;
        final potentialProfit = (price - cost) * stock;
        final profitColor = potentialProfit >= 0 ? cs.tertiary : cs.error;

        return FormSectionCard(
          key: const ValueKey('product-form-stock-value'),
          title: l10n.stockInventoryValueTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cost > 0) ...[
                ProductFormStockValueRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.productPreviewStockValue,
                  value: CurrencyFormatter.formatGroupedWithSymbol(
                    stockValue,
                    currency,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ProductFormStockValueRow(
                icon: Icons.point_of_sale_outlined,
                label: l10n.productPreviewStockValueSale,
                value: CurrencyFormatter.formatGroupedWithSymbol(
                  saleValue,
                  currency,
                ),
              ),
              if (cost > 0) ...[
                const SizedBox(height: 8),
                ProductFormStockValueRow(
                  icon: Icons.trending_up_outlined,
                  label: l10n.productPreviewPotentialProfit,
                  value: CurrencyFormatter.formatGroupedWithSymbol(
                    potentialProfit,
                    currency,
                  ),
                  valueColor: profitColor,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ProductFormStockValueRow extends StatelessWidget {
  const ProductFormStockValueRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}
