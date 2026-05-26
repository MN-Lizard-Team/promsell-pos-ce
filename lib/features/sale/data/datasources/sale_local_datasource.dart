import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

abstract class SaleLocalDatasource {
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? note,
  });

  Future<List<Sale>> querySales({DateTime? from, DateTime? to});
  Future<Sale?> querySaleById(int id);
  Stream<List<Sale>> watchRecentSales({int limit});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
}

class SaleLocalDatasourceImpl implements SaleLocalDatasource {
  const SaleLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  Sale _buildSale(SaleData s, List<SaleItemData> items) => Sale(
    id: s.id,
    totalAmount: s.totalAmount,
    paymentMethod: s.paymentMethod,
    amountReceived: s.amountReceived,
    changeAmount: s.changeAmount,
    note: s.note,
    createdAt: s.createdAt,
    items: items
        .map(
          (i) => SaleItem(
            id: i.id,
            saleId: i.saleId,
            productId: i.productId,
            productName: i.productName,
            price: i.price,
            qty: i.qty,
            subtotal: i.subtotal,
          ),
        )
        .toList(),
  );

  Future<List<SaleItemData>> _itemsForSale(int saleId) =>
      (_db.select(_db.saleItems)..where((t) => t.saleId.equals(saleId))).get();

  @override
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? note,
  }) async {
    final total = items.fold(0.0, (sum, i) => sum + i.subtotal);
    late SaleData saleData;
    await _db.transaction(() async {
      final saleId = await _db
          .into(_db.sales)
          .insert(
            SalesCompanion.insert(
              totalAmount: total,
              paymentMethod: paymentMethod,
              amountReceived: Value(amountReceived),
              changeAmount: Value(changeAmount),
              note: Value(note),
            ),
          );
      saleData = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      // Fetch each product once, then validate ALL before any inserts.
      final productMap = <int, ProductData>{};
      for (final item in items) {
        if (productMap.containsKey(item.product.id)) continue;
        final product = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(item.product.id))).getSingleOrNull();
        if (product == null) {
          throw StateError(
            '"${item.product.name}" no longer exists and cannot be sold.',
          );
        }
        productMap[item.product.id] = product;
      }
      for (final item in items) {
        final stock = productMap[item.product.id]!.stock;
        if (stock < item.qty) {
          throw StateError(
            'Insufficient stock for "${item.product.name}": '
            'available $stock, requested ${item.qty}',
          );
        }
      }

      // Insert sale items and deduct stock using already-fetched products.
      for (final item in items) {
        await _db
            .into(_db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: item.product.id,
                productName: item.product.name,
                price: item.product.price,
                qty: item.qty,
                subtotal: item.subtotal,
              ),
            );
        final newStock = productMap[item.product.id]!.stock - item.qty;
        await (_db.update(
          _db.products,
        )..where((p) => p.id.equals(item.product.id))).write(
          ProductsCompanion(
            stock: Value(newStock),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
    final saleItems = await _itemsForSale(saleData.id);
    return _buildSale(saleData, saleItems);
  }

  @override
  Future<List<Sale>> querySales({DateTime? from, DateTime? to}) async {
    final query = _db.select(_db.sales);
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final salesData = await query.get();
    if (salesData.isEmpty) return [];
    final saleIds = salesData.map((s) => s.id).toList();
    final allItems = await (_db.select(
      _db.saleItems,
    )..where((t) => t.saleId.isIn(saleIds))).get();
    final itemsBySaleId = <int, List<SaleItemData>>{};
    for (final item in allItems) {
      (itemsBySaleId[item.saleId] ??= []).add(item);
    }
    return salesData
        .map((s) => _buildSale(s, itemsBySaleId[s.id] ?? []))
        .toList();
  }

  @override
  Future<Sale?> querySaleById(int id) async {
    final s = await (_db.select(
      _db.sales,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (s == null) return null;
    final items = await _itemsForSale(id);
    return _buildSale(s, items);
  }

  @override
  Stream<List<Sale>> watchRecentSales({int limit = 20}) {
    final query = _db.select(_db.sales)
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit);
    return query.watch().asyncMap((salesData) async {
      if (salesData.isEmpty) return [];
      final saleIds = salesData.map((s) => s.id).toList();
      final allItems = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.isIn(saleIds))).get();
      final itemsBySaleId = <int, List<SaleItemData>>{};
      for (final item in allItems) {
        (itemsBySaleId[item.saleId] ??= []).add(item);
      }
      return salesData
          .map((s) => _buildSale(s, itemsBySaleId[s.id] ?? []))
          .toList();
    });
  }

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) {
    final query = _db.select(_db.sales);
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch().asyncMap((salesData) async {
      if (salesData.isEmpty) return [];
      final saleIds = salesData.map((s) => s.id).toList();
      final allItems = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.isIn(saleIds))).get();
      final itemsBySaleId = <int, List<SaleItemData>>{};
      for (final item in allItems) {
        (itemsBySaleId[item.saleId] ??= []).add(item);
      }
      return salesData
          .map((s) => _buildSale(s, itemsBySaleId[s.id] ?? []))
          .toList();
    });
  }
}
