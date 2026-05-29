import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class CreateSale {
  const CreateSale(this._repository);
  final SaleRepository _repository;

  Future<Sale> call({
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
  }) {
    Validators.nonEmptyCart(items);
    for (final item in items) {
      Validators.qty(item.qty);
      Validators.price(item.product.price);
    }
    return _repository.createSale(
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
  }
}
