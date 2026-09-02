import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/kitchen_ticket.dart';
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

  /// Bills-board counters in one aggregate query.
  ///
  /// Bit-identical to computing from [listDrafts] (`draftCount` =
  /// drafts.length, `openBillCount` = carts with itemCount > 0) without
  /// hydrating any items or Product objects.
  Future<({int draftCount, int openBillCount})> getDraftCounts();
  Future<int> archiveOldDrafts(DateTime cutoff);
  Future<KitchenTicket> fireUnfiredLines(String cartId);
  Future<void> transferDraftCart({
    required String cartId,
    required String sourceTableId,
    required String targetTableId,
  });
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
    try {
      await _db.transaction(() async {
        final existingCart = await (_db.select(
          _db.draftCarts,
        )..where((t) => t.id.equals(cartId))).getSingleOrNull();
        final openedAt =
            existingCart?.openedAt ??
            snapshot.openedAt ??
            ((snapshot.tableId != null || snapshot.items.isNotEmpty)
                ? DateTime.now()
                : null);
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
            guestCount: Value(snapshot.guestCount),
            openedAt: Value(openedAt),
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

        await _syncDraftItems(cartId, snapshot.items, deviceId);
      });
    } catch (e) {
      if (_isTableAlreadyBoundError(e)) {
        throw BusinessRuleError(
          'TableAlreadyBound',
          details: 'Table ${snapshot.tableId} already has an active draft cart',
        );
      }
      rethrow;
    }
  }

  /// True when the failure is idx_draft_carts_table_id_unique: another
  /// ACTIVE cart (not archived, not soft-deleted) already claims this table.
  bool _isTableAlreadyBoundError(Object error) {
    if (error is SqliteException) {
      final primaryCode = error.extendedResultCode & 0xFF;
      if (primaryCode != 19) return false; // not SQLITE_CONSTRAINT
    }
    final msg = error.toString().toLowerCase();
    return msg.contains('unique') && msg.contains('draft_carts.table_id');
  }

  /// Persists [items] as the complete item set of [cartId] by writing only
  /// the delta against the stored rows: delete lines gone from the snapshot,
  /// insert new line ids, update changed ones — one [batch], inside the
  /// caller's [upsertDraft] transaction.
  ///
  /// Net effect matches the former delete-all + reinsert exactly: rows absent
  /// from the snapshot are hard-deleted (including soft-deleted residue), and
  /// an incoming line id colliding with soft-deleted residue is re-inserted
  /// fresh so deletedAt/version/updatedAt end up as a reinsert would leave
  /// them.
  Future<void> _syncDraftItems(
    String cartId,
    List<CartItem> items,
    String deviceId,
  ) async {
    final existingRows = await (_db.select(
      _db.draftCartItems,
    )..where((t) => t.cartId.equals(cartId))).get();

    final desiredById = {for (final item in items) item.lineId: item};

    final deleteIds = [
      for (final row in existingRows)
        if (!desiredById.containsKey(row.id) || row.deletedAt != null) row.id,
    ];

    final liveRowById = {
      for (final row in existingRows)
        if (row.deletedAt == null && desiredById.containsKey(row.id))
          row.id: row,
    };
    final changedItems = [
      for (final entry in liveRowById.entries)
        if (!_samePersistedItem(entry.value, desiredById[entry.key]!, deviceId))
          desiredById[entry.key]!,
    ];
    final insertItems = [
      for (final item in items)
        if (!liveRowById.containsKey(item.lineId)) item,
    ];

    await _db.batch((b) {
      if (deleteIds.isNotEmpty) {
        b.deleteWhere(_db.draftCartItems, (t) => t.id.isIn(deleteIds));
      }
      for (final item in insertItems) {
        b.insert(_db.draftCartItems, _itemCompanion(cartId, item, deviceId));
      }
      for (final item in changedItems) {
        // Changed lines are stamped like a reinsert would be; unchanged rows
        // keep their original updatedAt.
        b.update(
          _db.draftCartItems,
          _itemCompanion(
            cartId,
            item,
            deviceId,
          ).copyWith(updatedAt: Value(DateTime.now())),
          where: (t) => t.id.equals(item.lineId),
        );
      }
    });
  }

  bool _samePersistedItem(
    DraftCartItemData row,
    CartItem item,
    String deviceId,
  ) =>
      row.productId == item.product.id &&
      row.productName == item.product.name &&
      row.price == item.product.price.value &&
      row.qty == item.qty &&
      row.discountType == item.discountType &&
      row.discountValue == item.discountValue &&
      row.discountValueSatang == _discountSatangOf(item) &&
      row.note == item.note &&
      row.productOptionsJson ==
          _serializeSelectedOptions(item.selectedOptions) &&
      row.deviceId == deviceId &&
      row.priceSatang == item.product.price;

  /// Full persisted-column mapping for a cart line — single source of truth
  /// so insert and update paths always agree.
  DraftCartItemsCompanion _itemCompanion(
    String cartId,
    CartItem item,
    String deviceId,
  ) => DraftCartItemsCompanion(
    // Persist stable cart line identity across save/load.
    id: Value(item.lineId),
    cartId: Value(cartId),
    productId: Value(item.product.id),
    productName: Value(item.product.name),
    price: Value(item.product.price.value),
    qty: Value(item.qty),
    discountType: Value(item.discountType),
    discountValue: Value(item.discountValue),
    discountValueSatang: Value(_discountSatangOf(item)),
    note: Value(item.note),
    productOptionsJson: Value(_serializeSelectedOptions(item.selectedOptions)),
    deviceId: Value(deviceId),
    // Phase M (C2): dual-write satang.
    // discountValue stays REAL (percent when type=PERCENT).
    priceSatang: Value(item.product.price),
  );

  Money? _discountSatangOf(CartItem item) =>
      item.discountType?.toUpperCase() == 'AMOUNT' && item.discountValue != null
      ? Money.fromDouble(item.discountValue!)
      : null;

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
      guestCount: cart.guestCount,
      openedAt: cart.openedAt,
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
            guestCount: cart.guestCount,
            openedAt: cart.openedAt,
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
  Future<({int draftCount, int openBillCount})> getDraftCounts() async {
    // Same population as listDrafts(includeArchived: false): not archived,
    // not soft-deleted. A cart counts as an open bill when the sum of qty of
    // its live item rows (row not soft-deleted, product still existing — the
    // rows listDrafts would hydrate) is positive, i.e. DraftCart.itemCount > 0.
    final row = await _db.customSelect('''
          SELECT COUNT(*) AS draft_count,
                 COALESCE(SUM(CASE WHEN COALESCE(q.total_qty, 0) > 0
                                   THEN 1 ELSE 0 END), 0) AS open_bill_count
          FROM draft_carts c
          LEFT JOIN (
            SELECT i.cart_id AS cart_id, SUM(i.qty) AS total_qty
            FROM draft_cart_items i
            WHERE i.deleted_at IS NULL
              AND EXISTS (SELECT 1 FROM products p WHERE p.id = i.product_id)
            GROUP BY i.cart_id
          ) q ON q.cart_id = c.id
          WHERE c.deleted_at IS NULL AND c.is_archived = 0
          ''').getSingle();
    return (
      draftCount: row.read<int>('draft_count'),
      openBillCount: row.read<int>('open_bill_count'),
    );
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

  @override
  Future<KitchenTicket> fireUnfiredLines(String cartId) async {
    final firedAt = DateTime.now();
    return _db.transaction(() async {
      final cart =
          await (_db.select(_db.draftCarts)
                ..where((t) => t.id.equals(cartId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (cart == null) throw NotFoundError('DraftCart', id: cartId);
      final rows =
          await (_db.select(_db.draftCartItems)..where(
                (t) =>
                    t.cartId.equals(cartId) &
                    t.deletedAt.isNull() &
                    t.firedAt.isNull() &
                    t.qty.isBiggerThanValue(0),
              ))
              .get();
      if (rows.isEmpty) {
        return KitchenTicket(
          cartId: cartId,
          firedAt: firedAt,
          lines: const [],
          tableId: cart.tableId,
        );
      }
      await (_db.update(_db.draftCartItems)..where(
            (t) =>
                t.cartId.equals(cartId) &
                t.deletedAt.isNull() &
                t.firedAt.isNull() &
                t.qty.isBiggerThanValue(0),
          ))
          .write(DraftCartItemsCompanion(firedAt: Value(firedAt)));
      final table = cart.tableId == null
          ? null
          : await (_db.select(
              _db.restaurantTables,
            )..where((t) => t.id.equals(cart.tableId!))).getSingleOrNull();
      return KitchenTicket(
        cartId: cartId,
        firedAt: firedAt,
        tableId: cart.tableId,
        tableName: table?.name,
        lines: [
          for (final row in rows)
            KitchenTicketLine(
              lineId: row.id,
              productId: row.productId,
              productName: row.productName,
              qty: row.qty,
              note: row.note,
              optionsJson: row.productOptionsJson,
            ),
        ],
      );
    });
  }

  @override
  Future<void> transferDraftCart({
    required String cartId,
    required String sourceTableId,
    required String targetTableId,
  }) async {
    if (sourceTableId == targetTableId) {
      throw const BusinessRuleError('TableTransferSameTarget');
    }
    try {
      await _db.transaction(() async {
        final cart =
            await (_db.select(_db.draftCarts)..where(
                  (t) =>
                      t.id.equals(cartId) &
                      t.deletedAt.isNull() &
                      t.isArchived.equals(false),
                ))
                .getSingleOrNull();
        if (cart == null) throw NotFoundError('DraftCart', id: cartId);
        if (cart.tableId != sourceTableId) {
          throw const BusinessRuleError('TableTransferSourceMismatch');
        }
        final target =
            await (_db.select(_db.restaurantTables)..where(
                  (t) => t.id.equals(targetTableId) & t.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (target == null) {
          throw NotFoundError('RestaurantTable', id: targetTableId);
        }
        if (target.status == 'reserved') {
          throw const BusinessRuleError('TableReserved');
        }
        final conflict =
            await (_db.select(_db.draftCarts)..where(
                  (t) =>
                      t.tableId.equals(targetTableId) &
                      t.id.equals(cartId).not() &
                      t.deletedAt.isNull() &
                      t.isArchived.equals(false),
                ))
                .getSingleOrNull();
        if (conflict != null) {
          throw const BusinessRuleError('TableAlreadyBound');
        }
        await (_db.update(
          _db.draftCarts,
        )..where((t) => t.id.equals(cartId))).write(
          DraftCartsCompanion(
            tableId: Value(targetTableId),
            updatedAt: Value(DateTime.now()),
            version: Value(cart.version + 1),
          ),
        );
      });
    } catch (e) {
      if (_isTableAlreadyBoundError(e)) {
        throw const BusinessRuleError('TableAlreadyBound');
      }
      rethrow;
    }
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
