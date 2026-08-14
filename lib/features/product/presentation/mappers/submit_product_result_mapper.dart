import 'package:promsell_pos_ce/features/product/domain/usecases/submit_product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';

/// Maps a domain [SubmitProductResult] to a presentation [ProductEvent].
///
/// Lives in presentation so the domain use case never imports the BLoC
/// event types.
ProductEvent? submitProductResultToEvent(SubmitProductResult? result) {
  if (result == null) return null;
  return switch (result) {
    SubmitProductAdd(:final command) => ProductAdded(
      name: command.name,
      price: command.price,
      stock: command.stock,
      sku: command.sku,
      barcode: command.barcode,
      cost: command.cost,
      categoryId: command.categoryId,
      imageUrl: command.imageUrl,
      imagePath: command.imagePath,
      imageThumbnailPath: command.imageThumbnailPath,
      trackStock: command.trackStock,
      isActive: command.isActive,
      description: command.description,
      brand: command.brand,
      unit: command.unit,
      supplier: command.supplier,
      isRecommended: command.isRecommended,
      optionGroups: command.optionGroups,
    ),
    SubmitProductUpdate(:final product, :final optionGroups) => ProductUpdated(
      product,
      optionGroups: optionGroups,
    ),
  };
}
