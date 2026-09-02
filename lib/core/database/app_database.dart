import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/core/database/database_opener.dart';
import 'package:promsell_pos_ce/core/database/migration_safety_service.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/database/tables/app_settings_table.dart';
import 'package:promsell_pos_ce/core/database/tables/categories_table.dart';
import 'package:promsell_pos_ce/core/database/tables/daily_closes_table.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_cart_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_carts_table.dart';
import 'package:promsell_pos_ce/core/database/tables/inventory_logs_table.dart';
import 'package:promsell_pos_ce/core/database/tables/product_audit_table.dart';
import 'package:promsell_pos_ce/core/database/tables/products_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sale_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sale_payments_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';
import 'package:promsell_pos_ce/core/database/tables/restaurant_tables_table.dart';
import 'package:promsell_pos_ce/core/database/tables/product_option_groups_table.dart';
import 'package:promsell_pos_ce/core/database/tables/product_options_table.dart';
import 'package:promsell_pos_ce/core/database/tables/customers_table.dart';
import 'package:promsell_pos_ce/core/database/tables/promotions_table.dart';
import 'package:promsell_pos_ce/core/database/tables/transaction_events_table.dart';

part 'app_database.g.dart';
part 'app_database_migrations.dart';
part 'app_database_migration_helpers.dart';
part 'app_database_migration_v32_satang.dart';

@DriftDatabase(
  tables: [
    Products,
    Sales,
    SaleItems,
    SalePayments,
    Categories,
    InventoryLogs,
    ProductAudits,
    AppSettings,
    DraftCarts,
    DraftCartItems,
    DailyCloses,
    RestaurantTables,
    ProductOptionGroups,
    ProductOptions,
    Customers,
    Promotions,
    TransactionEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 35;

  @override
  MigrationStrategy get migration => buildMigrationStrategy();

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
