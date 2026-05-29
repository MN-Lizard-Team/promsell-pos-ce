import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

abstract class SaleLocalDatasource {
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    double? cartDiscountAmount,
    double? amountReceived,
    double? changeAmount,
    String? note,
  });

  Future<List<Sale>> querySales({DateTime? from, DateTime? to});
  Future<Sale?> querySaleById(String id);
  Stream<List<Sale>> watchRecentSales({int limit});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
  Future<void> voidSale(String saleId, {String? reason});
}

@LazySingleton(as: SaleLocalDatasource)
class SaleLocalDatasourceImpl implements SaleLocalDatasource {
  const SaleLocalDatasourceImpl(
    this._db, {
    required this.receiptNumberService,
    required this.inventoryLogService,
  });
  final AppDatabase _db;
  final ReceiptNumberService receiptNumberService;
  final InventoryLogService inventoryLogService;

  Sale _buildSale(SaleData s, List<SaleItemData> items) => Sale(
    id: s.id,
    receiptNumber: s.receiptNumber,
    status: s.status,
    subtotalAmount: s.subtotalAmount,
    vatMode: s.vatMode,
    vatRate: s.vatRate,
    vatAmount: s.vatAmount,
    totalAmount: s.totalAmount,
    paymentMethod: s.paymentMethod,
    amountReceived: s.amountReceived,
    changeAmount: s.changeAmount,
    note: s.note,
    voidedAt: s.voidedAt,
    voidReason: s.voidReason,
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

  Future<List<SaleItemData>> _itemsForSale(String saleId) =>
      (_db.select(_db.saleItems)..where((t) => t.saleId.equals(saleId))).get();

  @override
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    double? cartDiscountAmount,
    double? amountReceived,
    double? changeAmount,
    String? note,
  }) async {
    final itemsSubtotal = double.parse(
      items.fold(0.0, (sum, i) => sum + i.subtotal).toStringAsFixed(2),
    );
    final effectiveCartDiscount = cartDiscountAmount ?? 0.0;
    final preTaxTotal = double.parse(
      (itemsSubtotal - effectiveCartDiscount).toStringAsFixed(2),
    );
    final r = vatRate / 100;
    final double subtotal;
    final double vatAmount;
    final double finalTotal;
    if (vatMode == 'INCLUSIVE' && r > 0) {
      subtotal = double.parse((preTaxTotal / (1 + r)).toStringAsFixed(2));
      vatAmount = double.parse((preTaxTotal - subtotal).toStringAsFixed(2));
      finalTotal = preTaxTotal;
    } else if (vatMode == 'EXCLUSIVE' && r > 0) {
      subtotal = preTaxTotal;
      vatAmount = double.parse((preTaxTotal * r).toStringAsFixed(2));
      finalTotal = double.parse((preTaxTotal + vatAmount).toStringAsFixed(2));
    } else {
      subtotal = preTaxTotal;
      vatAmount = 0.0;
      finalTotal = preTaxTotal;
    }
    final saleId = IdGenerator.newId();
    late SaleData saleData;
    await _db.transaction(() async {
      // 1. Generate receipt number (atomic inside tx)
      final receiptNumber = await receiptNumberService.nextReceiptNumber();

      // 2. Insert sale
      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion.insert(
              id: saleId,
              receiptNumber: Value(receiptNumber),
              totalAmount: finalTotal,
              subtotalAmount: Value(subtotal),
              discountType: Value(cartDiscountType),
              discountValue: Value(cartDiscountValue),
              discountAmount: Value(effectiveCartDiscount),
              vatMode: Value(vatMode),
              vatRate: Value(vatRate),
              vatAmount: Value(vatAmount),
              paymentMethod: paymentMethod,
              amountReceived: Value(amountReceived),
              changeAmount: Value(changeAmount),
              note: Value(note),
            ),
          );
      saleData = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      // 3. Validate ALL stock before any writes (skip non-tracked items)
      final productMap = <String, ProductData>{};
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
        final product = productMap[item.product.id]!;
        if (!product.trackStock) continue;
        if (product.stock < item.qty) {
          throw StateError(
            'Insufficient stock for "${item.product.name}": '
            'available ${product.stock}, requested ${item.qty}',
          );
        }
      }

      // 4. Insert sale items + deduct stock (trackStock only) + log inventory
      for (final item in items) {
        await _db
            .into(_db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                id: IdGenerator.newId(),
                saleId: saleId,
                productId: item.product.id,
                productName: item.product.name,
                price: item.product.price,
                qty: item.qty,
                subtotal: item.subtotal,
                discountAmount: Value(item.discountAmount),
              ),
            );
        if (!productMap[item.product.id]!.trackStock) continue;
        final newStock = productMap[item.product.id]!.stock - item.qty;
        await (_db.update(
          _db.products,
        )..where((p) => p.id.equals(item.product.id))).write(
          ProductsCompanion(
            stock: Value(newStock),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await inventoryLogService.logSale(
          productId: item.product.id,
          qty: item.qty,
          saleId: saleId,
          balanceAfter: newStock,
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
    final itemsBySaleId = <String, List<SaleItemData>>{};
    for (final item in allItems) {
      (itemsBySaleId[item.saleId] ??= []).add(item);
    }
    return salesData
        .map((s) => _buildSale(s, itemsBySaleId[s.id] ?? []))
        .toList();
  }

  @override
  Future<Sale?> querySaleById(String id) async {
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
      final itemsBySaleId = <String, List<SaleItemData>>{};
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
      final itemsBySaleId = <String, List<SaleItemData>>{};
      for (final item in allItems) {
        (itemsBySaleId[item.saleId] ??= []).add(item);
      }
      return salesData
          .map((s) => _buildSale(s, itemsBySaleId[s.id] ?? []))
          .toList();
    });
  }

  @override
  Future<void> voidSale(String saleId, {String? reason}) async {
    await _db.transaction(() async {
      final sale = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingleOrNull();
      if (sale == null) {
        throw StateError('Sale not found: $saleId');
      }
      if (sale.status == 'VOIDED') {
        throw StateError('Sale already voided');
      }

      final now = DateTime.now();
      await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          status: const Value('VOIDED'),
          voidedAt: Value(now),
          voidReason: Value(reason),
          updatedAt: Value(now),
        ),
      );

      final items = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.equals(saleId))).get();

      for (final item in items) {
        final product = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(item.productId))).getSingleOrNull();

        if (product == null) {
          // Product deleted — still log reversal but skip stock restore
          await inventoryLogService.logVoidReversal(
            productId: item.productId,
            qty: item.qty,
            saleId: saleId,
            balanceAfter: 0,
          );
          continue;
        }

        final newStock = product.stock + item.qty;
        await (_db.update(
          _db.products,
        )..where((p) => p.id.equals(item.productId))).write(
          ProductsCompanion(stock: Value(newStock), updatedAt: Value(now)),
        );
        await inventoryLogService.logVoidReversal(
          productId: item.productId,
          qty: item.qty,
          saleId: saleId,
          balanceAfter: newStock,
        );
      }
    });
  }
}
