import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Dispose helpers for [TextEditingController]s owned by dialogs / transient UI.
///
/// Closing a dialog with the IME open can rebuild [InputDecorator] /
/// [_AnimatedState] after the route has already started tearing down if the
/// controller is disposed synchronously (e.g. `await showDialog` then
/// `ctrl.dispose()`, or `.whenComplete(ctrl.dispose)`). Prefer owning the
/// controller in a dialog [State], call [unfocusForDialogClose] before
/// [Navigator.pop], and dispose with [disposeTextEditingControllerAfterFrame].
void unfocusForDialogClose() {
  FocusManager.instance.primaryFocus?.unfocus();
}

/// Disposes [controller] after two frames so route + IME teardown can detach
/// listeners first (one frame is often not enough while the keyboard animates).
void disposeTextEditingControllerAfterFrame(TextEditingController controller) {
  void disposeOnce() {
    // Guard: never throw if already disposed (debugAssert only in debug).
    try {
      controller.dispose();
    } catch (_) {
      // Already disposed or not ready — ignore.
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Second frame: dialog route fully inactive / InputDecorator detached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If still mid-frame, push to idle.
      final phase = SchedulerBinding.instance.schedulerPhase;
      if (phase == SchedulerPhase.idle ||
          phase == SchedulerPhase.postFrameCallbacks) {
        disposeOnce();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => disposeOnce());
      }
    });
  });
}
