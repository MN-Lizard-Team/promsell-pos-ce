import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview/receipt_preview_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class ReceiptPreviewThermal extends StatelessWidget {
  const ReceiptPreviewThermal({
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
      AppLogger.warning('ReceiptPreviewThermal._formatDate fallback', error: e);
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

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 11,
          height: 1.3,
          fontFamily: 'NotoSansThai',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isVoided) ...[
              _center(
                l.voided ?? 'VOIDED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              if (voidReason != null && voidReason!.isNotEmpty)
                _center(
                  '${l.voidReason ?? 'Reason'}: $voidReason',
                  style: const TextStyle(fontSize: 9),
                ),
              const SizedBox(height: 4),
            ],
            if (isReprint)
              _center(
                l.reprint ?? 'REPRINT',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (s.shopName.isNotEmpty)
              _center(
                s.shopName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (s.showShopInfoOnReceipt) ...[
              if (s.address.isNotEmpty)
                _center(s.address, style: const TextStyle(fontSize: 9)),
              if (s.phone.isNotEmpty)
                _center(s.phone, style: const TextStyle(fontSize: 9)),
            ],
            if (notTaxInvoiceDisclaimer != null &&
                notTaxInvoiceDisclaimer!.isNotEmpty)
              _center(
                notTaxInvoiceDisclaimer!,
                style: TextStyle(
                  fontSize: 8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 4),
            _divider(theme),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${l.receipt} #${receiptNumber ?? 'Preview'}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt!),
                    style: const TextStyle(fontSize: 9),
                  ),
              ],
            ),
            if (l.paymentLines.isNotEmpty)
              ...l.paymentLines.map((line) => Text('${l.payment}: $line'))
            else if (paymentMethod != null)
              Text('${l.payment}: $paymentMethod'),
            if (l.customer != null &&
                l.customerName != null &&
                l.customerName!.isNotEmpty)
              Text('${l.customer}: ${l.customerName}'),
            if (l.promotion != null &&
                l.promotionName != null &&
                l.promotionName!.isNotEmpty)
              Text('${l.promotion}: ${l.promotionName}'),
            const SizedBox(height: 6),
            _divider(theme),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
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
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        '${item.name} x${item.qty}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    Text(
                      _money(item.subtotal),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            _divider(theme),
            if (cartDiscount != null && cartDiscount! > 0)
              _row(l.cartDiscount, '-${_money(cartDiscount!)}'),
            if (promotionDiscount != null && promotionDiscount! > 0)
              _row(
                l.promotionDiscount ?? l.promotion ?? 'Promotion',
                '-${_money(promotionDiscount!)}',
              ),
            if (serviceCharge != null && serviceCharge! > 0)
              _row(
                (serviceChargeRate != null && serviceChargeRate! > 0)
                    ? '${l.serviceCharge ?? 'Service charge'} ${serviceChargeRate!.toStringAsFixed(0)}%'
                    : (l.serviceCharge ?? 'Service charge'),
                _money(serviceCharge!),
              ),
            if (vat != null) ...[
              _row(l.subtotal, _money(vat.subtotal)),
              _row(
                vat.isInclusive
                    ? l.vatIncluded
                    : '${l.vat} ${settings.vatRate}%',
                _money(vat.vatAmount),
              ),
            ],
            _row(l.total, _money(vat?.totalWithVat ?? total), bold: true),
            if (amountReceived != null) ...[
              _row(l.received, _money(amountReceived!)),
              _row(l.change, _money(changeAmount ?? 0)),
            ],
            if (note != null && note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${l.note}: $note', style: const TextStyle(fontSize: 9)),
            ],
            const SizedBox(height: 8),
            _center(footer, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _center(String text, {TextStyle? style}) => Center(
    child: Text(text, style: style, textAlign: TextAlign.center),
  );
  Widget _divider(ThemeData theme) => Divider(
    color: theme.colorScheme.outlineVariant,
    height: 1,
    thickness: 0.5,
  );
  Widget _row(String left, String right, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
