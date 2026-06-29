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
    required this.barcodeFocusNode,
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
  final FocusNode barcodeFocusNode;
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
    final currency = context.watch<SettingsCubit>().state.settings.currency;

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
            const SizedBox(height: 20),
            _BasicSection(
              nameCtrl: nameCtrl,
              priceCtrl: priceCtrl,
              currency: currency,
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
              barcodeCtrl: barcodeCtrl,
              barcodeFocusNode: barcodeFocusNode,
              isGeneratingBarcode: isGeneratingBarcode,
              onGenerateBarcode: onGenerateBarcode,
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
              costCtrl: costCtrl,
              currency: currency,
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
    required this.barcodeCtrl,
    required this.barcodeFocusNode,
    required this.isGeneratingBarcode,
    required this.onGenerateBarcode,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final String currency;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final TextEditingController barcodeCtrl;
  final FocusNode barcodeFocusNode;
  final bool isGeneratingBarcode;
  final VoidCallback onGenerateBarcode;

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
          const SizedBox(height: 12),
          _BarcodeField(
            barcodeCtrl: barcodeCtrl,
            barcodeFocusNode: barcodeFocusNode,
            isGeneratingBarcode: isGeneratingBarcode,
            onGenerateBarcode: onGenerateBarcode,
          ),
        ],
      ),
    );
  }
}

class _BarcodeField extends StatelessWidget {
  const _BarcodeField({
    required this.barcodeCtrl,
    required this.barcodeFocusNode,
    required this.isGeneratingBarcode,
    required this.onGenerateBarcode,
  });

  final TextEditingController barcodeCtrl;
  final FocusNode barcodeFocusNode;
  final bool isGeneratingBarcode;
  final VoidCallback onGenerateBarcode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductTextField(
          controller: barcodeCtrl,
          focusNode: barcodeFocusNode,
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
              await showProductBarcodeScanner(
                context,
                beepOnScan: settings.barcodeBeepOnScan,
                formats: barcodeFormatsFromNames(
                  settings.barcodeEnabledFormats,
                ),
                autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
                continuousScan: settings.barcodeContinuousScan,
                onScanned: (barcode) {
                  barcodeCtrl.text = barcode.toUpperCase();
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: isGeneratingBarcode ? null : onGenerateBarcode,
            icon: isGeneratingBarcode
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high_outlined, size: 18),
            label: Text(l10n.generateBarcode),
          ),
        ),
      ],
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
    required this.costCtrl,
    required this.currency,
  });

  final TextEditingController skuCtrl;
  final TextEditingController costCtrl;
  final String currency;

  @override
  State<_AdvancedSection> createState() => _AdvancedSectionState();
}

class _AdvancedSectionState extends State<_AdvancedSection> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded =
        widget.skuCtrl.text.isNotEmpty || widget.costCtrl.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant _AdvancedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_expanded &&
        (widget.skuCtrl.text.isNotEmpty || widget.costCtrl.text.isNotEmpty)) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FormSectionCard(
      icon: Icons.tune_outlined,
      title: l10n.advanced,
      trailing: IconButton(
        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () => setState(() => _expanded = !_expanded),
      ),
      child: _expanded
          ? Column(
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
                  controller: widget.costCtrl,
                  labelText: l10n.costLabel(widget.currency),
                  helperText: l10n.costHelper,
                  icon: Icons.price_change_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
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
            )
          : const SizedBox(width: double.infinity, height: 0),
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

class _StockDialog extends StatefulWidget {
  const _StockDialog({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  @override
  State<_StockDialog> createState() => _StockDialogState();
}

class _StockDialogState extends State<_StockDialog> {
  late final _ctrl = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.quantityLabel),
      content: TextField(
        controller: _ctrl,
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
            final qty = int.tryParse(_ctrl.text);
            if (qty != null && qty >= 0) {
              Navigator.pop(context);
              widget.onChanged(qty);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

void _showStockDialog(
  BuildContext context, {
  required int current,
  required ValueChanged<int> onChanged,
}) {
  showDialog(
    context: context,
    builder: (_) => _StockDialog(current: current, onChanged: onChanged),
  );
}
