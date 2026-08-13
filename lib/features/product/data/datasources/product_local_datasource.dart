import 'dart:developer' as dev;

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/exceptions/optimistic_lock_exception.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/inventory_log_reasons.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

abstract class ProductLocalDatasource {
  Stream<List<Product>> watchAllProducts({int? limit});
  Future<List<Product>> getActiveProducts();
  Future<List<Product>> getAllProducts();
  Future<int> getProductCount();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<bool> barcodeExistsAnyStatus(String barcode, {String? excludeId});

  /// Case-insensitive SKU check across all products. Empty → false.
  Future<bool> skuExistsAnyStatus(String sku, {String? excludeId});
  Future<void> insertProduct(ProductsCompanion companion);
  Future<void> updateProduct(ProductsCompanion companion);
  Future<void> insertProductWithOptionGroups(
    ProductsCompanion companion,
    List<ProductOptionGroup> optionGroups,
  );
  Future<void> updateProductWithOptionGroups(
    ProductsCompanion companion,
    List<ProductOptionGroup>? optionGroups,
  );
  Future<void> bulkUpdateBarcodes(List<({String id, String barcode})> updates);
  Future<void> bulkUpdateBarcodesWithImages(
    List<({String id, String barcode, String? barcodeImagePath})> updates,
  );
  Future<void> deleteProduct(String id);

  /// Restores a soft-deleted product (clears deletedAt, restores isActive).
  Future<void> restoreProduct(String id);
  Future<int> countSaleItemsByProduct(String productId);
  Future<int> countDraftItemsByProduct(String productId);

  /// Writes an audit entry for a product change (CREATE/UPDATE/DELETE).
  Future<void> logProductAudit({
    required String productId,
    required String action,
    String? fieldName,
    String? oldValue,
    String? newValue,
  });

  /// Atomically updates a product and writes all audit entries in a single
  /// transaction. If any audit write fails, the entire update is rolled back.
  Future<void> updateProductWithAudit(
    ProductsCompanion companion,
    List<ProductOptionGroup>? optionGroups,
    List<({String fieldName, String oldValue, String newValue})> auditEntries,
  );
}

