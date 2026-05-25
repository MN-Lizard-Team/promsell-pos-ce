import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

abstract class SaleRepository {
  Future<Sale> createSale({
    required List<CartItem> items,
    required String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? note,
  });

  Future<List<Sale>> getSales({DateTime? from, DateTime? to});
  Future<Sale?> getSaleById(int id);
  Stream<List<Sale>> watchRecentSales({int limit = 20});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
}
