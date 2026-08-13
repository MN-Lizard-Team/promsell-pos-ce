import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_barcode_eligibility.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class BatchGenerateBarcodes {
  const BatchGenerateBarcodes(
    this._repository,
    this._settingsRepo,
    this._generator,
  );
  final ProductRepository _repository;
  final SettingsRepository _settingsRepo;
  final Ean13Generator _generator;

  /// Generates EAN-13 barcodes for **all** products (active + inactive) that
  /// still need one. Returns how many rows were updated.
  Future<int> call({required String prefix}) async {
    final settings = await _settingsRepo.load();
    _generator.initCounter(settings.barcodeLastCounter);

    // Policy A: full catalog — matches UI count on ProductBloc.state.products.
    final products = await _repository.getAllProducts();
    final withoutBarcode = products.where(productNeedsBarcode).toList();

    if (withoutBarcode.isEmpty) return 0;

    final usedBarcodes = <String>{};
    final updates = <({String id, String barcode})>[];

    for (final product in withoutBarcode) {
      String? barcode;
      for (var i = 0; i < 10; i++) {
        final candidate = _generator.generate(prefix: prefix);
        final existsInDb = await _repository.barcodeExists(
          candidate,
          excludeId: product.id,
        );
        if (!existsInDb && !usedBarcodes.contains(candidate)) {
          barcode = candidate;
          // Persist counter immediately so a retry won't regenerate duplicates.
          await _persistCounter();
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

  Future<void> _persistCounter() async {
    try {
      await _settingsRepo.saveBarcodeLastCounter(_generator.currentCounter);
    } catch (e, stack) {
      AppLogger.warning(
        'Barcode counter persistence failed',
        error: e,
        stack: stack,
      );
    }
  }
}
