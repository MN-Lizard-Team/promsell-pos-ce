import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
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
    double? cartDiscountAmount,
    double? amountReceived,
    double? changeAmount,
    String? note,
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
  Future<void> voidSale(String saleId, {String? reason}) =>
      _datasource.voidSale(saleId, reason: reason);
}
