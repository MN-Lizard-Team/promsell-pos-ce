part of 'cart_bloc.dart';

/// Barcode scan with debounce.
mixin CartBlocBarcodeHandlers on Bloc<CartEvent, CartState> {
  ProductRepository get productRepo;
  SettingsRepository get settingsRepo;

  bool rejectIfPaymentLocked(Emitter<CartState> emit);
  int qtyInCart(String productId, {String? excludeLineId});

  static const barcodeDebounce = Duration(milliseconds: 1000);
  String? lastScannedBarcode;
  DateTime? lastScannedAt;

  Future<void> onBarcodeScanned(
    CartBarcodeScanned event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    final raw = event.barcode.trim().toUpperCase();
    if (raw.isEmpty) return;

    // Debounce identical codes (camera continuous + HID double-fire).
    final now = DateTime.now();
    if (lastScannedBarcode == raw &&
        lastScannedAt != null &&
        now.difference(lastScannedAt!) < barcodeDebounce) {
      return;
    }
    lastScannedBarcode = raw;
    lastScannedAt = now;

    try {
      final product = await productRepo.getProductByBarcode(raw);
      if (product != null) {
        final settings = await settingsRepo.load();
        final allowOversell = settings.allowOversell;
        final p = product;
        // Merge only empty-options lines (never bump optioned lines).
        final existing = state.items.indexWhere(
          (i) => i.product.id == p.id && i.selectedOptions.isEmpty,
        );
        final updated = List<CartItem>.from(state.items);
        final stockLimited = p.trackStock && !allowOversell;
        final inCartQty = qtyInCart(p.id);
        if (existing >= 0) {
          final currentQty = updated[existing].qty;
          if (stockLimited && inCartQty >= p.stock) {
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
        lastScannedAt = null;
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
        'CartBloc.onBarcodeScanned failed',
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
}
