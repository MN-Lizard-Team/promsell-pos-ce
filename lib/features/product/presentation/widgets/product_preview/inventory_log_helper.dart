import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/inventory/domain/inventory_log_reasons.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class InventoryLogHelper {
  InventoryLogHelper._();

  static const typeSale = 'SALE';
  static const typeVoidReversal = 'VOID_REVERSAL';
  static const typeAdjustmentIn = 'ADJUSTMENT_IN';
  static const typeAdjustmentOut = 'ADJUSTMENT_OUT';

  static IconData iconForType(String type) => switch (type) {
    typeSale => TablerIcons.shoppingCart,
    typeVoidReversal => TablerIcons.arrowBackUp,
    typeAdjustmentIn => TablerIcons.circlePlus,
    typeAdjustmentOut => TablerIcons.circleMinus,
    _ => TablerIcons.helpCircle,
  };

  static String labelForType(AppLocalizations l10n, String type) =>
      switch (type) {
        typeSale => l10n.invLogTypeSale,
        typeVoidReversal => l10n.invLogTypeVoidReversal,
        typeAdjustmentIn => l10n.invLogTypeStockIn,
        typeAdjustmentOut => l10n.invLogTypeStockOut,
        _ => type,
      };

  /// Maps known reason keys (and legacy English) to l10n; user text passes through.
  static String? localizeReason(AppLocalizations l10n, String? reason) {
    if (reason == null || reason.isEmpty) return null;
    if (reason == InventoryLogReasons.productStockEdited ||
        reason == InventoryLogReasons.productStockEditedLegacy) {
      return l10n.invLogReasonProductStockEdited;
    }
    return reason;
  }

  static String shortSaleRef(String saleId) {
    if (saleId.length <= 8) return saleId;
    return saleId.substring(saleId.length - 8);
  }
}
