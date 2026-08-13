import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Shared filter + sort for open-bills list and strip.
abstract final class DraftListQuery {
  DraftListQuery._();

  static List<DraftCart> filterAndSort(
    List<DraftCart> drafts, {
    required String? activeId,
    required String query,
    Settings? settings,
  }) {
    var result = drafts.where((d) {
      if (d.itemCount > 0) return true;
      return d.id == activeId;
    }).toList();

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((d) => matchesQuery(d, q, settings: settings))
          .toList();
    }

    result.sort((a, b) {
      final aActive = a.id == activeId ? 1 : 0;
      final bActive = b.id == activeId ? 1 : 0;
      if (aActive != bActive) return bActive - aActive;
      final aItems = a.itemCount > 0 ? 1 : 0;
      final bItems = b.itemCount > 0 ? 1 : 0;
      if (aItems != bItems) return bItems - aItems;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return result;
  }

  static bool matchesQuery(
    DraftCart d,
    String lowerQuery, {
    Settings? settings,
  }) {
    if ((d.name ?? '').toLowerCase().contains(lowerQuery)) return true;
    if ((d.tableId ?? '').toLowerCase().contains(lowerQuery)) return true;
    if ((d.note ?? '').toLowerCase().contains(lowerQuery)) return true;
    if ((d.externalOrderRef ?? '').toLowerCase().contains(lowerQuery)) {
      return true;
    }
    if (d.orderType.toLowerCase().contains(lowerQuery)) return true;
    if (d.orderChannel.toLowerCase().contains(lowerQuery)) return true;
    for (final item in d.items) {
      if (item.product.name.toLowerCase().contains(lowerQuery)) return true;
    }
    if (settings != null) {
      final due = d.payableTotal(settings).value;
      final asFixed = due.toStringAsFixed(2);
      final asInt = due.round().toString();
      if (asFixed.contains(lowerQuery) || asInt.contains(lowerQuery)) {
        return true;
      }
    }
    return false;
  }
}
