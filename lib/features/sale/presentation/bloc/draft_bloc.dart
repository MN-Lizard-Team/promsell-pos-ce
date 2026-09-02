import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/draft_naming.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_snapshot_mapper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_save_coordinator.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_bill_switch_guard.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class DraftBloc extends Bloc<DraftEvent, DraftState> {
  DraftBloc({
    required DraftCartRepository draftRepo,
    required SettingsRepository settingsRepo,
  }) : _draftRepo = draftRepo,
       _settingsRepo = settingsRepo,
       _saveCoordinator = DraftSaveCoordinator(draftRepo),
       super(const DraftState()) {
    on<DraftInitialized>(_onInitialized);
    on<DraftFireRequested>(_onFireRequested);
    on<DraftTransferRequested>(_onTransferRequested);
    on<DraftSwitched>(_onSwitched);
    on<DraftCreated>(_onCreated);
    on<DraftDeleted>(_onDeleted);
    on<DraftRenamed>(_onRenamed);
    on<DraftAutoSaveRequested>(_onAutoSaveRequested);
    on<DraftForceSaveRequested>(_onForceSaveRequested);
    on<DraftParkRequested>(_onParkRequested);
    on<DraftStartNewBillRequested>(_onStartNewBillRequested);
    on<DraftRotated>(_onRotated);
    on<DraftCountsRefreshRequested>(_onCountsRefreshRequested);
    on<DraftAutosaveFailed>(_onAutosaveFailed);
  }

  final DraftCartRepository _draftRepo;
  final SettingsRepository _settingsRepo;
  final DraftSaveCoordinator _saveCoordinator;
  String? _lastRestoredDraftId;
  DateTime? _lastRestoreTime;
  DateTime? _lastRotationTime;

  bool _isFiring = false;

  Future<void> _onTransferRequested(
    DraftTransferRequested event,
    Emitter<DraftState> emit,
  ) async {
    final cartId = state.activeDraftId;
    if (cartId == null) return;
    emit(state.copyWith(opStatus: DraftOpStatus.saving, lastOp: 'transfer'));
    try {
      await _draftRepo.transferDraftCart(
        cartId: cartId,
        sourceTableId: event.sourceTableId,
        targetTableId: event.targetTableId,
      );
      final draft = await _draftRepo.loadDraft(cartId);
      emit(
        state.copyWith(
          loadedDraft: draft,
          opStatus: DraftOpStatus.success,
          lastOp: 'transfer',
          opNonce: state.opNonce + 1,
          errorMessage: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc._onTransferRequested failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          opStatus: DraftOpStatus.failure,
          lastOp: 'transfer',
          opNonce: state.opNonce + 1,
          errorMessage: _errorMessageOf(e),
        ),
      );
    }
  }

  Future<void> _onFireRequested(
    DraftFireRequested event,
    Emitter<DraftState> emit,
  ) async {
    if (_isFiring) return;
    final cartId = event.cartId ?? state.activeDraftId;
    if (cartId == null) return;
    _isFiring = true;
    emit(state.copyWith(opStatus: DraftOpStatus.saving, lastOp: 'fire'));
    try {
      final ticket = await _draftRepo.fireUnfiredLines(cartId);
      emit(
        state.copyWith(
          opStatus: DraftOpStatus.success,
          lastOp: 'fire',
          lastKitchenTicket: ticket,
          opNonce: state.opNonce + 1,
          errorMessage: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc._onFireRequested failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          opStatus: DraftOpStatus.failure,
          lastOp: 'fire',
          opNonce: state.opNonce + 1,
          errorMessage: _errorMessageOf(e),
        ),
      );
    } finally {
      _isFiring = false;
    }
  }

  Future<({int draftCount, int openBillCount})> _readCounts() async {
    try {
      // SQL aggregate — avoids re-hydrating every open cart's items and
      // Product objects on each autosave-debounced counts refresh.
      return await _draftRepo.getDraftCounts();
    } catch (e, stack) {
      AppLogger.warning('DraftBloc._readCounts failed', error: e, stack: stack);
      return (draftCount: state.draftCount, openBillCount: state.openBillCount);
    }
  }

  static int _openCountOf(List<DraftCart> drafts) =>
      drafts.where((d) => d.itemCount > 0).length;

  /// Stable UI key for known business rules (e.g. a table already claimed by
  /// another active bill via idx_draft_carts_table_id_unique); raw strings
  /// would leak exception text instead of a localizable message.
  static String _errorMessageOf(Object e) {
    if (e is BusinessRuleError && e.rule == 'TableAlreadyBound') {
      return 'tableAlreadyBound';
    }
    return e.toString();
  }

  Future<void> _onInitialized(
    DraftInitialized event,
    Emitter<DraftState> emit,
  ) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      await _draftRepo.archiveOldDrafts(cutoff);

      final drafts = await _draftRepo.listDrafts();
      if (drafts.isEmpty) {
        final autoName = DraftNaming.forNewEmptyBill();
        final id = await _draftRepo.createDraft(name: autoName);
        emit(
          state.copyWith(
            activeDraftId: id,
            activeDraftName: autoName,
            loadedDraft: null,
            draftCount: 1,
            openBillCount: 0,
          ),
        );
      } else {
        final draft = drafts.first;
        _lastRestoredDraftId = draft.id;
        _lastRestoreTime = DateTime.now();
        emit(
          state.copyWith(
            activeDraftId: draft.id,
            activeDraftName: draft.name,
            loadedDraft: draft,
            draftCount: drafts.length,
            openBillCount: _openCountOf(drafts),
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc._onInitialized failed',
        error: e,
        stack: stack,
      );
      final autoName = DraftNaming.forNewEmptyBill();
      final id = await _draftRepo.createDraft(name: autoName);
      emit(
        state.copyWith(
          activeDraftId: id,
          activeDraftName: autoName,
          draftCount: 1,
          openBillCount: 0,
        ),
      );
    }
  }

  Future<void> _onSwitched(
    DraftSwitched event,
    Emitter<DraftState> emit,
  ) async {
    if (event.draftId == state.activeDraftId) return;
    if (event.paymentLocked) {
      emit(
        state.copyWith(
          errorMessage: DraftBillSwitchGuard.errorCode,
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'switch',
        ),
      );
      return;
    }
    _saveCoordinator.cancelTimer();
    // Prefer live cart force-save so debounce window edits are not lost.
    if (event.liveCart != null && state.activeDraftId != null) {
      try {
        await _saveCoordinator.doSave(
          state.activeDraftId!,
          cartStateToSnapshot(event.liveCart!),
          throwOnError: true,
          activeName: state.activeDraftName,
        );
        _saveCoordinator.clearPending(state.activeDraftId!);
      } catch (e, stack) {
        AppLogger.error(
          'DraftBloc._onSwitched: force-save before switch failed',
          error: e,
          stack: stack,
        );
        emit(
          state.copyWith(
            errorMessage: _errorMessageOf(e),
            opStatus: DraftOpStatus.failure,
            opNonce: state.opNonce + 1,
            lastOp: 'switch',
          ),
        );
        return;
      }
    } else {
      await _saveCoordinator.flushPending(
        onSaveFailure: (error) =>
            add(DraftAutosaveFailed(_errorMessageOf(error))),
      );
    }
    try {
      final draft = await _draftRepo.loadDraft(event.draftId);
      if (draft == null) {
        AppLogger.warning(
          'DraftBloc._onSwitched: draft ${event.draftId} not found',
        );
        emit(
          state.copyWith(
            errorMessage: 'draftNotFound',
            opStatus: DraftOpStatus.failure,
            opNonce: state.opNonce + 1,
            lastOp: 'switch',
          ),
        );
        return;
      }
      _lastRestoredDraftId = draft.id;
      _lastRestoreTime = DateTime.now();
      final counts = await _readCounts();
      emit(
        state.copyWith(
          activeDraftId: draft.id,
          activeDraftName: draft.name,
          loadedDraft: draft,
          draftCount: counts.draftCount,
          openBillCount: counts.openBillCount,
          opStatus: DraftOpStatus.success,
          opNonce: state.opNonce + 1,
          lastOp: 'switch',
          errorMessage: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onSwitched failed', error: e, stack: stack);
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'switch',
        ),
      );
    }
  }

  Future<void> _onCreated(DraftCreated event, Emitter<DraftState> emit) async {
    const op = 'create';
    try {
      final count = await _draftRepo.countDrafts();
      final settings = await _settingsRepo.load();
      if (count >= settings.draftConfig.maxDrafts) {
        emit(
          state.copyWith(
            errorMessage: 'maxDraftsReached:${settings.draftConfig.maxDrafts}',
            opStatus: DraftOpStatus.failure,
            opNonce: state.opNonce + 1,
            lastOp: op,
          ),
        );
        return;
      }
      _saveCoordinator.cancelTimer();
      await _saveCoordinator.flushPending(
        onSaveFailure: (error) =>
            add(DraftAutosaveFailed(_errorMessageOf(error))),
      );
      final trimmed = event.name?.trim();
      final name = (trimmed != null && trimmed.isNotEmpty)
          ? trimmed
          : DraftNaming.forNewEmptyBill();
      final id = await _draftRepo.createDraft(name: name);
      final counts = await _readCounts();
      _lastRestoredDraftId = id;
      _lastRestoreTime = DateTime.now();
      emit(
        state.copyWith(
          activeDraftId: id,
          activeDraftName: name,
          loadedDraft: null,
          draftCount: counts.draftCount,
          openBillCount: counts.openBillCount,
          opStatus: DraftOpStatus.success,
          opNonce: state.opNonce + 1,
          lastOp: op,
          errorMessage: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onCreated failed', error: e, stack: stack);
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: op,
        ),
      );
    }
  }

  Future<void> _onDeleted(DraftDeleted event, Emitter<DraftState> emit) async {
    if (event.paymentLocked) {
      emit(
        state.copyWith(
          errorMessage: DraftBillSwitchGuard.errorCode,
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'delete',
        ),
      );
      return;
    }
    _saveCoordinator.cancelTimer();
    try {
      await _draftRepo.deleteDraft(event.draftId);
      if (event.draftId != state.activeDraftId) {
        final counts = await _readCounts();
        emit(
          state.copyWith(
            draftCount: counts.draftCount,
            openBillCount: counts.openBillCount,
            opStatus: DraftOpStatus.success,
            opNonce: state.opNonce + 1,
            lastOp: 'delete',
            errorMessage: null,
          ),
        );
        return;
      }
      final remaining = await _draftRepo.listDrafts();
      if (remaining.isNotEmpty) {
        final draft = remaining.first;
        _lastRestoredDraftId = draft.id;
        _lastRestoreTime = DateTime.now();
        emit(
          state.copyWith(
            activeDraftId: draft.id,
            activeDraftName: draft.name,
            loadedDraft: draft,
            draftCount: remaining.length,
            openBillCount: _openCountOf(remaining),
            opStatus: DraftOpStatus.success,
            opNonce: state.opNonce + 1,
            lastOp: 'delete',
            errorMessage: null,
          ),
        );
      } else {
        final autoName = DraftNaming.forNewEmptyBill();
        final id = await _draftRepo.createDraft(name: autoName);
        _lastRestoredDraftId = id;
        _lastRestoreTime = DateTime.now();
        emit(
          state.copyWith(
            activeDraftId: id,
            activeDraftName: autoName,
            loadedDraft: null,
            draftCount: 1,
            openBillCount: 0,
            opStatus: DraftOpStatus.success,
            opNonce: state.opNonce + 1,
            lastOp: 'delete',
            errorMessage: null,
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onDeleted failed', error: e, stack: stack);
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'delete',
        ),
      );
    }
  }

  Future<void> _onRenamed(DraftRenamed event, Emitter<DraftState> emit) async {
    if (event.paymentLocked) {
      emit(
        state.copyWith(
          errorMessage: DraftBillSwitchGuard.errorCode,
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'rename',
        ),
      );
      return;
    }
    try {
      await _draftRepo.renameDraft(event.draftId, event.name);
      emit(
        state.copyWith(
          activeDraftName: event.draftId == state.activeDraftId
              ? event.name
              : state.activeDraftName,
          opStatus: DraftOpStatus.success,
          opNonce: state.opNonce + 1,
          lastOp: 'rename',
          errorMessage: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onRenamed failed', error: e, stack: stack);
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'rename',
        ),
      );
    }
  }

  Future<void> _onCountsRefreshRequested(
    DraftCountsRefreshRequested event,
    Emitter<DraftState> emit,
  ) async {
    try {
      final counts = await _readCounts();
      emit(
        state.copyWith(
          draftCount: counts.draftCount,
          openBillCount: counts.openBillCount,
        ),
      );
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc._onCountsRefreshRequested failed',
        error: e,
        stack: stack,
      );
    }
  }

  void _onAutoSaveRequested(
    DraftAutoSaveRequested event,
    Emitter<DraftState> emit,
  ) {
    final draftId = state.activeDraftId;
    if (draftId == null) return;
    // Skip empty autosave shortly after park/switch/restore so we do not
    // wipe a parked bill. Allow saves when the new draft already has items.
    if (draftId == _lastRestoredDraftId &&
        _lastRestoreTime != null &&
        DateTime.now().difference(_lastRestoreTime!) <
            const Duration(seconds: 2) &&
        event.cartState.isEmpty) {
      return;
    }
    // Same guard after checkout rotation: CartCleared fires an empty-cart
    // autosave that must never wipe whichever bill became active (the sold
    // one is already deleted; a switched-to bill must stay intact).
    if (event.cartState.isEmpty &&
        _lastRotationTime != null &&
        DateTime.now().difference(_lastRotationTime!) <
            const Duration(seconds: 2)) {
      return;
    }
    _saveCoordinator.scheduleAutoSave(
      draftId: draftId,
      snapshot: cartStateToSnapshot(event.cartState),
      isClosed: () => isClosed,
      onTimerFire: () async {
        if (!isClosed) add(const DraftCountsRefreshRequested());
      },
      onSaveFailure: (error) {
        if (isClosed) return;
        add(DraftAutosaveFailed(_errorMessageOf(error)));
      },
    );
  }

  /// Surfaces debounced/flushed autosave rejections through the same failure
  /// state the park/switch/newBill ops use, so the snackbar listener picks it
  /// up instead of the save silently not persisting.
  void _onAutosaveFailed(DraftAutosaveFailed event, Emitter<DraftState> emit) {
    emit(
      state.copyWith(
        errorMessage: event.messageKey,
        opStatus: DraftOpStatus.failure,
        opNonce: state.opNonce + 1,
        lastOp: 'autosave',
      ),
    );
  }

  Future<void> _onForceSaveRequested(
    DraftForceSaveRequested event,
    Emitter<DraftState> emit,
  ) async {
    await _persistCartToActive(
      event.cartState,
      emit,
      op: 'forceSave',
      emitOpLifecycle: true,
    );
  }

  Future<void> _onParkRequested(
    DraftParkRequested event,
    Emitter<DraftState> emit,
  ) async {
    if (event.cartState.paymentLocked) {
      emit(
        state.copyWith(
          errorMessage: DraftBillSwitchGuard.errorCode,
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'park',
        ),
      );
      return;
    }
    // Need room for a new empty draft after saving current (count + 1).
    if (!await _hasRoomForNewDraft(emit, op: 'park')) return;
    // Explicit [event.name] (incl. '' from long-press empty) → resolve path.
    // Null name (1-tap) → keep existing active name if set; else auto.
    final parkName = DraftNaming.resolveParkName(
      tableId: event.cartState.tableId,
      itemCount: event.cartState.itemCount,
      explicitName: event.name,
      existingName: state.activeDraftName,
    );
    final ok = await _persistCartToActive(
      event.cartState,
      emit,
      op: 'park',
      emitOpLifecycle: true,
      nameOverride: parkName,
    );
    if (!ok) return;
    await _createEmptyActiveDraft(emit, name: null, op: 'park');
  }

  Future<void> _onStartNewBillRequested(
    DraftStartNewBillRequested event,
    Emitter<DraftState> emit,
  ) async {
    if (event.cartState.paymentLocked) {
      emit(
        state.copyWith(
          errorMessage: DraftBillSwitchGuard.errorCode,
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: 'newBill',
        ),
      );
      return;
    }
    if (!await _hasRoomForNewDraft(emit, op: 'newBill')) return;
    final ok = await _persistCartToActive(
      event.cartState,
      emit,
      op: 'newBill',
      emitOpLifecycle: true,
    );
    if (!ok) return;
    final trimmed = event.name?.trim();
    final newName = (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
    await _createEmptyActiveDraft(emit, name: newName, op: 'newBill');
  }

  /// True if creating another draft would stay under maxDrafts.
  Future<bool> _hasRoomForNewDraft(
    Emitter<DraftState> emit, {
    required String op,
  }) async {
    try {
      final count = await _draftRepo.countDrafts();
      final settings = await _settingsRepo.load();
      if (count >= settings.draftConfig.maxDrafts) {
        emit(
          state.copyWith(
            errorMessage: 'maxDraftsReached:${settings.draftConfig.maxDrafts}',
            opStatus: DraftOpStatus.failure,
            opNonce: state.opNonce + 1,
            lastOp: op,
          ),
        );
        return false;
      }
      return true;
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc capacity check failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: op,
        ),
      );
      return false;
    }
  }

  Future<bool> _persistCartToActive(
    CartState cart,
    Emitter<DraftState> emit, {
    required String op,
    required bool emitOpLifecycle,
    String? nameOverride,
  }) async {
    final draftId = state.activeDraftId;
    if (draftId == null) {
      emit(
        state.copyWith(
          errorMessage: 'draftNotFound',
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: op,
        ),
      );
      return false;
    }
    _saveCoordinator.cancelTimer();
    final snapshot = cartStateToSnapshot(cart);
    _saveCoordinator.setPending(draftId, snapshot);
    if (emitOpLifecycle) {
      emit(
        state.copyWith(
          opStatus: DraftOpStatus.saving,
          lastOp: op,
          errorMessage: null,
        ),
      );
    }
    try {
      await _saveCoordinator.doSave(
        draftId,
        snapshot,
        throwOnError: true,
        name: nameOverride,
        activeName: state.activeDraftName,
      );
      _saveCoordinator.clearPending(draftId);
      if (emitOpLifecycle && op == 'forceSave') {
        emit(
          state.copyWith(
            opStatus: DraftOpStatus.success,
            opNonce: state.opNonce + 1,
            lastOp: op,
            errorMessage: null,
          ),
        );
      }
      return true;
    } catch (e, stack) {
      AppLogger.error('DraftBloc persist failed ($op)', error: e, stack: stack);
      emit(
        state.copyWith(
          errorMessage: _errorMessageOf(e),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: op,
        ),
      );
      return false;
    }
  }

  Future<void> _createEmptyActiveDraft(
    Emitter<DraftState> emit, {
    required String? name,
    required String op,
  }) async {
    try {
      final count = await _draftRepo.countDrafts();
      final settings = await _settingsRepo.load();
      if (count >= settings.draftConfig.maxDrafts) {
        emit(
          state.copyWith(
            errorMessage: 'maxDraftsReached:${settings.draftConfig.maxDrafts}',
            opStatus: DraftOpStatus.failure,
            opNonce: state.opNonce + 1,
            lastOp: op,
          ),
        );
        return;
      }
      final trimmed = name?.trim();
      final resolved = (trimmed != null && trimmed.isNotEmpty)
          ? trimmed
          : DraftNaming.forNewEmptyBill();
      final id = await _draftRepo.createDraft(name: resolved);
      final counts = await _readCounts();
      _lastRestoredDraftId = id;
      _lastRestoreTime = DateTime.now();
      emit(
        state.copyWith(
          activeDraftId: id,
          activeDraftName: resolved,
          loadedDraft: null,
          draftCount: counts.draftCount,
          openBillCount: counts.openBillCount,
          opStatus: DraftOpStatus.success,
          opNonce: state.opNonce + 1,
          lastOp: op,
          errorMessage: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc create empty failed ($op)',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          opStatus: DraftOpStatus.failure,
          opNonce: state.opNonce + 1,
          lastOp: op,
        ),
      );
    }
  }

  Future<void> _onRotated(DraftRotated event, Emitter<DraftState> emit) async {
    _saveCoordinator.cancelTimer();
    final soldId = event.soldDraftId;
    if (soldId != null) {
      // The sold cart row is already gone (deleted atomically inside the sale
      // transaction); drop any queued save targeting it so a late flush
      // cannot resurrect orphaned item rows.
      _saveCoordinator.clearPending(soldId);
    }
    _lastRotationTime = DateTime.now();
    try {
      final soldWasActive = soldId != null && soldId == state.activeDraftId;
      if (!soldWasActive) {
        // Sold bill was NOT the active draft (switched mid-payment) or the
        // cart was never parked — keep current pointers, refresh counters.
        final counts = await _readCounts();
        emit(
          state.copyWith(
            draftCount: counts.draftCount,
            openBillCount: counts.openBillCount,
          ),
        );
        return;
      }
      // Active pointer references the deleted row — hand out a fresh bill.
      final newDraftName = DraftNaming.forNewEmptyBill();
      final newDraftId = await _draftRepo.createDraft(name: newDraftName);
      _lastRestoredDraftId = newDraftId;
      _lastRestoreTime = DateTime.now();
      final counts = await _readCounts();
      emit(
        state.copyWith(
          activeDraftId: newDraftId,
          activeDraftName: newDraftName,
          loadedDraft: null,
          draftCount: counts.draftCount,
          openBillCount: counts.openBillCount,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onRotated failed', error: e, stack: stack);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    // Best-effort flush so last keystrokes within debounce are not lost.
    try {
      await _saveCoordinator.flushPending();
    } catch (e, stack) {
      AppLogger.warning('DraftBloc.close flush failed', error: e, stack: stack);
    }
    await _saveCoordinator.dispose();
    return super.close();
  }
}
