import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/restaurant_table/data/repositories/restaurant_table_repository_impl.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/services/restaurant_table_name_resolver.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';

import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

/// Gap B — renaming a table must not orphan history.
///
/// A paid sale persists only the raw `sales.table_id`; every read path joins
/// by ID, never by name:
/// - history hydration (`SaleQueryLocalDatasource.querySaleById` →
///   `Sale.tableId`),
/// - the `idx_sales_table_id` lookup on `sales(table_id)`,
/// - the display id→name join (`RestaurantTableNameResolver.resolve`,
///   backed by `getTableById`).
///
/// Renaming goes through `RestaurantTableRepositoryImpl.updateTable`, which
/// mutates the name on the SAME row id (and invalidates the resolver cache in
/// the management page), so reporting keeps joining after a rename.
void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late SaleQueryLocalDatasource saleQuery;
  late RestaurantTableRepositoryImpl tableRepo;
  late RestaurantTableNameResolver resolver;

  setUp(() {
    db = createInMemoryDatabase();
    final fakeSettingsRepo = FakeSettingsRepository();
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
    saleQuery = SaleQueryLocalDatasource(db);
    tableRepo = RestaurantTableRepositoryImpl(
      db,
      settingsRepo: fakeSettingsRepo,
    );
    resolver = RestaurantTableNameResolver(tableRepo);
  });

  tearDown(() => db.close());

  Future<Product> seedProduct(String id) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Item-$id',
        price: 100.0,
        stock: const Value(50),
      ),
    );
    final row = await (db.select(
      db.products,
    )..where((p) => p.id.equals(id))).getSingle();
    return Product(
      id: row.id,
      name: row.name,
      price: Money.fromDouble(row.price),
      stock: row.stock,
      isActive: row.isActive,
      trackStock: row.trackStock,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  test('paid sale still joins its table by id after rename', () async {
    final product = await seedProduct('p-rename');
    final tableId = await tableRepo.addTable(name: 'A1');

    // Sell & pay at "A1".
    final sale = await saleDs.insertSaleWithItems(
      items: [CartItem(product: product, qty: 2)],
      paymentMethod: 'cash',
      vatMode: 'NONE',
      vatRate: 0,
      orderType: 'dinein',
      tableId: tableId,
    );
    expect(sale.tableId, tableId);

    // Rename via the management-page path: updateTable keeps the ROW ID.
    // The page also calls resolver.invalidate() after edits — mirror that.
    final before = (await tableRepo.getTableById(tableId))!;
    expect(before.name, 'A1');
    await tableRepo.updateTable(before.copyWith(name: 'A2'));
    resolver.invalidate();

    // History hydration path: the paid sale still carries the SAME id.
    final historySale = (await saleQuery.querySaleById(sale.id))!;
    expect(historySale.id, sale.id);
    expect(historySale.tableId, tableId);

    // idx_sales_table_id lookup: sales by table_id still resolve by id.
    final salesForTable = await (db.select(
      db.sales,
    )..where((s) => s.tableId.equals(tableId))).get();
    expect(salesForTable.single.id, sale.id);

    // Display id→name join resolves the NEW name — nothing orphaned.
    expect(await resolver.resolve(tableId), 'A2');

    // Floor plan is id-keyed too: exactly one row for this id, new name.
    final tables = await tableRepo.getAllTables();
    expect(tables.where((t) => t.id == tableId).single.name, 'A2');
    expect(tables.where((t) => t.name == 'A1'), isEmpty);
  });

  test('rename does not disturb derived occupancy of an open bill', () async {
    final product = await seedProduct('p-open');
    final draftDs = DraftCartLocalDatasourceImpl(
      db,
      settingsRepo: FakeSettingsRepository(),
    );
    final tableId = await tableRepo.addTable(name: 'B1');

    // Open bill binds the table → effectively occupied.
    final cartId = await draftDs.createDraft(name: 'Bill B1');
    await draftDs.upsertDraft(
      cartId,
      CartSnapshot(
        items: [CartItem(product: product, qty: 1)],
        tableId: tableId,
      ),
    );

    await tableRepo.updateTable(
      (await tableRepo.getTableById(tableId))!.copyWith(name: 'B2'),
    );

    final renamed = (await tableRepo.getTableById(tableId))!;
    expect(renamed.name, 'B2');
    // Occupancy derivation follows the cart binding, not the name.
    expect(renamed.status, TableStatus.occupied);
    expect(await draftDs.loadDraft(cartId), isNotNull);
  });
}
