import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/cart_discount_math.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class CreateSale {
  const CreateSale(this._repository, this._settingsRepo);
  final SaleRepository _repository;
  final SettingsRepository _settingsRepo;

  Future<Sale> call({
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
  }) async {
    Validators.nonEmptyCart(items);
    for (final item in items) {
      Validators.qty(item.qty);
      Validators.price(item.product.price.value);
    }

    final settings = await _settingsRepo.load();
    if (SalesDayLock.isCreateBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
    )) {
      throw const BusinessRuleError(SalesDayLock.ruleDayClosed);
    }

    // Fiscal policy: clamp VAT rate and cart discount against settings.
    final safeVatRate = vatRate.clamp(0.0, 100.0);
    var safeCartDiscountType = cartDiscountType;
    var safeCartDiscountValue = cartDiscountValue;
    if (safeCartDiscountType != null && safeCartDiscountValue != null) {
      final isPercent = safeCartDiscountType.toUpperCase() == 'PERCENT';
      if (isPercent) {
        final maxP = settings.maxDiscountPercent.clamp(0.0, 100.0);
        if (safeCartDiscountValue > maxP) {
          safeCartDiscountValue = maxP;
        }
      } else {
        final maxAmt = settings.maxDiscountAmount.value;
        if (maxAmt > 0 && safeCartDiscountValue > maxAmt) {
          safeCartDiscountValue = maxAmt;
        }
      }
    }
    final safeServiceChargeRate = serviceChargeRate.clamp(0.0, 100.0);

    // Wave D / AH-2.3: recompute money from lines + clamped type/value.
    // Do not trust client cartDiscountAmount / serviceChargeAmount alone.
    final itemsSubtotal = items.fold(Money.zero, (sum, i) => sum + i.subtotal);
    final recomputedCartDiscount = CartDiscountMath.amountFromTypeValue(
      type: safeCartDiscountType,
      value: safeCartDiscountValue,
      itemsSubtotal: itemsSubtotal,
    );
    final recomputedPromo = CartDiscountMath.clampPromotionToBase(
      itemsSubtotal: itemsSubtotal,
      cartDiscountAmount: recomputedCartDiscount,
      promotionDiscount: promotionDiscountAmount,
    );
    final recomputedServiceCharge = CartDiscountMath.serviceChargeFromRate(
      itemsSubtotal: itemsSubtotal,
      cartDiscountAmount: recomputedCartDiscount,
      promotionDiscountAmount: recomputedPromo,
      serviceChargeRate: safeServiceChargeRate,
    );

    return _repository.createSale(
      items: items,
      paymentMethod: paymentMethod,
      vatMode: vatMode,
      vatRate: safeVatRate,
      cartDiscountType: safeCartDiscountType,
      cartDiscountValue: safeCartDiscountValue,
      cartDiscountAmount: recomputedCartDiscount,
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
      serviceChargeRate: safeServiceChargeRate,
      serviceChargeAmount: recomputedServiceCharge,
      customerId: customerId,
      promotionId: promotionId,
      promotionDiscountAmount: recomputedPromo,
      originatingDraftCartId: originatingDraftCartId,
      selectedItemIds: selectedItemIds,
    );
  }
}
