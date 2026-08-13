import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/sku_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class GenerateSku {
  const GenerateSku(this._productRepo, this._settingsRepo, this._generator);

  final ProductRepository _productRepo;
  final SettingsRepository _settingsRepo;
  final SkuGenerator _generator;

  Future<String> call({String? prefix, String? excludeId}) async {
    final settings = await _settingsRepo.load();
    _generator.initCounter(settings.skuLastCounter);
    final effectivePrefix = prefix ?? settings.skuAutoGeneratePrefix;

    for (var i = 0; i < 10; i++) {
      final sku = _generator.generate(prefix: effectivePrefix);
      final exists = await _productRepo.skuExists(sku, excludeId: excludeId);
      if (!exists) {
        await _persistCounter();
        return sku;
      }
    }
    await _persistCounter();
    throw StateError('Could not generate unique SKU after 10 attempts');
  }

  Future<void> _persistCounter() async {
    try {
      await _settingsRepo.saveSkuLastCounter(_generator.currentCounter);
    } catch (e, stack) {
      AppLogger.warning(
        'GenerateSku: counter persistence failed',
        error: e,
        stack: stack,
      );
    }
  }
}
