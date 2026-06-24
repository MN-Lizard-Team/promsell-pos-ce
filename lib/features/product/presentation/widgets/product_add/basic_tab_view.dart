import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_form_avatar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';

class BasicTabView extends StatelessWidget {
  const BasicTabView({
    super.key,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.imagePath,
    required this.isPickingImage,
    required this.trackStock,
    required this.selectedCategory,
    required this.currency,
    required this.onMarkDirty,
    required this.onImageTap,
    required this.onPickCategory,
    required this.onStockChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final String? imagePath;
  final bool isPickingImage;
  final bool trackStock;
  final Category? selectedCategory;
  final String currency;
  final VoidCallback onMarkDirty;
  final VoidCallback onImageTap;
  final VoidCallback onPickCategory;
  final ValueChanged<String> onStockChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final l10n = context.l10n;
        final useTwoColumns = constraints.maxWidth >= 420;
        final priceField = ProductTextField(
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
            if (parsed == null || parsed < 0) {
              return l10n.invalidPrice;
            }
            return null;
          },
          onChanged: (_) => onMarkDirty(),
        );
        final stockField = ProductTextField(
          controller: stockCtrl,
          labelText: l10n.quantityLabel,
          icon: Icons.inventory_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          helperText: (int.tryParse(stockCtrl.text) ?? -1) == 0
              ? l10n.stockZeroWarning
              : null,
          onChanged: (_) {
            onMarkDirty();
            onStockChanged(stockCtrl.text);
          },
          validator: (value) {
            if (!trackStock) return null;
            if (value == null || value.isEmpty) {
              return l10n.quantityRequired;
            }
            if (int.tryParse(value) == null) {
              return l10n.invalidQuantity;
            }
            return null;
          },
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ProductFormAvatar(
                    imagePath: imagePath,
                    isLoading: isPickingImage,
                    onTap: onImageTap,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.addProductTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.imageHelper,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ProductTextField(
                controller: nameCtrl,
                labelText: l10n.productNameLabel,
                icon: Icons.badge_outlined,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.productNameRequired
                    : null,
                textInputAction: TextInputAction.next,
                onChanged: (_) => onMarkDirty(),
              ),
              const SizedBox(height: 10),
              if (trackStock) ...[
                if (useTwoColumns)
                  Row(
                    children: [
                      Expanded(child: priceField),
                      const SizedBox(width: 12),
                      Expanded(child: stockField),
                    ],
                  )
                else ...[
                  priceField,
                  const SizedBox(height: 10),
                  stockField,
                ],
              ] else ...[
                priceField,
              ],
              const SizedBox(height: 10),
              _CategoryField(
                selectedCategory: selectedCategory,
                onTap: onPickCategory,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.selectedCategory, required this.onTap});

  final Category? selectedCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCategory?.name ?? l10n.noCategorySelected,
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
}
