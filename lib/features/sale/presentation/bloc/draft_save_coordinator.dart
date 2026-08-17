import 'dart:async';

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
  void scheduleAutoSave({
    required String draftId,
    required CartSnapshot snapshot,
    required bool Function() isClosed,
    required Future<void> Function() onTimerFire,
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
        await doSave(id, snap, throwOnError: false);
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
  Future<void> flushPending({String? fallbackDraftId}) async {
    cancelTimer();
    final pending = _pendingSnapshot;
    final draftId = _pendingDraftId ?? fallbackDraftId;
    if (pending != null && draftId != null) {
      try {
        await doSave(draftId, pending, throwOnError: false);
      } catch (e, stack) {
        AppLogger.warning(
          'DraftSaveCoordinator.flushPending failed',
          error: e,
          stack: stack,
        );
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
    var spins = 0;
    while (_isSaving && spins < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      spins++;
    }
    if (_isSaving) {
      if (throwOnError) {
        throw StateError('draftSaveBusy');
      }
      return;
    }
    _isSaving = true;
    try {
      await _draftRepo.saveDraft(draftId, snapshot, name: name ?? activeName);
      if (_pendingDraftId == draftId) {
        _pendingSnapshot = null;
      }
    } catch (e, stack) {
      AppLogger.error(
        'DraftSaveCoordinator.doSave failed',
        error: e,
        stack: stack,
      );
      if (throwOnError) rethrow;
    } finally {
      _isSaving = false;
    }
  }

  /// Disposes resources. Should be called from the owning BLoC's [close].
  Future<void> dispose() async {
    cancelTimer();
  }
}
