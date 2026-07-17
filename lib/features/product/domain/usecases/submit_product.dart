import 'dart:io';

import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';

class SubmitProductInput {
  const SubmitProductInput({
    required this.isEditing,
    required this.name,
    required this.priceText,
    required this.stock,
    required this.sku,
    required this.barcode,
    required this.costText,
    required this.selectedCategory,
    required this.categoryWasChanged,
    required this.imageUrl,
    required this.imagePath,
    required this.imageThumbnailPath,
    required this.isActive,
    required this.trackStock,
    required this.description,
    required this.brand,
    required this.unit,
    required this.supplier,
    required this.isRecommended,
    required this.optionGroups,
    this.existingProduct,
    this.latestProduct,
  });

  final bool isEditing;
  final String name;
  final String priceText;
  final int stock;
  final String? sku;
  final String? barcode;
  final String costText;
  final Category? selectedCategory;
  final bool categoryWasChanged;
  final String? imageUrl;
  final String? imagePath;
  final String? imageThumbnailPath;
  final bool isActive;
  final bool trackStock;
  final String description;
  final String brand;
  final String unit;
  final String supplier;
  final bool isRecommended;
  final List<ProductOptionGroup> optionGroups;
  final Product? existingProduct;
  final Product? latestProduct;
}

class SubmitProductUseCase {
  ProductEvent? call(SubmitProductInput input) {
    final price = double.tryParse(input.priceText);
    if (price == null) return null;

    final cost = double.tryParse(input.costText);
    final sku = input.sku?.trim().isEmpty == true ? null : input.sku?.trim();
    final barcode = input.barcode?.trim().isEmpty == true
        ? null
        : input.barcode?.trim();
    final description = input.description.trim().isEmpty
        ? null
        : input.description.trim();
    final brand = input.brand.trim().isEmpty ? null : input.brand.trim();
    final unit = input.unit.trim().isEmpty ? null : input.unit.trim();
    final supplier = input.supplier.trim().isEmpty
        ? null
        : input.supplier.trim();

    String? imagePath = input.imagePath;
    String? imageThumbnailPath = input.imageThumbnailPath;
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        !File(imagePath).existsSync()) {
      imagePath = null;
      imageThumbnailPath = null;
      AppLogger.warning(
        'Image file not found at submit, clearing path: ${input.imagePath}',
      );
    }

    if (input.isEditing) {
      final base = input.latestProduct ?? input.existingProduct!;
      // Normalize empty id (picker "none" sentinel) to null so copyWith
      // actually clears categoryId instead of writing "".
      final rawCategoryId = input.categoryWasChanged
          ? input.selectedCategory?.id
          : base.categoryId;
      final categoryId = (rawCategoryId == null || rawCategoryId.isEmpty)
          ? null
          : rawCategoryId;
      return ProductUpdated(
        base.copyWith(
          name: input.name.trim(),
          price: Money.fromDouble(price),
          stock: input.stock,
          sku: sku,
          barcode: barcode,
          cost: cost != null ? Money.fromDouble(cost) : null,
          // Always pass explicitly when user changed category (including clear).
          categoryId: categoryId,
          imagePath: imagePath,
          imageUrl: input.imageUrl,
          imageThumbnailPath: imageThumbnailPath,
          isActive: input.isActive,
          trackStock: input.trackStock,
          description: description,
          brand: brand,
          unit: unit,
          supplier: supplier,
          isRecommended: input.isRecommended,
        ),
        optionGroups: input.optionGroups,
      );
    } else {
      final addCategoryId = input.selectedCategory?.id;
      return ProductAdded(
        name: input.name.trim(),
        price: price,
        stock: input.stock,
        sku: sku,
        barcode: barcode,
        cost: cost,
        categoryId: (addCategoryId == null || addCategoryId.isEmpty)
            ? null
            : addCategoryId,
        imageUrl: input.imageUrl,
        imagePath: imagePath,
        imageThumbnailPath: imageThumbnailPath,
        trackStock: input.trackStock,
        isActive: input.isActive,
        description: description,
        brand: brand,
        unit: unit,
        supplier: supplier,
        isRecommended: input.isRecommended,
        optionGroups: input.optionGroups,
      );
    }
  }
}
