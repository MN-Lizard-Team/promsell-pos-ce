import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';

abstract class DraftCartLocalDatasource {
  Future<String> createDraft({String? name});
  Future<void> upsertDraft(String cartId, SaleState state, {String? name});
  Future<DraftCart?> loadDraft(String cartId);
  Future<List<DraftCart>> listDrafts();
  Future<void> deleteDraft(String cartId);
  Future<void> renameDraft(String cartId, String name);
  Future<int> countDrafts();
}

class DraftCartLocalDatasourceImpl implements DraftCartLocalDatasource {
  const DraftCartLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<String> createDraft({String? name}) async {
    final id = IdGenerator.newId();
    await _db
        .into(_db.draftCarts)
        .insert(
          DraftCartsCompanion.insert(
            id: id,
            name: Value(name),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return id;
  }

  @override
  Future<void> upsertDraft(
    String cartId,
    SaleState state, {
    String? name,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.draftCarts,
      )..where((t) => t.id.equals(cartId))).write(
        DraftCartsCompanion(
          name: Value(name),
          note: Value(state.note.isEmpty ? null : state.note),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (_db.delete(
        _db.draftCartItems,
      )..where((t) => t.cartId.equals(cartId))).go();

      for (final item in state.items) {
        await _db
            .into(_db.draftCartItems)
            .insert(
              DraftCartItemsCompanion.insert(
                id: IdGenerator.newId(),
                cartId: cartId,
                productId: item.product.id,
                productName: item.product.name,
                price: item.product.price,
                qty: item.qty,
                discountType: Value(item.discountType),
                discountValue: Value(item.discountValue),
              ),
            );
      }
    });
  }

  @override
  Future<DraftCart?> loadDraft(String cartId) async {
    final cart = await (_db.select(
      _db.draftCarts,
    )..where((t) => t.id.equals(cartId))).getSingleOrNull();
    if (cart == null) return null;

    final itemRows = await (_db.select(
      _db.draftCartItems,
    )..where((t) => t.cartId.equals(cartId))).get();

    final productIds = itemRows.map((r) => r.productId).toSet().toList();
    final productRows = await (_db.select(
      _db.products,
    )..where((t) => t.id.isIn(productIds))).get();
    final productMap = {for (final p in productRows) p.id: _productFromData(p)};

    final items = itemRows
        .where((r) => productMap.containsKey(r.productId))
        .map(
          (r) => CartItem(
            product: productMap[r.productId]!,
            qty: r.qty,
            discountType: r.discountType,
            discountValue: r.discountValue,
          ),
        )
        .toList();

    return DraftCart(
      id: cart.id,
      name: cart.name,
      note: cart.note,
      items: items,
      updatedAt: cart.updatedAt,
    );
  }

  @override
  Future<List<DraftCart>> listDrafts() async {
    final carts = await (_db.select(
      _db.draftCarts,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

    final result = <DraftCart>[];
    for (final cart in carts) {
      final itemRows = await (_db.select(
        _db.draftCartItems,
      )..where((t) => t.cartId.equals(cart.id))).get();

      final productIds = itemRows.map((r) => r.productId).toSet().toList();
      final productRows = productIds.isEmpty
          ? <ProductData>[]
          : await (_db.select(
              _db.products,
            )..where((t) => t.id.isIn(productIds))).get();
      final productMap = {
        for (final p in productRows) p.id: _productFromData(p),
      };

      final items = itemRows
          .where((r) => productMap.containsKey(r.productId))
          .map(
            (r) => CartItem(
              product: productMap[r.productId]!,
              qty: r.qty,
              discountType: r.discountType,
              discountValue: r.discountValue,
            ),
          )
          .toList();

      result.add(
        DraftCart(
          id: cart.id,
          name: cart.name,
          note: cart.note,
          items: items,
          updatedAt: cart.updatedAt,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> deleteDraft(String cartId) =>
      (_db.delete(_db.draftCarts)..where((t) => t.id.equals(cartId))).go();

  @override
  Future<void> renameDraft(String cartId, String name) =>
      (_db.update(_db.draftCarts)..where((t) => t.id.equals(cartId))).write(
        DraftCartsCompanion(name: Value(name)),
      );

  @override
  Future<int> countDrafts() async {
    final count = await _db.draftCarts.count().getSingle();
    return count;
  }

  Product _productFromData(ProductData d) => Product(
    id: d.id,
    name: d.name,
    price: d.price,
    stock: d.stock,
    category: d.categoryId,
    imageUrl: d.imageUrl,
    isActive: d.isActive,
    trackStock: d.trackStock,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );
}
