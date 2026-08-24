part of 'app_database.dart';

/// Migration helper methods extracted from [AppDatabaseMigrationLogic]
/// to keep the main migration file focused on the migration strategy.
///
/// These helpers handle deduplication, backfilling, and column additions
/// that are called from version-specific migration steps.
extension AppDatabaseMigrationHelpers on AppDatabase {
  Future<void> addColumnIfNotExists(
    String table,
    String column,
    String type,
  ) async {
    final exists = await customSelect(
      'SELECT COUNT(*) as cnt FROM pragma_table_info(?) WHERE name = ?',
      variables: [Variable.withString(table), Variable.withString(column)],
    ).getSingle();
    if (exists.read<int>('cnt') == 0) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  @visibleForTesting
  Future<void> deduplicateBarcodesForTest() => deduplicateBarcodes();

  Future<void> deduplicateBarcodes() async {
    final duplicates = await customSelect('''
      SELECT barcode FROM products
      WHERE barcode IS NOT NULL AND barcode != ''
      GROUP BY barcode HAVING COUNT(*) > 1
    ''').get();

    if (duplicates.isEmpty) return;

    var clearedCount = 0;
    for (final row in duplicates) {
      final barcode = row.read<String>('barcode');

      // Keep the product with latest updated_at; prefer active products.
      final keepId = await customSelect(
        '''SELECT id FROM products
           WHERE barcode = ?
           ORDER BY is_active DESC, updated_at DESC
           LIMIT 1''',
        variables: [Variable.withString(barcode)],
      ).getSingle();

      final result = await customUpdate(
        '''UPDATE products SET barcode = NULL
           WHERE barcode = ? AND id != ?''',
        updates: {products},
        variables: [
          Variable.withString(barcode),
          Variable.withString(keepId.read<String>('id')),
        ],
      );
      clearedCount += result;
    }

    AppLogger.warning(
      'Schema v17: cleared $clearedCount duplicate barcodes '
      'across ${duplicates.length} groups.',
    );
  }

  /// Deduplicates barcodes case-insensitively — keeps one product per
  /// [LOWER(barcode)] group before creating the barcode_lower unique index.
  Future<void> deduplicateBarcodesLower() async {
    final duplicates = await customSelect('''
      SELECT LOWER(barcode) as barcode_lower FROM products
      WHERE barcode IS NOT NULL AND barcode != ''
      GROUP BY LOWER(barcode) HAVING COUNT(*) > 1
    ''').get();

    if (duplicates.isEmpty) return;

    var clearedCount = 0;
    for (final row in duplicates) {
      final lower = row.read<String>('barcode_lower');

      final keepId = await customSelect(
        '''SELECT id FROM products
           WHERE LOWER(barcode) = ?
           ORDER BY is_active DESC, updated_at DESC
           LIMIT 1''',
        variables: [Variable.withString(lower)],
      ).getSingle();

      final result = await customUpdate(
        '''UPDATE products SET barcode = NULL, barcode_lower = NULL
           WHERE LOWER(barcode) = ? AND id != ?''',
        updates: {products},
        variables: [
          Variable.withString(lower),
          Variable.withString(keepId.read<String>('id')),
        ],
      );
      clearedCount += result;
    }

    AppLogger.warning(
      'Schema v29: cleared $clearedCount case-insensitive duplicate barcodes '
      'across ${duplicates.length} groups.',
    );
  }

  /// V092-C.2: Deduplicates SKUs case-insensitively — keeps one product per
  /// [LOWER(sku)] group before creating the sku_lower unique index.
  /// Mirrors [deduplicateBarcodesLower].
  Future<void> deduplicateSkuLower() async {
    final duplicates = await customSelect('''
      SELECT LOWER(sku) as sku_lower FROM products
      WHERE sku IS NOT NULL AND sku != ''
      GROUP BY LOWER(sku) HAVING COUNT(*) > 1
    ''').get();

    if (duplicates.isEmpty) return;

    var clearedCount = 0;
    for (final row in duplicates) {
      final lower = row.read<String>('sku_lower');

      final keepId = await customSelect(
        '''SELECT id FROM products
           WHERE LOWER(sku) = ?
           ORDER BY is_active DESC, updated_at DESC
           LIMIT 1''',
        variables: [Variable.withString(lower)],
      ).getSingle();

      final result = await customUpdate(
        '''UPDATE products SET sku = NULL, sku_lower = NULL
           WHERE LOWER(sku) = ? AND id != ?''',
        updates: {products},
        variables: [
          Variable.withString(lower),
          Variable.withString(keepId.read<String>('id')),
        ],
      );
      clearedCount += result;
    }

    AppLogger.warning(
      'V092-C.2: cleared $clearedCount case-insensitive duplicate SKUs '
      'across ${duplicates.length} groups.',
    );
  }

  Future<void> backfillCategoryIds() async {
    final dupes = await customSelect(
      'SELECT name, COUNT(*) as cnt FROM categories '
      'GROUP BY name HAVING cnt > 1',
    ).get();

    if (dupes.isNotEmpty) {
      AppLogger.warning(
        'Schema v14: found ${dupes.length} duplicate category names. '
        'Using first match for backfill.',
      );
    }

    await customStatement('''
      UPDATE products
      SET category_id = (
        SELECT id FROM categories
        WHERE categories.name = products.category_id
        LIMIT 1
      )
      WHERE category_id IS NOT NULL
    ''');
  }

  Future<void> createBarcodeUniqueIndex() async {
    final duplicates = await customSelect('''
      SELECT barcode, COUNT(*) as cnt FROM products
      WHERE barcode IS NOT NULL AND barcode != ''
      GROUP BY barcode HAVING cnt > 1
    ''').get();

    if (duplicates.isNotEmpty) {
      throw StateError(
        'Schema v16 cannot create barcode unique index: '
        '${duplicates.length} duplicate barcode groups remain',
      );
    }

    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique '
      "ON products (barcode) WHERE barcode IS NOT NULL AND barcode != ''",
    );
  }

  Future<void> backfillDeviceId() async {
    final result = await customSelect(
      "SELECT value FROM app_settings WHERE key = 'deviceId'",
    ).getSingleOrNull();
    final deviceId = result?.read<String>('value') ?? '';
    if (deviceId.isEmpty) return;

    const tables = [
      'sales',
      'sale_items',
      'draft_carts',
      'draft_cart_items',
      'daily_closes',
      'inventory_logs',
    ];
    for (final table in tables) {
      await customStatement(
        "UPDATE $table SET device_id = ? WHERE device_id IS NULL OR device_id = ''",
        [deviceId],
      );
    }
  }
}
