import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

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
    String? paymentReference,
    String? sendingBankCode,
  });

  Future<List<Sale>> querySales({DateTime? from, DateTime? to});
  Future<Sale?> querySaleById(String id);
  Stream<List<Sale>> watchRecentSales({int limit});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
  Future<void> voidSale(String saleId, {String? reason});
}

@LazySingleton(as: SaleLocalDatasource)
class SaleLocalDatasourceImpl implements SaleLocalDatasource {
  SaleLocalDatasourceImpl(
    this._db, {
    required this.receiptNumberService,
    required this.inventoryLogService,
    required this.settingsRepo,
  });
  final AppDatabase _db;
  final ReceiptNumberService receiptNumberService;
  final InventoryLogService inventoryLogService;
  final SettingsRepository settingsRepo;

  String? _cachedDeviceId;
  Future<String> _getDeviceId() async {
    return _cachedDeviceId ??=
        (await settingsRepo.load()).deviceConfig.deviceId;
  }

  Sale _buildSale(SaleData s, List<SaleItemData> items) => Sale(
    id: s.id,
    receiptNumber: s.receiptNumber,
    status: s.status,
    subtotalAmount: s.subtotalAmount,
    discountType: s.discountType,
    discountValue: s.discountValue,
    discountAmount: s.discountAmount,
    vatMode: s.vatMode,
    vatRate: s.vatRate,
    vatAmount: s.vatAmount,
    totalAmount: s.totalAmount,
    paymentMethod: s.paymentMethod,
    amountReceived: s.amountReceived,
    changeAmount: s.changeAmount,
    note: s.note,
    paymentReference: s.paymentReference,
    sendingBankCode: s.sendingBankCode,
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
            discountAmount: i.discountAmount,
            vatAmount: i.vatAmount,
            updatedAt: i.updatedAt,
            deletedAt: i.deletedAt,
            version: i.version,
            deviceId: i.deviceId,
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
    String? paymentReference,
    String? sendingBankCode,
  }) async {
    final itemsSubtotal = MoneyUtils.round(
      items.fold(0.0, (sum, i) => sum + i.subtotal),
    );
    final effectiveCartDiscount = cartDiscountAmount ?? 0.0;
    final preTaxTotal = MoneyUtils.round(
      itemsSubtotal - effectiveCartDiscount,
    ).clamp(0.0, double.maxFinite);
    final r = vatRate / 100;
    final double subtotal;
    final double vatAmount;
    final double finalTotal;
    if (vatMode == 'INCLUSIVE' && r > 0) {
      subtotal = MoneyUtils.round(preTaxTotal / (1 + r));
      vatAmount = MoneyUtils.round(preTaxTotal - subtotal);
      finalTotal = preTaxTotal;
    } else if (vatMode == 'EXCLUSIVE' && r > 0) {
      subtotal = preTaxTotal;
      vatAmount = MoneyUtils.round(preTaxTotal * r);
      finalTotal = MoneyUtils.round(preTaxTotal + vatAmount);
    } else {
      subtotal = preTaxTotal;
      vatAmount = 0.0;
      finalTotal = preTaxTotal;
    }
    final saleId = IdGenerator.newId();
    final deviceId = await _getDeviceId();
    late SaleData saleData;
    await _db.transaction(() async {
      // Generate receipt number
      final receiptNumber = await receiptNumberService.nextReceiptNumber();
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
              paymentReference: Value(paymentReference),
              sendingBankCode: Value(sendingBankCode),
              deviceId: Value(deviceId),
            ),
          );
      saleData = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      // Validate ALL stock before any writes
      final productIds = items.map((i) => i.product.id).toSet().toList();
      final productRows = await (_db.select(
        _db.products,
      )..where((p) => p.id.isIn(productIds))).get();
      final productMap = {for (final p in productRows) p.id: p};
      for (final item in items) {
        final product = productMap[item.product.id];
        if (product == null) {
          throw StateError(
            '"${item.product.name}" no longer exists and cannot be sold.',
          );
        }
        if (!product.trackStock) continue;
        if (product.stock < item.qty) {
          throw StateError(
            'Insufficient stock for "${item.product.name}": '
            'available ${product.stock}, requested ${item.qty}',
          );
        }
      }

      for (final item in items) {
        final double itemVatAmount;
        if (vatMode == 'INCLUSIVE' && r > 0) {
          itemVatAmount = MoneyUtils.round(item.subtotal * r / (1 + r));
        } else if (vatMode == 'EXCLUSIVE' && r > 0) {
          itemVatAmount = MoneyUtils.round(item.subtotal * r);
        } else {
          itemVatAmount = 0.0;
        }
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
                vatAmount: Value(itemVatAmount),
                deviceId: Value(deviceId),
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
          version: Value(sale.version + 1),
        ),
      );

      final items = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.equals(saleId))).get();

      final productIds = items.map((i) => i.productId).toSet().toList();
      final productRows = productIds.isEmpty
          ? <ProductData>[]
          : await (_db.select(
              _db.products,
            )..where((p) => p.id.isIn(productIds))).get();
      final productMap = {for (final p in productRows) p.id: p};

      for (final item in items) {
        final product = productMap[item.productId];

        if (product == null) {
          // Product deleted — still log reversal but skip stock restore
          await inventoryLogService.logVoidReversal(
            productId: item.productId,
            qty: item.qty,
            saleId: saleId,
            balanceAfter: -1,
            reason: 'Product deleted since sale',
          );
          continue;
        }

        if (!product.trackStock) {
          await inventoryLogService.logVoidReversal(
            productId: item.productId,
            qty: item.qty,
            saleId: saleId,
            balanceAfter: product.stock,
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
