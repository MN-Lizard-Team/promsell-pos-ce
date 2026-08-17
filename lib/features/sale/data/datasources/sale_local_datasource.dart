import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_insert_writer.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_void_writer.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_side_effects.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

abstract class SaleLocalDatasource {
  Future<Sale> insertSaleWithItems({
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
  });

  Future<List<Sale>> querySales({DateTime? from, DateTime? to});
  Future<Sale?> querySaleById(String id);
  Stream<List<Sale>> watchRecentSales({int limit});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});

  /// Cursor-paginated history page (createdAt DESC, id DESC). Hydrates items
  /// and payments only for the sales on the current page.
  Future<SalePage> querySalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
  });

  /// Total non-deleted sale count, optionally within a date range.
  Future<int> querySalesCount({DateTime? from, DateTime? to});

  /// SQL-aggregated report summary (no item hydration).
  Future<ReportSummary> queryReportSummary({DateTime? from, DateTime? to});

  Future<void> voidSale(String saleId, {String? reason});
}

/// Facade: public API unchanged; write/query split into collaborators.
@LazySingleton(as: SaleLocalDatasource)
class SaleLocalDatasourceImpl implements SaleLocalDatasource {
  SaleLocalDatasourceImpl(
    AppDatabase db, {
    required ReceiptNumberService receiptNumberService,
    required InventoryLogService inventoryLogService,
    required SettingsRepository settingsRepo,
  }) : _settingsRepo = settingsRepo,
       _query = SaleQueryLocalDatasource(db),
       _sideEffects = SaleWriteSideEffects(db) {
    _insert = SaleInsertWriter(
      db,
      receiptNumberService: receiptNumberService,
      inventoryLogService: inventoryLogService,
      settingsRepo: settingsRepo,
      query: _query,
      sideEffects: _sideEffects,
      deviceId: _getDeviceId,
    );
    _void = SaleVoidWriter(
      db,
      inventoryLogService: inventoryLogService,
      sideEffects: _sideEffects,
    );
  }

  final SettingsRepository _settingsRepo;
  final SaleQueryLocalDatasource _query;
  final SaleWriteSideEffects _sideEffects;
  late final SaleInsertWriter _insert;
  late final SaleVoidWriter _void;

  String? _cachedDeviceId;
  Future<String> _getDeviceId() async {
    return _cachedDeviceId ??=
        (await _settingsRepo.load()).deviceConfig.deviceId;
  }

  @override
  Future<Sale> insertSaleWithItems({
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
  }) => _insert.insertSaleWithItems(
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
  );

  @override
  Future<List<Sale>> querySales({DateTime? from, DateTime? to}) =>
      _query.querySales(from: from, to: to);

  @override
  Future<Sale?> querySaleById(String id) => _query.querySaleById(id);

  @override
  Stream<List<Sale>> watchRecentSales({int limit = 20}) =>
      _query.watchRecentSales(limit: limit);

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _query.watchSales(from: from, to: to);

  @override
  Future<SalePage> querySalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
  }) => _query.querySalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
  );

  @override
  Future<int> querySalesCount({DateTime? from, DateTime? to}) =>
      _query.querySalesCount(from: from, to: to);

  @override
  Future<ReportSummary> queryReportSummary({DateTime? from, DateTime? to}) =>
      _query.queryReportSummary(from: from, to: to);

  @override
  Future<void> voidSale(String saleId, {String? reason}) =>
      _void.voidSale(saleId, reason: reason);
}
