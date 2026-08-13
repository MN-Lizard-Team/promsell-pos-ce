import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

/// SSOT for open-bill / draft display names.
///
/// Format family (time-based, no DB counter):
/// - non-empty [tableId] → table id as-is
/// - empty cart → `B-HHmm`
/// - cart with lines → `B-HHmm · N` (N = item count)
///
/// Custom names are only set by explicit UI (rename / long-press park).
abstract final class DraftNaming {
  DraftNaming._();

  /// Core generator — prefer table, else time (+ qty when non-empty).
  static String autoName({String? tableId, int itemCount = 0, DateTime? now}) {
    final table = tableId?.trim();
    if (table != null && table.isNotEmpty) return table;

    final t = now ?? DateTime.now();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final stamp = 'B-$hh$mm';
    if (itemCount > 0) return '$stamp · $itemCount';
    return stamp;
  }

  /// Name for a brand-new empty bill (init / after park / after sale / new bill).
  static String forNewEmptyBill({DateTime? now}) =>
      autoName(itemCount: 0, now: now);

  /// Park adapter — same SSOT from [CartState] fields.
  static String autoParkName(CartState cart, {DateTime? now}) =>
      autoName(tableId: cart.tableId, itemCount: cart.itemCount, now: now);

  /// Effective name when parking.
  ///
  /// - [explicitName] non-null (long-press path): use trim, or auto if empty
  /// - else if [existingName] non-empty: **keep** (do not overwrite custom/auto)
  /// - else: [autoParkName]
  static String resolveParkName({
    required CartState cart,
    String? explicitName,
    String? existingName,
    DateTime? now,
  }) {
    if (explicitName != null) {
      final trimmed = explicitName.trim();
      if (trimmed.isNotEmpty) return trimmed;
      return autoParkName(cart, now: now);
    }
    final existing = existingName?.trim();
    if (existing != null && existing.isNotEmpty) return existing;
    return autoParkName(cart, now: now);
  }
}
