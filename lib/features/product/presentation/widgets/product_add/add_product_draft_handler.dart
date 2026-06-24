import 'dart:io';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddProductDraftHandler {
  AddProductDraftHandler({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.costCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController costCtrl;

  Map<String, dynamic> collectDraft({
    required Category? selectedCategory,
    required String? imagePath,
    required String? imageThumbnailPath,
    required bool trackStock,
  }) {
    return {
      'name': nameCtrl.text,
      'price': priceCtrl.text,
      'stock': stockCtrl.text,
      'sku': skuCtrl.text,
      'barcode': barcodeCtrl.text,
      'cost': costCtrl.text,
      'categoryId': selectedCategory?.id,
      'categoryName': selectedCategory?.name,
      'imagePath': imagePath,
      'imageThumbnailPath': imageThumbnailPath,
      'trackStock': trackStock,
    };
  }

  void restoreDraft(
    BuildContext context,
    Map<String, dynamic> draft, {
    required void Function(Category? category) onCategoryRestored,
    required void Function(String? imagePath, String? thumbnailPath)
    onImageRestored,
    required void Function(bool trackStock) onTrackStockRestored,
    required VoidCallback onSetState,
  }) {
    nameCtrl.text = draft['name'] as String? ?? '';
    priceCtrl.text = draft['price'] as String? ?? '';
    stockCtrl.text = draft['stock'] as String? ?? '0';
    skuCtrl.text = draft['sku'] as String? ?? '';
    barcodeCtrl.text = draft['barcode'] as String? ?? '';
    costCtrl.text = draft['cost'] as String? ?? '';

    final catId = draft['categoryId'] as String?;
    final catName = draft['categoryName'] as String?;
    if (catId != null && catName != null) {
      onCategoryRestored(
        Category(
          id: catId,
          name: catName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    final draftImagePath = draft['imagePath'] as String?;
    final draftThumbPath = draft['imageThumbnailPath'] as String?;
    if (draftImagePath != null && File(draftImagePath).existsSync()) {
      onImageRestored(draftImagePath, draftThumbPath);
    } else if (draftImagePath != null) {
      onImageRestored(null, null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          AppSnackBar.info(context, context.l10n.imageNotFound);
        }
      });
    }

    onTrackStockRestored(draft['trackStock'] as bool? ?? true);
    onSetState();
  }

  void showRestoreDialog(
    BuildContext context,
    Map<String, dynamic> draft, {
    required VoidCallback onRestore,
    required VoidCallback onDiscard,
  }) {
    final l10n = context.l10n;
    final name = draft['name'] as String?;
    final price = double.tryParse(draft['price'] as String? ?? '');
    final categoryName = draft['categoryName'] as String?;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreDraft),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null && name.isNotEmpty)
              Text('${l10n.productNameLabel}: $name'),
            if (price != null)
              Text('${l10n.priceLabel('')}: ${price.toStringAsFixed(2)}'),
            if (categoryName != null && categoryName.isNotEmpty)
              Text('${l10n.categoryLabel}: $categoryName'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              onDiscard();
              Navigator.pop(ctx);
            },
            child: Text(l10n.discardDraft),
          ),
          FilledButton(
            onPressed: () {
              onRestore();
              Navigator.pop(ctx);
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }

  Future<bool> onWillPop(
    BuildContext context, {
    required bool isDirty,
    required bool submitted,
    required VoidCallback onDiscard,
  }) async {
    if (!isDirty || submitted) return true;

    final l10n = context.l10n;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveDraft),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: Text(l10n.discardDraft),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text(l10n.saveDraft),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (result == 'save') {
      if (context.mounted) {
        context.read<AddProductDraftCubit>().saveDraft(
          collectDraft(
            selectedCategory: null,
            imagePath: null,
            imageThumbnailPath: null,
            trackStock: true,
          ),
        );
      }
      return true;
    } else if (result == 'discard') {
      onDiscard();
      if (context.mounted) {
        context.read<AddProductDraftCubit>().clearDraft();
      }
      return true;
    }
    return false;
  }
}
