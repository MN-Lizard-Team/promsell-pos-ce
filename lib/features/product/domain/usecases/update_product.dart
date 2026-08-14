import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_sku_exception.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class UpdateProduct {
  const UpdateProduct(this._repository, this._appLock);
  final ProductRepository _repository;
  final AppLockService _appLock;

  /// Throws [BusinessRuleError] `AppLockRequired` when store PIN is on and
  /// session locked (V092-B.1).
  Future<void> call(
    Product product, {
    List<ProductOptionGroup>? optionGroups,
  }) async {
    await _appLock.requireSensitiveSession();
    Validators.productName(product.name);
    Validators.price(product.price.value);
    Validators.cost(product.cost.value);
    Validators.stock(product.stock);
    Validators.barcode(product.barcode);
    final normalizedSku = Validators.sku(product.sku);
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      final exists = await _repository.barcodeExists(
        product.barcode!,
        excludeId: product.id,
      );
      if (exists) throw DuplicateBarcodeException(product.barcode!);
    }
    if (normalizedSku != null && normalizedSku.isNotEmpty) {
      final skuExists = await _repository.skuExists(
        normalizedSku,
        excludeId: product.id,
      );
      if (skuExists) throw DuplicateSkuException(normalizedSku);
    }
    return _repository.updateProduct(product, optionGroups: optionGroups);
  }
}
