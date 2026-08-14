import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

abstract class DraftCartLocalDatasource {
  Future<String> createDraft({String? name});
  Future<void> upsertDraft(
    String cartId,
    CartSnapshot snapshot, {
    String? name,
  });
  Future<DraftCart?> loadDraft(String cartId);
  Future<List<DraftCart>> listDrafts({bool includeArchived = false});
  Future<void> deleteDraft(String cartId);
  Future<void> renameDraft(String cartId, String name);
  Future<int> countDrafts();
  Future<int> archiveOldDrafts(DateTime cutoff);
}

@LazySingleton(as: DraftCartLocalDatasource)
class DraftCartLocalDatasourceImpl implements DraftCartLocalDatasource {
  DraftCartLocalDatasourceImpl(this._db, {required this.settingsRepo});
  final AppDatabase _db;
  final SettingsRepository settingsRepo;

  String? _cachedDeviceId;
  Future<String> _getDeviceId() async {
    return _cachedDeviceId ??=
        (await settingsRepo.load()).deviceConfig.deviceId;
  }

  @override
  Future<String> createDraft({String? name}) async {
    final id = IdGenerator.newId();
    final deviceId = await _getDeviceId();
    await _db
        .into(_db.draftCarts)
        .insert(
          DraftCartsCompanion.insert(
            id: id,
            name: Value(name),
            updatedAt: Value(DateTime.now()),
            deviceId: Value(deviceId),
          ),
        );
    return id;
  }

  @override
  Future<void> upsertDraft(
    String cartId,
    CartSnapshot snapshot, {
    String? name,
  }) async {
    final deviceId = await _getDeviceId();
    await _db.transaction(() async {
      await (_db.update(
        _db.draftCarts,
      )..where((t) => t.id.equals(cartId))).write(
        DraftCartsCompanion(
          // Null or blank → omit (do not wipe custom/auto names on autosave).
          name: (name != null && name.trim().isNotEmpty)
              ? Value(name.trim())
              : const Value.absent(),
          note: Value(snapshot.note.isEmpty ? null : snapshot.note),
          cartDiscountType: Value(snapshot.cartDiscountType),
          cartDiscountValue: Value(snapshot.cartDiscountValue),
          cartDiscountValueSatang: Value(
            snapshot.cartDiscountType?.toUpperCase() == 'AMOUNT' &&
                    snapshot.cartDiscountValue != null
                ? Money.fromDouble(snapshot.cartDiscountValue!)
                : null,
          ),
          orderType: Value(snapshot.orderType),
          orderChannel: Value(snapshot.orderChannel),
          externalOrderRef: Value(snapshot.externalOrderRef),
          tableId: Value(snapshot.tableId),
          serviceChargeRate: Value(snapshot.serviceChargeRate),
          customerId: Value(snapshot.customerId),
          promotionId: Value(snapshot.promotionId),
          promotionDiscountAmount: Value(snapshot.promotionDiscountAmount),
          updatedAt: Value(DateTime.now()),
          deviceId: Value(deviceId),
          // Phase M (C2): dual-write satang for money fields.
          // cartDiscountValue stays REAL (percent when type=PERCENT).
          // serviceChargeRate stays REAL (rate, not money).
          promotionDiscountAmountSatang: Value(
            Money.fromDouble(snapshot.promotionDiscountAmount),
          ),
        ),
      );

      await (_db.delete(
        _db.draftCartItems,
      )..where((t) => t.cartId.equals(cartId))).go();

      for (final item in snapshot.items) {
        await _db
            .into(_db.draftCartItems)
            .insert(
              DraftCartItemsCompanion.insert(
                // Persist stable cart line identity across save/load.
                id: item.lineId,
                cartId: cartId,
                productId: item.product.id,
                productName: item.product.name,
                price: item.product.price.value,
                qty: item.qty,
                discountType: Value(item.discountType),
                discountValue: Value(item.discountValue),
                discountValueSatang: Value(
                  item.discountType?.toUpperCase() == 'AMOUNT' &&
                          item.discountValue != null
                      ? Money.fromDouble(item.discountValue!)
                      : null,
                ),
                note: Value(item.note),
                productOptionsJson: Value(
                  _serializeSelectedOptions(item.selectedOptions),
                ),
                deviceId: Value(deviceId),
                // Phase M (C2): dual-write satang.
                // discountValue stays REAL (percent when type=PERCENT).
                priceSatang: Value(item.product.price),
              ),
            );
      }
    });
  }

