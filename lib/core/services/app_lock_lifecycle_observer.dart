import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// App-level lifecycle observer that locks the sensitive session on cold
/// start and whenever the app goes to background (V092-B.2).
///
/// This is intentionally separate from [WidgetsBindingObserver] mixins in
/// individual pages so the lock fires even when the user is on the onboarding
/// flow or a dialog is open. [AppLockService.lockSession] is idempotent, so
/// page-level observers may still call it without harm.
class AppLockLifecycleObserver extends WidgetsBindingObserver {
  AppLockLifecycleObserver(this._lock);

  final AppLockService _lock;

  /// Call once after DI is configured and before `runApp`.
  ///
  /// Ensures a fresh process starts with a cold session even if GetIt
  /// somehow retained a stale unlocked service (e.g. hot restart in dev).
  Future<void> start() async {
    try {
      if (await _lock.isEnabled()) {
        _lock.lockSession();
      }
    } catch (e, stack) {
      AppLogger.warning(
        'AppLockLifecycleObserver.start lockSession failed',
        error: e,
        stack: stack,
      );
    }
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      try {
        _lock.lockSession();
      } catch (e, stack) {
        AppLogger.warning(
          'AppLockLifecycleObserver pause lockSession failed',
          error: e,
          stack: stack,
        );
      }
    }
  }
}
