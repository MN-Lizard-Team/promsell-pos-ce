import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required ProductRepository productRepo,
    required SettingsRepository settingsRepo,
    required PromotionRepository promotionRepo,
  }) : _productRepo = productRepo,
       _settingsRepo = settingsRepo,
       _promotionRepo = promotionRepo,
       super(const CartState()) {
    on<CartProductAdded>(_onProductAdded);
    on<CartProductRemoved>(_onProductRemoved);
    on<CartItemQtyChanged>(_onQtyChanged);
    on<CartCleared>(_onCartCleared);
    on<CartRestored>(_onCartRestored);
    on<CartItemRestored>(_onCartItemRestored);
    on<CartItemDuplicated>(_onCartItemDuplicated);
    on<CartItemDiscountChanged>(_onItemDiscountChanged);
    on<CartItemDiscountCleared>(_onItemDiscountCleared);
    on<CartDiscountChanged>(_onCartDiscountChanged);
    on<CartDiscountCleared>(_onCartDiscountCleared);
    on<CartNoteChanged>(_onNoteChanged);
    on<CartProductsRefreshed>(_onProductsRefreshed);
    // Async paths: run sequentially to avoid lost updates after await.
    on<CartBarcodeScanned>(_onBarcodeScanned, transformer: sequential());
    on<CartBulkItemsRemoved>(_onBulkItemsRemoved);
    on<CartBulkItemDiscountsCleared>(_onBulkItemDiscountsCleared);
    on<CartItemsReordered>(_onCartItemsReordered);
    on<CartItemNoteChanged>(_onItemNoteChanged);
    on<CartTableAssigned>(_onTableAssigned);
    on<CartCustomerSet>(_onCustomerSet);
    on<CartPromotionSet>(_onPromotionSet, transformer: sequential());
    on<CartPromotionRecompute>(
      _onPromotionRecompute,
      transformer: sequential(),
    );
    on<CartOrderTypeChanged>(_onOrderTypeChanged);
    on<CartOrderChannelChanged>(_onOrderChannelChanged);
    on<CartExternalOrderRefChanged>(_onExternalOrderRefChanged);
    on<CartServiceChargeRateChanged>(_onServiceChargeRateChanged);
    on<CartPaymentLockChanged>(_onPaymentLockChanged);
  }

  final ProductRepository _productRepo;
  final SettingsRepository _settingsRepo;
  final PromotionRepository _promotionRepo;

  void _schedulePromoRecompute() {
    if (state.promotionId != null) {
      add(const CartPromotionRecompute());
    }
  }

  Money _promoBase(CartState s) =>
      (s.itemsSubtotal - s.cartDiscountAmount).clampToZero();

  bool get isPaymentLocked => state.paymentLocked;

  /// Mutations blocked while checkout is waitingPayment/processing.
  bool _rejectIfPaymentLocked(Emitter<CartState> emit) {
    if (!state.paymentLocked) return false;
    emit(
      state.copyWith(
        errorMessage: 'paymentInProgress',
        errorNonce: state.errorNonce + 1,
      ),
    );
    return true;
  }

  void _onPaymentLockChanged(
    CartPaymentLockChanged event,
    Emitter<CartState> emit,
  ) {
    if (state.paymentLocked == event.locked) return;
    emit(state.copyWith(paymentLocked: event.locked, errorMessage: null));
  }

  int _qtyInCart(String productId, {String? excludeLineId}) {
    var sum = 0;
    for (final i in state.items) {
      if (i.product.id != productId) continue;
      if (excludeLineId != null && i.lineId == excludeLineId) continue;
      sum += i.qty;
    }
    return sum;
  }

  void _onProductAdded(CartProductAdded event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    final p = event.product;
    final qtyToAdd = event.qty;
    final options = event.selectedOptions;
    final hasOptions = options.isNotEmpty;
    final existing = hasOptions
        ? -1
        : state.items.indexWhere(
            (i) => i.product.id == p.id && i.selectedOptions.isEmpty,
          );
    final updated = List<CartItem>.from(state.items);
    final stockLimited = p.trackStock && !event.allowOversell;
    final qtyInCart = _qtyInCart(p.id);
    if (existing >= 0) {
      final currentQty = updated[existing].qty;
      final newQty = currentQty + qtyToAdd;
      if (stockLimited && qtyInCart >= p.stock) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final maxForLine = stockLimited
          ? (p.stock - (qtyInCart - currentQty)).clamp(0, p.stock)
          : 999999;
      updated[existing] = updated[existing].copyWith(
        qty: stockLimited ? newQty.clamp(0, maxForLine) : newQty,
      );
    } else {
      if (stockLimited && qtyInCart >= p.stock) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final remaining = stockLimited
          ? (p.stock - qtyInCart).clamp(0, p.stock)
          : qtyToAdd;
      final clampedQty = stockLimited
          ? qtyToAdd.clamp(1, remaining > 0 ? remaining : 1)
          : qtyToAdd;
      if (stockLimited && remaining <= 0) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      updated.add(
        CartItem(product: p, qty: clampedQty, selectedOptions: options),
      );
    }
    emit(state.copyWith(items: updated, errorMessage: null));
    _schedulePromoRecompute();
  }

  void _onProductRemoved(CartProductRemoved event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    final updated = state.items.where((i) {
      if (event.lineId != null) return i.lineId != event.lineId;
      return i.product.id != event.productId;
    }).toList();
    emit(state.copyWith(items: updated, errorMessage: null));
    _schedulePromoRecompute();
  }

  void _onQtyChanged(CartItemQtyChanged event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    if (event.qty <= 0) {
      add(CartProductRemoved(event.productId, lineId: event.lineId));
      return;
    }
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      if (matches) {
        final stockLimited = i.product.trackStock && !event.allowOversell;
        final others = _qtyInCart(i.product.id, excludeLineId: i.lineId);
        final maxForLine = stockLimited
            ? (i.product.stock - others).clamp(1, i.product.stock)
            : 999999;
        final clamped = stockLimited
            ? event.qty.clamp(1, maxForLine)
            : event.qty.clamp(1, 999999);
        return i.copyWith(qty: clamped);
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated, errorMessage: null));
    _schedulePromoRecompute();
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    // Always allow clear (post-sale / reset); drops payment lock.
    emit(const CartState());
  }

  void _onCartRestored(CartRestored event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(
      CartState(
        items: event.items,
        note: event.note,
        cartDiscountType: event.cartDiscountType,
        cartDiscountValue: event.cartDiscountValue,
        orderType: event.orderType,
        orderChannel: event.orderChannel,
        externalOrderRef: event.externalOrderRef,
        tableId: event.tableId,
        serviceChargeRate: event.serviceChargeRate,
        customerId: event.customerId,
        promotionId: event.promotionId,
        promotionDiscountAmount: event.promotionDiscountAmount,
      ),
    );
    _schedulePromoRecompute();
  }

  void _onCartItemRestored(CartItemRestored event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    final updated = List<CartItem>.from(state.items);
    final existing = updated.indexWhere((i) => i.lineId == event.item.lineId);
    if (existing >= 0) {
      updated[existing] = event.item;
    } else {
      updated.add(event.item);
    }
    emit(state.copyWith(items: updated));
    _schedulePromoRecompute();
  }

  void _onCartItemDuplicated(
    CartItemDuplicated event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    final item = event.item;
    // allowOversell not on event — treat trackStock as limited (safe default).
    final stockLimited = item.product.trackStock;
    final existingQty = _qtyInCart(item.product.id);
    if (stockLimited && existingQty >= item.product.stock) {
      emit(
        state.copyWith(
          errorMessage: 'outOfStock',
          errorNonce: state.errorNonce + 1,
        ),
      );
      return;
    }

    final duplicateQty = stockLimited
        ? item.qty.clamp(1, item.product.stock - existingQty)
        : item.qty;
    if (duplicateQty <= 0) return;

    final duplicate = CartItem(
      product: item.product,
      qty: duplicateQty,
      discountType: item.discountType,
      discountValue: item.discountValue,
      note: item.note,
      selectedOptions: item.selectedOptions,
      isAvailable: item.isAvailable,
    );
    emit(state.copyWith(items: [...state.items, duplicate]));
    _schedulePromoRecompute();
  }

  Future<void> _onItemDiscountChanged(
    CartItemDiscountChanged event,
    Emitter<CartState> emit,
  ) async {
    if (_rejectIfPaymentLocked(emit)) return;
    final clamped = await _clampDiscount(
      type: event.discountType,
      value: event.discountValue,
    );
    if (clamped == null) return;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      if (matches) {
        return i.copyWith(discountType: clamped.$1, discountValue: clamped.$2);
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    _schedulePromoRecompute();
  }

  void _onItemDiscountCleared(
    CartItemDiscountCleared event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      return matches ? i.clearDiscount() : i;
    }).toList();
    emit(state.copyWith(items: updated));
    _schedulePromoRecompute();
  }

  Future<void> _onCartDiscountChanged(
    CartDiscountChanged event,
    Emitter<CartState> emit,
  ) async {
    if (_rejectIfPaymentLocked(emit)) return;
    final clamped = await _clampDiscount(
      type: event.discountType,
      value: event.discountValue,
    );
    if (clamped == null) {
      emit(state.copyWith(cartDiscountType: null, cartDiscountValue: null));
      _schedulePromoRecompute();
      return;
    }
    emit(
      state.copyWith(
        cartDiscountType: clamped.$1,
        cartDiscountValue: clamped.$2,
      ),
    );
    _schedulePromoRecompute();
  }

  /// Enforces settings discount policy (not UI-only).
  /// Returns null when item/cart discounts are disabled for that type path.
  Future<(String, double)?> _clampDiscount({
    required String type,
    required double value,
  }) async {
    try {
      final settings = await _settingsRepo.load();
      final isPercent = type.toUpperCase() == 'PERCENT';
      if (isPercent &&
          !settings.enableItemDiscount &&
          !settings.enableCartDiscount) {
        // Still allow if either path is on; finer flags enforced at dialog.
      }
      if (value <= 0) return null;
      if (isPercent) {
        final maxP = settings.maxDiscountPercent.clamp(0.0, 100.0);
        return (type, value.clamp(0.0, maxP));
      }
      final maxAmt = settings.maxDiscountAmount.value;
      final capped = maxAmt > 0 ? value.clamp(0.0, maxAmt) : value;
      return (type, capped);
    } catch (e, stack) {
      AppLogger.warning(
        'CartBloc._clampDiscount failed; applying raw value',
        error: e,
        stack: stack,
      );
      return (type, value);
    }
  }

  void _onCartDiscountCleared(
    CartDiscountCleared event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(cartDiscountType: null, cartDiscountValue: null));
    _schedulePromoRecompute();
  }

  void _onNoteChanged(CartNoteChanged event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(note: event.note));
  }

  void _onProductsRefreshed(
    CartProductsRefreshed event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    if (state.isEmpty) return;
    final productMap = {for (final Product p in event.products) p.id: p};
    final updated = <CartItem>[];
    final outOfStockNames = <String>[];
    final deletedNames = <String>[];

    for (final item in state.items) {
      final p = productMap[item.product.id];
      if (p == null) {
        deletedNames.add(item.product.name);
        updated.add(item.copyWith(isAvailable: false));
        continue;
      }
      if (p.trackStock && p.stock == 0) {
        outOfStockNames.add(p.name);
        updated.add(item.copyWith(product: p, qty: item.qty));
      } else if (p.trackStock && item.qty > p.stock) {
        updated.add(item.copyWith(product: p, qty: p.stock));
      } else {
        updated.add(item.copyWith(product: p));
      }
    }

    final allWarnings = [...outOfStockNames, ...deletedNames];
    final warning = allWarnings.isNotEmpty ? allWarnings.join(', ') : null;

    emit(state.copyWith(items: updated, stockWarning: warning));
  }

  static const _barcodeDebounce = Duration(milliseconds: 1000);
  String? _lastScannedBarcode;
  DateTime? _lastScannedAt;

  Future<void> _onBarcodeScanned(
    CartBarcodeScanned event,
    Emitter<CartState> emit,
  ) async {
    if (_rejectIfPaymentLocked(emit)) return;
    final raw = event.barcode.trim().toUpperCase();
    if (raw.isEmpty) return;

    // Debounce identical codes (camera continuous + HID double-fire).
    final now = DateTime.now();
    if (_lastScannedBarcode == raw &&
        _lastScannedAt != null &&
        now.difference(_lastScannedAt!) < _barcodeDebounce) {
      return;
    }
    _lastScannedBarcode = raw;
    _lastScannedAt = now;

    try {
      final product = await _productRepo.getProductByBarcode(raw);
      if (product != null) {
        final settings = await _settingsRepo.load();
        final allowOversell = settings.allowOversell;
        final p = product;
        // Merge only empty-options lines (never bump optioned lines).
        final existing = state.items.indexWhere(
          (i) => i.product.id == p.id && i.selectedOptions.isEmpty,
        );
        final updated = List<CartItem>.from(state.items);
        final stockLimited = p.trackStock && !allowOversell;
        final qtyInCart = _qtyInCart(p.id);
        if (existing >= 0) {
          final currentQty = updated[existing].qty;
          if (stockLimited && qtyInCart >= p.stock) {
            emit(
              state.copyWith(
                errorMessage: 'outOfStock',
                lastFailedBarcode: null,
                errorNonce: state.errorNonce + 1,
              ),
            );
            return;
          }
          final newQty = currentQty + 1;
          final maxForLine = stockLimited
              ? (p.stock - (qtyInCart - currentQty)).clamp(0, p.stock)
              : 999999;
          updated[existing] = updated[existing].copyWith(
            qty: stockLimited ? newQty.clamp(0, maxForLine) : newQty,
          );
        } else {
          if (stockLimited && qtyInCart >= p.stock) {
            emit(
              state.copyWith(
                errorMessage: 'outOfStock',
                lastFailedBarcode: null,
                errorNonce: state.errorNonce + 1,
              ),
            );
            return;
          }
          updated.add(CartItem(product: p, qty: 1));
        }
        emit(
          state.copyWith(
            items: updated,
            errorMessage: null,
            lastFailedBarcode: null,
          ),
        );
      } else {
        // Allow immediate re-scan after create-product recovery CTA.
        _lastScannedAt = null;
        emit(
          state.copyWith(
            errorMessage: 'barcodeNotFound',
            lastFailedBarcode: raw,
            errorNonce: state.errorNonce + 1,
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        'CartBloc._onBarcodeScanned failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          errorMessage: 'errorOccurred',
          lastFailedBarcode: null,
          errorNonce: state.errorNonce + 1,
        ),
      );
    }
  }

  void _onBulkItemsRemoved(
    CartBulkItemsRemoved event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    final remove = event.lineIds.toSet();
    final updated = state.items
        .where((i) => !remove.contains(i.lineId))
        .toList();
    emit(state.copyWith(items: updated));
    _schedulePromoRecompute();
  }

  void _onBulkItemDiscountsCleared(
    CartBulkItemDiscountsCleared event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    final clear = event.lineIds.toSet();
    final updated = state.items.map((i) {
      if (clear.contains(i.lineId)) return i.clearDiscount();
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    _schedulePromoRecompute();
  }

  void _onCartItemsReordered(
    CartItemsReordered event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    final orderMap = {
      for (var i = 0; i < event.lineIds.length; i++) event.lineIds[i]: i,
    };
    final fallbackIndex = event.lineIds.length;
    final updated = [...state.items];
    updated.sort((a, b) {
      final aIndex = orderMap[a.lineId] ?? fallbackIndex;
      final bIndex = orderMap[b.lineId] ?? fallbackIndex;
      return aIndex.compareTo(bIndex);
    });
    emit(state.copyWith(items: updated));
  }

  void _onItemNoteChanged(CartItemNoteChanged event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      return matches ? i.copyWith(note: event.note) : i;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onTableAssigned(CartTableAssigned event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(tableId: event.tableId));
  }

  void _onCustomerSet(CartCustomerSet event, Emitter<CartState> emit) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(customerId: event.customerId));
  }

  Future<void> _onPromotionSet(
    CartPromotionSet event,
    Emitter<CartState> emit,
  ) async {
    if (_rejectIfPaymentLocked(emit)) return;
    if (event.promotionId == null) {
      emit(
        state.copyWith(
          promotionId: null,
          promotionDiscountAmount: 0,
          errorMessage: null,
        ),
      );
      return;
    }
    try {
      final promo = await _promotionRepo.getPromotionById(event.promotionId!);
      if (promo == null || !promo.isCurrentlyActive) {
        emit(
          state.copyWith(
            errorMessage: 'promotionNotFound',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final amount = promo.discountFor(_promoBase(state));
      emit(
        state.copyWith(
          promotionId: promo.id,
          promotionDiscountAmount: amount.value,
          errorMessage: null,
        ),
      );
    } catch (e, st) {
      AppLogger.error('CartBloc._onPromotionSet failed', error: e, stack: st);
      emit(
        state.copyWith(
          errorMessage: 'promotionNotFound',
          errorNonce: state.errorNonce + 1,
        ),
      );
    }
  }

  Future<void> _onPromotionRecompute(
    CartPromotionRecompute event,
    Emitter<CartState> emit,
  ) async {
    if (_rejectIfPaymentLocked(emit)) return;
    final id = state.promotionId;
    if (id == null) return;
    try {
      final promo = await _promotionRepo.getPromotionById(id);
      if (promo == null || !promo.isCurrentlyActive) {
        emit(
          state.copyWith(
            promotionId: null,
            promotionDiscountAmount: 0,
            errorMessage: 'promotionNotFound',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final amount = promo.discountFor(_promoBase(state));
      if (amount.value == state.promotionDiscountAmount) return;
      emit(state.copyWith(promotionDiscountAmount: amount.value));
    } catch (e, st) {
      AppLogger.error(
        'CartBloc._onPromotionRecompute failed',
        error: e,
        stack: st,
      );
    }
  }

  void _onOrderTypeChanged(
    CartOrderTypeChanged event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(orderType: event.orderType));
  }

  void _onOrderChannelChanged(
    CartOrderChannelChanged event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(orderChannel: event.orderChannel));
  }

  void _onExternalOrderRefChanged(
    CartExternalOrderRefChanged event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(externalOrderRef: event.externalOrderRef));
  }

  void _onServiceChargeRateChanged(
    CartServiceChargeRateChanged event,
    Emitter<CartState> emit,
  ) {
    if (_rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(serviceChargeRate: event.rate));
  }
}