  @override
  Future<DraftCart?> loadDraft(String cartId) async {
    final cart =
        await (_db.select(_db.draftCarts)
              ..where((t) => t.id.equals(cartId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (cart == null) return null;

    final itemRows = await (_db.select(
      _db.draftCartItems,
    )..where((t) => t.cartId.equals(cartId) & t.deletedAt.isNull())).get();

    final productIds = itemRows.map((r) => r.productId).toSet().toList();
    final productRows = await (_db.select(
      _db.products,
    )..where((t) => t.id.isIn(productIds))).get();
    final productMap = {for (final p in productRows) p.id: _productFromData(p)};

    final missingProductIds = itemRows
        .where((r) => !productMap.containsKey(r.productId))
        .map((r) => r.productId)
        .toSet();
    if (missingProductIds.isNotEmpty) {
      AppLogger.warning(
        'DraftCartLocalDatasource.loadDraft: skipped items with deleted products: $missingProductIds',
      );
    }

    final items = itemRows
        .where((r) => productMap.containsKey(r.productId))
        .map(
          (r) => CartItem(
            product: productMap[r.productId]!,
            qty: r.qty,
            discountType: r.discountType,
            discountValue: r.discountValueSatang?.value ?? r.discountValue,
            note: r.note,
            selectedOptions: _parseSelectedOptions(r.productOptionsJson),
            lineId: r.id,
          ),
        )
        .toList();

    return DraftCart.withCache(
      id: cart.id,
      name: cart.name,
      note: cart.note,
      cartDiscountType: cart.cartDiscountType,
      cartDiscountValue:
          cart.cartDiscountValueSatang?.value ?? cart.cartDiscountValue,
      orderType: cart.orderType,
      orderChannel: cart.orderChannel,
      externalOrderRef: cart.externalOrderRef,
      tableId: cart.tableId,
      serviceChargeRate: cart.serviceChargeRate,
      customerId: cart.customerId,
      promotionId: cart.promotionId,
      promotionDiscountAmount: moneyFromSatangOrBaht(
        cart.promotionDiscountAmountSatang,
        cart.promotionDiscountAmount,
      ),
      items: items,
      updatedAt: cart.updatedAt,
      deletedAt: cart.deletedAt,
      version: cart.version,
      skippedItemCount: missingProductIds.length,
    );
  }

  @override
  Future<List<DraftCart>> listDrafts({bool includeArchived = false}) async {
    final query = _db.select(_db.draftCarts)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    final carts = await query.get();
    if (carts.isEmpty) return [];

    final cartIds = carts.map((c) => c.id).toList();
    final allItemRows = await (_db.select(
      _db.draftCartItems,
    )..where((t) => t.cartId.isIn(cartIds) & t.deletedAt.isNull())).get();

    final allProductIds = allItemRows.map((r) => r.productId).toSet().toList();
    final allProductRows = allProductIds.isEmpty
        ? <ProductData>[]
        : await (_db.select(
            _db.products,
          )..where((t) => t.id.isIn(allProductIds))).get();
    final productMap = {
      for (final p in allProductRows) p.id: _productFromData(p),
    };

    final itemsByCartId = <String, List<CartItem>>{};
    for (final row in allItemRows) {
      final product = productMap[row.productId];
      if (product == null) continue;
      (itemsByCartId[row.cartId] ??= []).add(
        CartItem(
          product: product,
          qty: row.qty,
          discountType: row.discountType,
          discountValue: row.discountValueSatang?.value ?? row.discountValue,
          note: row.note,
          selectedOptions: _parseSelectedOptions(row.productOptionsJson),
          lineId: row.id,
        ),
      );
    }

    return carts
        .map(
          (cart) => DraftCart.withCache(
            id: cart.id,
            name: cart.name,
            note: cart.note,
            cartDiscountType: cart.cartDiscountType,
            cartDiscountValue:
                cart.cartDiscountValueSatang?.value ?? cart.cartDiscountValue,
            orderType: cart.orderType,
            orderChannel: cart.orderChannel,
            externalOrderRef: cart.externalOrderRef,
            tableId: cart.tableId,
            serviceChargeRate: cart.serviceChargeRate,
            customerId: cart.customerId,
            promotionId: cart.promotionId,
            promotionDiscountAmount: moneyFromSatangOrBaht(
              cart.promotionDiscountAmountSatang,
              cart.promotionDiscountAmount,
            ),
            items: itemsByCartId[cart.id] ?? [],
            updatedAt: cart.updatedAt,
            deletedAt: cart.deletedAt,
            version: cart.version,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteDraft(String cartId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.draftCartItems)
            ..where((t) => t.cartId.equals(cartId)))
          .write(DraftCartItemsCompanion(deletedAt: Value(now)));
      await (_db.update(
        _db.draftCarts,
      )..where((t) => t.id.equals(cartId))).write(
        DraftCartsCompanion(
          deletedAt: Value(now),
          isArchived: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> renameDraft(String cartId, String name) =>
      (_db.update(_db.draftCarts)..where((t) => t.id.equals(cartId))).write(
        DraftCartsCompanion(name: Value(name)),
      );

  @override
  Future<int> countDrafts() async {
    final countExpr = _db.draftCarts.id.count();
    final query = _db.selectOnly(_db.draftCarts)
      ..where(
        _db.draftCarts.isArchived.equals(false) &
            _db.draftCarts.deletedAt.isNull(),
      )
      ..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<int> archiveOldDrafts(DateTime cutoff) async {
    final query = _db.update(_db.draftCarts)
      ..where(
        (t) =>
            t.isArchived.equals(false) &
            t.deletedAt.isNull() &
            t.updatedAt.isSmallerThanValue(cutoff),
      );
    final rows = await query.write(
      const DraftCartsCompanion(isArchived: Value(true)),
    );
    return rows;
  }

  Product _productFromData(ProductData d) => Product(
    id: d.id,
    name: d.name,
    price: moneyFromSatangOrBaht(d.priceSatang, d.price),
    stock: d.stock,
    categoryId: d.categoryId,
    imageUrl: d.imageUrl,
    imagePath: d.imagePath,
    imageThumbnailPath: d.imageThumbnailPath,
    isActive: d.isActive,
    trackStock: d.trackStock,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  List<SelectedProductOption> _parseSelectedOptions(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => SelectedProductOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      AppLogger.warning(
        'draft_cart_local: parseSelectedOptions failed',
        error: e,
        stack: stack,
      );
      return const [];
    }
  }

  String? _serializeSelectedOptions(List<SelectedProductOption> options) {
    if (options.isEmpty) return null;
    return jsonEncode(options.map((o) => o.toJson()).toList());
  }
}
