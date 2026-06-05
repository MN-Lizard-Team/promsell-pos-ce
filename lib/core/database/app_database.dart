import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
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
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _seedDefaultSettings();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1/v2 pre-release schemas: ensure all base tables exist before column migrations
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
        await customStatement(
          'ALTER TABLE products ADD COLUMN image_path TEXT',
        );
      }
      if (from < 5) {
        await _seedR4Settings();
      }
      if (from < 6) {
        await customStatement(
          'ALTER TABLE products ADD COLUMN image_thumbnail_path TEXT',
        );
        await _seedR45Settings();
      }
      if (from < 7) {
        await customStatement(
          'ALTER TABLE draft_carts ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0',
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
      'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products (barcode)',
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
      if (!e.toString().contains('duplicate column')) rethrow;
    }
  }

  static QueryExecutor _openDatabase() {
    return driftDatabase(name: 'promsell_pos.db');
  }
}
