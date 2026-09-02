import 'package:promsell_pos_ce/core/services/app_lock_service.dart';

/// Pure validation for first-run / create-PIN flows (POST-090 E0c default-on).
abstract final class StorePinSetup {
  static const minLength = AppLockService.minPinLength;

  /// Returns null when [pin] / [confirm] are acceptable; otherwise a stable code:
  /// `too_short` | `mismatch` | `empty` | `trivial`.
  static String? validateNewPin(String pin, String confirm) {
    final a = pin.trim();
    final b = confirm.trim();
    if (a.isEmpty) return 'empty';
    if (a.length < minLength) return 'too_short';
    if (a != b) return 'mismatch';
    // Mirror AppLockService.setPin's trivial guard here so the create-PIN
    // dialog rejects obvious PINs before setPin throws an uncaught StateError.
    if (AppLockService.isTrivialPin(a)) return 'trivial';
    return null;
  }
}
