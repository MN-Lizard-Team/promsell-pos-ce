import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/database/tables/app_settings_table.dart';
import 'package:promsell_pos_ce/core/database/tables/categories_table.dart';
import 'package:promsell_pos_ce/core/database/tables/daily_closes_table.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_cart_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_carts_table.dart';
import 'package:promsell_pos_ce/core/database/tables/inventory_logs_table.dart';
import 'package:promsell_pos_ce/core/database/tables/products_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sale_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Sales,
    SaleItems,
    Categories,
    InventoryLogs,
    AppSettings,
    DraftCarts,
    DraftCartItems,
    DailyCloses,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 16;

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
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products (barcode)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales (created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_status ON sales (status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items (sale_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inventory_logs_product_id ON inventory_logs (product_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_draft_cart_items_cart_id ON draft_cart_items (cart_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_daily_closes_close_date ON daily_closes (close_date)',
    );
  }

  Future<void> _seedDefaultSettings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'shop_name', value: ''),
        AppSettingsCompanion.insert(key: 'receipt_footer', value: ''),
        AppSettingsCompanion.insert(key: 'vat_rate', value: '7'),
        AppSettingsCompanion.insert(key: 'vat_mode', value: 'NONE'),
        AppSettingsCompanion.insert(key: 'currency_symbol', value: '฿'),
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
    try {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Column may already exist; ignore
      if (!e.toString().contains('duplicate column')) {
        AppLogger.error('Migration ALTER failed for $table.$column', error: e);
        rethrow;
      }
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

  static QueryExecutor _openDatabase() {
    return driftDatabase(name: 'promsell_pos.db');
  }
}
