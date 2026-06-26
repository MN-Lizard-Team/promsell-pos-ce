import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/category_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductFormView extends StatelessWidget {
  const ProductFormView({
    super.key,
    required this.formKey,
    required this.product,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.costCtrl,
    required this.selectedCategory,
    required this.imageUrl,
    required this.imagePath,
    required this.isActive,
    required this.trackStock,
    required this.isPickingImage,
    required this.isGeneratingBarcode,
    required this.onCategoryChanged,
    required this.onImageTap,
    required this.onTrackStockChanged,
    required this.onActiveChanged,
    required this.onStockChanged,
    required this.onGenerateBarcode,
  });

  final GlobalKey<FormState> formKey;
  final Product? product;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController costCtrl;
  final Category? selectedCategory;
  final String? imageUrl;
  final String? imagePath;
  final bool isActive;
  final bool trackStock;
  final bool isPickingImage;
  final bool isGeneratingBarcode;
  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onImageTap;
  final ValueChanged<bool> onTrackStockChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<int> onStockChanged;
  final VoidCallback onGenerateBarcode;

  bool get isEditing => product != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final hasImage = imagePath != null || imageUrl != null;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductHeroImage(
              imagePath: imagePath,
              imageUrl: imageUrl,
              categoryName: selectedCategory?.name,
              isLoading: isPickingImage,
              onTap: onImageTap,
            ),
            if (!hasImage) ...[
              const SizedBox(height: 8),
              Text(
                l10n.imageHelper,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _BasicSection(
              nameCtrl: nameCtrl,
              priceCtrl: priceCtrl,
              currency: currency,
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: 16),
            _StockSection(
              stockCtrl: stockCtrl,
              trackStock: trackStock,
              onStockChanged: onStockChanged,
              onTrackStockChanged: onTrackStockChanged,
            ),
            const SizedBox(height: 16),
            _AdvancedSection(
              skuCtrl: skuCtrl,
              barcodeCtrl: barcodeCtrl,
              costCtrl: costCtrl,
              currency: currency,
              isGeneratingBarcode: isGeneratingBarcode,
              onGenerateBarcode: onGenerateBarcode,
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              _VisibilitySection(
                isActive: isActive,
                onActiveChanged: onActiveChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BasicSection extends StatelessWidget {
  const _BasicSection({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.currency,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final String currency;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormSectionCard(
      icon: Icons.badge_outlined,
      title: l10n.productFormSectionBasicInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductTextField(
            controller: nameCtrl,
            labelText: l10n.productNameLabel,
            icon: Icons.badge_outlined,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? l10n.productNameRequired
                : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          CategoryField(
            selectedCategory: selectedCategory,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 12),
          ProductTextField(
            controller: priceCtrl,
            labelText: l10n.priceLabel(currency),
            icon: Icons.sell_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.priceRequired;
              }
              final parsed = double.tryParse(value);
              if (parsed == null) {
                return l10n.invalidPrice;
              }
              if (parsed <= 0) {
                return l10n.priceMustBePositive;
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}

class _StockSection extends StatelessWidget {
  const _StockSection({
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
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return FormSectionCard(
      icon: Icons.inventory_2_outlined,
      title: l10n.quantityLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trackStock)
            StockStepper(
              value: int.tryParse(stockCtrl.text) ?? 0,
              onChanged: onStockChanged,
              onQtyTap: () => _showStockDialog(
                context,
                current: int.tryParse(stockCtrl.text) ?? 0,
                onChanged: onStockChanged,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.stockTrackingDisabled,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 12),
          ModernToggleCard(
            icon: Icons.inventory_2,
            title: l10n.trackStock,
            subtitle: l10n.trackStockHint,
            value: trackStock,
            onChanged: onTrackStockChanged,
          ),
        ],
      ),
    );
  }
}

class _AdvancedSection extends StatefulWidget {
  const _AdvancedSection({
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.costCtrl,
    required this.currency,
    required this.isGeneratingBarcode,
    required this.onGenerateBarcode,
  });

  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController costCtrl;
  final String currency;
  final bool isGeneratingBarcode;
  final VoidCallback onGenerateBarcode;

  @override
  State<_AdvancedSection> createState() => _AdvancedSectionState();
}

class _AdvancedSectionState extends State<_AdvancedSection> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded =
        widget.skuCtrl.text.isNotEmpty ||
        widget.barcodeCtrl.text.isNotEmpty ||
        widget.costCtrl.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;

    return FormSectionCard(
      icon: Icons.tune_outlined,
      title: l10n.advanced,
      trailing: IconButton(
        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () => setState(() => _expanded = !_expanded),
      ),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _expanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox(width: double.infinity),
        secondChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductTextField(
              controller: widget.skuCtrl,
              labelText: l10n.skuLabel,
              helperText: l10n.skuHelper,
              icon: Icons.qr_code,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            ProductTextField(
              controller: widget.barcodeCtrl,
              labelText: l10n.barcodeLabel,
              helperText: l10n.barcodeHelper,
              icon: Icons.qr_code_scanner,
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
                onPressed: () async {
                  final result = await showProductBarcodeScanner(
                    context,
                    beepOnScan: settings.barcodeBeepOnScan,
                    formats: barcodeFormatsFromNames(
                      settings.barcodeEnabledFormats,
                    ),
                    autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
                  );
                  if (result != null && result.isNotEmpty) {
                    widget.barcodeCtrl.text = result;
                  }
                },
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.isGeneratingBarcode
                    ? null
                    : widget.onGenerateBarcode,
                icon: widget.isGeneratingBarcode
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_fix_high_outlined, size: 18),
                label: Text(l10n.generateBarcode),
              ),
            ),
            const SizedBox(height: 12),
            ProductTextField(
              controller: widget.costCtrl,
              labelText: l10n.costLabel(widget.currency),
              icon: Icons.price_change_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return l10n.invalidPrice;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilitySection extends StatelessWidget {
  const _VisibilitySection({
    required this.isActive,
    required this.onActiveChanged,
  });

  final bool isActive;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return FormSectionCard(
      icon: Icons.visibility_outlined,
      title: l10n.productVisibility,
      child: ModernToggleCard(
        icon: Icons.visibility,
        title: l10n.showProduct,
        value: isActive,
        onChanged: onActiveChanged,
        activeColor: theme.colorScheme.primary,
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
  ).then((_) => ctrl.dispose());
}
