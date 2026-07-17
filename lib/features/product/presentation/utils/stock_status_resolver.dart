import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

enum StockLevel { notTracked, outOfStock, lowStock, inStock }

/// Shared stock level + presentation for form stock tab and hero chips.
class ResolvedStockStatus {
  const ResolvedStockStatus({
    required this.level,
    required this.label,
    required this.icon,
    required this.color,
    required this.containerColor,
    required this.onContainerColor,
  });

  final StockLevel level;
  final String label;
  final IconData icon;
  final Color color;
  final Color containerColor;
  final Color onContainerColor;

  bool get isTracked => level != StockLevel.notTracked;
}

ResolvedStockStatus resolveStockStatus({
  required bool trackStock,
  required int stock,
  required int lowStockThreshold,
  required AppLocalizations l10n,
  required ColorScheme cs,
}) {
  if (!trackStock) {
    return ResolvedStockStatus(
      level: StockLevel.notTracked,
      label: l10n.stockTrackingDisabled,
      icon: Icons.remove_circle_outline,
      color: cs.onSurfaceVariant,
      containerColor: cs.surfaceContainerHighest,
      onContainerColor: cs.onSurfaceVariant,
    );
  }

  final threshold = lowStockThreshold < 1 ? 1 : lowStockThreshold;

  if (stock <= 0) {
    return ResolvedStockStatus(
      level: StockLevel.outOfStock,
      label: l10n.outOfStock,
      icon: Icons.error_outline,
      color: cs.error,
      containerColor: cs.errorContainer,
      onContainerColor: cs.onErrorContainer,
    );
  }

  if (stock <= threshold) {
    return ResolvedStockStatus(
      level: StockLevel.lowStock,
      label: l10n.lowStock,
      icon: Icons.warning_amber_outlined,
      color: cs.tertiary,
      containerColor: cs.tertiaryContainer,
      onContainerColor: cs.onTertiaryContainer,
    );
  }

  return ResolvedStockStatus(
    level: StockLevel.inStock,
    label: l10n.inStock,
    icon: Icons.check_circle_outline,
    color: cs.primary,
    containerColor: cs.primaryContainer,
    onContainerColor: cs.onPrimaryContainer,
  );
}
