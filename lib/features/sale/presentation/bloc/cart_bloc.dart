import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required ProductRepository productRepo,
    required SettingsRepository settingsRepo,
  }) : _productRepo = productRepo,
       _settingsRepo = settingsRepo,
       super(const CartState()) {
    on<CartProductAdded>(_onProductAdded);
    on<CartProductRemoved>(_onProductRemoved);
    on<CartItemQtyChanged>(_onQtyChanged);
    on<CartCleared>(_onCartCleared);
    on<CartRestored>(_onCartRestored);
    on<CartItemRestored>(_onCartItemRestored);
    on<CartItemDiscountChanged>(_onItemDiscountChanged);
    on<CartItemDiscountCleared>(_onItemDiscountCleared);
    on<CartDiscountChanged>(_onCartDiscountChanged);
    on<CartDiscountCleared>(_onCartDiscountCleared);
    on<CartNoteChanged>(_onNoteChanged);
    on<CartProductsRefreshed>(_onProductsRefreshed);
    on<CartBarcodeScanned>(_onBarcodeScanned);
    on<CartBulkItemsRemoved>(_onBulkItemsRemoved);
    on<CartBulkItemDiscountsCleared>(_onBulkItemDiscountsCleared);
    on<CartItemsReordered>(_onCartItemsReordered);
  }

  final ProductRepository _productRepo;
  final SettingsRepository _settingsRepo;

  void _onProductAdded(CartProductAdded event, Emitter<CartState> emit) {
    final p = event.product;
    final qtyToAdd = event.qty;
    final existing = state.items.indexWhere((i) => i.product.id == p.id);
    final updated = List<CartItem>.from(state.items);
    final stockLimited = p.trackStock && !event.allowOversell;
    if (existing >= 0) {
      final currentQty = updated[existing].qty;
      final newQty = currentQty + qtyToAdd;
      if (stockLimited && currentQty >= p.stock) return;
      updated[existing] = updated[existing].copyWith(
        qty: stockLimited ? newQty.clamp(0, p.stock) : newQty,
      );
    } else {
      if (stockLimited && p.stock <= 0) {
        emit(state.copyWith(errorMessage: 'outOfStock'));
        return;
      }
      final clampedQty = stockLimited ? qtyToAdd.clamp(1, p.stock) : qtyToAdd;
      updated.add(CartItem(product: p, qty: clampedQty));
    }
    emit(state.copyWith(items: updated, errorMessage: null));
  }

  void _onProductRemoved(CartProductRemoved event, Emitter<CartState> emit) {
    final updated = state.items
        .where((i) => i.product.id != event.productId)
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onQtyChanged(CartItemQtyChanged event, Emitter<CartState> emit) {
    if (event.qty <= 0) {
      add(CartProductRemoved(event.productId));
      return;
    }
    final updated = state.items.map((i) {
      if (i.product.id == event.productId) {
        final stockLimited = i.product.trackStock && !event.allowOversell;
        final clamped = stockLimited
            ? event.qty.clamp(1, i.product.stock)
            : event.qty.clamp(1, 999999);
        return i.copyWith(qty: clamped);
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _onCartRestored(CartRestored event, Emitter<CartState> emit) {
    emit(
      state.copyWith(
        items: event.items,
        cartDiscountType: event.cartDiscountType,
        cartDiscountValue: event.cartDiscountValue,
      ),
    );
  }

  void _onCartItemRestored(CartItemRestored event, Emitter<CartState> emit) {
    final updated = List<CartItem>.from(state.items);
    final existing = updated.indexWhere(
      (i) => i.product.id == event.item.product.id,
    );
    if (existing >= 0) {
      updated[existing] = event.item;
    } else {
      updated.add(event.item);
    }
    emit(state.copyWith(items: updated));
  }

  void _onItemDiscountChanged(
    CartItemDiscountChanged event,
    Emitter<CartState> emit,
  ) {
    final updated = state.items.map((i) {
      if (i.product.id == event.productId) {
        return i.copyWith(
          discountType: event.discountType,
          discountValue: event.discountValue,
        );
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onItemDiscountCleared(
    CartItemDiscountCleared event,
    Emitter<CartState> emit,
  ) {
    final updated = state.items.map((i) {
      if (i.product.id == event.productId) return i.clearDiscount();
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onCartDiscountChanged(
    CartDiscountChanged event,
    Emitter<CartState> emit,
  ) {
    emit(
      state.copyWith(
        cartDiscountType: event.discountType,
        cartDiscountValue: event.discountValue,
      ),
    );
  }

  void _onCartDiscountCleared(
    CartDiscountCleared event,
    Emitter<CartState> emit,
  ) {
    emit(state.copyWith(cartDiscountType: null, cartDiscountValue: null));
  }

  void _onNoteChanged(CartNoteChanged event, Emitter<CartState> emit) {
    emit(state.copyWith(note: event.note));
  }

  void _onProductsRefreshed(
    CartProductsRefreshed event,
    Emitter<CartState> emit,
  ) {
    if (state.isEmpty) return;
    final productMap = {for (final Product p in event.products) p.id: p};
    final updated = <CartItem>[];
    final outOfStockNames = <String>[];
    final deletedNames = <String>[];

    for (final item in state.items) {
      final p = productMap[item.product.id];
      if (p == null) {
        deletedNames.add(item.product.name);
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

  Future<void> _onBarcodeScanned(
    CartBarcodeScanned event,
    Emitter<CartState> emit,
  ) async {
    try {
      final product = await _productRepo.getProductByBarcode(event.barcode);
      if (product != null) {
        final settings = await _settingsRepo.load();
        final allowOversell = settings.allowOversell;
        final p = product;
        final existing = state.items.indexWhere((i) => i.product.id == p.id);
        final updated = List<CartItem>.from(state.items);
        final stockLimited = p.trackStock && !allowOversell;
        if (existing >= 0) {
          final currentQty = updated[existing].qty;
          if (stockLimited && currentQty >= p.stock) {
            emit(state.copyWith(errorMessage: 'outOfStock'));
            return;
          }
          final newQty = currentQty + 1;
          updated[existing] = updated[existing].copyWith(
            qty: stockLimited ? newQty.clamp(0, p.stock) : newQty,
          );
        } else {
          if (stockLimited && p.stock <= 0) {
            emit(state.copyWith(errorMessage: 'outOfStock'));
            return;
          }
          updated.add(CartItem(product: p, qty: 1));
        }
        emit(state.copyWith(items: updated, errorMessage: null));
      } else {
        emit(state.copyWith(errorMessage: 'barcodeNotFound'));
      }
    } catch (e) {
      AppLogger.error('CartBloc._onBarcodeScanned failed', error: e);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onBulkItemsRemoved(
    CartBulkItemsRemoved event,
    Emitter<CartState> emit,
  ) {
    final updated = state.items
        .where((i) => !event.productIds.contains(i.product.id))
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onBulkItemDiscountsCleared(
    CartBulkItemDiscountsCleared event,
    Emitter<CartState> emit,
  ) {
    final updated = state.items.map((i) {
      if (event.productIds.contains(i.product.id)) return i.clearDiscount();
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onCartItemsReordered(
    CartItemsReordered event,
    Emitter<CartState> emit,
  ) {
    final orderMap = {
      for (var i = 0; i < event.productIds.length; i++) event.productIds[i]: i,
    };
    final fallbackIndex = event.productIds.length;
    final updated = [...state.items];
    updated.sort((a, b) {
      final aIndex = orderMap[a.product.id] ?? fallbackIndex;
      final bIndex = orderMap[b.product.id] ?? fallbackIndex;
      return aIndex.compareTo(bIndex);
    });
    emit(state.copyWith(items: updated));
  }
}
