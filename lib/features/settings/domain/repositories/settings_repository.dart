import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

abstract interface class SettingsRepository {
  Future<Settings> load();
  Future<void> save(Settings settings);

  /// Patch only the barcode sequence counter (avoids full-document clobber).
  Future<void> saveBarcodeLastCounter(int counter);

  /// Patch only the SKU sequence counter (avoids full-document clobber).
  Future<void> saveSkuLastCounter(int counter);
}
