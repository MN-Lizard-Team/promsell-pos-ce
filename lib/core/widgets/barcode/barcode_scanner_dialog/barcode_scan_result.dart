import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';

class BarcodeScanResult extends StatelessWidget {
  const BarcodeScanResult({
    super.key,
    required this.scannedValue,
    required this.successLabel,
    this.productName,
    this.productPrice,
    this.currency,
    this.isFound,
    this.notFoundLabel,
    this.notFoundActionLabel,
    this.onNotFoundAction,
    this.panelStyle = false,
  });

  final String? scannedValue;
  final String successLabel;
  final String? productName;
  final double? productPrice;
  final String? currency;
  final bool? isFound;
  final String? notFoundLabel;
  final String? notFoundActionLabel;
  final VoidCallback? onNotFoundAction;

  /// When true, text sits on the dark bottom panel (no heavy shadows).
  final bool panelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = panelStyle ? Colors.white : Colors.white;
    final shadows = panelStyle
        ? const <Shadow>[]
        : const [Shadow(blurRadius: 6, color: Colors.black)];

    if (isFound == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, color: theme.colorScheme.error, size: 40),
          const SizedBox(height: 8),
          Text(
            scannedValue ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notFoundLabel ?? 'Product not found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              shadows: shadows,
            ),
          ),
          if (notFoundActionLabel != null && onNotFoundAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('scanner-create-product'),
                onPressed: onNotFoundAction,
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: Text(notFoundActionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onWarning,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      );
    }

    final priceText = productPrice != null
        ? (currency != null && currency!.trim().isNotEmpty
              ? CurrencyFormatter.formatGroupedWithSymbol(
                  productPrice!,
                  currency!.trim(),
                )
              : productPrice!.toStringAsFixed(2))
        : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          color: panelStyle
              ? AppColors.primaryLight
              : theme.colorScheme.primary,
          size: 40,
        ),
        const SizedBox(height: 8),
        if (productName != null) ...[
          Text(
            productName!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              shadows: shadows,
            ),
          ),
          if (priceText != null) ...[
            const SizedBox(height: 4),
            Text(
              priceText,
              style: TextStyle(
                color: panelStyle
                    ? AppColors.primaryLight
                    : theme.colorScheme.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                shadows: shadows,
              ),
            ),
          ],
        ] else ...[
          Text(
            scannedValue ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              shadows: shadows,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          successLabel,
          style: TextStyle(
            color: panelStyle
                ? AppColors.primaryLight
                : theme.colorScheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: shadows,
          ),
        ),
      ],
    );
  }
}
