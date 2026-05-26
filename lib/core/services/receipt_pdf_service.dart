import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

class ReceiptPdfService {
  const ReceiptPdfService();

  Future<void> printReceipt({
    required Sale sale,
    required String currency,
    required String storeName,
  }) async {
    final doc = _buildDocument(sale: sale, currency: currency, storeName: storeName);
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<void> shareReceipt({
    required Sale sale,
    required String currency,
    required String storeName,
  }) async {
    final doc = _buildDocument(sale: sale, currency: currency, storeName: storeName);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'receipt_${sale.id}.pdf',
    );
  }

  pw.Document _buildDocument({
    required Sale sale,
    required String currency,
    required String storeName,
  }) {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                storeName,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Receipt #${sale.id}'),
                pw.Text(_formatDate(sale.createdAt)),
              ],
            ),
            pw.Text('Payment: ${sale.paymentMethod}'),
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
                      '$currency${item.subtotal.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '$currency${sale.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            if (sale.amountReceived != null) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Received'),
                  pw.Text('$currency${sale.amountReceived!.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Change'),
                  pw.Text(
                    '$currency${(sale.changeAmount ?? 0).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
            if (sale.note != null && sale.note!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text('Note: ${sale.note}', style: const pw.TextStyle(fontSize: 9)),
            ],
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text('Thank you!', style: const pw.TextStyle(fontSize: 10))),
          ],
        ),
      ),
    );
    return doc;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
