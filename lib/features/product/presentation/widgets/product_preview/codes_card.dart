import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/barcode_symbology.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/barcode_image_widget.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';

class CodesCard extends StatelessWidget {
  const CodesCard({super.key, required this.product, this.onGenerateBarcode});

  final Product product;
  final VoidCallback? onGenerateBarcode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasSku = product.sku != null && product.sku!.isNotEmpty;
    final hasBarcode = product.barcode != null && product.barcode!.isNotEmpty;
    final dividerColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.3,
    );

    return Column(
      children: [
        PreviewCard(
          title: l10n.codesCardTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoListItem(
                icon: Icons.tag_outlined,
                label: l10n.skuLabel,
                value: Text(hasSku ? product.sku! : l10n.na),
                onTap: hasSku
                    ? () => _copyToClipboard(context, product.sku!)
                    : null,
                trailingIcon: Icons.copy,
                semanticHint: hasSku ? l10n.copyBarcode : null,
              ),
              Divider(height: 1, color: dividerColor),
              InfoListItem(
                icon: Icons.barcode_reader,
                label: l10n.barcodeLabel,
                value: hasBarcode
                    ? Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            product.barcode!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            key: const ValueKey('codes-card-barcode-type'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              barcodeSymbologyLabel(product.barcode!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(l10n.na),
                onTap: hasBarcode
                    ? () => _copyToClipboard(context, product.barcode!)
                    : null,
                trailingIcon: Icons.copy,
                semanticHint: hasBarcode ? l10n.copyBarcode : null,
              ),
              if (!hasBarcode && onGenerateBarcode != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: onGenerateBarcode,
                    icon: const Icon(Icons.qr_code_2_outlined, size: 18),
                    label: Text(l10n.generateBarcode),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasBarcode) ...[
          const SizedBox(height: 16),
          PreviewCard(
            title: l10n.barcodeLabel,
            child: BarcodeImageWidget(
              barcode: product.barcode!,
              productName: product.name,
              barcodeImagePath: product.barcodeImagePath,
            ),
          ),
        ],
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.info(context, context.l10n.copyBarcode);
  }
}
