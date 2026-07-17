import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_discount_policy.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

part 'cart_bloc_line_handlers.dart';
part 'cart_bloc_discount_handlers.dart';
part 'cart_bloc_barcode_handlers.dart';
part 'cart_bloc_promo_handlers.dart';
part 'cart_bloc_meta_handlers.dart';

/// Cart state machine. Handlers split into sibling mixins (D2.1); event API unchanged.
@lazySingleton
class CartBloc extends Bloc<CartEvent, CartState>
    with
        CartBlocLineHandlers,
        CartBlocDiscountHandlers,
        CartBlocBarcodeHandlers,
        CartBlocPromoHandlers,
        CartBlocMetaHandlers {
  CartBloc({
    required this.productRepo,
    required this.settingsRepo,
    required this.promotionRepo,
  }) : super(const CartState()) {
    on<CartProductAdded>(onProductAdded);
    on<CartProductRemoved>(onProductRemoved);
    on<CartItemQtyChanged>(onQtyChanged);
    on<CartCleared>(onCartCleared);
    on<CartRestored>(onCartRestored);
    on<CartItemRestored>(onCartItemRestored);
    on<CartItemDuplicated>(onCartItemDuplicated);
    on<CartItemDiscountChanged>(onItemDiscountChanged);
    on<CartItemDiscountCleared>(onItemDiscountCleared);
    on<CartDiscountChanged>(onCartDiscountChanged);
    on<CartDiscountCleared>(onCartDiscountCleared);
    on<CartNoteChanged>(onNoteChanged);
    on<CartProductsRefreshed>(onProductsRefreshed);
    // Async paths: run sequentially to avoid lost updates after await.
    on<CartBarcodeScanned>(onBarcodeScanned, transformer: sequential());
    on<CartBulkItemsRemoved>(onBulkItemsRemoved);
    on<CartBulkItemDiscountsCleared>(onBulkItemDiscountsCleared);
    on<CartItemsReordered>(onCartItemsReordered);
    on<CartItemNoteChanged>(onItemNoteChanged);
    on<CartTableAssigned>(onTableAssigned);
    on<CartCustomerSet>(onCustomerSet);
    on<CartPromotionSet>(onPromotionSet, transformer: sequential());
    on<CartPromotionRecompute>(onPromotionRecompute, transformer: sequential());
    on<CartOrderTypeChanged>(onOrderTypeChanged);
    on<CartOrderChannelChanged>(onOrderChannelChanged);
    on<CartExternalOrderRefChanged>(onExternalOrderRefChanged);
    on<CartServiceChargeRateChanged>(onServiceChargeRateChanged);
    on<CartPaymentLockChanged>(onPaymentLockChanged);
  }

  @override
  final ProductRepository productRepo;
  @override
  final SettingsRepository settingsRepo;
  @override
  final PromotionRepository promotionRepo;

  @override
  void schedulePromoRecompute() {
    if (state.promotionId != null) {
      add(const CartPromotionRecompute());
    }
  }

  @override
  Money promoBase(CartState s) =>
      (s.itemsSubtotal - s.cartDiscountAmount).clampToZero();

  bool get isPaymentLocked => state.paymentLocked;

  /// Mutations blocked while checkout is waitingPayment/processing.
  @override
  bool rejectIfPaymentLocked(Emitter<CartState> emit) {
    if (!state.paymentLocked) return false;
    emit(
      state.copyWith(
        errorMessage: 'paymentInProgress',
        errorNonce: state.errorNonce + 1,
      ),
    );
    return true;
  }

  @override
  int qtyInCart(String productId, {String? excludeLineId}) {
    var sum = 0;
    for (final i in state.items) {
      if (i.product.id != productId) continue;
      if (excludeLineId != null && i.lineId == excludeLineId) continue;
      sum += i.qty;
    }
    return sum;
  }
}