@LazySingleton(as: ProductLocalDatasource)
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  const ProductLocalDatasourceImpl(
    this._db,
    this._optionDatasource, [
    @ignoreParam this._inventoryLogService,
  ]);
  final AppDatabase _db;
  final ProductOptionDatasource _optionDatasource;
  final InventoryLogService? _inventoryLogService;

  Product _fromData(ProductData d) {
    if (d.cost == null) {
      // Data integrity warning: cost should never be NULL after schema
      // constraints. Log so we can detect legacy/migrated rows.
      AppLogger.warning('Product ${d.id} has NULL cost — defaulting to 0.0');
    }
    return Product(
      id: d.id,
      name: d.name,
      sku: d.sku,
      barcode: d.barcode,
      price: Money.fromDouble(d.price),
      cost: Money.fromDouble(d.cost ?? 0.0),
      stock: d.stock,
      categoryId: d.categoryId,
      imageUrl: d.imageUrl,
      imagePath: d.imagePath,
      imageThumbnailPath: d.imageThumbnailPath,
      barcodeImagePath: d.barcodeImagePath,
      description: d.description,
      brand: d.brand,
      unit: d.unit,
      supplier: d.supplier,
      isRecommended: d.isRecommended,
      isActive: d.isActive,
      trackStock: d.trackStock,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
      version: d.version,
    );
  }

  Future<Product> _fromDataWithOptions(ProductData d) async {
    try {
      final groups = await _optionDatasource.getOptionGroupsForProduct(d.id);
      return _fromData(d).copyWith(optionGroups: groups);
    } catch (e) {
      // Return product with empty option groups rather than failing the whole
      // fetch — option groups can be reloaded separately if needed.
      dev.log(
        'Failed to load option groups for product ${d.id}: $e',
        level: 900,
        name: 'ProductLocalDatasource',
      );
      return _fromData(d);
    }
  }

  @override
  Stream<List<Product>> watchAllProducts({int? limit}) {
    final query = _db.select(_db.products)
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return <Product>[];

      final productIds = rows.map((r) => r.id).toList();
      final allGroups = await _optionDatasource.getOptionGroupsForProducts(
        productIds,
      );

      return rows.map((row) {
        final groups = allGroups[row.id] ?? <ProductOptionGroup>[];
        return _fromData(row).copyWith(optionGroups: groups);
      }).toList();
    });
  }

  @override
  Future<int> getProductCount() async {
    final countExpression = _db.products.id.count();
    final query = _db.selectOnly(_db.products)
      ..addColumns([countExpression])
      ..where(_db.products.deletedAt.isNull());
    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    final rows =
        await (_db.select(_db.products)
              ..where((p) => p.isActive.equals(true))
              ..where((p) => p.deletedAt.isNull())
              ..orderBy([(p) => OrderingTerm.asc(p.name)]))
            .get();

    if (rows.isEmpty) return <Product>[];

    final productIds = rows.map((r) => r.id).toList();
    final allGroups = await _optionDatasource.getOptionGroupsForProducts(
      productIds,
    );

    return rows.map((row) {
      final groups = allGroups[row.id] ?? <ProductOptionGroup>[];
      return _fromData(row).copyWith(optionGroups: groups);
    }).toList();
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final rows =
        await (_db.select(_db.products)
              ..where((p) => p.deletedAt.isNull())
              ..orderBy([(p) => OrderingTerm.asc(p.name)]))
            .get();

    if (rows.isEmpty) return <Product>[];

    final productIds = rows.map((r) => r.id).toList();
    final allGroups = await _optionDatasource.getOptionGroupsForProducts(
      productIds,
    );

    return rows.map((row) {
      final groups = allGroups[row.id] ?? <ProductOptionGroup>[];
      return _fromData(row).copyWith(optionGroups: groups);
    }).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final row =
        await (_db.select(_db.products)
              ..where((p) => p.id.equals(id))
              ..where((p) => p.deletedAt.isNull()))
            .getSingleOrNull();
    return row == null ? null : await _fromDataWithOptions(row);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;
    final lowerBarcode = barcode.toLowerCase();
    final rows =
        await (_db.select(_db.products)
              ..where((p) => p.barcodeLower.equals(lowerBarcode))
              ..where((p) => p.isActive.equals(true))
              ..where((p) => p.deletedAt.isNull())
              ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : await _fromDataWithOptions(rows.first);
  }

  @override
  Future<bool> barcodeExistsAnyStatus(
    String barcode, {
    String? excludeId,
  }) async {
    final lowerBarcode = barcode.toLowerCase();
    final query = _db.select(_db.products)
      ..where((p) => p.barcodeLower.equals(lowerBarcode));
    if (excludeId != null) {
      query.where((p) => p.id.equals(excludeId).not());
    }
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<bool> skuExistsAnyStatus(String sku, {String? excludeId}) async {
    final trimmed = sku.trim();
    if (trimmed.isEmpty) return false;
    final lowerSku = trimmed.toLowerCase();
    final query = _db.select(_db.products)
      ..where((p) => p.skuLower.equals(lowerSku));
    if (excludeId != null) {
      query.where((p) => p.id.equals(excludeId).not());
    }
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> insertProduct(ProductsCompanion companion) =>
      _db.into(_db.products).insert(companion);

  @override
  Future<void> updateProduct(ProductsCompanion companion) =>
      _db.transaction(() async {
        final existing =
            await (_db.select(_db.products)..where(
                  (p) => p.id.equals(companion.id.value) & p.deletedAt.isNull(),
                ))
                .getSingleOrNull();

        if (existing == null) {
          throw StateError(
            'Cannot update: product not found or deleted: '
            '${companion.id.value}',
          );
        }

        // Optimistic locking: if the companion carries an expected version,
        // verify it matches the current DB version before updating.
        // If no version is provided, skip the check (backwards-compatible).
        if (companion.version.present) {
          final expectedVersion = companion.version.value;
          if (expectedVersion != existing.version) {
            throw OptimisticLockException(
              entityId: companion.id.value,
              expectedVersion: expectedVersion,
              actualVersion: existing.version,
            );
          }
        }

        final newVersion = existing.version + 1;
        final companionWithVersion = companion.copyWith(
          version: Value(newVersion),
        );

        await (_db.update(_db.products)
              ..where((p) => p.id.equals(companion.id.value)))
            .write(companionWithVersion);

        // Log stock changes for every update path (form, quick-edit, etc.).
        if (companion.stock.present &&
            existing.trackStock &&
            companion.stock.value != existing.stock &&
            _inventoryLogService != null) {
          await _inventoryLogService.logAdjustment(
            productId: existing.id,
            qtyChange: companion.stock.value - existing.stock,
            // Stable key — localized in History UI.
            reason: InventoryLogReasons.productStockEdited,
            balanceAfter: companion.stock.value,
          );
        }
      });

  @override
  Future<void> insertProductWithOptionGroups(
    ProductsCompanion companion,
    List<ProductOptionGroup> optionGroups,
  ) => _db.transaction(() async {
    await insertProduct(companion);
    await _replaceOptionGroups(companion.id.value, optionGroups);
  });

  @override
  Future<void> updateProductWithOptionGroups(
    ProductsCompanion companion,
    List<ProductOptionGroup>? optionGroups,
  ) => _db.transaction(() async {
    // Stock logging lives in [updateProduct] so quick-edit paths also log.
    await updateProduct(companion);
    if (optionGroups != null) {
      await _replaceOptionGroups(companion.id.value, optionGroups);
    }
  });

  @override
  Future<void> updateProductWithAudit(
    ProductsCompanion companion,
    List<ProductOptionGroup>? optionGroups,
    List<({String fieldName, String oldValue, String newValue})> auditEntries,
  ) => _db.transaction(() async {
    // 1. Update product (includes version check + stock logging).
    if (optionGroups == null) {
      await updateProduct(companion);
    } else {
      await updateProduct(companion);
      await _replaceOptionGroups(companion.id.value, optionGroups);
    }
    // 2. Write all audit entries within the same transaction.
    //    If any audit write throws, the entire transaction (including the
    //    product update) is rolled back — guaranteeing atomicity.
    for (final entry in auditEntries) {
      await _db
          .into(_db.productAudits)
          .insert(
            ProductAuditsCompanion.insert(
              id: IdGenerator.newId(),
              productId: companion.id.value,
              action: 'UPDATE',
              fieldName: Value(entry.fieldName),
              oldValue: Value(entry.oldValue),
              newValue: Value(entry.newValue),
            ),
          );
    }
  });

  Future<void> _replaceOptionGroups(
    String productId,
    List<ProductOptionGroup> groups,
  ) async {
    final existing = await _optionDatasource.getOptionGroupsForProduct(
      productId,
    );
    final existingGroupIds = existing.map((group) => group.id).toSet();
    final newGroupIds = groups.map((group) => group.id).toSet();
    final now = DateTime.now();

    for (final groupId in existingGroupIds.difference(newGroupIds)) {
      await _optionDatasource.deleteOptionsByGroupId(groupId);
      await _optionDatasource.deleteOptionGroup(groupId);
    }

    for (final group in groups) {
      final groupExists = existingGroupIds.contains(group.id);
      if (groupExists) {
        await _optionDatasource.updateOptionGroup(
          ProductOptionGroupsCompanion(
            id: Value(group.id),
            name: Value(group.name),
            selectionType: Value(
              group.selectionType == OptionSelectionType.multiple
                  ? 'multiple'
                  : 'single',
            ),
            isRequired: Value(group.isRequired),
            sortOrder: Value(group.sortOrder),
            updatedAt: Value(now),
          ),
        );
      } else {
        await _optionDatasource.insertOptionGroup(
          ProductOptionGroupsCompanion.insert(
            id: group.id,
            productId: productId,
            name: group.name,
            selectionType: Value(
              group.selectionType == OptionSelectionType.multiple
                  ? 'multiple'
                  : 'single',
            ),
            isRequired: Value(group.isRequired),
            sortOrder: Value(group.sortOrder),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      final existingOptions = groupExists
          ? existing.firstWhere((item) => item.id == group.id).options
          : const <ProductOption>[];
      final existingOptionIds = existingOptions
          .map((option) => option.id)
          .toSet();
      final newOptionIds = group.options.map((option) => option.id).toSet();
      for (final optionId in existingOptionIds.difference(newOptionIds)) {
        await _optionDatasource.deleteOption(optionId);
      }
      for (final option in group.options) {
        if (existingOptionIds.contains(option.id)) {
          await _optionDatasource.updateOption(
            ProductOptionsCompanion(
              id: Value(option.id),
              name: Value(option.name),
              priceDelta: Value(option.priceDelta.value),
              sortOrder: Value(option.sortOrder),
              updatedAt: Value(now),
            ),
          );
        } else {
          await _optionDatasource.insertOption(
            ProductOptionsCompanion.insert(
              id: option.id,
              groupId: group.id,
              name: option.name,
              priceDelta: Value(option.priceDelta.value),
              sortOrder: Value(option.sortOrder),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      }
    }
  }

  @override
  Future<void> bulkUpdateBarcodes(
    List<({String id, String barcode})> updates,
  ) async {
    await _db.batch((b) {
      final now = DateTime.now();
      for (final u in updates) {
        b.update(
          _db.products,
          ProductsCompanion(
            barcode: Value(u.barcode),
            barcodeLower: Value(u.barcode.toLowerCase()),
            updatedAt: Value(now),
          ),
          where: (p) => p.id.equals(u.id),
        );
      }
    });
  }

  @override
  Future<void> deleteProduct(String id) =>
      (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          isActive: const Value(false),
        ),
      );

  @override
  Future<void> restoreProduct(String id) =>
      (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
          deletedAt: const Value(null),
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> bulkUpdateBarcodesWithImages(
    List<({String id, String barcode, String? barcodeImagePath})> updates,
  ) async {
    await _db.batch((b) {
      final now = DateTime.now();
      for (final u in updates) {
        b.update(
          _db.products,
          ProductsCompanion(
            barcode: Value(u.barcode),
            barcodeLower: Value(u.barcode.toLowerCase()),
            barcodeImagePath: Value(u.barcodeImagePath),
            updatedAt: Value(now),
          ),
          where: (p) => p.id.equals(u.id),
        );
      }
    });
  }

  @override
  Future<int> countSaleItemsByProduct(String productId) async {
    final query = _db.selectOnly(_db.saleItems)
      ..addColumns([_db.saleItems.id.count()])
      ..where(_db.saleItems.productId.equals(productId))
      ..where(_db.saleItems.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(_db.saleItems.id.count()) ?? 0;
  }

  @override
  Future<int> countDraftItemsByProduct(String productId) async {
    final query = _db.selectOnly(_db.draftCartItems)
      ..addColumns([_db.draftCartItems.id.count()])
      ..where(_db.draftCartItems.productId.equals(productId))
      ..where(_db.draftCartItems.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(_db.draftCartItems.id.count()) ?? 0;
  }

  @override
  Future<void> logProductAudit({
    required String productId,
    required String action,
    String? fieldName,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      await _db
          .into(_db.productAudits)
          .insert(
            ProductAuditsCompanion.insert(
              id: IdGenerator.newId(),
              productId: productId,
              action: action,
              fieldName: Value(fieldName),
              oldValue: Value(oldValue),
              newValue: Value(newValue),
            ),
          );
    } catch (e) {
      // Audit logging should never block the main operation.
      AppLogger.warning('Failed to log product audit: $e');
    }
  }
}
