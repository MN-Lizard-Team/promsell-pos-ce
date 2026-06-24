import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_edit_tab_view/category_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductInfoTab extends StatelessWidget {
  const ProductInfoTab({
    super.key,
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
    final theme = Theme.of(context);
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
                CategoryField(
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

Future<void> _generateBarcode(
  BuildContext context,
  TextEditingController barcodeCtrl,
) async {
  final l10n = context.l10n;
  final settings = context.read<SettingsCubit>().state.settings;
  final prefix = settings.barcodeAutoGeneratePrefix;
  try {
    final generateBarcode = sl<GenerateBarcode>();
    final barcode = await generateBarcode(prefix: prefix);
    if (!context.mounted) return;
    barcodeCtrl.text = barcode;
    AppSnackBar.success(context, l10n.barcodeGenerated);
  } catch (_) {
    if (context.mounted) AppSnackBar.error(context, l10n.errorOccurred);
  }
}
