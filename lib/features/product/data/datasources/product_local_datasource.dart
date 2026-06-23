import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

abstract class ProductLocalDatasource {
  Stream<List<Product>> watchAllProducts();
  Future<List<Product>> getActiveProducts();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<void> insertProduct(ProductsCompanion companion);
  Future<void> updateProduct(ProductsCompanion companion);
  Future<void> bulkUpdateBarcodes(List<({String id, String barcode})> updates);
  Future<void> deleteProduct(String id);
}

@LazySingleton(as: ProductLocalDatasource)
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  const ProductLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  Product _fromData(ProductData d) => Product(
    id: d.id,
    name: d.name,
    sku: d.sku,
    barcode: d.barcode,
    price: d.price,
    cost: d.cost ?? 0.0,
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

  @override
  Stream<List<Product>> watchAllProducts() =>
      (_db.select(_db.products)
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch()
          .map((rows) => rows.map(_fromData).toList());

  @override
  Future<List<Product>> getActiveProducts() =>
      (_db.select(_db.products)
            ..where((p) => p.isActive.equals(true))
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get()
          .then((rows) => rows.map(_fromData).toList());

  @override
  Future<Product?> getProductById(String id) async {
    final row = await (_db.select(
      _db.products,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromData(row);
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
    return rows.isEmpty ? null : _fromData(rows.first);
  }

  @override
  Future<void> insertProduct(ProductsCompanion companion) =>
      _db.into(_db.products).insert(companion);

  @override
  Future<void> updateProduct(ProductsCompanion companion) => (_db.update(
    _db.products,
  )..where((p) => p.id.equals(companion.id.value))).write(companion);

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
            barcode: Value(u.barcode.toUpperCase()),
            updatedAt: Value(now),
          ),
          where: (p) => p.id.equals(u.id),
        );
      }
    });
  }

  @override
  Future<void> deleteProduct(String id) =>
      (_db.delete(_db.products)..where((p) => p.id.equals(id))).go();
}
