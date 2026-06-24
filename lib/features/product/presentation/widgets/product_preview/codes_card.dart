import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/barcode_image_widget.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';

class CodesCard extends StatelessWidget {
  const CodesCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSku = product.sku != null && product.sku!.isNotEmpty;
    final hasBarcode = product.barcode != null && product.barcode!.isNotEmpty;

    return PreviewCard(
      icon: Icons.qr_code_2,
      title: l10n.skuLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            label: l10n.skuLabel,
            value: SelectableText(
              hasSku ? product.sku! : l10n.na,
              style: _valueStyle(context, dimmed: !hasSku),
            ),
          ),
          const SizedBox(height: 10),
          InfoRow(
            label: l10n.barcodeLabel,
            value: SelectableText(
              hasBarcode ? product.barcode! : l10n.na,
              style: _valueStyle(context, dimmed: !hasBarcode),
            ),
          ),
          if (hasBarcode) ...[
            const SizedBox(height: 12),
            BarcodeImageWidget(
              barcode: product.barcode!,
              productName: product.name,
            ),
          ],
        ],
      ),
    );
  }

  TextStyle _valueStyle(BuildContext context, {bool dimmed = false}) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: dimmed
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface,
        ) ??
        const TextStyle();
  }
}
