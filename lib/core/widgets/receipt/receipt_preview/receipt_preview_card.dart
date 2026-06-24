import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview/receipt_preview_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class ReceiptPreviewCard extends StatelessWidget {
  const ReceiptPreviewCard({
    super.key,
    required this.settings,
    required this.labels,
    required this.items,
    required this.total,
    this.vatInfo,
    this.paymentMethod,
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.receiptNumber,
    this.createdAt,
  });

  final Settings settings;
  final ReceiptLabels labels;
  final List<ReceiptPreviewItem> items;
  final double total;
  final ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  vatInfo;
  final String? paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  final String? receiptNumber;
  final DateTime? createdAt;

  String _formatDate(DateTime dt) {
    try {
      return DateFormat(settings.dateFormat).add_Hm().format(dt);
    } catch (e) {
      AppLogger.warning('ReceiptPreviewCard._formatDate fallback', error: e);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = settings;
    final l = labels;
    final vat = vatInfo;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s.shopName.isNotEmpty)
                Text(
                  s.shopName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (s.showShopInfoOnReceipt) ...[
                if (s.address.isNotEmpty)
                  Text(
                    s.address,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                if (s.phone.isNotEmpty)
                  Text(
                    s.phone,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l.receipt} #${receiptNumber ?? 'Preview'}',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      _formatDate(createdAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              if (paymentMethod != null)
                Text(
                  '${l.payment}: $paymentMethod',
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (item.imagePath != null ||
                          item.imageThumbnailPath != null ||
                          item.imageUrl != null) ...[
                        ProductAvatar(
                          imagePath: item.imagePath,
                          imageThumbnailPath: item.imageThumbnailPath,
                          imageUrl: item.imageUrl,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(child: Text('${item.name} x${item.qty}')),
                      Text('${s.currency}${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              if (vat != null) ...[
                _row(
                  theme,
                  l.subtotal,
                  '${s.currency}${vat.subtotal.toStringAsFixed(2)}',
                ),
                _row(
                  theme,
                  vat.isInclusive ? l.vatIncluded : '${l.vat} ${s.vatRate}%',
                  '${s.currency}${vat.vatAmount.toStringAsFixed(2)}',
                ),
              ],
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.total,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${s.currency}${vat?.totalWithVat.toStringAsFixed(2) ?? total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (amountReceived != null) ...[
                const SizedBox(height: 4),
                _row(
                  theme,
                  l.received,
                  '${s.currency}${amountReceived!.toStringAsFixed(2)}',
                ),
                _row(
                  theme,
                  l.change,
                  '${s.currency}${(changeAmount ?? 0).toStringAsFixed(2)}',
                ),
              ],
              if (note != null && note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${l.note}: $note', style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 8),
              Text(
                s.receiptNote.isNotEmpty ? s.receiptNote : 'Thank you!',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String left, String right) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: theme.textTheme.bodyMedium),
        Text(right, style: theme.textTheme.bodyMedium),
      ],
    ),
  );
}
