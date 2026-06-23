import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/danger_zone_card.dart';
import 'package:promsell_pos_ce/core/widgets/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/stock_stepper.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart'
    show parseCategoryColor, parseCategoryIcon;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_picker_bottom_sheet.dart';
import 'package:promsell_pos_ce/core/widgets/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_hero_image.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductEditTabView extends StatelessWidget {
  const ProductEditTabView({
    super.key,
    required this.product,
    required this.formKey,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.costCtrl,
    required this.selectedCategory,
    required this.imagePath,
    required this.imageUrl,
    required this.isActive,
    required this.trackStock,
    required this.isPickingImage,
    required this.onCategoryChanged,
    required this.onImageTap,
    required this.onActiveChanged,
    required this.onTrackStockChanged,
    required this.onStockChanged,
    required this.onDelete,
  });

  final Product? product;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController costCtrl;
  final Category? selectedCategory;
  final String? imagePath;
  final String? imageUrl;
  final bool isActive;
  final bool trackStock;
  final bool isPickingImage;
  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onImageTap;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onTrackStockChanged;
  final ValueChanged<int> onStockChanged;
  final VoidCallback onDelete;

  bool get isEditing => product != null;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Form(
      key: formKey,
      child: TabBarView(
        children: [
          _InfoTab(
            nameCtrl: nameCtrl,
            skuCtrl: skuCtrl,
            barcodeCtrl: barcodeCtrl,
            selectedCategory: selectedCategory,
            imagePath: imagePath,
            imageUrl: imageUrl,
            categoryName: selectedCategory?.name,
            isPickingImage: isPickingImage,
            onImageTap: onImageTap,
            onCategoryChanged: onCategoryChanged,
          ),
          _PricingTab(
            priceCtrl: priceCtrl,
            costCtrl: costCtrl,
            currency: currency,
          ),
          _StockTab(
            stockCtrl: stockCtrl,
            trackStock: trackStock,
            onStockChanged: onStockChanged,
            onTrackStockChanged: onTrackStockChanged,
          ),
          _SettingsTab(
            isActive: isActive,
            isEditing: isEditing,
            onActiveChanged: onActiveChanged,
            onDelete: onDelete,
            productName: product?.name ?? '',
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.nameCtrl,
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.selectedCategory,
    required this.imagePath,
    required this.imageUrl,
    required this.categoryName,
    required this.isPickingImage,
    required this.onImageTap,
    required this.onCategoryChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final Category? selectedCategory;
  final String? imagePath;
  final String? imageUrl;
  final String? categoryName;
  final bool isPickingImage;
  final VoidCallback onImageTap;
  final ValueChanged<Category?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductHeroImage(
            imagePath: imagePath,
            imageUrl: imageUrl,
            categoryName: categoryName,
            isLoading: isPickingImage,
            onTap: onImageTap,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.imageHelper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FormSectionCard(
            icon: Icons.badge_outlined,
            title: context.l10n.productFormSectionBasicInfo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductTextField(
                  controller: nameCtrl,
                  labelText: context.l10n.productNameLabel,
                  icon: Icons.badge_outlined,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? context.l10n.productNameRequired
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _CategoryField(
                  selectedCategory: selectedCategory,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: 12),
                ProductTextField(
                  controller: skuCtrl,
                  labelText: context.l10n.skuLabel,
                  helperText: context.l10n.skuHelper,
                  icon: Icons.qr_code,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                ProductTextField(
                  controller: barcodeCtrl,
                  labelText: context.l10n.barcodeLabel,
                  helperText: context.l10n.barcodeHelper,
                  icon: Icons.qr_code_scanner,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
                      return context.l10n.invalidBarcode;
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: context.l10n.scanBarcode,
                    onPressed: () async {
                      final settings = context
                          .read<SettingsCubit>()
                          .state
                          .settings;
                      final result = await showProductBarcodeScanner(
                        context,
                        beepOnScan: settings.barcodeBeepOnScan,
                        formats: barcodeFormatsFromNames(
                          settings.barcodeEnabledFormats,
                        ),
                        autoOpenManualDelay:
                            settings.barcodeAutoOpenManualDelay,
                      );
                      if (result != null && result.isNotEmpty) {
                        barcodeCtrl.text = result;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _generateBarcode(context, barcodeCtrl),
                    icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
                    label: Text(context.l10n.generateBarcode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.selectedCategory,
    required this.onChanged,
  });

  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _pickCategory(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: parseCategoryColor(
                  selectedCategory?.color,
                ).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                parseCategoryIcon(selectedCategory?.iconName),
                size: 16,
                color: parseCategoryColor(selectedCategory?.color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCategory?.name ?? context.l10n.noCategorySelected,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: selectedCategory == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _pickCategory(BuildContext context) async {
    final result = await showCategoryPicker(
      context,
      selectedId: selectedCategory?.id,
      showNoneOption: true,
    );
    if (result != null || selectedCategory != null) {
      onChanged(result);
    }
  }
}

class _PricingTab extends StatelessWidget {
  const _PricingTab({
    required this.priceCtrl,
    required this.costCtrl,
    required this.currency,
  });

  final TextEditingController priceCtrl;
  final TextEditingController costCtrl;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FormSectionCard(
        icon: Icons.sell_outlined,
        title: context.l10n.priceLabel(currency),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductTextField(
              controller: priceCtrl,
              labelText: context.l10n.priceLabel(currency),
              icon: Icons.sell_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.priceRequired;
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return context.l10n.invalidPrice;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ProductTextField(
              controller: costCtrl,
              labelText: context.l10n.costLabel(currency),
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
                  return context.l10n.invalidPrice;
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

class _StockTab extends StatelessWidget {
  const _StockTab({
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.isActive,
    required this.isEditing,
    required this.onActiveChanged,
    required this.onDelete,
    required this.productName,
  });

  final bool isActive;
  final bool isEditing;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onDelete;
  final String productName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isEditing)
            FormSectionCard(
              icon: Icons.settings_outlined,
              title: context.l10n.settingsTitle,
              child: ModernToggleCard(
                icon: Icons.visibility,
                title: context.l10n.showProduct,
                value: isActive,
                onChanged: onActiveChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (isEditing) ...[
            const SizedBox(height: 16),
            DangerZoneCard(
              icon: Icons.delete_outline,
              title: context.l10n.deleteProduct,
              subtitle: context.l10n.confirmDeleteProduct(productName),
              actionLabel: context.l10n.delete,
              onAction: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _generateBarcode(
  BuildContext context,
  TextEditingController barcodeCtrl,
) async {
  final l10n = context.l10n;
  final prefix =
      GetIt.I<SettingsCubit>().state.settings.barcodeAutoGeneratePrefix;
  try {
    final barcode = await GetIt.I<GenerateBarcode>()(prefix: prefix);
    if (!context.mounted) return;
    barcodeCtrl.text = barcode;
    AppSnackBar.success(context, l10n.barcodeGenerated);
  } catch (_) {
    if (context.mounted) AppSnackBar.error(context, l10n.errorOccurred);
  }
}
