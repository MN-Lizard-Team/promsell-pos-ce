import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

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

/// Pure domain command carrying the fields needed to insert a new product.
class SubmitProductCommand {
  const SubmitProductCommand({
    required this.name,
    required this.price,
    required this.stock,
    this.sku,
    this.barcode,
    this.cost,
    this.categoryId,
    this.imageUrl,
    this.imagePath,
    this.imageThumbnailPath,
    required this.trackStock,
    required this.isActive,
    this.description,
    this.brand,
    this.unit,
    this.supplier,
    required this.isRecommended,
    required this.optionGroups,
  });

  final String name;
  final double price;
  final int stock;
  final String? sku;
  final String? barcode;
  final double? cost;
  final String? categoryId;
  final String? imageUrl;
  final String? imagePath;
  final String? imageThumbnailPath;
  final bool trackStock;
  final bool isActive;
  final String? description;
  final String? brand;
  final String? unit;
  final String? supplier;
  final bool isRecommended;
  final List<ProductOptionGroup> optionGroups;
}

/// Result of [SubmitProductUseCase]: either an add command or an update of
/// an existing [Product]. The presentation layer maps this to a
/// `ProductEvent`; the domain never imports presentation.
sealed class SubmitProductResult {
  const SubmitProductResult();
}

class SubmitProductAdd extends SubmitProductResult {
  const SubmitProductAdd(this.command);
  final SubmitProductCommand command;
}

class SubmitProductUpdate extends SubmitProductResult {
  const SubmitProductUpdate(this.product, {this.optionGroups});
  final Product product;
  final List<ProductOptionGroup>? optionGroups;
}

class SubmitProductUseCase {
  SubmitProductResult? call(SubmitProductInput input) {
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

    // Preserve image paths even when the local file is currently missing.
    // Clearing them here would silently destroy the reference on every edit
    // (e.g. after a cache clear), making the image unrecoverable even if the
    // file returns via sync/restore. UnifiedImageWidget already renders a
    // placeholder for non-existent paths, so we keep the path; the
    // presentation layer logs a warning if the file is absent.
    final imagePath = input.imagePath;
    final imageThumbnailPath = input.imageThumbnailPath;

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
      // V092-C.1: the product form must NOT overwrite stock from a stale
      // snapshot. Operational paths (sale / void / adjustStock) own the
      // count. The form's stock field is ignored on edit; stock changes go
      // through the Adjust sheet. Initial stock on insert is still allowed.
      return SubmitProductUpdate(
        base.copyWith(
          name: input.name.trim(),
          price: Money.fromDouble(price),
          stock: base.stock,
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
      return SubmitProductAdd(
        SubmitProductCommand(
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
        ),
      );
    }
  }
}
