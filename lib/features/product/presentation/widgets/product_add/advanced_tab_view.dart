import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';

class AdvancedTabView extends StatelessWidget {
  const AdvancedTabView({
    super.key,
    required this.barcodeCtrl,
    required this.skuCtrl,
    required this.costCtrl,
    required this.trackStock,
    required this.currency,
    required this.onMarkDirty,
    required this.onScanBarcode,
    required this.onGenerateBarcode,
    required this.onTrackStockChanged,
  });

  final TextEditingController barcodeCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController costCtrl;
  final bool trackStock;
  final String currency;
  final VoidCallback onMarkDirty;
  final VoidCallback onScanBarcode;
  final VoidCallback onGenerateBarcode;
  final ValueChanged<bool> onTrackStockChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 420;
        final barcodeField = ProductTextField(
          controller: barcodeCtrl,
          labelText: l10n.barcodeLabel,
          helperText: l10n.barcodeHelper,
          icon: Icons.qr_code_scanner_outlined,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onMarkDirty(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
              return l10n.invalidBarcode;
            }
            return null;
          },
          suffix: IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: l10n.scanBarcode,
            onPressed: onScanBarcode,
          ),
        );
        final skuField = ProductTextField(
          controller: skuCtrl,
          labelText: l10n.skuLabel,
          helperText: l10n.skuHelper,
          icon: Icons.tag_outlined,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onMarkDirty(),
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (useTwoColumns)
                Row(
                  children: [
                    Expanded(child: barcodeField),
                    const SizedBox(width: 12),
                    Expanded(child: skuField),
                  ],
                )
              else ...[
                barcodeField,
                const SizedBox(height: 10),
                skuField,
              ],
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onGenerateBarcode,
                  icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
                  label: Text(l10n.generateBarcode),
                ),
              ),
              const SizedBox(height: 10),
              ProductTextField(
                controller: costCtrl,
                labelText: l10n.costLabel(currency),
                icon: Icons.price_change_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.done,
                onChanged: (_) => onMarkDirty(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return l10n.invalidPrice;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: trackStock,
                onChanged: onTrackStockChanged,
                title: Text(l10n.trackStock),
                subtitle: Text(l10n.trackStockHint),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }
}
