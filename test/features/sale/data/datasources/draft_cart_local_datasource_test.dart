import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
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
    productDs = ProductLocalDatasourceImpl(db);
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
      price: data.price,
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

      await ds.upsertDraft(
        cartId,
        CartState(
          items: [CartItem(product: product, qty: 3)],
          note: 'test note',
        ),
      );

      final loaded = await ds.loadDraft(cartId);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Cart1');
      expect(loaded.items, hasLength(1));
      expect(loaded.items.first.product.id, 'prod-001');
      expect(loaded.items.first.qty, 3);
      expect(loaded.note, 'test note');
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
      await ds.upsertDraft(cartId, const CartState(items: [], note: ''));

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
        CartState(items: [CartItem(product: product, qty: 1)]),
      );

      await ds.upsertDraft(
        cartId,
        CartState(items: [CartItem(product: product2, qty: 5)]),
      );

      final loaded = await ds.loadDraft(cartId);
      expect(loaded!.items, hasLength(1));
      expect(loaded.items.first.product.id, 'prod-002');
      expect(loaded.items.first.qty, 5);
    });
  });
}
