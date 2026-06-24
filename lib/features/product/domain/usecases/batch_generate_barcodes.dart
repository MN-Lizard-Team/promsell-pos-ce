import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class BatchGenerateBarcodes {
  const BatchGenerateBarcodes(this._repository, this._settingsRepo);
  final ProductRepository _repository;
  final SettingsRepository _settingsRepo;

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
    await _persistCounter();
    return updates.length;
  }

  Future<void> _persistCounter() async {
    try {
      final settings = await _settingsRepo.load();
      final updated = settings.copyWith(
        barcodeLastCounter: Ean13Generator.currentCounter,
      );
      await _settingsRepo.save(updated);
    } catch (e) {
      AppLogger.warning('Barcode counter persistence failed', error: e);
    }
  }
}
