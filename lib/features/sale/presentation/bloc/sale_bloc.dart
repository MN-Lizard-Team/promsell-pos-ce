import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  SaleBloc({
    required CreateSale createSale,
    required DraftCartRepository draftRepo,
    required SettingsRepository settingsRepo,
    required ProductRepository productRepo,
  }) : _createSale = createSale,
       _draftRepo = draftRepo,
       _settingsRepo = settingsRepo,
       _productRepo = productRepo,
       super(const SaleState()) {
    on<SaleProductAdded>(_onProductAdded);
    on<SaleProductRemoved>(_onProductRemoved);
    on<SaleItemQtyChanged>(_onQtyChanged);
    on<SaleCartCleared>(_onCartCleared);
    on<SaleConfirmed>(_onConfirmed);
    on<SaleNoteChanged>(_onNoteChanged);
    on<SaleCartProductsRefreshed>(_onProductsRefreshed);
    on<SaleBarcodeScanned>(_onBarcodeScanned);
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
    on<SaleCartItemRestored>(_onCartItemRestored);
    on<SaleBulkItemsRemoved>(_onBulkItemsRemoved);
    on<SaleBulkItemDiscountsCleared>(_onBulkItemDiscountsCleared);
    on<SaleCartItemsReordered>(_onCartItemsReordered);
    on<SalePaymentConfirmed>(_onPaymentConfirmed);
    on<SalePaymentCancelled>(_onPaymentCancelled);
  }

  final CreateSale _createSale;
  final DraftCartRepository _draftRepo;
  final SettingsRepository _settingsRepo;
  final ProductRepository _productRepo;
  Timer? _saveTimer;
  SaleConfirmed? _pendingSaleEvent;

  void _onProductAdded(SaleProductAdded event, Emitter<SaleState> emit) {
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
      final clampedQty = stockLimited ? qtyToAdd.clamp(1, p.stock) : qtyToAdd;
      updated.add(CartItem(product: p, qty: clampedQty));
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
            : event.qty.clamp(1, 999999);
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
      ),
    );
    _immediateSave();
  }

  void _onCartRestored(SaleCartRestored event, Emitter<SaleState> emit) {
    emit(
      state.copyWith(
        items: event.items,
        cartDiscountType: event.cartDiscountType,
        cartDiscountValue: event.cartDiscountValue,
      ),
    );
    _immediateSave();
  }

  void _onCartItemRestored(
    SaleCartItemRestored event,
    Emitter<SaleState> emit,
  ) {
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
    final fallbackIndex = event.productIds.length;
    final updated = [...state.items];
    updated.sort((a, b) {
      final aIndex = orderMap[a.product.id] ?? fallbackIndex;
      final bIndex = orderMap[b.product.id] ?? fallbackIndex;
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
        activeDraftId: state.activeDraftId,
        activeDraftName: state.activeDraftName,
      ),
    );
  }

  Future<void> _onConfirmed(
    SaleConfirmed event,
    Emitter<SaleState> emit,
  ) async {
    if (state.items.isEmpty) return;

    // For PromptPay, enter waiting state instead of immediately creating sale
    if (event.paymentMethod == 'promptpay') {
      _pendingSaleEvent = event;
      emit(
        state.copyWith(status: SaleStatus.waitingPayment, errorMessage: null),
      );
      return;
    }

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
        paymentReference: event.paymentReference,
      );
      final prevDraftId = state.activeDraftId;
      if (prevDraftId != null) {
        await _draftRepo.deleteDraft(prevDraftId);
      }
      final draftCount = await _draftRepo.countDrafts();
      final newDraftName = 'Bill #${draftCount + 1}';
      final newDraftId = await _draftRepo.createDraft(name: newDraftName);
      final newState = SaleState(
        status: SaleStatus.success,
        lastSale: sale,
        activeDraftId: newDraftId,
        activeDraftName: newDraftName,
      );
      emit(newState);
      try {
        await _draftRepo.saveDraft(newDraftId, newState, name: newDraftName);
      } catch (e, stack) {
        AppLogger.error(
          'SaleBloc._onConfirmed: failed to save new draft',
          error: e,
          stack: stack,
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: SaleStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onPaymentConfirmed(
    SalePaymentConfirmed event,
    Emitter<SaleState> emit,
  ) async {
    final pending = _pendingSaleEvent;
    if (pending == null) return;
    _pendingSaleEvent = null;
    emit(state.copyWith(status: SaleStatus.processing, errorMessage: null));
    try {
      final sale = await _createSale(
        items: state.items,
        paymentMethod: pending.paymentMethod,
        vatMode: pending.vatMode,
        vatRate: pending.vatRate,
        cartDiscountType: pending.cartDiscountType,
        cartDiscountValue: pending.cartDiscountValue,
        cartDiscountAmount: pending.cartDiscountAmount,
        amountReceived: pending.amountReceived,
        changeAmount: pending.changeAmount,
        note: pending.note,
        paymentReference: event.paymentReference ?? pending.paymentReference,
        sendingBankCode: event.sendingBankCode,
      );
      final prevDraftId = state.activeDraftId;
      if (prevDraftId != null) {
        await _draftRepo.deleteDraft(prevDraftId);
      }
      final draftCount = await _draftRepo.countDrafts();
      final newDraftName = 'Bill #${draftCount + 1}';
      final newDraftId = await _draftRepo.createDraft(name: newDraftName);
      final newState = SaleState(
        status: SaleStatus.success,
        lastSale: sale,
        activeDraftId: newDraftId,
        activeDraftName: newDraftName,
      );
      emit(newState);
      try {
        await _draftRepo.saveDraft(newDraftId, newState, name: newDraftName);
      } catch (e, stack) {
        AppLogger.error(
          'SaleBloc._onPaymentConfirmed: failed to save new draft',
          error: e,
          stack: stack,
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: SaleStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onPaymentCancelled(
    SalePaymentCancelled event,
    Emitter<SaleState> emit,
  ) {
    _pendingSaleEvent = null;
    emit(state.copyWith(status: SaleStatus.idle, errorMessage: null));
  }

  void _scheduleSave() {
    final draftId = state.activeDraftId;
    if (draftId == null) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () async {
      if (isClosed) return;
      final currentState = state;
      if (currentState.activeDraftId == draftId) {
        try {
          await _draftRepo.saveDraft(
            draftId,
            currentState,
            name: currentState.activeDraftName,
          );
        } catch (e, stack) {
          AppLogger.error(
            'SaleBloc._scheduleSave failed',
            error: e,
            stack: stack,
          );
        }
      }
    });
  }

  Future<void> _immediateSave() async {
    final draftId = state.activeDraftId;
    if (draftId == null) return;
    _saveTimer?.cancel();
    try {
      await _draftRepo.saveDraft(draftId, state, name: state.activeDraftName);
    } catch (e, stack) {
      AppLogger.error('SaleBloc._immediateSave failed', error: e, stack: stack);
    }
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
    } catch (e, stack) {
      AppLogger.error(
        'SaleBloc._onDraftInitialized failed',
        error: e,
        stack: stack,
      );
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
    if (draft == null) {
      AppLogger.warning(
        'SaleBloc._onDraftSwitched: draft ${event.draftId} not found',
      );
      emit(state.copyWith(errorMessage: 'Draft not found'));
      return;
    }
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
    if (count >= settings.draftConfig.maxDrafts) {
      emit(
        state.copyWith(
          errorMessage:
              'Max drafts (${settings.draftConfig.maxDrafts}) reached',
        ),
      );
      return;
    }
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

  Future<void> _onBarcodeScanned(
    SaleBarcodeScanned event,
    Emitter<SaleState> emit,
  ) async {
    try {
      final product = await _productRepo.getProductByBarcode(event.barcode);
      if (product != null) {
        add(SaleProductAdded(product, qty: 1));
      } else {
        emit(
          state.copyWith(
            status: SaleStatus.idle,
            errorMessage: 'barcodeNotFound',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('SaleBloc._onBarcodeScanned failed', error: e);
      emit(state.copyWith(status: SaleStatus.idle, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _saveTimer?.cancel();
    await _immediateSave();
    return super.close();
  }
}
