import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';

class ProductStockTab extends StatelessWidget {
  const ProductStockTab({
    super.key,
    required this.stockCtrl,
    required this.trackStock,
    required this.onStockChanged,
    required this.onTrackStockChanged,
  });

  final TextEditingController stockCtrl;
  final bool trackStock;
  final ValueChanged<int> onStockChanged;
  final ValueChanged<bool> onTrackStockChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trackStock)
            FormSectionCard(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.quantityLabel,
              child: StockStepper(
                value: int.tryParse(stockCtrl.text) ?? 0,
                onChanged: onStockChanged,
                onQtyTap: () => _showStockDialog(
                  context,
                  current: int.tryParse(stockCtrl.text) ?? 0,
                  onChanged: onStockChanged,
                ),
              ),
            )
          else
            FormSectionCard(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.quantityLabel,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  context.l10n.stockTrackingDisabled,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ModernToggleCard(
            icon: Icons.inventory_2,
            title: context.l10n.trackStock,
            subtitle: context.l10n.trackStockHint,
            value: trackStock,
            onChanged: onTrackStockChanged,
          ),
        ],
      ),
    );
  }
}

void _showStockDialog(
  BuildContext context, {
  required int current,
  required ValueChanged<int> onChanged,
}) {
  final ctrl = TextEditingController(text: '$current');
  final l10n = context.l10n;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.quantityLabel),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(labelText: l10n.quantityLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final qty = int.tryParse(ctrl.text);
            if (qty != null && qty >= 0) {
              Navigator.pop(context);
              onChanged(qty);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
