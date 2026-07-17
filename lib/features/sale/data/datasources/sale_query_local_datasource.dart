import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_helpers.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

/// Read/hydrate path for sales (query, watch, row → domain).
///
/// Owned by [SaleLocalDatasourceImpl]; not registered separately in DI.
class SaleQueryLocalDatasource {
  SaleQueryLocalDatasource(this._db);

  final AppDatabase _db;

  Sale buildSale(
    SaleData s,
    List<SaleItemData> items, {
    List<SalePaymentData> paymentRows = const [],
  }) => Sale(
    id: s.id,
    receiptNumber: s.receiptNumber,
    status: s.status,
    subtotalAmount: Money.fromDouble(s.subtotalAmount),
    discountType: s.discountType,
    discountValue: s.discountValue,
    discountAmount: Money.fromDouble(s.discountAmount),
    vatMode: s.vatMode,
    vatRate: s.vatRate,
    vatAmount: Money.fromDouble(s.vatAmount),
    orderType: s.orderType,
    orderChannel: s.orderChannel,
    externalOrderRef: s.externalOrderRef,
    tableId: s.tableId,
    serviceChargeRate: s.serviceChargeRate,
    serviceChargeAmount: Money.fromDouble(s.serviceChargeAmount),
    customerId: s.customerId,
    promotionId: s.promotionId,
    promotionDiscountAmount: Money.fromDouble(s.promotionDiscountAmount),
    totalAmount: Money.fromDouble(s.totalAmount),
    paymentMethod: s.paymentMethod,
    amountReceived: s.amountReceived != null
        ? Money.fromDouble(s.amountReceived!)
        : null,
    changeAmount: s.changeAmount != null
        ? Money.fromDouble(s.changeAmount!)
        : null,
    note: s.note,
    paymentReference: s.paymentReference,
    sendingBankCode: s.sendingBankCode,
    voidedAt: s.voidedAt,
    voidReason: s.voidReason,
    createdAt: s.createdAt,
    payments: [
      for (final p in paymentRows)
        SalePayment(
          id: p.id,
          saleId: p.saleId,
          method: p.method,
          amount: Money.fromDouble(p.amount),
          reference: p.reference,
          sendingBankCode: p.sendingBankCode,
          sortOrder: p.sortOrder,
        ),
    ],
    items: items
        .map(
          (i) => SaleItem(
            id: i.id,
            saleId: i.saleId,
            productId: i.productId,
            productName: i.productName,
            price: Money.fromDouble(i.price),
            qty: i.qty,
            subtotal: Money.fromDouble(i.subtotal),
            discountAmount: Money.fromDouble(i.discountAmount),
            vatAmount: Money.fromDouble(i.vatAmount),
            note: i.note,
            selectedOptions: SaleWriteHelpers.parseSelectedOptions(
              i.productOptionsJson,
            ),
            updatedAt: i.updatedAt,
            deletedAt: i.deletedAt,
            version: i.version,
            deviceId: i.deviceId,
          ),
        )
        .toList(),
  );

  Future<List<SaleItemData>> itemsForSale(String saleId) => (_db.select(
    _db.saleItems,
  )..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())).get();

  Future<List<SalePaymentData>> paymentsForSale(String saleId) =>
      (_db.select(_db.salePayments)
            ..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<List<Sale>> querySales({DateTime? from, DateTime? to}) async {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final salesData = await query.get();
    return hydrateSales(salesData);
  }

  Future<Sale?> querySaleById(String id) async {
    final s =
        await (_db.select(_db.sales)
              ..where((t) => t.id.equals(id))
              ..where((t) => t.deletedAt.isNull()))
            .getSingleOrNull();
    if (s == null) return null;
    final items = await itemsForSale(id);
    final paymentRows = await paymentsForSale(id);
    return buildSale(s, items, paymentRows: paymentRows);
  }

  Stream<List<Sale>> watchRecentSales({int limit = 20}) {
    final query = _db.select(_db.sales)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit);
    return query.watch().asyncMap(hydrateSales);
  }

  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch().asyncMap(hydrateSales);
  }

  /// Batch-load items + payments for [salesData] and map to domain.
  Future<List<Sale>> hydrateSales(List<SaleData> salesData) async {
    if (salesData.isEmpty) return [];
    final saleIds = salesData.map((s) => s.id).toList();
    final allItems = await (_db.select(
      _db.saleItems,
    )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
    final itemsBySaleId = <String, List<SaleItemData>>{};
    for (final item in allItems) {
      (itemsBySaleId[item.saleId] ??= []).add(item);
    }
    final allPays = await (_db.select(
      _db.salePayments,
    )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
    final paysBySaleId = <String, List<SalePaymentData>>{};
    for (final pay in allPays) {
      (paysBySaleId[pay.saleId] ??= []).add(pay);
    }
    return salesData
        .map(
          (s) => buildSale(
            s,
            itemsBySaleId[s.id] ?? [],
            paymentRows: paysBySaleId[s.id] ?? const [],
          ),
        )
        .toList();
  }
}
