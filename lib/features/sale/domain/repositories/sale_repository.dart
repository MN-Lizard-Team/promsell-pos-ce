import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

abstract class SaleRepository {
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
  });

  Future<List<Sale>> getSales({DateTime? from, DateTime? to});
  Future<Sale?> getSaleById(String id);
  Stream<List<Sale>> watchRecentSales({int limit = 20});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});

  /// Cursor-paginated history page (createdAt DESC, id DESC).
  Future<SalePage> getSalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
  });

  /// Total non-deleted sale count, optionally within a date range.
  Future<int> getSalesCount({DateTime? from, DateTime? to});

  /// SQL-aggregated report summary (no item hydration).
  Future<ReportSummary> getReportSummary({DateTime? from, DateTime? to});

  /// Reactive SQL-aggregated report bundle (no item hydration). Emits once
  /// immediately, then re-aggregates whenever contributing tables change.
  Stream<ReportAggregate> watchReportAggregate({DateTime? from, DateTime? to});

  Future<void> voidSale(String saleId, {String? reason});
}
