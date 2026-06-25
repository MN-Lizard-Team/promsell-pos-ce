import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class UpdateProduct {
  const UpdateProduct(this._repository);
  final ProductRepository _repository;

  Future<void> call(Product product) async {
    Validators.productName(product.name);
    Validators.price(product.price);
    Validators.stock(product.stock);
    Validators.barcode(product.barcode);
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      final exists = await _repository.barcodeExists(
        product.barcode!,
        excludeId: product.id,
      );
      if (exists) throw DuplicateBarcodeException(product.barcode!);
    }
    return _repository.updateProduct(product);
  }
}
