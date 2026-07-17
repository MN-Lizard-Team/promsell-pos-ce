import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
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
    this.cartDiscount,
    this.promotionDiscount,
    this.serviceCharge,
    this.serviceChargeRate,
    this.isVoided = false,
    this.voidReason,
    this.isReprint = false,
    this.notTaxInvoiceDisclaimer,
    this.footerOverride,
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
  final double? cartDiscount;
  final double? promotionDiscount;
  final double? serviceCharge;
  final double? serviceChargeRate;
  final bool isVoided;
  final String? voidReason;
  final bool isReprint;
  final String? notTaxInvoiceDisclaimer;
  final String? footerOverride;

  String _formatDate(DateTime dt) {
    try {
      return DateFormat(settings.dateFormat).add_Hm().format(dt);
    } catch (e) {
      AppLogger.warning('ReceiptPreviewCard._formatDate fallback', error: e);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }

  String _money(double amount) =>
      CurrencyFormatter.formatGroupedWithSymbol(amount, settings.currency);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = settings;
    final l = labels;
    final vat = vatInfo;
    final footer =
        footerOverride ??
        (s.receiptNote.isNotEmpty ? s.receiptNote : 'Thank you!');

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
              if (isVoided) ...[
                Text(
                  l.voided ?? 'VOIDED',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (voidReason != null && voidReason!.isNotEmpty)
                  Text(
                    '${l.voidReason ?? 'Reason'}: $voidReason',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
              ],
              if (isReprint)
                Text(
                  l.reprint ?? 'REPRINT',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
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
              if (notTaxInvoiceDisclaimer != null &&
                  notTaxInvoiceDisclaimer!.isNotEmpty)
                Text(
                  notTaxInvoiceDisclaimer!,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
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
              if (l.paymentLines.isNotEmpty)
                ...l.paymentLines.map(
                  (line) => Text(
                    '${l.payment}: $line',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              else if (paymentMethod != null)
                Text(
                  '${l.payment}: $paymentMethod',
                  style: theme.textTheme.bodySmall,
                ),
              if (l.customer != null &&
                  l.customerName != null &&
                  l.customerName!.isNotEmpty)
                Text(
                  '${l.customer}: ${l.customerName}',
                  style: theme.textTheme.bodySmall,
                ),
              if (l.promotion != null &&
                  l.promotionName != null &&
                  l.promotionName!.isNotEmpty)
                Text(
                  '${l.promotion}: ${l.promotionName}',
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
                      Text(_money(item.subtotal)),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              if (cartDiscount != null && cartDiscount! > 0)
                _row(theme, l.cartDiscount, '-${_money(cartDiscount!)}'),
              if (promotionDiscount != null && promotionDiscount! > 0)
                _row(
                  theme,
                  l.promotionDiscount ?? l.promotion ?? 'Promotion',
                  '-${_money(promotionDiscount!)}',
                ),
              if (serviceCharge != null && serviceCharge! > 0)
                _row(
                  theme,
                  (serviceChargeRate != null && serviceChargeRate! > 0)
                      ? '${l.serviceCharge ?? 'Service charge'} ${serviceChargeRate!.toStringAsFixed(0)}%'
                      : (l.serviceCharge ?? 'Service charge'),
                  _money(serviceCharge!),
                ),
              if (vat != null) ...[
                _row(theme, l.subtotal, _money(vat.subtotal)),
                _row(
                  theme,
                  vat.isInclusive
                      ? l.vatIncluded
                      : '${l.vat} ${settings.vatRate}%',
                  _money(vat.vatAmount),
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
                      _money(vat?.totalWithVat ?? total),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (amountReceived != null) ...[
                const SizedBox(height: 4),
                _row(theme, l.received, _money(amountReceived!)),
                _row(theme, l.change, _money(changeAmount ?? 0)),
              ],
              if (note != null && note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${l.note}: $note', style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 8),
              Text(
                footer,
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
        Flexible(child: Text(left, style: theme.textTheme.bodyMedium)),
        Text(right, style: theme.textTheme.bodyMedium),
      ],
    ),
  );
}
