import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

class ChangePreview extends StatelessWidget {
  const ChangePreview({
    super.key,
    required this.change,
    required this.currency,
    required this.visible,
  });

  final double change;
  final String currency;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final isEnough = change >= 0;
    final color = isEnough
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: visible ? null : 0,
      decoration: BoxDecoration(
        color: visible ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        border: visible
            ? Border.all(color: color.withValues(alpha: 0.25))
            : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                isEnough ? Icons.price_check : Icons.warning_amber_rounded,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEnough ? context.l10n.change : context.l10n.remainingAmount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MoneyText(
                value: change,
                currency: currency,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'NotoSansThai',
                  fontWeight: FontWeight.w800,
                ),
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ticket-style payment method tile (flat paper — no freestyle Card elev).
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pos = context.posTheme;
    final radius = BorderRadius.circular(pos.billStubRadius);
    final bg = selected ? colorScheme.primary : pos.billStubPaper;
    final fg = selected ? colorScheme.onPrimary : colorScheme.secondary;
    final borderColor = selected ? colorScheme.primary : pos.billStubBorder;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        elevation: selected ? pos.elevPaperActive : pos.elevFlat,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor, width: selected ? 2 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: 'NotoSansThai',
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentTotalRow extends StatelessWidget {
  const PaymentTotalRow({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    this.style,
  });

  final String label;
  final double value;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final finalStyle = style?.copyWith(fontFamily: 'NotoSansThai');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: finalStyle)),
          MoneyText(
            value: value,
            currency: currency,
            style: finalStyle,
            color: finalStyle?.color,
          ),
        ],
      ),
    );
  }
}

/// Quick-cash ticket chip (exact / round-up) — Command Deck dialect.
class PaymentCashChip extends StatelessWidget {
  const PaymentCashChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Exact-amount chip: slightly stronger selected fill.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final radius = BorderRadius.circular(pos.billStubRadius);
    final bg = selected
        ? (emphasized ? scheme.primary : scheme.primaryContainer)
        : pos.billStubPaper;
    final fg = selected
        ? (emphasized ? scheme.onPrimary : scheme.onPrimaryContainer)
        : scheme.onSurface;
    final border = selected ? scheme.primary : pos.billStubBorder;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        elevation: pos.elevFlat,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: fg,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
