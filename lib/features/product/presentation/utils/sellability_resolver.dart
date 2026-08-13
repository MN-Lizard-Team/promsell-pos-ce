import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/stock_status_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/summary_widgets.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Why a product is / is not sellable — used for chip label + deep-link tab.
enum SellabilityKind {
  disabled,
  needPrice,
  notTracked,
  outOfStock,
  lowStock,
  ready,
}

int? sellabilityTargetTab(Object kind) {
  if (kind is! SellabilityKind) return null;
  return switch (kind) {
    SellabilityKind.disabled => 0,
    SellabilityKind.needPrice => 1,
    SellabilityKind.notTracked ||
    SellabilityKind.outOfStock ||
    SellabilityKind.lowStock => 2,
    SellabilityKind.ready => null,
  };
}

/// Shared sellability for form hero + preview summary (single rule set).
SellabilityStatus resolveSellabilityStatus({
  required bool isActive,
  required double price,
  required bool trackStock,
  required int stock,
  required int lowStockThreshold,
  required AppLocalizations l10n,
  required ColorScheme cs,
  String? needPriceLabel,
}) {
  if (!isActive) {
    return SellabilityStatus(
      kind: SellabilityKind.disabled,
      label: l10n.disabled,
      icon: TablerIcons.eyeOff,
      color: cs.errorContainer,
      onColor: cs.onErrorContainer,
    );
  }
  if (price <= 0) {
    return SellabilityStatus(
      kind: SellabilityKind.needPrice,
      label: needPriceLabel ?? l10n.setSellingPrice,
      icon: TablerIcons.currencyBaht,
      color: cs.errorContainer,
      onColor: cs.onErrorContainer,
    );
  }
  if (!trackStock) {
    return SellabilityStatus(
      kind: SellabilityKind.notTracked,
      label: l10n.stockTrackingDisabled,
      icon: TablerIcons.circleMinus,
      color: cs.secondaryContainer,
      onColor: cs.onSecondaryContainer,
    );
  }

  final stockStatus = resolveStockStatus(
    trackStock: true,
    stock: stock,
    lowStockThreshold: lowStockThreshold,
    l10n: l10n,
    cs: cs,
  );

  return switch (stockStatus.level) {
    StockLevel.outOfStock => SellabilityStatus(
      kind: SellabilityKind.outOfStock,
      label: stockStatus.label,
      icon: stockStatus.icon,
      color: stockStatus.containerColor,
      onColor: stockStatus.onContainerColor,
    ),
    StockLevel.lowStock => SellabilityStatus(
      kind: SellabilityKind.lowStock,
      label: stockStatus.label,
      icon: stockStatus.icon,
      color: stockStatus.containerColor,
      onColor: stockStatus.onContainerColor,
    ),
    StockLevel.inStock || StockLevel.notTracked => SellabilityStatus(
      kind: SellabilityKind.ready,
      label: l10n.readyToSell,
      icon: TablerIcons.circleCheck,
      color: cs.primaryContainer,
      onColor: cs.onPrimaryContainer,
    ),
  };
}
