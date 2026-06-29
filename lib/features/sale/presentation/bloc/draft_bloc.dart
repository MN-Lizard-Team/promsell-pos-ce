import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class DraftBloc extends Bloc<DraftEvent, DraftState> {
  DraftBloc({
    required DraftCartRepository draftRepo,
    required SettingsRepository settingsRepo,
  }) : _draftRepo = draftRepo,
       _settingsRepo = settingsRepo,
       super(const DraftState()) {
    on<DraftInitialized>(_onInitialized);
    on<DraftSwitched>(_onSwitched);
    on<DraftCreated>(_onCreated);
    on<DraftDeleted>(_onDeleted);
    on<DraftRenamed>(_onRenamed);
    on<DraftAutoSaveRequested>(_onAutoSaveRequested);
    on<DraftRotated>(_onRotated);
  }

  final DraftCartRepository _draftRepo;
  final SettingsRepository _settingsRepo;
  Timer? _saveTimer;
  bool _isSaving = false;
  CartState? _pendingCartState;
  String? _lastRestoredDraftId;
  DateTime? _lastRestoreTime;

  Future<void> _onInitialized(
    DraftInitialized event,
    Emitter<DraftState> emit,
  ) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      await _draftRepo.archiveOldDrafts(cutoff);

      final drafts = await _draftRepo.listDrafts();
      if (drafts.isEmpty) {
        final id = await _draftRepo.createDraft();
        emit(state.copyWith(activeDraftId: id, loadedDraft: null));
      } else {
        final draft = drafts.first;
        _lastRestoredDraftId = draft.id;
        _lastRestoreTime = DateTime.now();
        emit(
          state.copyWith(
            activeDraftId: draft.id,
            activeDraftName: draft.name,
            loadedDraft: draft,
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        'DraftBloc._onInitialized failed',
        error: e,
        stack: stack,
      );
      final id = await _draftRepo.createDraft();
      emit(state.copyWith(activeDraftId: id));
    }
  }

  Future<void> _onSwitched(
    DraftSwitched event,
    Emitter<DraftState> emit,
  ) async {
    if (event.draftId == state.activeDraftId) return;
    _cancelSaveTimer();
    await _flushPendingSave();
    try {
      final draft = await _draftRepo.loadDraft(event.draftId);
      if (draft == null) {
        AppLogger.warning(
          'DraftBloc._onSwitched: draft ${event.draftId} not found',
        );
        emit(state.copyWith(errorMessage: 'Draft not found'));
        return;
      }
      _lastRestoredDraftId = draft.id;
      _lastRestoreTime = DateTime.now();
      emit(
        state.copyWith(
          activeDraftId: draft.id,
          activeDraftName: draft.name,
          loadedDraft: draft,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onSwitched failed', error: e, stack: stack);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreated(DraftCreated event, Emitter<DraftState> emit) async {
    try {
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
      _cancelSaveTimer();
      await _flushPendingSave();
      final id = await _draftRepo.createDraft(name: event.name);
      emit(
        state.copyWith(
          activeDraftId: id,
          activeDraftName: event.name ?? 'Draft',
          loadedDraft: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onCreated failed', error: e, stack: stack);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleted(DraftDeleted event, Emitter<DraftState> emit) async {
    _cancelSaveTimer();
    try {
      await _draftRepo.deleteDraft(event.draftId);
      if (event.draftId != state.activeDraftId) return;
      final remaining = await _draftRepo.listDrafts();
      if (remaining.isNotEmpty) {
        final draft = remaining.first;
        emit(
          state.copyWith(
            activeDraftId: draft.id,
            activeDraftName: draft.name,
            loadedDraft: draft,
          ),
        );
      } else {
        final id = await _draftRepo.createDraft();
        emit(state.copyWith(activeDraftId: id, loadedDraft: null));
      }
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onDeleted failed', error: e, stack: stack);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRenamed(DraftRenamed event, Emitter<DraftState> emit) async {
    try {
      await _draftRepo.renameDraft(event.draftId, event.name);
      if (event.draftId == state.activeDraftId) {
        emit(state.copyWith(activeDraftName: event.name));
      }
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onRenamed failed', error: e, stack: stack);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onAutoSaveRequested(
    DraftAutoSaveRequested event,
    Emitter<DraftState> emit,
  ) {
    final draftId = state.activeDraftId;
    if (draftId == null) return;
    if (draftId == _lastRestoredDraftId &&
        _lastRestoreTime != null &&
        DateTime.now().difference(_lastRestoreTime!) <
            const Duration(seconds: 2)) {
      return;
    }
    _pendingCartState = event.cartState;
    _cancelSaveTimer();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () async {
      if (isClosed) return;
      await _doSave(draftId, event.cartState);
    });
  }

  Future<void> _onRotated(DraftRotated event, Emitter<DraftState> emit) async {
    _cancelSaveTimer();
    try {
      final prevDraftId = state.activeDraftId;
      if (prevDraftId != null) {
        await _draftRepo.deleteDraft(prevDraftId);
      }
      final newDraftId = await _draftRepo.createDraft();
      final newDraftName =
          'Bill #${DateTime.now().millisecondsSinceEpoch % 100000}';
      try {
        await _draftRepo.saveDraft(
          newDraftId,
          const CartState(),
          name: newDraftName,
        );
      } catch (e, stack) {
        AppLogger.error(
          'DraftBloc._onRotated: failed to save new draft',
          error: e,
          stack: stack,
        );
      }
      emit(
        state.copyWith(
          activeDraftId: newDraftId,
          activeDraftName: newDraftName,
          loadedDraft: null,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DraftBloc._onRotated failed', error: e, stack: stack);
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _cancelSaveTimer() {
    _saveTimer?.cancel();
    _saveTimer = null;
  }

  Future<void> _flushPendingSave() async {
    _cancelSaveTimer();
    final pending = _pendingCartState;
    final draftId = state.activeDraftId;
    if (pending != null && draftId != null && !_isSaving) {
      await _doSave(draftId, pending);
    }
  }

  Future<void> _doSave(String draftId, CartState cartState) async {
    if (_isSaving) return;
    if (state.activeDraftId != draftId) return;
    _isSaving = true;
    try {
      await _draftRepo.saveDraft(
        draftId,
        cartState,
        name: state.activeDraftName,
      );
      _pendingCartState = null;
    } catch (e, stack) {
      AppLogger.error('DraftBloc._doSave failed', error: e, stack: stack);
    } finally {
      _isSaving = false;
    }
  }

  @override
  Future<void> close() async {
    _cancelSaveTimer();
    return super.close();
  }
}
