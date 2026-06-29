import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class GenerateBarcode {
  const GenerateBarcode(this._productRepo, this._settingsRepo, this._generator);
  final ProductRepository _productRepo;
  final SettingsRepository _settingsRepo;
  final Ean13Generator _generator;

  Future<String> call({String? prefix, String? excludeId}) async {
    final settings = await _settingsRepo.load();
    _generator.initCounter(settings.barcodeLastCounter);

    for (var i = 0; i < 10; i++) {
      final barcode = _generator.generate(prefix: prefix);
      final exists = await _productRepo.barcodeExists(
        barcode,
        excludeId: excludeId,
      );
      if (!exists) {
        await _persistCounter();
        return barcode;
      }
    }
    await _persistCounter();
    throw StateError('Could not generate unique barcode after 10 attempts');
  }

  Future<void> _persistCounter() async {
    try {
      final settings = await _settingsRepo.load();
      final updated = settings.copyWith(
        barcodeLastCounter: _generator.currentCounter,
      );
      await _settingsRepo.save(updated);
    } catch (_) {
      // Counter persistence is best-effort — don't fail barcode generation
    }
  }
}
