import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  SaleBloc({
    required CreateSale createSale,
    required DraftCartRepository draftRepo,
    required SettingsRepository settingsRepo,
  }) : _createSale = createSale,
       _draftRepo = draftRepo,
       _settingsRepo = settingsRepo,
       super(const SaleState()) {
    on<SaleProductAdded>(_onProductAdded);
    on<SaleProductRemoved>(_onProductRemoved);
    on<SaleItemQtyChanged>(_onQtyChanged);
    on<SaleCartCleared>(_onCartCleared);
    on<SaleConfirmed>(_onConfirmed);
    on<SaleNoteChanged>(_onNoteChanged);
    on<SaleCartProductsRefreshed>(_onProductsRefreshed);
    on<SaleReset>(_onReset);
    on<SaleItemDiscountChanged>(_onItemDiscountChanged);
    on<SaleItemDiscountCleared>(_onItemDiscountCleared);
    on<SaleCartDiscountChanged>(_onCartDiscountChanged);
    on<SaleCartDiscountCleared>(_onCartDiscountCleared);
    on<SaleDraftInitialized>(_onDraftInitialized);
    on<SaleDraftSwitched>(_onDraftSwitched);
    on<SaleDraftCreated>(_onDraftCreated);
    on<SaleDraftDeleted>(_onDraftDeleted);
    on<SaleDraftRenamed>(_onDraftRenamed);
    on<SaleCartRestored>(_onCartRestored);
    on<SaleBulkItemsRemoved>(_onBulkItemsRemoved);
    on<SaleBulkItemDiscountsCleared>(_onBulkItemDiscountsCleared);
    on<SaleCartItemsReordered>(_onCartItemsReordered);
  }

  final CreateSale _createSale;
  final DraftCartRepository _draftRepo;
  final SettingsRepository _settingsRepo;
  Timer? _saveTimer;

  void _onProductAdded(SaleProductAdded event, Emitter<SaleState> emit) {
    final p = event.product;
    final existing = state.items.indexWhere((i) => i.product.id == p.id);
    final updated = List<CartItem>.from(state.items);
    if (existing >= 0) {
      final currentQty = updated[existing].qty;
      final stockLimited = p.trackStock && !event.allowOversell;
      if (stockLimited && currentQty >= p.stock) return;
      updated[existing] = updated[existing].copyWith(qty: currentQty + 1);
    } else {
      updated.add(CartItem(product: p, qty: 1));
    }
    emit(
      state.copyWith(
        items: updated,
        status: SaleStatus.idle,
        errorMessage: null,
      ),
    );
    _scheduleSave();
  }

  void _onProductRemoved(SaleProductRemoved event, Emitter<SaleState> emit) {
    final updated = state.items
        .where((i) => i.product.id != event.productId)
        .toList();
    emit(state.copyWith(items: updated));
    _scheduleSave();
  }

  void _onQtyChanged(SaleItemQtyChanged event, Emitter<SaleState> emit) {
    if (event.qty <= 0) {
      add(SaleProductRemoved(event.productId));
      return;
    }
    final updated = state.items.map((i) {
      if (i.product.id == event.productId) {
        final stockLimited = i.product.trackStock && !event.allowOversell;
        final clamped = stockLimited
            ? event.qty.clamp(1, i.product.stock)
            : event.qty.clamp(1, 99999);
        return i.copyWith(qty: clamped);
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    _scheduleSave();
  }

  void _onCartCleared(SaleCartCleared event, Emitter<SaleState> emit) {
    emit(
      SaleState(
        activeDraftId: state.activeDraftId,
        activeDraftName: state.activeDraftName,
        cartDiscountType: state.cartDiscountType,
        cartDiscountValue: state.cartDiscountValue,
      ),
    );
    _scheduleSave();
  }

  void _onCartRestored(SaleCartRestored event, Emitter<SaleState> emit) {
    emit(
      state.copyWith(
        items: event.items,
        cartDiscountType: event.cartDiscountType,
        cartDiscountValue: event.cartDiscountValue,
      ),
    );
    _scheduleSave();
  }

  void _onItemDiscountChanged(
    SaleItemDiscountChanged event,
    Emitter<SaleState> emit,
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
    _scheduleSave();
  }

  void _onItemDiscountCleared(
    SaleItemDiscountCleared event,
    Emitter<SaleState> emit,
  ) {
    final updated = state.items.map((i) {
      if (i.product.id == event.productId) return i.clearDiscount();
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    _scheduleSave();
  }

  void _onBulkItemsRemoved(
    SaleBulkItemsRemoved event,
    Emitter<SaleState> emit,
  ) {
    final updated = state.items
        .where((i) => !event.productIds.contains(i.product.id))
        .toList();
    emit(state.copyWith(items: updated));
    _scheduleSave();
  }

  void _onBulkItemDiscountsCleared(
    SaleBulkItemDiscountsCleared event,
    Emitter<SaleState> emit,
  ) {
    final updated = state.items.map((i) {
      if (event.productIds.contains(i.product.id)) return i.clearDiscount();
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    _scheduleSave();
  }

  void _onCartItemsReordered(
    SaleCartItemsReordered event,
    Emitter<SaleState> emit,
  ) {
    final orderMap = {
      for (var i = 0; i < event.productIds.length; i++) event.productIds[i]: i,
    };
    final updated = [...state.items];
    updated.sort((a, b) {
      final aIndex = orderMap[a.product.id] ?? 0;
      final bIndex = orderMap[b.product.id] ?? 0;
      return aIndex.compareTo(bIndex);
    });
    emit(state.copyWith(items: updated));
    _scheduleSave();
  }

  void _onCartDiscountChanged(
    SaleCartDiscountChanged event,
    Emitter<SaleState> emit,
  ) {
    emit(
      state.copyWith(
        cartDiscountType: event.discountType,
        cartDiscountValue: event.discountValue,
      ),
    );
    _scheduleSave();
  }

  void _onCartDiscountCleared(
    SaleCartDiscountCleared event,
    Emitter<SaleState> emit,
  ) {
    emit(state.copyWith(cartDiscountType: null, cartDiscountValue: null));
    _scheduleSave();
  }

  void _onNoteChanged(SaleNoteChanged event, Emitter<SaleState> emit) {
    emit(state.copyWith(note: event.note));
    _scheduleSave();
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
        .where((i) => !i.product.trackStock || i.product.stock > 0)
        .map((i) {
          if (!i.product.trackStock) return i;
          return i.copyWith(qty: i.qty.clamp(1, i.product.stock));
        })
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onReset(SaleReset event, Emitter<SaleState> emit) {
    emit(
      SaleState(
        items: state.items,
        note: state.note,
        activeDraftId: state.activeDraftId,
        activeDraftName: state.activeDraftName,
        cartDiscountType: state.cartDiscountType,
        cartDiscountValue: state.cartDiscountValue,
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
        vatMode: event.vatMode,
        vatRate: event.vatRate,
        cartDiscountType: event.cartDiscountType,
        cartDiscountValue: event.cartDiscountValue,
        cartDiscountAmount: event.cartDiscountAmount,
        amountReceived: event.amountReceived,
        changeAmount: event.changeAmount,
        note: event.note,
      );
      final prevDraftId = state.activeDraftId;
      if (prevDraftId != null) {
        await _draftRepo.deleteDraft(prevDraftId);
      }
      final draftCount = await _draftRepo.countDrafts();
      final newDraftName = 'Bill #${draftCount + 1}';
      final newDraftId = await _draftRepo.createDraft(name: newDraftName);
      emit(
        SaleState(
          status: SaleStatus.success,
          lastSale: sale,
          activeDraftId: newDraftId,
          activeDraftName: newDraftName,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: SaleStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _scheduleSave() {
    final draftId = state.activeDraftId;
    if (draftId == null) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!isClosed && state.activeDraftId == draftId) {
        _draftRepo.saveDraft(draftId, state, name: state.activeDraftName);
      }
    });
  }

  Future<void> _onDraftInitialized(
    SaleDraftInitialized event,
    Emitter<SaleState> emit,
  ) async {
    try {
      // Archive drafts older than 7 days
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      await _draftRepo.archiveOldDrafts(cutoff);

      final drafts = await _draftRepo.listDrafts();
      if (drafts.isEmpty) {
        final id = await _draftRepo.createDraft();
        emit(state.copyWith(activeDraftId: id));
      } else {
        final draft = drafts.first;
        emit(
          SaleState(
            activeDraftId: draft.id,
            activeDraftName: draft.name,
            items: draft.items,
            note: draft.note ?? '',
            cartDiscountType: draft.cartDiscountType,
            cartDiscountValue: draft.cartDiscountValue,
          ),
        );
      }
    } catch (_) {
      final id = await _draftRepo.createDraft();
      emit(state.copyWith(activeDraftId: id));
    }
  }

  Future<void> _onDraftSwitched(
    SaleDraftSwitched event,
    Emitter<SaleState> emit,
  ) async {
    if (event.draftId == state.activeDraftId) return;
    if (state.activeDraftId != null) {
      await _draftRepo.saveDraft(
        state.activeDraftId!,
        state,
        name: state.activeDraftName,
      );
    }
    final draft = await _draftRepo.loadDraft(event.draftId);
    if (draft == null) return;
    emit(
      SaleState(
        activeDraftId: draft.id,
        activeDraftName: draft.name,
        items: draft.items,
        note: draft.note ?? '',
        cartDiscountType: draft.cartDiscountType,
        cartDiscountValue: draft.cartDiscountValue,
      ),
    );
  }

  Future<void> _onDraftCreated(
    SaleDraftCreated event,
    Emitter<SaleState> emit,
  ) async {
    final count = await _draftRepo.countDrafts();
    final settings = await _settingsRepo.load();
    if (count >= settings.maxDrafts) return;
    if (state.activeDraftId != null) {
      await _draftRepo.saveDraft(
        state.activeDraftId!,
        state,
        name: state.activeDraftName,
      );
    }
    final id = await _draftRepo.createDraft(name: event.name);
    emit(SaleState(activeDraftId: id, activeDraftName: event.name ?? 'Draft'));
  }

  Future<void> _onDraftDeleted(
    SaleDraftDeleted event,
    Emitter<SaleState> emit,
  ) async {
    await _draftRepo.deleteDraft(event.draftId);
    if (event.draftId != state.activeDraftId) return;
    final remaining = await _draftRepo.listDrafts();
    if (remaining.isNotEmpty) {
      final draft = remaining.first;
      emit(
        SaleState(
          activeDraftId: draft.id,
          activeDraftName: draft.name,
          items: draft.items,
          note: draft.note ?? '',
          cartDiscountType: draft.cartDiscountType,
          cartDiscountValue: draft.cartDiscountValue,
        ),
      );
    } else {
      final id = await _draftRepo.createDraft();
      emit(SaleState(activeDraftId: id));
    }
  }

  Future<void> _onDraftRenamed(
    SaleDraftRenamed event,
    Emitter<SaleState> emit,
  ) async {
    await _draftRepo.renameDraft(event.draftId, event.name);
    if (event.draftId == state.activeDraftId) {
      emit(state.copyWith(activeDraftName: event.name));
    }
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
