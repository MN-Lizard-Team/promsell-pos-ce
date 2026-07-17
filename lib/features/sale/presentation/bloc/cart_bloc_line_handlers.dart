part of 'cart_bloc.dart';

/// Line CRUD, restore, bulk, reorder, catalog refresh.
mixin CartBlocLineHandlers on Bloc<CartEvent, CartState> {
  bool rejectIfPaymentLocked(Emitter<CartState> emit);
  int qtyInCart(String productId, {String? excludeLineId});
  void schedulePromoRecompute();

  void onProductAdded(CartProductAdded event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
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
    final inCartQty = qtyInCart(p.id);
    if (existing >= 0) {
      final currentQty = updated[existing].qty;
      final newQty = currentQty + qtyToAdd;
      if (stockLimited && inCartQty >= p.stock) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final maxForLine = stockLimited
          ? (p.stock - (inCartQty - currentQty)).clamp(0, p.stock)
          : 999999;
      updated[existing] = updated[existing].copyWith(
        qty: stockLimited
            ? newQty.clamp(0, maxForLine).toInt().toInt()
            : newQty,
      );
    } else {
      if (stockLimited && inCartQty >= p.stock) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final remaining = stockLimited
          ? (p.stock - inCartQty).clamp(0, p.stock)
          : qtyToAdd;
      final clampedQty = stockLimited
          ? qtyToAdd.clamp(1, remaining > 0 ? remaining : 1).toInt()
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
    schedulePromoRecompute();
  }

  void onProductRemoved(CartProductRemoved event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    final updated = state.items.where((i) {
      if (event.lineId != null) return i.lineId != event.lineId;
      return i.product.id != event.productId;
    }).toList();
    emit(state.copyWith(items: updated, errorMessage: null));
    schedulePromoRecompute();
  }

  void onQtyChanged(CartItemQtyChanged event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
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
        final others = qtyInCart(i.product.id, excludeLineId: i.lineId);
        final maxForLine = stockLimited
            ? (i.product.stock - others).clamp(1, i.product.stock)
            : 999999;
        final clamped = stockLimited
            ? event.qty.clamp(1, maxForLine).toInt()
            : event.qty.clamp(1, 999999).toInt();
        return i.copyWith(qty: clamped);
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated, errorMessage: null));
    schedulePromoRecompute();
  }

  void onCartCleared(CartCleared event, Emitter<CartState> emit) {
    // Always allow clear (post-sale / reset); drops payment lock.
    emit(const CartState());
  }

  void onCartRestored(CartRestored event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
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
    schedulePromoRecompute();
  }

  void onCartItemRestored(CartItemRestored event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    final updated = List<CartItem>.from(state.items);
    final existing = updated.indexWhere((i) => i.lineId == event.item.lineId);
    if (existing >= 0) {
      updated[existing] = event.item;
    } else {
      updated.add(event.item);
    }
    emit(state.copyWith(items: updated));
    schedulePromoRecompute();
  }

  void onCartItemDuplicated(CartItemDuplicated event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    final item = event.item;
    // allowOversell not on event — treat trackStock as limited (safe default).
    final stockLimited = item.product.trackStock;
    final existingQty = qtyInCart(item.product.id);
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
        ? item.qty.clamp(1, item.product.stock - existingQty).toInt()
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
    schedulePromoRecompute();
  }

  void onProductsRefreshed(
    CartProductsRefreshed event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
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

  void onBulkItemsRemoved(CartBulkItemsRemoved event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    final remove = event.lineIds.toSet();
    final updated = state.items
        .where((i) => !remove.contains(i.lineId))
        .toList();
    emit(state.copyWith(items: updated));
    schedulePromoRecompute();
  }

  void onBulkItemDiscountsCleared(
    CartBulkItemDiscountsCleared event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    final clear = event.lineIds.toSet();
    final updated = state.items.map((i) {
      if (clear.contains(i.lineId)) return i.clearDiscount();
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    schedulePromoRecompute();
  }

  void onCartItemsReordered(CartItemsReordered event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
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

  void onItemNoteChanged(CartItemNoteChanged event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      return matches ? i.copyWith(note: event.note) : i;
    }).toList();
    emit(state.copyWith(items: updated));
  }
}
