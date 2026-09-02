import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@LazySingleton(as: SaleRepository)
class SaleRepositoryImpl implements SaleRepository {
  const SaleRepositoryImpl(this._datasource);
  final SaleLocalDatasource _datasource;

  @override
  Future<Sale> createSale({
    required List<CartItem> items,
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    Money? cartDiscountAmount,
    Money? amountReceived,
    Money? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
    List<SalePayment>? payments,
    String orderType = 'delivery',
    String orderChannel = 'walkin',
    String? externalOrderRef,
    String? tableId,
    double serviceChargeRate = 0.0,
    Money serviceChargeAmount = Money.zero,
    String? customerId,
    String? promotionId,
    Money promotionDiscountAmount = Money.zero,
    String? originatingDraftCartId,
    List<String>? selectedItemIds,
  }) => _datasource.insertSaleWithItems(
    items: items,
    paymentMethod: paymentMethod,
    vatMode: vatMode,
    vatRate: vatRate,
    cartDiscountType: cartDiscountType,
    cartDiscountValue: cartDiscountValue,
    cartDiscountAmount: cartDiscountAmount,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    note: note,
    paymentReference: paymentReference,
    sendingBankCode: sendingBankCode,
    payments: payments,
    orderType: orderType,
    orderChannel: orderChannel,
    externalOrderRef: externalOrderRef,
    tableId: tableId,
    serviceChargeRate: serviceChargeRate,
    serviceChargeAmount: serviceChargeAmount,
    customerId: customerId,
    promotionId: promotionId,
    promotionDiscountAmount: promotionDiscountAmount,
    originatingDraftCartId: originatingDraftCartId,
    selectedItemIds: selectedItemIds,
  );

  @override
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) =>
      _datasource.querySales(from: from, to: to);

  @override
  Future<Sale?> getSaleById(String id) => _datasource.querySaleById(id);

  @override
  Stream<List<Sale>> watchRecentSales({int limit = 20}) =>
      _datasource.watchRecentSales(limit: limit);

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _datasource.watchSales(from: from, to: to);

  @override
  Future<SalePage> getSalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
    String? searchQuery,
  }) => _datasource.querySalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
    searchQuery: searchQuery,
  );

  @override
  Future<int> getSalesCount({
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  }) =>
      _datasource.querySalesCount(from: from, to: to, searchQuery: searchQuery);

  @override
  Future<ReportSummary> getReportSummary({DateTime? from, DateTime? to}) =>
      _datasource.queryReportSummary(from: from, to: to);

  @override
  Stream<ReportAggregate> watchReportAggregate({
    DateTime? from,
    DateTime? to,
  }) => _datasource.watchReportAggregate(from: from, to: to);

  @override
  Future<void> voidSale(String saleId, {String? reason}) =>
      _datasource.voidSale(saleId, reason: reason);
}
