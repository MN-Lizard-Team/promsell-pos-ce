import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
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
    subtotalAmount: moneyFromSatangOrBaht(
      s.subtotalAmountSatang,
      s.subtotalAmount,
    ),
    discountType: s.discountType,
    discountValue: s.discountValueSatang?.value ?? s.discountValue,
    discountAmount: moneyFromSatangOrBaht(
      s.discountAmountSatang,
      s.discountAmount,
    ),
    vatMode: s.vatMode,
    vatRate: s.vatRate,
    vatAmount: moneyFromSatangOrBaht(s.vatAmountSatang, s.vatAmount),
    orderType: s.orderType,
    orderChannel: s.orderChannel,
    externalOrderRef: s.externalOrderRef,
    tableId: s.tableId,
    serviceChargeRate: s.serviceChargeRate,
    serviceChargeAmount: moneyFromSatangOrBaht(
      s.serviceChargeAmountSatang,
      s.serviceChargeAmount,
    ),
    customerId: s.customerId,
    promotionId: s.promotionId,
    promotionDiscountAmount: moneyFromSatangOrBaht(
      s.promotionDiscountAmountSatang,
      s.promotionDiscountAmount,
    ),
    totalAmount: moneyFromSatangOrBaht(s.totalAmountSatang, s.totalAmount),
    paymentMethod: s.paymentMethod,
    amountReceived: nullableMoneyFromSatangOrBaht(
      s.amountReceivedSatang,
      s.amountReceived,
    ),
    changeAmount: nullableMoneyFromSatangOrBaht(
      s.changeAmountSatang,
      s.changeAmount,
    ),
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
          amount: moneyFromSatangOrBaht(p.amountSatang, p.amount),
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
            price: moneyFromSatangOrBaht(i.priceSatang, i.price),
            qty: i.qty,
            subtotal: moneyFromSatangOrBaht(i.subtotalSatang, i.subtotal),
            discountAmount: moneyFromSatangOrBaht(
              i.discountAmountSatang,
              i.discountAmount,
            ),
            vatAmount: moneyFromSatangOrBaht(i.vatAmountSatang, i.vatAmount),
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
