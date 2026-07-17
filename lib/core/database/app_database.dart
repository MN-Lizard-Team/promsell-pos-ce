import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/core/database/database_opener.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/database/tables/app_settings_table.dart';
import 'package:promsell_pos_ce/core/database/tables/categories_table.dart';
import 'package:promsell_pos_ce/core/database/tables/daily_closes_table.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_cart_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_carts_table.dart';
import 'package:promsell_pos_ce/core/database/tables/inventory_logs_table.dart';
import 'package:promsell_pos_ce/core/database/tables/products_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sale_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sale_payments_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';
import 'package:promsell_pos_ce/core/database/tables/restaurant_tables_table.dart';
import 'package:promsell_pos_ce/core/database/tables/product_option_groups_table.dart';
import 'package:promsell_pos_ce/core/database/tables/product_options_table.dart';
import 'package:promsell_pos_ce/core/database/tables/customers_table.dart';
import 'package:promsell_pos_ce/core/database/tables/promotions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Sales,
    SaleItems,
    SalePayments,
    Categories,
    InventoryLogs,
    AppSettings,
    DraftCarts,
    DraftCartItems,
    DailyCloses,
    RestaurantTables,
    ProductOptionGroups,
    ProductOptions,
    Customers,
    Promotions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 28;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _seedDefaultSettings();
    },
    onUpgrade: (m, from, to) async {
      // incremental table creation (replaces old drop+recreate)
      if (from < 2) {
        await m.createTable(draftCarts);
        await m.createTable(draftCartItems);
        await m.createTable(dailyCloses);
        await m.createTable(categories);
        await m.createTable(inventoryLogs);
        await m.createTable(appSettings);
        await _createIndexes();
        await _seedDefaultSettings();
      }
      if (from < 3) {
        await _addColumnIfNotExists(
          'draft_carts',
          'cart_discount_type',
          'TEXT',
        );
        await _addColumnIfNotExists(
          'draft_carts',
          'cart_discount_value',
          'REAL',
        );
      }
      if (from < 4) {
        await _addColumnIfNotExists('products', 'image_path', 'TEXT');
      }
      if (from < 5) {
        await _seedR4Settings();
      }
      if (from < 6) {
        await _addColumnIfNotExists('products', 'image_thumbnail_path', 'TEXT');
        await _seedR45Settings();
      }
      if (from < 7) {
        await _addColumnIfNotExists(
          'draft_carts',
          'is_archived',
          'INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 8) {
        await _seedR5Settings();
      }
      if (from < 9) {
        await _addColumnIfNotExists(
          'daily_closes',
          'payment_breakdown',
          'TEXT NOT NULL DEFAULT \'{}\'',
        );
        await _addColumnIfNotExists(
          'daily_closes',
          'vat_amount',
          'REAL NOT NULL DEFAULT 0',
        );
        await _addColumnIfNotExists(
          'daily_closes',
          'discount_amount',
          'REAL NOT NULL DEFAULT 0',
        );
      }
      if (from < 10) {
        // Recreate daily_closes to make closed_at nullable
        await customStatement(
          'ALTER TABLE daily_closes RENAME TO daily_closes_old',
        );
        await m.createTable(dailyCloses);
        await customStatement(
          'INSERT INTO daily_closes SELECT * FROM daily_closes_old',
        );
        await customStatement('DROP TABLE daily_closes_old');
      }
      // Add sync columns to all tables for Phase 2 multi-device readiness
      if (from < 11) {
        // SaleItems: add updatedAt, deletedAt, version, deviceId
        await _addColumnIfNotExists(
          'sale_items',
          'updated_at',
          'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
        );
        await _addColumnIfNotExists('sale_items', 'deleted_at', 'TEXT');
        await _addColumnIfNotExists(
          'sale_items',
          'version',
          'INTEGER NOT NULL DEFAULT 1',
        );
        await _addColumnIfNotExists('sale_items', 'device_id', 'TEXT');

        // DraftCartItems: add updatedAt, deletedAt, version, deviceId
        await _addColumnIfNotExists(
          'draft_cart_items',
          'updated_at',
          'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
        );
        await _addColumnIfNotExists('draft_cart_items', 'deleted_at', 'TEXT');
        await _addColumnIfNotExists(
          'draft_cart_items',
          'version',
          'INTEGER NOT NULL DEFAULT 1',
        );
        await _addColumnIfNotExists('draft_cart_items', 'device_id', 'TEXT');

        // DailyCloses: add updatedAt, deletedAt, version (deviceId already exists)
        await _addColumnIfNotExists(
          'daily_closes',
          'updated_at',
          'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
        );
        await _addColumnIfNotExists('daily_closes', 'deleted_at', 'TEXT');
        await _addColumnIfNotExists(
          'daily_closes',
          'version',
          'INTEGER NOT NULL DEFAULT 1',
        );

        // InventoryLogs: add updatedAt, deletedAt, version (deviceId already exists)
        await _addColumnIfNotExists(
          'inventory_logs',
          'updated_at',
          'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
        );
        await _addColumnIfNotExists('inventory_logs', 'deleted_at', 'TEXT');
        await _addColumnIfNotExists(
          'inventory_logs',
          'version',
          'INTEGER NOT NULL DEFAULT 1',
        );

        // DraftCarts: add deletedAt, version (updatedAt, deviceId already exist)
        await _addColumnIfNotExists('draft_carts', 'deleted_at', 'TEXT');
        await _addColumnIfNotExists(
          'draft_carts',
          'version',
          'INTEGER NOT NULL DEFAULT 1',
        );

        // AppSettings: add version, deviceId
        await _addColumnIfNotExists(
          'app_settings',
          'version',
          'INTEGER NOT NULL DEFAULT 1',
        );
        await _addColumnIfNotExists('app_settings', 'device_id', 'TEXT');
      }
      // TEXT ISO8601 → INTEGER milliseconds (strftime is universally available)
      if (from < 12) {
        final conversions = [
          ('sale_items', 'updated_at'),
          ('sale_items', 'deleted_at'),
          ('draft_cart_items', 'updated_at'),
          ('draft_cart_items', 'deleted_at'),
          ('daily_closes', 'updated_at'),
          ('daily_closes', 'deleted_at'),
          ('inventory_logs', 'updated_at'),
          ('inventory_logs', 'deleted_at'),
          ('draft_carts', 'deleted_at'),
        ];
        for (final (table, column) in conversions) {
          try {
            await customStatement(
              "UPDATE $table SET $column = CAST(strftime('%s', $column) AS INTEGER) * 1000 WHERE typeof($column) = 'text'",
            );
          } catch (e) {
            AppLogger.warning(
              'Schema v12 migration failed for $table.$column',
              error: e,
            );
          }
        }
      }
      if (from < 13) {
        await _backfillDeviceId();
      }
      if (from < 14) {
        await _backfillCategoryIds();
      }
      if (from < 15) {
        await _addColumnIfNotExists('categories', 'color', 'TEXT');
        await _addColumnIfNotExists('categories', 'icon_name', 'TEXT');
      }
      if (from < 16) {
        await _createBarcodeUniqueIndex();
      }
      if (from < 17) {
        await _deduplicateBarcodes();
        await _createBarcodeUniqueIndex();
      }
      if (from < 18) {
        await _addColumnIfNotExists('products', 'barcode_image_path', 'TEXT');
      }
      if (from < 19) {
        await _addColumnIfNotExists('sale_items', 'note', 'TEXT');
        await _addColumnIfNotExists('draft_cart_items', 'note', 'TEXT');
      }
      if (from < 20) {
        // Sales: order type, channel, external ref, table, service charge
        await _addColumnIfNotExists(
          'sales',
          'order_type',
          "TEXT NOT NULL DEFAULT 'delivery'",
        );
        await _addColumnIfNotExists(
          'sales',
          'order_channel',
          "TEXT NOT NULL DEFAULT 'walkin'",
        );
        await _addColumnIfNotExists('sales', 'external_order_ref', 'TEXT');
        await _addColumnIfNotExists('sales', 'table_id', 'TEXT');
        await _addColumnIfNotExists(
          'sales',
          'service_charge_rate',
          'REAL NOT NULL DEFAULT 0',
        );
        await _addColumnIfNotExists(
          'sales',
          'service_charge_amount',
          'REAL NOT NULL DEFAULT 0',
        );

        // DraftCarts: order type, channel, external ref, table, service charge
        await _addColumnIfNotExists(
          'draft_carts',
          'order_type',
          "TEXT NOT NULL DEFAULT 'delivery'",
        );
        await _addColumnIfNotExists(
          'draft_carts',
          'order_channel',
          "TEXT NOT NULL DEFAULT 'walkin'",
        );
        await _addColumnIfNotExists(
          'draft_carts',
          'external_order_ref',
          'TEXT',
        );
        await _addColumnIfNotExists('draft_carts', 'table_id', 'TEXT');
        await _addColumnIfNotExists(
          'draft_carts',
          'service_charge_rate',
          'REAL',
        );

        // SaleItems + DraftCartItems: product options JSON snapshot
        await _addColumnIfNotExists(
          'sale_items',
          'product_options_json',
          'TEXT',
        );
        await _addColumnIfNotExists(
          'draft_cart_items',
          'product_options_json',
          'TEXT',
        );

        // New tables for restaurant support
        await m.createTable(restaurantTables);
        await m.createTable(productOptionGroups);
        await m.createTable(productOptions);

        // Indexes for new tables
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_product_option_groups_product_id ON product_option_groups (product_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_product_options_group_id ON product_options (group_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_restaurant_tables_status ON restaurant_tables (status)',
        );

        // Seed default business type setting
        await batch((b) {
          b.insertAll(appSettings, [
            AppSettingsCompanion.insert(key: 'businessType', value: 'retail'),
            AppSettingsCompanion.insert(
              key: 'defaultServiceChargeRate',
              value: '0',
            ),
          ], mode: InsertMode.insertOrIgnore);
        });
      }
      if (from < 21) {
        // New tables: Customers + Promotions
        await m.createTable(customers);
        await m.createTable(promotions);

        // Add customerId + promotionId columns to Sales
        await _addColumnIfNotExists('sales', 'customer_id', 'TEXT');
        await _addColumnIfNotExists('sales', 'promotion_id', 'TEXT');
        await _addColumnIfNotExists(
          'sales',
          'promotion_discount_amount',
          'REAL NOT NULL DEFAULT 0',
        );

        // Add customerId + promotionId columns to DraftCarts
        await _addColumnIfNotExists('draft_carts', 'customer_id', 'TEXT');
        await _addColumnIfNotExists('draft_carts', 'promotion_id', 'TEXT');
        await _addColumnIfNotExists(
          'draft_carts',
          'promotion_discount_amount',
          'REAL NOT NULL DEFAULT 0',
        );

        // Indexes
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers (phone)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions (is_active)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales (customer_id)',
        );
      }
      if (from < 22) {
        await _addColumnIfNotExists('products', 'description', 'TEXT');
      }
      // v23: Runtime validations only (barcode uniqueness, product delete guard)
      // No schema changes required
      if (from < 23) {
        // No-op: validations implemented in repository layer
      }
      // v24: Barcode UNIQUE INDEX + performance indexes
      if (from < 24) {
        // Re-run barcode deduplication to ensure uniqueness before creating index
        await _deduplicateBarcodes();

        // Drop old non-conditional unique index if exists
        await customStatement(
          'DROP INDEX IF EXISTS idx_products_barcode_unique',
        );

        // Create conditional unique index (NULL and empty string allowed)
        await customStatement(
          "CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products(barcode) WHERE barcode IS NOT NULL AND barcode != ''",
        );

        // Add performance indexes
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at)',
        );
      }
      if (from < 25) {
        await _addColumnIfNotExists('products', 'brand', 'TEXT');
        await _addColumnIfNotExists('products', 'unit', 'TEXT');
        await _addColumnIfNotExists('products', 'supplier', 'TEXT');
        await _addColumnIfNotExists(
          'products',
          'is_recommended',
          'INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 26) {
        // Keep one row per close_date (latest id wins), then unique index.
        await customStatement('''
DELETE FROM daily_closes WHERE id NOT IN (
  SELECT id FROM daily_closes
  GROUP BY close_date
  HAVING id = MAX(id)
)
''');
        await customStatement(
          'DROP INDEX IF EXISTS idx_daily_closes_close_date',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_closes_close_date_unique ON daily_closes (close_date)',
        );
      }
      if (from < 28) {
        await m.createTable(salePayments);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sale_payments_sale_id '
          'ON sale_payments (sale_id)',
        );
      }
      if (from < 27) {
        // Dedupe non-null receipt numbers (keep latest created_at), then unique.
        await customStatement('''
UPDATE sales
SET receipt_number = receipt_number || '-dup-' || id
WHERE receipt_number IS NOT NULL
  AND receipt_number != ''
  AND id NOT IN (
    SELECT id FROM sales
    WHERE receipt_number IS NOT NULL AND receipt_number != ''
    GROUP BY receipt_number
    HAVING id = MAX(id)
  )
''');
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_receipt_number_unique '
          'ON sales(receipt_number) '
          "WHERE receipt_number IS NOT NULL AND receipt_number != ''",
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode=WAL');
      await customStatement('PRAGMA foreign_keys=ON');
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_category_id ON products (category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_is_active ON products (is_active)',
    );
    // Conditional unique index created in v24 migration
    await customStatement(
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products(barcode) WHERE barcode IS NOT NULL AND barcode != ''",
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales (created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_status ON sales (status)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_receipt_number_unique '
      'ON sales(receipt_number) '
      "WHERE receipt_number IS NOT NULL AND receipt_number != ''",
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items (sale_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_payments_sale_id ON sale_payments (sale_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items (product_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inventory_logs_product_id ON inventory_logs (product_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_draft_cart_items_cart_id ON draft_cart_items (cart_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_closes_close_date_unique ON daily_closes (close_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions (is_active)',
    );
  }

  Future<void> _seedDefaultSettings() async {
    // Canonical keys must match [SettingsMapper] (camelCase).
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'shopName', value: ''),
        AppSettingsCompanion.insert(key: 'receiptNote', value: ''),
        AppSettingsCompanion.insert(key: 'vatRate', value: '7'),
        AppSettingsCompanion.insert(key: 'vatMode', value: 'NONE'),
        AppSettingsCompanion.insert(key: 'currency', value: '฿'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _seedR4Settings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'promptpayId', value: ''),
        AppSettingsCompanion.insert(key: 'receiptSize', value: '80mm'),
        AppSettingsCompanion.insert(key: 'backupReminderDays', value: '7'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _seedR5Settings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'accessibilityMode', value: 'false'),
        AppSettingsCompanion.insert(key: 'deviceId', value: ''),
        AppSettingsCompanion.insert(key: 'devicePrefix', value: ''),
        AppSettingsCompanion.insert(key: 'onboardingCompleted', value: 'false'),
        AppSettingsCompanion.insert(key: 'dailyCloseLock', value: 'false'),
        AppSettingsCompanion.insert(key: 'lastClosedDate', value: ''),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _seedR45Settings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'imageMaxWidth', value: '800'),
        AppSettingsCompanion.insert(key: 'imageQuality', value: '80'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _addColumnIfNotExists(
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
  Future<void> deduplicateBarcodesForTest() => _deduplicateBarcodes();

  Future<void> _deduplicateBarcodes() async {
    try {
      final duplicates = await customSelect('''
        SELECT barcode FROM products
        WHERE barcode IS NOT NULL AND barcode != ''
        GROUP BY barcode HAVING COUNT(*) > 1
      ''').get();

      if (duplicates.isEmpty) return;

      var clearedCount = 0;
      for (final row in duplicates) {
        final barcode = row.read<String>('barcode');

        // Keep the product with latest updated_at; prefer active products
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
    } catch (e) {
      AppLogger.error('Schema v17: barcode dedup failed', error: e);
    }
  }

  Future<void> _backfillCategoryIds() async {
    try {
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
    } catch (e) {
      AppLogger.warning('Schema v14 categoryId backfill failed', error: e);
    }
  }

  Future<void> _createBarcodeUniqueIndex() async {
    try {
      final duplicates = await customSelect('''
        SELECT barcode, COUNT(*) as cnt FROM products
        WHERE barcode IS NOT NULL AND barcode != ''
        GROUP BY barcode HAVING cnt > 1
      ''').get();

      if (duplicates.isNotEmpty) {
        AppLogger.warning(
          'Schema v16: found ${duplicates.length} duplicate barcodes. '
          'Skipping unique index creation. Clean duplicates manually.',
        );
        return;
      }

      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products (barcode)',
      );
    } catch (e) {
      AppLogger.error(
        'Schema v16: barcode unique index creation failed',
        error: e,
      );
    }
  }

  Future<void> _backfillDeviceId() async {
    try {
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
        try {
          await customStatement(
            "UPDATE $table SET device_id = ? WHERE device_id IS NULL OR device_id = ''",
            [deviceId],
          );
        } catch (e) {
          AppLogger.warning('Schema v13 backfill failed for $table', error: e);
        }
      }
    } catch (e) {
      AppLogger.warning('Schema v13 deviceId backfill failed', error: e);
    }
  }

  /// Opens the database with SQLCipher AES-256-CBC encryption (Phase 2a / v0.9.0).
  ///
  /// Uses LazyDatabase to defer opening until first query, allowing async key fetch
  /// from secure storage. On first launch after upgrade, transparently migrates
  /// plain SQLite → encrypted SQLCipher.
  static QueryExecutor _openDatabase() {
    return LazyDatabase(() async {
      return EncryptedDatabaseOpener.open();
    });
  }
}
