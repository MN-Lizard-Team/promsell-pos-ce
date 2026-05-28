import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  SaleBloc({required CreateSale createSale})
    : _createSale = createSale,
      super(const SaleState()) {
    on<SaleProductAdded>(_onProductAdded);
    on<SaleProductRemoved>(_onProductRemoved);
    on<SaleItemQtyChanged>(_onQtyChanged);
    on<SaleCartCleared>(_onCartCleared);
    on<SaleConfirmed>(_onConfirmed);
    on<SaleNoteChanged>(_onNoteChanged);
    on<SaleCartProductsRefreshed>(_onProductsRefreshed);
    on<SaleReset>(_onReset);
  }

  final CreateSale _createSale;

  void _onProductAdded(SaleProductAdded event, Emitter<SaleState> emit) {
    final existing = state.items.indexWhere(
      (i) => i.product.id == event.product.id,
    );
    final updated = List<CartItem>.from(state.items);
    if (existing >= 0) {
      final currentQty = updated[existing].qty;
      if (currentQty >= event.product.stock) return;
      updated[existing] = updated[existing].copyWith(qty: currentQty + 1);
    } else {
      updated.add(CartItem(product: event.product, qty: 1));
    }
    emit(
      state.copyWith(
        items: updated,
        status: SaleStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void _onProductRemoved(SaleProductRemoved event, Emitter<SaleState> emit) {
    final updated = state.items
        .where((i) => i.product.id != event.productId)
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onQtyChanged(SaleItemQtyChanged event, Emitter<SaleState> emit) {
    if (event.qty <= 0) {
      add(SaleProductRemoved(event.productId));
      return;
    }
    final updated = state.items.map((i) {
      if (i.product.id == event.productId) {
        return i.copyWith(qty: event.qty.clamp(1, i.product.stock));
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onCartCleared(SaleCartCleared event, Emitter<SaleState> emit) {
    emit(const SaleState());
  }

  void _onNoteChanged(SaleNoteChanged event, Emitter<SaleState> emit) {
    emit(state.copyWith(note: event.note));
  }

  void _onProductsRefreshed(
    SaleCartProductsRefreshed event,
    Emitter<SaleState> emit,
  ) {
    if (state.isEmpty) return;
    final productMap = {for (final Product p in event.products) p.id: p};
    final updated = state.items
        .where((i) => productMap.containsKey(i.product.id))
        .map((i) => i.copyWith(product: productMap[i.product.id]!))
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onReset(SaleReset event, Emitter<SaleState> emit) {
    emit(
      const SaleState().copyWith(
        items: state.items,
        note: state.note,
      ),
    );
  }

  Future<void> _onConfirmed(
    SaleConfirmed event,
    Emitter<SaleState> emit,
  ) async {
    if (state.items.isEmpty) return;
    emit(state.copyWith(status: SaleStatus.processing, errorMessage: null));
    try {
      final sale = await _createSale(
        items: state.items,
        paymentMethod: event.paymentMethod,
        amountReceived: event.amountReceived,
        changeAmount: event.changeAmount,
        note: event.note,
      );
      emit(SaleState(status: SaleStatus.success, lastSale: sale));
    } catch (e) {
      emit(
        state.copyWith(status: SaleStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
