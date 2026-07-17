import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_manual_entry.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_scan_result.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Bottom status panel for the barcode scanner — all feedback lives here,
/// never inside the camera cutout.
class BarcodeBottomPanel extends StatelessWidget {
  const BarcodeBottomPanel({
    super.key,
    required this.showManualEntry,
    required this.manualController,
    required this.onManualSubmit,
    required this.onManualCancel,
    required this.onOpenManual,
    required this.isLookingUp,
    required this.isScanned,
    required this.scannedValue,
    required this.productName,
    required this.productPrice,
    required this.currency,
    required this.productFound,
    required this.errorText,
    required this.scanCount,
    required this.hint,
    this.onCreateProduct,
  });

  final bool showManualEntry;
  final TextEditingController manualController;
  final VoidCallback onManualSubmit;
  final VoidCallback onManualCancel;
  final VoidCallback onOpenManual;
  final bool isLookingUp;
  final bool isScanned;
  final String? scannedValue;
  final String? productName;
  final double? productPrice;
  final String? currency;
  final bool? productFound;
  final String? errorText;
  final int? scanCount;
  final String? hint;
  final VoidCallback? onCreateProduct;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + safeBottom + bottomInset),
      child: Material(
        color: Colors.black.withValues(alpha: 0.86),
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: showManualEntry
                  ? BarcodeManualEntry(
                      key: const ValueKey('manual'),
                      controller: manualController,
                      onSubmit: onManualSubmit,
                      onCancel: onManualCancel,
                    )
                  : _buildStatus(context, l10n, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (errorText != null && errorText!.isNotEmpty) {
      return _ErrorBlock(key: const ValueKey('panel-error'), text: errorText!);
    }

    if (isLookingUp) {
      return const Padding(
        key: ValueKey('panel-lookup'),
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (isScanned) {
      return BarcodeScanResult(
        key: const ValueKey('panel-result'),
        scannedValue: scannedValue,
        successLabel: productFound == false
            ? l10n.productNotFoundShort
            : l10n.scanSuccess,
        productName: productName,
        productPrice: productPrice,
        currency: currency,
        isFound: productFound,
        notFoundLabel: l10n.productNotFoundShort,
        notFoundActionLabel: productFound == false && onCreateProduct != null
            ? l10n.createProductFromBarcode
            : null,
        onNotFoundAction: onCreateProduct,
        panelStyle: true,
      );
    }

    // Idle
    return Column(
      key: const ValueKey('scanner'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hint ?? l10n.barcodeScannerHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (scanCount != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.scanCount(scanCount!),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpenManual,
            icon: const Icon(Icons.keyboard, size: 18),
            label: Text(l10n.enterManually),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.error_outline, color: theme.colorScheme.error, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
