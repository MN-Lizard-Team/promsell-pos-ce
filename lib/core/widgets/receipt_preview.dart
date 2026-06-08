import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

/// A data item for receipt preview (works for both pre-sale cart items
/// and post-sale [SaleItem]s).
class ReceiptPreviewItem {
  const ReceiptPreviewItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  final String name;
  final int qty;
  final double price;
  final double subtotal;
}

enum ReceiptPreviewStyle { thermal, card, none }

/// On-screen receipt preview widget with two visual styles.
///
/// * [style] determines the visual presentation.
/// * [items] are the line items.
/// * [total] is the cart/sale total before VAT (used for pre-sale).
/// * [vatInfo] is computed externally so the widget stays pure.
class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({
    super.key,
    required this.settings,
    required this.labels,
    required this.style,
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

  final AppSettings settings;
  final ReceiptLabels labels;
  final ReceiptPreviewStyle style;
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

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      ReceiptPreviewStyle.thermal => _ThermalPreview(this),
      ReceiptPreviewStyle.card => _CardPreview(this),
      ReceiptPreviewStyle.none => const SizedBox.shrink(),
    };
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat(settings.dateFormat).add_Hm().format(dt);
    } catch (e) {
      debugPrint('ReceiptPreview._formatDate fallback: $e');
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }
}

class _ThermalPreview extends StatelessWidget {
  const _ThermalPreview(this._parent);

  final ReceiptPreview _parent;

  @override
  Widget build(BuildContext context) {
    final s = _parent.settings;
    final l = _parent.labels;
    final vat = _parent.vatInfo;

    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          height: 1.3,
          fontFamily: 'monospace',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shop info
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
            const SizedBox(height: 4),
            _divider(),
            const SizedBox(height: 4),
            // Receipt number + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${l.receipt} #${_parent.receiptNumber ?? 'Preview'}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                if (_parent.createdAt != null)
                  Text(
                    _parent._formatDate(_parent.createdAt!),
                    style: const TextStyle(fontSize: 9),
                  ),
              ],
            ),
            if (_parent.paymentMethod != null)
              Text('${l.payment}: ${_parent.paymentMethod}'),
            const SizedBox(height: 6),
            _divider(),
            // Items
            ..._parent.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.qty}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    Text(
                      '${s.currency}${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            _divider(),
            // VAT
            if (vat != null) ...[
              _row(
                l.subtotal,
                '${s.currency}${vat.subtotal.toStringAsFixed(2)}',
              ),
              _row(
                vat.isInclusive ? l.vatIncluded : '${l.vat} ${s.vatRate}%',
                '${s.currency}${vat.vatAmount.toStringAsFixed(2)}',
              ),
            ],
            // Total
            _row(
              l.total,
              '${s.currency}${vat?.totalWithVat.toStringAsFixed(2) ?? _parent.total.toStringAsFixed(2)}',
              bold: true,
            ),
            // Received / Change
            if (_parent.amountReceived != null) ...[
              _row(
                l.received,
                '${s.currency}${_parent.amountReceived!.toStringAsFixed(2)}',
              ),
              _row(
                l.change,
                '${s.currency}${(_parent.changeAmount ?? 0).toStringAsFixed(2)}',
              ),
            ],
            // Note
            if (_parent.note != null && _parent.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l.note}: ${_parent.note}',
                style: const TextStyle(fontSize: 9),
              ),
            ],
            const SizedBox(height: 8),
            // Footer
            _center(
              s.receiptNote.isNotEmpty ? s.receiptNote : 'Thank you!',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _center(String text, {TextStyle? style}) => Center(
    child: Text(text, style: style, textAlign: TextAlign.center),
  );

  Widget _divider() =>
      const Divider(color: Colors.black, height: 1, thickness: 0.5);

  Widget _row(String left, String right, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
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

class _CardPreview extends StatelessWidget {
  const _CardPreview(this._parent);

  final ReceiptPreview _parent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _parent.settings;
    final l = _parent.labels;
    final vat = _parent.vatInfo;

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
              // Header
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
              // Meta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l.receipt} #${_parent.receiptNumber ?? 'Preview'}',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_parent.createdAt != null)
                    Text(
                      _parent._formatDate(_parent.createdAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              if (_parent.paymentMethod != null)
                Text(
                  '${l.payment}: ${_parent.paymentMethod}',
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              // Items
              ..._parent.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text('${item.name} x${item.qty}')),
                      Text('${s.currency}${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              // VAT
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
              // Total
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
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
                      '${s.currency}${vat?.totalWithVat.toStringAsFixed(2) ?? _parent.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_parent.amountReceived != null) ...[
                const SizedBox(height: 4),
                _row(
                  theme,
                  l.received,
                  '${s.currency}${_parent.amountReceived!.toStringAsFixed(2)}',
                ),
                _row(
                  theme,
                  l.change,
                  '${s.currency}${(_parent.changeAmount ?? 0).toStringAsFixed(2)}',
                ),
              ],
              if (_parent.note != null && _parent.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l.note}: ${_parent.note}',
                  style: theme.textTheme.bodySmall,
                ),
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
