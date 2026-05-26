import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  const SaleRepositoryImpl(this._datasource);
  final SaleLocalDatasource _datasource;

  @override
  Future<Sale> createSale({
    required List<CartItem> items,
    required String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? note,
  }) => _datasource.insertSaleWithItems(
    items: items,
    paymentMethod: paymentMethod,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    note: note,
  );

  @override
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) =>
      _datasource.querySales(from: from, to: to);

  @override
  Future<Sale?> getSaleById(int id) => _datasource.querySaleById(id);

  @override
  Stream<List<Sale>> watchRecentSales({int limit = 20}) =>
      _datasource.watchRecentSales(limit: limit);

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _datasource.watchSales(from: from, to: to);
}
