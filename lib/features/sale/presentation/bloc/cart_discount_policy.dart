import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Settings-backed discount clamps for cart mutations (not UI-only).
abstract final class CartDiscountPolicy {
  CartDiscountPolicy._();

  /// Returns null when [value] is non-positive.
  /// On settings load failure, returns the raw pair (fail-open for UX).
  static (String, double)? clamp({
    required Settings settings,
    required String type,
    required double value,
  }) {
    final isPercent = type.toUpperCase() == 'PERCENT';
    if (isPercent &&
        !settings.enableItemDiscount &&
        !settings.enableCartDiscount) {
      // Still allow if either path is on; finer flags enforced at dialog.
    }
    if (value <= 0) return null;
    if (isPercent) {
      final maxP = settings.maxDiscountPercent.clamp(0.0, 100.0);
      return (type, value.clamp(0.0, maxP));
    }
    final maxAmt = settings.maxDiscountAmount.value;
    final capped = maxAmt > 0 ? value.clamp(0.0, maxAmt) : value;
    return (type, capped);
  }

  static (String, double)? clampOrRaw({
    required Settings? settings,
    required String type,
    required double value,
    Object? loadError,
    StackTrace? stack,
  }) {
    if (settings == null) {
      if (loadError != null) {
        AppLogger.warning(
          'CartDiscountPolicy: settings load failed; applying raw value',
          error: loadError,
          stack: stack,
        );
      }
      return (type, value);
    }
    return clamp(settings: settings, type: type, value: value);
  }
}
