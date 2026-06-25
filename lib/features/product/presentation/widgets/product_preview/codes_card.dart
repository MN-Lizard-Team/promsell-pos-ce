import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/barcode_image_widget.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';

class CodesCard extends StatelessWidget {
  const CodesCard({super.key, required this.product, this.onGenerateBarcode});

  final Product product;
  final VoidCallback? onGenerateBarcode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSku = product.sku != null && product.sku!.isNotEmpty;
    final hasBarcode = product.barcode != null && product.barcode!.isNotEmpty;

    return PreviewCard(
      icon: Icons.qr_code_2,
      title: l10n.codesCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CopyableRow(
            label: l10n.skuLabel,
            value: hasSku ? product.sku! : l10n.na,
            dimmed: !hasSku,
            onCopy: hasSku
                ? () => _copyToClipboard(context, product.sku!)
                : null,
          ),
          const SizedBox(height: 10),
          _CopyableRow(
            label: l10n.barcodeLabel,
            value: hasBarcode ? product.barcode! : l10n.na,
            dimmed: !hasBarcode,
            onCopy: hasBarcode
                ? () => _copyToClipboard(context, product.barcode!)
                : null,
          ),
          if (hasBarcode) ...[
            const SizedBox(height: 12),
            BarcodeImageWidget(
              barcode: product.barcode!,
              productName: product.name,
              barcodeImagePath: product.barcodeImagePath,
            ),
          ] else if (onGenerateBarcode != null) ...[
            const SizedBox(height: 12),
            _GenerateBarcodeButton(onPressed: onGenerateBarcode!),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copyPromptpayId),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  const _CopyableRow({
    required this.label,
    required this.value,
    required this.dimmed,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool dimmed;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64, maxWidth: 100),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: dimmed
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: context.l10n.copyPromptpayId,
            visualDensity: VisualDensity.compact,
            onPressed: onCopy,
          ),
      ],
    );
  }
}

class _GenerateBarcodeButton extends StatelessWidget {
  const _GenerateBarcodeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.auto_fix_high_outlined,
          color: theme.colorScheme.primary,
        ),
        label: Text(l10n.generateBarcode),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
