import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

/// Labels for receipt text that must be localized by the caller.
class ReceiptLabels {
  const ReceiptLabels({
    required this.receipt,
    required this.payment,
    required this.total,
    required this.received,
    required this.change,
    required this.note,
    required this.vat,
    required this.vatIncluded,
    required this.subtotal,
  });

  final String receipt;
  final String payment;
  final String total;
  final String received;
  final String change;
  final String note;
  final String vat;
  final String vatIncluded;
  final String subtotal;
}

class ReceiptPdfService {
  ReceiptPdfService();

  pw.Font? _baseFont;
  pw.Font? _boldFont;

  Future<void> _ensureFonts() async {
    _baseFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansThai-Regular.ttf'),
    );
    _boldFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansThai-Bold.ttf'),
    );
  }

  Future<void> printReceipt({
    required Sale sale,
    required AppSettings settings,
    required ReceiptLabels labels,
  }) async {
    await _ensureFonts();
    final doc = _buildDocument(
      sale: sale,
      settings: settings,
      labels: labels,
      baseFont: _baseFont,
      boldFont: _boldFont,
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<void> shareReceipt({
    required Sale sale,
    required AppSettings settings,
    required ReceiptLabels labels,
  }) async {
    await _ensureFonts();
    final doc = _buildDocument(
      sale: sale,
      settings: settings,
      labels: labels,
      baseFont: _baseFont,
      boldFont: _boldFont,
    );
    final number = sale.receiptNumber ?? sale.id;
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'receipt_$number.pdf',
    );
  }

  pw.Document _buildDocument({
    required Sale sale,
    required AppSettings settings,
    required ReceiptLabels labels,
    pw.Font? baseFont,
    pw.Font? boldFont,
  }) {
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );
    final number = sale.receiptNumber ?? sale.id;
    final footer = settings.receiptNote.isNotEmpty
        ? settings.receiptNote
        : 'Thank you!';
    final vatInfo = calculateVat(
      total: sale.totalAmount,
      rate: settings.vatRate,
      mode: settings.vatMode,
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                settings.shopName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (settings.showShopInfoOnReceipt) ...[
              if (settings.address.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    settings.address,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              if (settings.phone.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    settings.phone,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
            ],
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${labels.receipt} #$number',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Text(
                  _formatDate(sale.createdAt, settings.dateFormat),
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
            pw.Text(
              '${labels.payment}: ${sale.paymentMethod}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 6),
            pw.Divider(),
            ...sale.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${item.productName} x${item.qty}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Text(
                      '${settings.currency}${item.subtotal.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            pw.Divider(),
            if (vatInfo != null) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(labels.subtotal),
                  pw.Text(
                    '${settings.currency}${vatInfo.subtotal.toStringAsFixed(2)}',
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    vatInfo.isInclusive
                        ? labels.vatIncluded
                        : '${labels.vat} ${settings.vatRate}%',
                  ),
                  pw.Text(
                    '${settings.currency}${vatInfo.vatAmount.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  labels.total,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${settings.currency}${vatInfo?.totalWithVat.toStringAsFixed(2) ?? sale.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            if (sale.amountReceived != null) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(labels.received),
                  pw.Text(
                    '${settings.currency}${sale.amountReceived!.toStringAsFixed(2)}',
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(labels.change),
                  pw.Text(
                    '${settings.currency}${(sale.changeAmount ?? 0).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
            if (sale.note != null && sale.note!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                '${labels.note}: ${sale.note}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(footer, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  pw.Document buildDocumentForTest({
    required Sale sale,
    required AppSettings settings,
    required ReceiptLabels labels,
  }) => _buildDocument(
    sale: sale,
    settings: settings,
    labels: labels,
    baseFont: null,
    boldFont: null,
  );

  ({double subtotal, double vatAmount, double totalWithVat, bool isInclusive})?
  calculateVat({
    required double total,
    required double rate,
    required String mode,
  }) {
    if (mode == 'NONE') return null;
    final r = rate / 100;
    if (mode == 'INCLUSIVE') {
      final subtotal = total / (1 + r);
      final vatAmount = total - subtotal;
      return (
        subtotal: subtotal,
        vatAmount: vatAmount,
        totalWithVat: total,
        isInclusive: true,
      );
    }
    // EXCLUSIVE
    final vatAmount = total * r;
    return (
      subtotal: total,
      vatAmount: vatAmount,
      totalWithVat: total + vatAmount,
      isInclusive: false,
    );
  }

  String _formatDate(DateTime dt, String format) {
    try {
      return DateFormat(format).add_Hm().format(dt);
    } catch (_) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }
}
