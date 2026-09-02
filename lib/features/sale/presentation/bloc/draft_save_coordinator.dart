import 'dart:async';

import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';

/// Coordinates debounced auto-save and force-save operations for [DraftBloc].
///
/// Extracted from the god-file `draft_bloc.dart` to isolate:
/// - Save queue serialization (prevent concurrent writes to the same draft)
/// - Pending snapshot tracking (latest cart state awaiting flush)
/// - Timer-based debounce (1500ms delay before auto-save)
class DraftSaveCoordinator {
  DraftSaveCoordinator(this._draftRepo);

  final DraftCartRepository _draftRepo;

  Timer? _saveTimer;
  bool _isSaving = false;
  CartSnapshot? _pendingSnapshot;
  String? _pendingDraftId;

  /// Whether there is a pending snapshot awaiting save.
  bool get hasPending => _pendingSnapshot != null;

  /// The draft ID for the pending snapshot, if any.
  String? get pendingDraftId => _pendingDraftId;

  /// Schedules a debounced auto-save. Replaces any previous pending snapshot.
  ///
  /// [onTimerFire] is called after the save attempt (e.g. to refresh counts).
  /// [isClosed] should return `true` when the owning BLoC is closed.
  /// [onSaveFailure] is invoked when a non-throwing save hits
  /// [BusinessRuleError] `'TableAlreadyBound'` so the rejection reaches the
  /// user instead of silently not persisting.
  void scheduleAutoSave({
    required String draftId,
    required CartSnapshot snapshot,
    required bool Function() isClosed,
    required Future<void> Function() onTimerFire,
    void Function(Object error)? onSaveFailure,
    Duration delay = const Duration(milliseconds: 1500),
  }) {
    _pendingSnapshot = snapshot;
    _pendingDraftId = draftId;
    cancelTimer();
    _saveTimer = Timer(delay, () async {
      if (isClosed()) return;
      final id = _pendingDraftId;
      final snap = _pendingSnapshot;
      if (id == null || snap == null) return;
      try {
        final error = await _runSave(id, snap);
        _surfaceTableAlreadyBound(error, onSaveFailure);
        if (!isClosed()) await onTimerFire();
      } catch (e, stack) {
        AppLogger.warning(
          'DraftSaveCoordinator autosave timer failed',
          error: e,
          stack: stack,
        );
      }
    });
  }

  /// Sets the pending snapshot without scheduling a timer.
  void setPending(String draftId, CartSnapshot snapshot) {
    _pendingSnapshot = snapshot;
    _pendingDraftId = draftId;
  }

  /// Clears the pending snapshot for [draftId] if it matches.
  void clearPending(String draftId) {
    if (_pendingDraftId == draftId) {
      _pendingSnapshot = null;
    }
  }

  /// Cancels any pending auto-save timer.
  void cancelTimer() {
    _saveTimer?.cancel();
    _saveTimer = null;
  }

  /// Flushes the pending snapshot immediately (if any).
  ///
  /// Uses [fallbackDraftId] when no pending draft ID is set.
  /// [onSaveFailure] mirrors [scheduleAutoSave]'s: non-throwing saves still
  /// surface `TableAlreadyBound` rejections through it.
  Future<void> flushPending({
    String? fallbackDraftId,
    void Function(Object error)? onSaveFailure,
  }) async {
    cancelTimer();
    final pending = _pendingSnapshot;
    final draftId = _pendingDraftId ?? fallbackDraftId;
    if (pending != null && draftId != null) {
      final error = await _runSave(draftId, pending);
      if (error != null) {
        AppLogger.warning(
          'DraftSaveCoordinator.flushPending failed',
          error: error,
        );
        _surfaceTableAlreadyBound(error, onSaveFailure);
      }
    }
  }

  /// Performs a save, serializing concurrent attempts with a spin-wait.
  ///
  /// [name] overrides the draft name; if null, the caller should provide
  /// the current active name via [activeName].
  Future<void> doSave(
    String draftId,
    CartSnapshot snapshot, {
    required bool throwOnError,
    String? name,
    String? activeName,
  }) async {
    final error = await _runSave(draftId, snapshot, name: name ?? activeName);
    if (error != null && throwOnError) {
      throw error;
    }
  }

  /// Serialized save core shared by throwing and swallowing callers.
  ///
  /// Returns the failure instead of throwing when possible so non-throw paths
  /// can still inspect business-rule rejections; only a busy-coordinator
  /// spin-wait timeout is returned as a [StateError] like before. Clears the
  /// pending snapshot only on success.
  Future<Object?> _runSave(
    String draftId,
    CartSnapshot snapshot, {
    String? name,
  }) async {
    var spins = 0;
    while (_isSaving && spins < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      spins++;
    }
    if (_isSaving) {
      return StateError('draftSaveBusy');
    }
    _isSaving = true;
    try {
      await _draftRepo.saveDraft(draftId, snapshot, name: name);
      if (_pendingDraftId == draftId) {
        _pendingSnapshot = null;
      }
      return null;
    } catch (e, stack) {
      AppLogger.error(
        'DraftSaveCoordinator.doSave failed',
        error: e,
        stack: stack,
      );
      return e;
    } finally {
      _isSaving = false;
    }
  }

  /// Non-throw paths normally log-and-continue, but `TableAlreadyBound` means
  /// the save did NOT persist — without surfacing it the cashier only finds
  /// out at park time that the table choice was rejected.
  static void _surfaceTableAlreadyBound(
    Object? error,
    void Function(Object error)? onSaveFailure,
  ) {
    if (error == null || onSaveFailure == null) return;
    if (error is BusinessRuleError && error.rule == 'TableAlreadyBound') {
      onSaveFailure(error);
    }
  }

  /// Disposes resources. Should be called from the owning BLoC's [close].
  Future<void> dispose() async {
    cancelTimer();
  }
}
