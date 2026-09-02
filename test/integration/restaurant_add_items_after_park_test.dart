import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/restaurant_table/data/repositories/restaurant_table_repository_impl.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';

import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

/// Gap A — add items AFTER park across a reopen cycle.
///
/// Park a cart bound to table T holding X,Y → hydrate it back (what reopening
/// a parked bill does) → add Z → re-park → the persisted cart must hold
/// EXACTLY X,Y,Z still bound to T. This pins the diff-based item sync in
/// `DraftCartLocalDatasourceImpl.upsertDraft` under the save→load→save
/// round-trip the multi-bill flow performs on every park/reopen.
void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late DraftCartLocalDatasourceImpl draftDs;
  late RestaurantTableRepositoryImpl tableRepo;

  setUp(() {
    db = createInMemoryDatabase();
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    draftDs = DraftCartLocalDatasourceImpl(
      db,
      settingsRepo: FakeSettingsRepository(),
    );
    tableRepo = RestaurantTableRepositoryImpl(
      db,
      settingsRepo: FakeSettingsRepository(),
    );
  });

  tearDown(() => db.close());

  Future<Product> seedProduct(String id, {int qty = 1}) async {
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

  CartItem lineOf(Product product, String cartId, {int qty = 1}) => CartItem(
    product: product,
    qty: qty,
    lineId: 'line-$cartId-${product.id}',
  );

  /// Raw persisted item rows for [cartId] — no hydration, catches residue.
  Future<List<DraftCartItemData>> rawItemRows(String cartId) => (db.select(
    db.draftCartItems,
  )..where((r) => r.cartId.equals(cartId))).get();

  group('add items after park (diff-sync under park/reopen cycles)', () {
    test(
      'park X,Y → reopen → add Z → re-park persists exactly X,Y,Z on T',
      () async {
        final x = await seedProduct('p-x');
        final y = await seedProduct('p-y');
        final z = await seedProduct('p-z');
        final tableId = await tableRepo.addTable(name: 'T-A');

        // Park: cart bound to T with X and Y.
        final cartId = await draftDs.createDraft(name: 'Bill T-A');
        await draftDs.upsertDraft(
          cartId,
          CartSnapshot(
            items: [lineOf(x, cartId), lineOf(y, cartId, qty: 2)],
            tableId: tableId,
          ),
        );

        // Reopen: hydration returns the STORED line ids — the identity a
        // real re-park keeps for untouched lines.
        final reopened = await draftDs.loadDraft(cartId);
        expect(reopened, isNotNull);
        expect(reopened!.tableId, tableId);
        expect(reopened.items, hasLength(2));
        expect(
          reopened.items.map((i) => i.lineId),
          contains(lineOf(x, cartId).lineId),
        );
        expect(
          reopened.items.map((i) => i.lineId),
          contains(lineOf(y, cartId).lineId),
        );

        // Add Z on top of the hydrated lines and re-park.
        await draftDs.upsertDraft(
          cartId,
          CartSnapshot(
            items: [...reopened.items, lineOf(z, cartId)],
            tableId: tableId,
          ),
        );

        // Persisted state: exactly X,Y,Z — correct quantities, still bound.
        final persisted = (await draftDs.loadDraft(cartId))!;
        expect(persisted.tableId, tableId);
        expect(persisted.items, hasLength(3));
        final qtyByProduct = {
          for (final i in persisted.items) i.product.id: i.qty,
        };
        expect(qtyByProduct['p-x'], 1);
        expect(qtyByProduct['p-y'], 2);
        expect(qtyByProduct['p-z'], 1);

        // Raw rows: exactly the three live line ids — no duplicates, no
        // soft-deleted residue left behind by the delta sync.
        final rows = await rawItemRows(cartId);
        expect(rows.map((r) => r.id).toSet(), {
          lineOf(x, cartId).lineId,
          lineOf(y, cartId).lineId,
          lineOf(z, cartId).lineId,
        });

        // The table stays effectively occupied by this one active cart.
        expect(
          (await tableRepo.getTableById(tableId))!.status,
          TableStatus.occupied,
        );
      },
    );

    test(
      're-parking an unchanged reopened snapshot does not duplicate rows',
      () async {
        final x = await seedProduct('p-idem');
        final tableId = await tableRepo.addTable(name: 'T-B');

        final cartId = await draftDs.createDraft(name: 'Bill T-B');
        var snapshot = CartSnapshot(
          items: [lineOf(x, cartId, qty: 3)],
          tableId: tableId,
        );
        await draftDs.upsertDraft(cartId, snapshot);

        // Park/reopen/park again with the SAME hydrated content twice.
        snapshot = CartSnapshot(
          items: (await draftDs.loadDraft(cartId))!.items,
          tableId: tableId,
        );
        await draftDs.upsertDraft(cartId, snapshot);
        await draftDs.upsertDraft(cartId, snapshot);

        final persisted = (await draftDs.loadDraft(cartId))!;
        expect(persisted.tableId, tableId);
        expect(persisted.items.single.product.id, 'p-idem');
        expect(persisted.items.single.qty, 3);
        expect(await rawItemRows(cartId), hasLength(1));
      },
    );
  });
}
