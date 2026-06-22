import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class BatchGenerateBarcodes {
  const BatchGenerateBarcodes(this._repository);
  final ProductRepository _repository;

  Future<int> call({required String prefix}) async {
    final products = await _repository.getActiveProducts();
    final withoutBarcode = products
        .where((p) => p.barcode == null || p.barcode!.isEmpty)
        .toList();

    if (withoutBarcode.isEmpty) return 0;

    final usedBarcodes = <String>{};
    final updates = <({String id, String barcode})>[];

    for (final product in withoutBarcode) {
      String? barcode;
      for (var i = 0; i < 10; i++) {
        final candidate = Ean13Generator.generate(prefix: prefix);
        final existsInDb = await _repository.barcodeExists(
          candidate,
          excludeId: product.id,
        );
        if (!existsInDb && !usedBarcodes.contains(candidate)) {
          barcode = candidate;
          break;
        }
      }
      if (barcode == null) continue;

      updates.add((id: product.id, barcode: barcode));
      usedBarcodes.add(barcode);
    }

    if (updates.isEmpty) return 0;

    await _repository.bulkUpdateBarcodes(updates);
    return updates.length;
  }
}
