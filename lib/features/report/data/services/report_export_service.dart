import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:share_plus/share_plus.dart';

/// Hard cap on exported rows (capacity contract baseline).
const int kExportMaxRows = 10000;

/// Result of a streaming CSV export.
class CsvExportResult {
  const CsvExportResult({required this.rowsWritten, required this.truncated});

  final int rowsWritten;
  final bool truncated;
}

/// Service for exporting report data to PDF and CSV formats.
class ReportExportService {
  const ReportExportService(this._appLock);

  final AppLockService _appLock;

  // PDF Export
  /// Generates a PDF report from [data].
  ///
  /// Pass [productLookup] to include per-product cost and margin columns
  /// in the top-products table.
  ///
  /// Throws [BusinessRuleError] `AppLockRequired` when store PIN is on and
  /// session locked (V092-B.3).
  Future<Uint8List> exportPdf(
    ReportData data, {
    Map<String, Product>? productLookup,
    ReportCalculatorService calculator = const ReportCalculatorService(),
    int? maxRows,
  }) async {
    await _appLock.requireSensitiveSession();
    final doc = pw.Document();
    final now = DateTime.now();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _pdfHeader(data, now),
          pw.SizedBox(height: 20),
          _pdfSummary(data),
          pw.SizedBox(height: 16),
          _pdfPaymentBreakdown(data),
          pw.SizedBox(height: 16),
          _pdfTopProducts(
            data,
            productLookup: productLookup,
            calculator: calculator,
          ),
          pw.SizedBox(height: 16),
          _pdfSalesTable(data, maxRows: maxRows),
        ],
      ),
    );

    return doc.save();
  }

  // CSV Export
  /// Generates a CSV report from [data].
  ///
  /// When [maxRows] is provided, only the first [maxRows] sales rows are
  /// exported to avoid memory exhaustion on very large datasets.
  ///
  /// Throws [BusinessRuleError] `AppLockRequired` when store PIN is on and
  /// session locked (V092-B.3).
  Future<String> exportCsv(ReportData data, {int? maxRows}) async {
    await _appLock.requireSensitiveSession();
    final rows = <List<String>>[];

    // Header
    rows.add([
      'Receipt Number',
      'Date',
      'Status',
      'Payment Method',
      'Order Type',
      'Order Channel',
      'Service Charge',
      'Promotion Discount',
      'Total Amount',
      'Items',
    ]);

    // Sales rows (optionally capped to avoid memory exhaustion).
    final sales = maxRows != null && data.sales.length > maxRows
        ? data.sales.take(maxRows).toList()
        : data.sales;
    for (final sale in sales) {
      rows.add([
        _csvCell(sale.receiptNumber ?? ''),
        sale.createdAt.toIso8601String(),
        sale.isVoided ? 'VOIDED' : 'COMPLETED',
        _csvCell(sale.paymentMethod),
        _csvCell(sale.orderType),
        _csvCell(sale.orderChannel),
        sale.serviceChargeAmount.value.toStringAsFixed(2),
        sale.promotionDiscountAmount.value.toStringAsFixed(2),
        sale.totalAmount.value.toStringAsFixed(2),
        _csvCell(
          sale.items.map((i) => '${i.productName} x${i.qty}').join('; '),
        ),
      ]);
    }

    // Profit summary footer (when cost data is available).
    final profit = data.profit;
    if (profit != null && !profit.hasNoCoverage) {
      rows.add([]);
      rows.add(['Profitability Summary']);
      rows.add([
        'Total Cost',
        'Gross Profit',
        'Margin %',
        'Items With Cost',
        'Items Without Cost',
      ]);
      rows.add([
        profit.totalCost.value.toStringAsFixed(2),
        profit.grossProfit.value.toStringAsFixed(2),
        profit.marginPercent.toStringAsFixed(1),
        '${profit.itemsWithCost}',
        '${profit.itemsWithoutCost}',
      ]);
    }

    return csv.encode(rows);
  }

  /// Streaming CSV export that pages through sales via [saleRepository]
  /// and writes rows to [sink] in chunks. Memory is bounded by the page
  /// size, not by the total row count.
  ///
  /// [maxRows] enforces a hard cap (defaults to [kExportMaxRows]). The
  /// returned [CsvExportResult.truncated] is true when the cap was hit.
  ///
  /// [startSignal] resolves just before the first row is written so callers
  /// can dismiss a "preparing" indicator without waiting for the full export.
  ///
  /// Throws [BusinessRuleError] `AppLockRequired` when store PIN is on and
  /// session locked (V092-B.3).
  Future<CsvExportResult> exportCsvStream({
    required SaleRepository saleRepository,
    required void Function(String chunk) sink,
    DateTime? from,
    DateTime? to,
    int maxRows = kExportMaxRows,
    int pageSize = 500,
    Future<void> Function()? startSignal,
  }) async {
    await _appLock.requireSensitiveSession();
    final header = csv.encode([
      [
        'Receipt Number',
        'Date',
        'Status',
        'Payment Method',
        'Order Type',
        'Order Channel',
        'Service Charge',
        'Promotion Discount',
        'Total Amount',
        'Items',
      ],
    ]);
    sink(header);
    if (startSignal != null) {
      await startSignal();
    }

    var rowsWritten = 0;
    var truncated = false;
    SaleCursor? cursor;
    final buffer = <List<String>>[];

    while (rowsWritten < maxRows) {
      final page = await saleRepository.getSalesPage(
        from: from,
        to: to,
        cursor: cursor,
        pageSize: pageSize,
      );
      if (page.sales.isEmpty) break;
      for (final sale in page.sales) {
        if (rowsWritten >= maxRows) {
          truncated = true;
          break;
        }
        buffer.add(_saleRow(sale));
        rowsWritten++;
      }
      if (buffer.isNotEmpty) {
        sink(csv.encode(buffer));
        buffer.clear();
      }
      cursor = page.nextCursor;
      if (truncated) break;
      if (!page.hasMore) break;
    }
    // If we exited the loop exactly at maxRows but there are more rows,
    // mark as truncated.
    if (!truncated && rowsWritten >= maxRows) {
      final probe = await saleRepository.getSalesPage(
        from: from,
        to: to,
        cursor: cursor,
        pageSize: 1,
      );
      if (probe.sales.isNotEmpty) truncated = true;
    }

    return CsvExportResult(rowsWritten: rowsWritten, truncated: truncated);
  }

  List<String> _saleRow(Sale sale) => [
    _csvCell(sale.receiptNumber ?? ''),
    sale.createdAt.toIso8601String(),
    sale.isVoided ? 'VOIDED' : 'COMPLETED',
    _csvCell(sale.paymentMethod),
    _csvCell(sale.orderType),
    _csvCell(sale.orderChannel),
    sale.serviceChargeAmount.value.toStringAsFixed(2),
    sale.promotionDiscountAmount.value.toStringAsFixed(2),
    sale.totalAmount.value.toStringAsFixed(2),
    _csvCell(sale.items.map((i) => '${i.productName} x${i.qty}').join('; ')),
  ];

  String _csvCell(String value) {
    if (value.isEmpty) return value;
    // Trim leading whitespace before checking — formula injection can be
    // hidden behind spaces/tabs (e.g. " =SUM(A1)").
    final trimmed = value.trimLeft();
    if (trimmed.isEmpty) return value;
    final first = trimmed[0];
    return switch (first) {
      '=' || '+' || '-' || '@' => "'$value",
      _ => value,
    };
  }

  /// Shares the report file (PDF bytes or CSV string).
  Future<void> shareReport({
    required String filename,
    Uint8List? pdfBytes,
    String? csvContent,
  }) async {
    if (pdfBytes != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              pdfBytes,
              name: filename,
              mimeType: 'application/pdf',
            ),
          ],
        ),
      );
    } else if (csvContent != null) {
      // UTF-8 (not String.codeUnits / UTF-16) so Thai product names survive.
      final bytes = Uint8List.fromList(utf8.encode(csvContent));
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: filename,
              mimeType: 'text/csv; charset=utf-8',
            ),
          ],
        ),
      );
    }
  }

  // Private PDF builders
  pw.Widget _pdfHeader(ReportData data, DateTime now) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Sales Report',
          style: const pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Period: ${_fmtDate(data.from)} – ${_fmtDate(data.to)}'),
        pw.Text('Generated: ${_fmtDateTime(now)}'),
      ],
    );
  }

  pw.Widget _pdfSummary(ReportData data) {
    final t = data.totals;
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: const pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Net Revenue: ${t.netRevenue.value.toStringAsFixed(2)}'),
              pw.Text('${t.salesCount} sales'),
            ],
          ),
          pw.Text('Gross Revenue: ${t.grossRevenue.value.toStringAsFixed(2)}'),
          pw.Text(
            'Average Transaction: ${t.averageTransactionValue.value.toStringAsFixed(2)}',
          ),
          if (t.serviceChargeAmount.isPositive)
            pw.Text(
              'Service Charge: ${t.serviceChargeAmount.value.toStringAsFixed(2)}',
            ),
          if (t.discountAmount.isPositive)
            pw.Text(
              'Discounts: ${t.discountAmount.value.toStringAsFixed(2)} '
              '(promotion ${t.promotionDiscountAmount.value.toStringAsFixed(2)})',
            ),
          if (t.voidCount > 0)
            pw.Text(
              'Voided: ${t.voidedTotal.value.toStringAsFixed(2)} (${t.voidCount})',
            ),
          if (data.profit != null && !data.profit!.hasNoCoverage) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Gross Profit: ${data.profit!.grossProfit.value.toStringAsFixed(2)}',
            ),
            pw.Text(
              'Total Cost: ${data.profit!.totalCost.value.toStringAsFixed(2)}',
            ),
            pw.Text(
              'Margin: ${data.profit!.marginPercent.toStringAsFixed(1)}%'
              '${data.profit!.hasFullCoverage ? '' : ' (partial cost coverage)'}',
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _pdfPaymentBreakdown(ReportData data) {
    final rows = data.totals.paymentBreakdown.entries.toList();
    if (rows.isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Payment Methods',
          style: const pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Method',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Amount',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Count',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...rows.map((e) {
              final count = data.totals.paymentCounts[e.key] ?? 0;
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(e.key),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(e.value.toStringAsFixed(2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('$count'),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfTopProducts(
    ReportData data, {
    Map<String, Product>? productLookup,
    required ReportCalculatorService calculator,
  }) {
    final top = calculator.topProductStats(
      data.sales,
      productLookup: productLookup,
    );
    if (top.isEmpty) return pw.SizedBox.shrink();
    final hasCost = top.any((s) => s.hasCostData);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top Products',
          style: const pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '#',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Product',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Qty',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Revenue',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                if (hasCost) ...[
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Cost',
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Margin',
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            ...top.asMap().entries.map((e) {
              final stat = e.value;
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${e.key + 1}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(stat.displayName),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${stat.qty}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(stat.revenue.toStringAsFixed(2)),
                  ),
                  if (hasCost) ...[
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(stat.cost?.toStringAsFixed(2) ?? '-'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        stat.marginPercent != null
                            ? '${stat.marginPercent!.toStringAsFixed(1)}%'
                            : '-',
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfSalesTable(ReportData data, {int? maxRows}) {
    var completed = data.sales.where((s) => !s.isVoided).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (maxRows != null && completed.length > maxRows) {
      completed = completed.take(maxRows).toList();
    }
    if (completed.isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Sales Detail',
          style: const pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Receipt',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Date',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Method',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Total',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...completed.map((s) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(s.receiptNumber ?? ''),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(_fmtDateTime(s.createdAt)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(s.paymentMethod),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(s.totalAmount.value.toStringAsFixed(2)),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtDateTime(DateTime d) =>
      '${_fmtDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
