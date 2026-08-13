part of 'cart_bloc.dart';

/// Line CRUD, restore, bulk, reorder, catalog refresh.
mixin CartBlocLineHandlers on Bloc<CartEvent, CartState> {
  SettingsRepository get settingsRepo;

  bool rejectIfPaymentLocked(Emitter<CartState> emit);
  int qtyInCart(String productId, {String? excludeLineId});
  int maxQtyForLine({
    required int stock,
    required int othersQty,
    required bool stockLimited,
  });
  void schedulePromoRecompute();

  void onProductAdded(CartProductAdded event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    final p = event.product;
    final qtyToAdd = event.qty;
    if (qtyToAdd <= 0) return;
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
      final others = inCartQty - currentQty;
      final maxForLine = maxQtyForLine(
        stock: p.stock,
        othersQty: others,
        stockLimited: stockLimited,
      );
      if (stockLimited && maxForLine <= 0) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      updated[existing] = updated[existing].copyWith(
        qty: stockLimited ? newQty.clamp(1, maxForLine).toInt() : newQty,
      );
    } else {
      final maxForLine = maxQtyForLine(
        stock: p.stock,
        othersQty: inCartQty,
        stockLimited: stockLimited,
      );
      if (stockLimited && maxForLine <= 0) {
        emit(
          state.copyWith(
            errorMessage: 'outOfStock',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final clampedQty = stockLimited
          ? qtyToAdd.clamp(1, maxForLine).toInt()
          : qtyToAdd;
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
    var outOfStock = false;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      if (!matches) return i;
      final stockLimited = i.product.trackStock && !event.allowOversell;
      final others = qtyInCart(i.product.id, excludeLineId: i.lineId);
      final maxForLine = maxQtyForLine(
        stock: i.product.stock,
        othersQty: others,
        stockLimited: stockLimited,
      );
      if (stockLimited && maxForLine <= 0) {
        outOfStock = true;
        return i;
      }
      final clamped = stockLimited
          ? event.qty.clamp(1, maxForLine).toInt()
          : event.qty.clamp(1, 999999).toInt();
      return i.copyWith(qty: clamped);
    }).toList();
    if (outOfStock) {
      emit(
        state.copyWith(
          errorMessage: 'outOfStock',
          errorNonce: state.errorNonce + 1,
        ),
      );
      return;
    }
    emit(state.copyWith(items: updated, errorMessage: null));
    schedulePromoRecompute();
  }

  void onCartCleared(CartCleared event, Emitter<CartState> emit) {
    // User clear mid-pay must not drop lock (freeze/live desync).
    // System paths pass force: true (post-sale, park, checkout reset).
    if (!event.force && rejectIfPaymentLocked(emit)) return;
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

  Future<void> onCartItemRestored(
    CartItemRestored event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    final item = event.item;
    // Load allowOversell from settings to respect the toggle on undo.
    final settings = await settingsRepo.load();
    final stockLimited = item.product.trackStock && !settings.allowOversell;
    final others = qtyInCart(item.product.id, excludeLineId: item.lineId);
    final maxForLine = maxQtyForLine(
      stock: item.product.stock,
      othersQty: others,
      stockLimited: stockLimited,
    );
    if (stockLimited && maxForLine <= 0) {
      emit(
        state.copyWith(
          errorMessage: 'outOfStock',
          errorNonce: state.errorNonce + 1,
        ),
      );
      return;
    }
    final restored = stockLimited && item.qty > maxForLine
        ? item.copyWith(qty: maxForLine)
        : item;
    final updated = List<CartItem>.from(state.items);
    final existing = updated.indexWhere((i) => i.lineId == restored.lineId);
    if (existing >= 0) {
      updated[existing] = restored;
    } else {
      updated.add(restored);
    }
    emit(state.copyWith(items: updated, errorMessage: null));
    schedulePromoRecompute();
  }

  Future<void> onCartItemDuplicated(
    CartItemDuplicated event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    final item = event.item;
    // Load allowOversell from settings to respect the toggle on duplicate.
    final settings = await settingsRepo.load();
    final stockLimited = item.product.trackStock && !settings.allowOversell;
    final existingQty = qtyInCart(item.product.id);
    final maxForLine = maxQtyForLine(
      stock: item.product.stock,
      othersQty: existingQty,
      stockLimited: stockLimited,
    );
    if (stockLimited && maxForLine <= 0) {
      emit(
        state.copyWith(
          errorMessage: 'outOfStock',
          errorNonce: state.errorNonce + 1,
        ),
      );
      return;
    }

    final duplicateQty = stockLimited
        ? item.qty.clamp(1, maxForLine).toInt()
        : item.qty;
    if (duplicateQty <= 0) {
      emit(
        state.copyWith(
          errorMessage: 'outOfStock',
          errorNonce: state.errorNonce + 1,
        ),
      );
      return;
    }

    final duplicate = CartItem(
      product: item.product,
      qty: duplicateQty,
      discountType: item.discountType,
      discountValue: item.discountValue,
      note: item.note,
      selectedOptions: item.selectedOptions,
      isAvailable: item.isAvailable,
    );
    emit(
      state.copyWith(items: [...state.items, duplicate], errorMessage: null),
    );
    schedulePromoRecompute();
  }

  Future<void> onProductsRefreshed(
    CartProductsRefreshed event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    if (state.isEmpty) return;
    final settings = await settingsRepo.load();
    final allowOversell = settings.allowOversell;
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
      // Validate selectedOptions against the updated product's option groups.
      // Drop any options whose group or option ID no longer exists.
      final validOptions = <SelectedProductOption>[];
      for (final opt in item.selectedOptions) {
        final group = p.optionGroups
            .where((g) => g.id == opt.groupId)
            .firstOrNull;
        if (group == null) continue; // group deleted
        final optionExists = group.options.any((o) => o.id == opt.optionId);
        if (!optionExists) continue; // option deleted
        validOptions.add(opt);
      }
      // Only enforce stock limits when trackStock is on AND oversell is off.
      if (p.trackStock && !allowOversell && p.stock == 0) {
        outOfStockNames.add(p.name);
        updated.add(
          item.copyWith(
            product: p,
            qty: item.qty,
            selectedOptions: validOptions,
          ),
        );
      } else if (p.trackStock && !allowOversell && item.qty > p.stock) {
        updated.add(
          item.copyWith(
            product: p,
            qty: p.stock,
            selectedOptions: validOptions,
          ),
        );
      } else {
        updated.add(item.copyWith(product: p, selectedOptions: validOptions));
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
