import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/inventory_log_reasons.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

abstract class ProductLocalDatasource {
  Stream<List<Product>> watchAllProducts();
  Future<List<Product>> getActiveProducts();
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<bool> barcodeExistsAnyStatus(String barcode, {String? excludeId});
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
  Future<int> countSaleItemsByProduct(String productId);
  Future<int> countDraftItemsByProduct(String productId);
}

@LazySingleton(as: ProductLocalDatasource)
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  const ProductLocalDatasourceImpl(
    this._db,
    this._optionDatasource, [
    this._inventoryLogService,
  ]);
  final AppDatabase _db;
  final ProductOptionDatasource _optionDatasource;
  final InventoryLogService? _inventoryLogService;

  Product _fromData(ProductData d) => Product(
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
  );

  Future<Product> _fromDataWithOptions(ProductData d) async {
    final groups = await _optionDatasource.getOptionGroupsForProduct(d.id);
    return _fromData(d).copyWith(optionGroups: groups);
  }

  @override
  Stream<List<Product>> watchAllProducts() {
    return (_db.select(_db.products)
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .watch()
        .asyncMap((rows) async {
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
  Future<List<Product>> getActiveProducts() async {
    final rows =
        await (_db.select(_db.products)
              ..where((p) => p.isActive.equals(true))
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
    final rows = await (_db.select(
      _db.products,
    )..orderBy([(p) => OrderingTerm.asc(p.name)])).get();

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
    final row = await (_db.select(
      _db.products,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : await _fromDataWithOptions(row);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final lowerBarcode = barcode.toLowerCase();
    final rows =
        await (_db.select(_db.products)
              ..where((p) => p.barcode.lower().equals(lowerBarcode))
              ..where((p) => p.isActive.equals(true))
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
      ..where((p) => p.barcode.lower().equals(lowerBarcode));
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
        final existing = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(companion.id.value))).getSingle();

        await (_db.update(
          _db.products,
        )..where((p) => p.id.equals(companion.id.value))).write(companion);

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
          ProductsCompanion(barcode: Value(u.barcode), updatedAt: Value(now)),
          where: (p) => p.id.equals(u.id),
        );
      }
    });
  }

  @override
  Future<void> deleteProduct(String id) =>
      (_db.delete(_db.products)..where((p) => p.id.equals(id))).go();

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
}
