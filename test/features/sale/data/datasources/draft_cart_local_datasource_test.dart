import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late DraftCartLocalDatasourceImpl ds;
  late FakeSettingsRepository fakeSettingsRepo;
  late ProductLocalDatasourceImpl productDs;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    ds = DraftCartLocalDatasourceImpl(db, settingsRepo: fakeSettingsRepo);
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
  });

  tearDown(() => db.close());

  Future<Product> seedProduct(String id) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Product-$id',
        price: 100.0,
        stock: const Value(50),
      ),
    );
    final data = await (db.select(
      db.products,
    )..where((t) => t.id.equals(id))).getSingle();
    return Product(
      id: data.id,
      name: data.name,
      price: Money.fromDouble(data.price),
      stock: data.stock,
      isActive: data.isActive,
      trackStock: data.trackStock,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  group('DraftCartLocalDatasourceImpl', () {
    test('createDraft returns a non-empty id', () async {
      final id = await ds.createDraft(name: 'Test Draft');
      expect(id, isNotEmpty);
    });

    test('loadDraft returns null for non-existent id', () async {
      final result = await ds.loadDraft('non-existent');
      expect(result, isNull);
    });

    test('upsertDraft and loadDraft round-trip', () async {
      final product = await seedProduct('prod-001');
      final cartId = await ds.createDraft(name: 'Cart1');
      final line = CartItem(
        product: product,
        qty: 3,
        lineId: 'stable-line-1',
        discountType: 'AMOUNT',
        discountValue: 0.50,
      );

      await ds.upsertDraft(
        cartId,
        CartSnapshot(
          items: [line],
          note: 'test note',
          cartDiscountType: 'AMOUNT',
          cartDiscountValue: 1.23,
        ),
      );

      final loaded = await ds.loadDraft(cartId);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Cart1');
      expect(loaded.items, hasLength(1));
      expect(loaded.items.first.product.id, 'prod-001');
      expect(loaded.items.first.qty, 3);
      expect(loaded.items.first.lineId, 'stable-line-1');
      expect(loaded.items.first.discountValue, 0.50);
      expect(loaded.cartDiscountValue, 1.23);
      expect(loaded.note, 'test note');

      final cartRow = await (db.select(
        db.draftCarts,
      )..where((t) => t.id.equals(cartId))).getSingle();
      expect(cartRow.cartDiscountValueSatang, const Money.fromSatang(123));
      final itemRow = await (db.select(
        db.draftCartItems,
      )..where((t) => t.id.equals('stable-line-1'))).getSingle();
      expect(itemRow.discountValueSatang, const Money.fromSatang(50));
    });

    test('listDrafts returns empty when no drafts', () async {
      final drafts = await ds.listDrafts();
      expect(drafts, isEmpty);
    });

    test('listDrafts returns all non-archived drafts', () async {
      await ds.createDraft(name: 'A');
      await ds.createDraft(name: 'B');

      final drafts = await ds.listDrafts();
      expect(drafts, hasLength(2));
    });

    test('deleteDraft soft-deletes and archives', () async {
      final cartId = await ds.createDraft(name: 'ToDelete');
      await ds.deleteDraft(cartId);

      final drafts = await ds.listDrafts();
      expect(drafts, isEmpty);

      final count = await ds.countDrafts();
      expect(count, 0);
    });

    test('renameDraft updates the name', () async {
      final cartId = await ds.createDraft(name: 'OldName');
      await ds.renameDraft(cartId, 'NewName');

      final loaded = await ds.loadDraft(cartId);
      expect(loaded!.name, 'NewName');
    });

    test('countDrafts returns count of non-archived', () async {
      await ds.createDraft(name: 'A');
      await ds.createDraft(name: 'B');
      final cartId = await ds.createDraft(name: 'C');
      await ds.deleteDraft(cartId);

      final count = await ds.countDrafts();
      expect(count, 2);
    });

    test('archiveOldDrafts archives drafts older than cutoff', () async {
      final cartId = await ds.createDraft(name: 'Old');
      await ds.upsertDraft(cartId, const CartSnapshot(items: [], note: ''));

      final archived = await ds.archiveOldDrafts(
        DateTime.now().add(const Duration(days: 1)),
      );
      expect(archived, 1);

      final count = await ds.countDrafts();
      expect(count, 0);
    });

    test('upsertDraft replaces items on second call', () async {
      final product = await seedProduct('prod-001');
      final product2 = await seedProduct('prod-002');
      final cartId = await ds.createDraft(name: 'Cart');

      await ds.upsertDraft(
        cartId,
        CartSnapshot(items: [CartItem(product: product, qty: 1)]),
      );

      await ds.upsertDraft(
        cartId,
        CartSnapshot(items: [CartItem(product: product2, qty: 5)]),
      );

      final loaded = await ds.loadDraft(cartId);
      expect(loaded!.items, hasLength(1));
      expect(loaded.items.first.product.id, 'prod-002');
      expect(loaded.items.first.qty, 5);
    });
  });

  group('DraftCartLocalDatasourceImpl.getDraftCounts parity', () {
    /// Seeds the full mixed fixture set and returns the created cart ids.
    Future<
      ({
        String empty,
        String withItems,
        String ghostProduct,
        String zeroQty,
        String softDeletedItem,
      })
    >
    seedMixedCarts() async {
      final product1 = await seedProduct('prod-001');
      final product2 = await seedProduct('prod-002');

      // Never saved โ€” zero items.
      final empty = await ds.createDraft(name: 'Empty');

      // Two live lines โ€” an open bill.
      final withItems = await ds.createDraft(name: 'With items');
      await ds.upsertDraft(
        withItems,
        CartSnapshot(
          items: [
            CartItem(product: product1, qty: 2, lineId: 'line-full-1'),
            CartItem(product: product2, qty: 1, lineId: 'line-full-2'),
          ],
        ),
      );

      // Item whose product does not exist โ€” listDrafts skips the line, so
      // this cart must NOT count as open.
      final ghostProduct = await ds.createDraft(name: 'Ghost product');
      await ds.upsertDraft(
        ghostProduct,
        CartSnapshot(
          items: [CartItem(product: product1, qty: 4, lineId: 'line-ghost')],
        ),
      );
      await (db.delete(
        db.products,
      )..where((t) => t.id.equals('prod-001'))).go();

      // All-zero quantities sum to itemCount 0 โ€” not an open bill either.
      final zeroQty = await ds.createDraft(name: 'Zero qty');
      await ds.upsertDraft(
        zeroQty,
        CartSnapshot(
          items: [
            CartItem(product: product2, qty: 0, lineId: 'line-zero-1'),
            CartItem(product: product2, qty: 0, lineId: 'line-zero-2'),
          ],
        ),
      );

      // One live line plus soft-deleted residue โ€” only the live line counts.
      final softDeletedItem = await ds.createDraft(name: 'Partial');
      await ds.upsertDraft(
        softDeletedItem,
        CartSnapshot(
          items: [
            CartItem(product: product2, qty: 3, lineId: 'line-partial-live'),
            CartItem(product: product2, qty: 9, lineId: 'line-partial-dead'),
          ],
        ),
      );
      await (db.update(
        db.draftCartItems,
      )..where((t) => t.id.equals('line-partial-dead'))).write(
        DraftCartItemsCompanion(deletedAt: Value(DateTime(2026, 1, 1))),
      );

      return (
        empty: empty,
        withItems: withItems,
        ghostProduct: ghostProduct,
        zeroQty: zeroQty,
        softDeletedItem: softDeletedItem,
      );
    }

    test(
      'aggregate equals listDrafts-derived counts over mixed fixtures',
      () async {
        final ids = await seedMixedCarts();

        // Archive + soft-delete two more carts โ€” excluded from every count.
        await (db.update(db.draftCarts)..where((t) => t.id.equals(ids.empty)))
            .write(const DraftCartsCompanion(isArchived: Value(true)));
        await ds.deleteDraft(ids.zeroQty);

        final drafts = await ds.listDrafts();
        final expected = (
          draftCount: drafts.length,
          openBillCount: drafts.where((d) => d.itemCount > 0).length,
        );

        final counts = await ds.getDraftCounts();

        // Bit-identical to computing from the hydrated listโ€ฆ
        expect(counts, expected);
        // โ€ฆand to the hand-computed fixture expectation:
        // withItems (qty 2+1) + partial (live line qty 3) are open; empty is
        // archived out, zeroQty soft-deleted out; ghostProduct has no live
        // qualifying line so it is counted as a draft but not an open bill.
        expect(counts.draftCount, 3);
        expect(counts.openBillCount, 2);
      },
    );

    test('aggregate equals listDrafts-derived counts with no drafts', () async {
      final drafts = await ds.listDrafts();
      final counts = await ds.getDraftCounts();
      expect(counts.draftCount, drafts.length);
      expect(counts.draftCount, 0);
      expect(counts.openBillCount, drafts.where((d) => d.itemCount > 0).length);
      expect(counts.openBillCount, 0);
    });
  });

  group('DraftCartLocalDatasourceImpl.upsertDraft delta sync', () {
    test('removing 2 of 3 lines persists exactly the remaining row', () async {
      final product = await seedProduct('prod-001');
      final cartId = await ds.createDraft(name: 'Cart');

      CartItem line(String id, {int qty = 1}) =>
          CartItem(product: product, qty: qty, lineId: id);

      await ds.upsertDraft(
        cartId,
        CartSnapshot(items: [line('L1'), line('L2'), line('L3')]),
      );

      // Edit removes L1 and L2; survivor keeps identity with new qty.
      await ds.upsertDraft(cartId, CartSnapshot(items: [line('L3', qty: 7)]));

      final rows = await (db.select(
        db.draftCartItems,
      )..where((t) => t.cartId.equals(cartId))).get();
      // No orphans from removed lines, no duplicates from re-inserts.
      expect(rows.map((r) => r.id), ['L3']);
      expect(rows.single.productId, 'prod-001');
      expect(rows.single.qty, 7);

      final loaded = await ds.loadDraft(cartId);
      expect(loaded!.items, hasLength(1));
      expect(loaded.items.single.lineId, 'L3');
      expect(loaded.items.single.qty, 7);
    });

    test(
      'resaving an unchanged snapshot leaves stored rows untouched',
      () async {
        final product = await seedProduct('prod-001');
        final cartId = await ds.createDraft(name: 'Cart');
        final snapshot = CartSnapshot(
          items: [
            CartItem(product: product, qty: 2, lineId: 'L1'),
            CartItem(product: product, qty: 1, lineId: 'L2'),
          ],
          note: 'keep me',
        );
        await ds.upsertDraft(cartId, snapshot);

        Future<List<(String, int, DateTime?, DateTime?, int)>>
        readRows() async =>
            (await (db.select(
                  db.draftCartItems,
                )..where((t) => t.cartId.equals(cartId))).get())
                .map((r) => (r.id, r.qty, r.updatedAt, r.deletedAt, r.version))
                .toList();
        final before = await readRows();

        // Long enough that a delete-all + reinsert would visibly bump
        // updated_at; skipping unchanged rows must keep it frozen.
        await Future<void>.delayed(const Duration(seconds: 2));
        await ds.upsertDraft(cartId, snapshot);

        final after = await readRows();
        expect(after, before);
      },
    );

    test('changed line is rewritten in place keeping its line id', () async {
      final product = await seedProduct('prod-001');
      final product2 = await seedProduct('prod-002');
      final cartId = await ds.createDraft(name: 'Cart');

      await ds.upsertDraft(
        cartId,
        CartSnapshot(
          items: [
            CartItem(
              product: product,
              qty: 1,
              lineId: 'L1',
              discountType: 'AMOUNT',
              discountValue: 0.50,
              note: 'no ice',
            ),
          ],
        ),
      );
      await ds.upsertDraft(
        cartId,
        CartSnapshot(
          items: [
            CartItem(
              product: product2,
              qty: 4,
              lineId: 'L1',
              note: 'extra shot',
            ),
          ],
        ),
      );

      final rows = await (db.select(
        db.draftCartItems,
      )..where((t) => t.id.equals('L1'))).get();
      expect(rows, hasLength(1));
      expect(rows.single.productId, 'prod-002');
      expect(rows.single.qty, 4);
      expect(rows.single.note, 'extra shot');
      expect(rows.single.discountValueSatang, isNull);
    });
  });

  group('DraftCartLocalDatasourceImpl.upsertDraft name handling', () {
    test('blank name keeps the existing name', () async {
      final cartId = await ds.createDraft(name: 'Keep Me');

      await ds.upsertDraft(cartId, const CartSnapshot(items: []), name: '   ');

      final loaded = await ds.loadDraft(cartId);
      expect(loaded!.name, 'Keep Me');
    });
  });

  group('DraftCartLocalDatasourceImpl.fireUnfiredLines', () {
    Future<void> seedTable(
      String id,
      String name, {
      String status = 'available',
    }) async {
      await db
          .into(db.restaurantTables)
          .insert(
            RestaurantTablesCompanion.insert(
              id: id,
              name: name,
              status: Value(status),
            ),
          );
    }

    Future<String> seedCart({
      String? tableId,
      List<CartItem> items = const [],
    }) async {
      final cartId = await ds.createDraft(name: 'Cart');
      await ds.upsertDraft(
        cartId,
        CartSnapshot(items: items, tableId: tableId),
      );
      return cartId;
    }

    test('throws NotFoundError when cart does not exist', () async {
      await expectLater(
        ds.fireUnfiredLines('missing-cart'),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('returns empty ticket when no unfired lines', () async {
      await seedTable('table-1', 'A1');
      final cartId = await seedCart(tableId: 'table-1');

      final ticket = await ds.fireUnfiredLines(cartId);

      expect(ticket.cartId, cartId);
      expect(ticket.lines, isEmpty);
      expect(ticket.tableId, 'table-1');
      expect(ticket.tableName, isNull);
    });

    test('fires lines and resolves the table name', () async {
      await seedTable('table-1', 'A1');
      final product = await seedProduct('prod-001');
      final cartId = await seedCart(
        tableId: 'table-1',
        items: [
          CartItem(product: product, qty: 2, lineId: 'L1', note: 'spicy'),
        ],
      );

      final ticket = await ds.fireUnfiredLines(cartId);

      expect(ticket.lines, hasLength(1));
      expect(ticket.lines.first.lineId, 'L1');
      expect(ticket.lines.first.productId, 'prod-001');
      expect(ticket.lines.first.productName, 'Product-prod-001');
      expect(ticket.lines.first.qty, 2);
      expect(ticket.lines.first.note, 'spicy');
      expect(ticket.tableId, 'table-1');
      expect(ticket.tableName, 'A1');

      final row = await (db.select(
        db.draftCartItems,
      )..where((t) => t.id.equals('L1'))).getSingle();
      expect(row.firedAt, isNotNull);
    });

    test('second fire returns an empty ticket (already fired)', () async {
      final product = await seedProduct('prod-001');
      final cartId = await seedCart(
        items: [CartItem(product: product, qty: 1, lineId: 'L1')],
      );

      await ds.fireUnfiredLines(cartId);
      final ticket = await ds.fireUnfiredLines(cartId);

      expect(ticket.lines, isEmpty);
    });

    test('selected options json is carried into the ticket line', () async {
      final product = await seedProduct('prod-001');
      final cartId = await seedCart(
        items: [
          CartItem(
            product: product,
            qty: 1,
            lineId: 'L1',
            selectedOptions: const [
              SelectedProductOption(
                optionId: 'opt-1',
                optionName: 'Extra egg',
                groupId: 'g1',
                groupName: 'Add-ons',
              ),
            ],
          ),
        ],
      );

      final ticket = await ds.fireUnfiredLines(cartId);

      expect(ticket.lines.first.optionsJson, isNotNull);
      expect(ticket.lines.first.optionsJson, contains('opt-1'));
    });
  });

  group('DraftCartLocalDatasourceImpl.transferDraftCart', () {
    Future<void> seedTable(
      String id,
      String name, {
      String status = 'available',
    }) async {
      await db
          .into(db.restaurantTables)
          .insert(
            RestaurantTablesCompanion.insert(
              id: id,
              name: name,
              status: Value(status),
            ),
          );
    }

    Future<String> seedCartBoundTo(String tableId) async {
      final cartId = await ds.createDraft(name: 'Cart');
      await ds.upsertDraft(
        cartId,
        CartSnapshot(items: const [], tableId: tableId),
      );
      return cartId;
    }

    test('rejects identical source and target', () async {
      await expectLater(
        ds.transferDraftCart(
          cartId: 'c1',
          sourceTableId: 'table-1',
          targetTableId: 'table-1',
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'TableTransferSameTarget',
          ),
        ),
      );
    });

    test('throws NotFound when the cart does not exist', () async {
      await seedTable('table-1', 'A1');
      await seedTable('table-2', 'A2');

      await expectLater(
        ds.transferDraftCart(
          cartId: 'missing',
          sourceTableId: 'table-1',
          targetTableId: 'table-2',
        ),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('throws TableTransferSourceMismatch when bound elsewhere', () async {
      await seedTable('table-1', 'A1');
      await seedTable('table-2', 'A2');
      await seedTable('table-3', 'A3');
      final cartId = await seedCartBoundTo('table-1');

      await expectLater(
        ds.transferDraftCart(
          cartId: cartId,
          sourceTableId: 'table-2',
          targetTableId: 'table-3',
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'TableTransferSourceMismatch',
          ),
        ),
      );
    });

    test('throws NotFound when the target table does not exist', () async {
      await seedTable('table-1', 'A1');
      final cartId = await seedCartBoundTo('table-1');

      await expectLater(
        ds.transferDraftCart(
          cartId: cartId,
          sourceTableId: 'table-1',
          targetTableId: 'missing-table',
        ),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('throws TableReserved when the target is reserved', () async {
      await seedTable('table-1', 'A1');
      await seedTable('table-2', 'A2', status: 'reserved');
      final cartId = await seedCartBoundTo('table-1');

      await expectLater(
        ds.transferDraftCart(
          cartId: cartId,
          sourceTableId: 'table-1',
          targetTableId: 'table-2',
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'TableReserved',
          ),
        ),
      );
    });

    test('throws TableAlreadyBound when target holds another cart', () async {
      await seedTable('table-1', 'A1');
      await seedTable('table-2', 'A2');
      final cartId = await seedCartBoundTo('table-1');
      await seedCartBoundTo('table-2');

      await expectLater(
        ds.transferDraftCart(
          cartId: cartId,
          sourceTableId: 'table-1',
          targetTableId: 'table-2',
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'TableAlreadyBound',
          ),
        ),
      );
    });

    test('moves the cart and bumps its version on success', () async {
      await seedTable('table-1', 'A1');
      await seedTable('table-2', 'A2');
      final cartId = await seedCartBoundTo('table-1');
      final before = await (db.select(
        db.draftCarts,
      )..where((t) => t.id.equals(cartId))).getSingle();

      await ds.transferDraftCart(
        cartId: cartId,
        sourceTableId: 'table-1',
        targetTableId: 'table-2',
      );

      final after = await (db.select(
        db.draftCarts,
      )..where((t) => t.id.equals(cartId))).getSingle();
      expect(after.tableId, 'table-2');
      expect(after.version, before.version + 1);
    });
  });

  group('DraftCartLocalDatasourceImpl corrupt options json', () {
    test('loadDraft returns empty options instead of crashing', () async {
      final product = await seedProduct('prod-001');
      final cartId = await ds.createDraft(name: 'Cart');
      await ds.upsertDraft(
        cartId,
        CartSnapshot(
          items: [
            CartItem(
              product: product,
              qty: 1,
              lineId: 'L1',
              selectedOptions: const [
                SelectedProductOption(
                  optionId: 'opt-1',
                  optionName: 'Extra egg',
                  groupId: 'g1',
                  groupName: 'Add-ons',
                ),
              ],
            ),
          ],
        ),
      );
      await (db.update(
        db.draftCartItems,
      )..where((t) => t.id.equals('L1'))).write(
        const DraftCartItemsCompanion(
          productOptionsJson: Value('{not-valid-json'),
        ),
      );

      final loaded = await ds.loadDraft(cartId);

      expect(loaded, isNotNull);
      expect(loaded!.items, hasLength(1));
      expect(loaded.items.first.selectedOptions, isEmpty);
    });
  });
}
