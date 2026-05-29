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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _seedDefaultSettings();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await customStatement(
          'ALTER TABLE draft_carts ADD COLUMN cart_discount_type TEXT',
        );
        await customStatement(
          'ALTER TABLE draft_carts ADD COLUMN cart_discount_value REAL',
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

  static QueryExecutor _openDatabase() {
    return driftDatabase(name: 'promsell_pos.db');
  }
}
