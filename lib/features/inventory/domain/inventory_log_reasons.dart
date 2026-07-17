/// Stable reason keys stored in [InventoryLog.reason].
/// UI maps known keys to l10n; unknown values are shown as-is (user text).
abstract final class InventoryLogReasons {
  static const productStockEdited = 'product_stock_edited';

  /// Legacy English string written before i18n keys.
  static const productStockEditedLegacy = 'Product stock edited';
}
