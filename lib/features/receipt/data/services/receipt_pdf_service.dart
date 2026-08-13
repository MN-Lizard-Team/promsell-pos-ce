import 'dart:typed_data';

import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_document.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/domain/services/build_receipt_document.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

@lazySingleton
class ReceiptPdfService {
  ReceiptPdfService({@ignoreParam BuildReceiptDocument? documentBuilder})
    : _documentBuilder = documentBuilder ?? const BuildReceiptDocument();

  final BuildReceiptDocument _documentBuilder;

  pw.Font? _baseFont;
  pw.Font? _boldFont;

  Future<void> _ensureFonts() async {
    // Load Regular first — it's the critical Thai-capable font.
    _baseFont ??= await _loadFont(
      'assets/fonts/NotoSansThai-Regular.ttf',
      fallback: pw.Font.helvetica(),
    );
    // Bold falls back to Regular (still Thai-capable) before helvetica.
    _boldFont ??= await _loadFont(
      'assets/fonts/NotoSansThai-Bold.ttf',
      fallback: _baseFont ?? pw.Font.helveticaBold(),
    );
    // Defensive: guarantee non-null so PDF generation never crashes.
    _baseFont ??= pw.Font.helvetica();
    _boldFont ??= _baseFont ?? pw.Font.helveticaBold();
  }

  Future<pw.Font> _loadFont(
    String assetKey, {
    required pw.Font fallback,
  }) async {
    try {
      return pw.Font.ttf(await rootBundle.load(assetKey));
    } catch (e, stack) {
      AppLogger.error('Failed to load font: $assetKey', error: e, stack: stack);
      return fallback;
    }
  }

  Future<void> printReceipt({
    required Sale sale,
    required Settings settings,
    required ReceiptLabels labels,
    Map<String, Uint8List>? productImages,
    bool isReprint = false,
    String? thankYouFallback,
    String? notTaxInvoiceDisclaimer,
  }) async {
    await _ensureFonts();
    final doc = _buildDocument(
      document: _documentBuilder.fromSale(
        sale: sale,
        settings: settings,
        labels: labels,
        isReprint: isReprint,
        thankYouFallback: thankYouFallback,
        notTaxInvoiceDisclaimer: notTaxInvoiceDisclaimer,
      ),
      baseFont: _baseFont,
      boldFont: _boldFont,
      productImages: productImages,
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<void> shareReceipt({
    required Sale sale,
    required Settings settings,
    required ReceiptLabels labels,
    Map<String, Uint8List>? productImages,
    bool isReprint = false,
    String? thankYouFallback,
    String? notTaxInvoiceDisclaimer,
  }) async {
    await _ensureFonts();
    final document = _documentBuilder.fromSale(
      sale: sale,
      settings: settings,
      labels: labels,
      isReprint: isReprint,
      thankYouFallback: thankYouFallback,
      notTaxInvoiceDisclaimer: notTaxInvoiceDisclaimer,
    );
    final pdf = _buildDocument(
      document: document,
      baseFont: _baseFont,
      boldFont: _boldFont,
      productImages: productImages,
    );
    final number = document.receiptNumber;
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'receipt_$number.pdf',
    );
  }

  /// Builds a PDF from a pre-built [ReceiptDocument] (tests / advanced callers).
  pw.Document buildFromDocument(
    ReceiptDocument document, {
    Map<String, Uint8List>? productImages,
    pw.Font? baseFont,
    pw.Font? boldFont,
  }) {
    return _buildDocument(
      document: document,
      baseFont: baseFont,
      boldFont: boldFont,
      productImages: productImages,
    );
  }

  pw.Document _buildDocument({
    required ReceiptDocument document,
    pw.Font? baseFont,
    pw.Font? boldFont,
    Map<String, Uint8List>? productImages,
  }) {
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );
    final labels = document.labels;
    final currency = document.currency;

    String money(Money m) =>
        CurrencyFormatter.formatGroupedWithSymbol(m.value, currency);

    final pageFormat = _pageFormatFor(document.receiptSize);
    final isA4 = document.receiptSize.trim().toUpperCase() == 'A4';

    if (isA4) {
      // A4 has fixed page height — use MultiPage for automatic page breaks.
      // H5: Footer shows page numbers on non-final pages; full footer on last.
      doc.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          header: (ctx) => _buildHeader(document, labels, money),
          build: (ctx) => _buildBody(document, labels, money, productImages),
          footer: (ctx) => ctx.pageNumber == ctx.pagesCount
              ? _buildFooter(document)
              : pw.Center(
                  child: pw.Text(
                    '${ctx.pageNumber} / ${ctx.pagesCount}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
        ),
      );
    } else {
      // Thermal rolls (58mm/80mm) have unbounded height — single Page is fine.
      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(document, labels, money),
              ..._buildBody(document, labels, money, productImages),
              _buildFooter(document),
            ],
          ),
        ),
      );
    }
    return doc;
  }

  /// Receipt header (voided stamp, shop info, receipt#, payment, customer).
  pw.Widget _buildHeader(
    ReceiptDocument document,
    ReceiptLabels labels,
    String Function(Money) money,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        if (document.isVoided) ...[
          pw.Center(
            child: pw.Text(
              labels.voided ?? 'VOIDED',
              style: const pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          if (document.voidReason != null && document.voidReason!.isNotEmpty)
            pw.Center(
              child: pw.Text(
                '${labels.voidReason ?? 'Reason'}: ${document.voidReason}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          if (document.voidedAt != null)
            pw.Center(
              child: pw.Text(
                '${labels.voidedAt ?? 'Voided at'}: ${_formatDate(document.voidedAt!, document.dateFormat)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          pw.SizedBox(height: 4),
        ],
        if (document.isReprint)
          pw.Center(
            child: pw.Text(
              labels.reprint ?? 'REPRINT',
              style: const pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        pw.Center(
          child: pw.Text(
            document.shopName,
            style: const pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        // H8: Label as "Tax Invoice" when Tax ID is present, else "Receipt".
        pw.Center(
          child: pw.Text(
            document.taxId.isNotEmpty
                ? (labels.taxInvoice ?? labels.receipt)
                : labels.receipt,
            style: const pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        if (document.showShopInfo) ...[
          if (document.address.isNotEmpty)
            pw.Center(
              child: pw.Text(
                document.address,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          if (document.phone.isNotEmpty)
            pw.Center(
              child: pw.Text(
                document.phone,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          // H7: Tax ID prominent — 12pt bold for Thai tax compliance.
          if (document.taxId.isNotEmpty)
            pw.Center(
              child: pw.Text(
                '${labels.taxId ?? 'Tax ID'}: ${document.taxId}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
        ],
        if (document.notTaxInvoiceDisclaimer != null &&
            document.notTaxInvoiceDisclaimer!.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text(
              document.notTaxInvoiceDisclaimer!,
              style: const pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.center,
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
                '${labels.receipt} #${document.receiptNumber}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Text(
              _formatDate(document.createdAt, document.dateFormat),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        if (document.paymentLines.isNotEmpty)
          ...document.paymentLines.map(
            (line) => pw.Text(
              '${labels.payment}: $line',
              style: const pw.TextStyle(fontSize: 10),
            ),
          )
        else
          pw.Text(
            '${labels.payment}: ${document.paymentMethodLabel}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        if (labels.customer != null &&
            document.customerName != null &&
            document.customerName!.isNotEmpty)
          pw.Text(
            '${labels.customer}: ${document.customerName}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        if (labels.promotion != null &&
            document.promotionName != null &&
            document.promotionName!.isNotEmpty)
          pw.Text(
            document.promotionDiscount.isPositive &&
                    labels.promotionDiscount != null
                ? '${labels.promotion}: ${document.promotionName} (${money(document.promotionDiscount)})'
                : '${labels.promotion}: ${document.promotionName}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        pw.SizedBox(height: 6),
        pw.Divider(),
      ],
    );
  }

  /// Receipt body (items + totals breakdown).
  List<pw.Widget> _buildBody(
    ReceiptDocument document,
    ReceiptLabels labels,
    String Function(Money) money,
    Map<String, Uint8List>? productImages,
  ) {
    return [
      ...document.items.map((item) {
        final imgBytes = productImages?[item.productId];
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (imgBytes != null && imgBytes.lengthInBytes > 8) ...[
                pw.Container(
                  width: 28,
                  height: 28,
                  margin: const pw.EdgeInsets.only(right: 6),
                  child: pw.Image(
                    pw.MemoryImage(imgBytes),
                    width: 28,
                    height: 28,
                  ),
                ),
              ],
              pw.Expanded(
                child: pw.Text(
                  '${item.name} x${item.qty}',
                  style: const pw.TextStyle(fontSize: 10),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              pw.Text(
                money(item.lineTotal),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        );
      }),
      pw.Divider(),
      // Net lines only — no aggregate item-discount row (avoids double-count).
      if (document.cartDiscount.isPositive)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(labels.cartDiscount),
            pw.Text('-${money(document.cartDiscount)}'),
          ],
        ),
      if (document.promotionDiscount.isPositive)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              labels.promotionDiscount ?? labels.promotion ?? 'Promotion',
            ),
            pw.Text('-${money(document.promotionDiscount)}'),
          ],
        ),
      if (document.serviceCharge.isPositive)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              document.serviceChargeRate > 0
                  ? '${labels.serviceCharge ?? 'Service charge'} ${document.serviceChargeRate.toStringAsFixed(0)}%'
                  : (labels.serviceCharge ?? 'Service charge'),
            ),
            pw.Text(money(document.serviceCharge)),
          ],
        ),
      if (document.hasVat) ...[
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(labels.subtotal),
            pw.Text(money(document.pretaxOrNetOfVat)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              document.isVatInclusive
                  ? labels.vatIncluded
                  : '${labels.vat} ${document.vatRate}%',
            ),
            pw.Text(money(document.vatAmount)),
          ],
        ),
      ],
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            labels.total,
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            money(document.total),
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      if (document.amountReceived != null) ...[
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(labels.received),
            pw.Text(money(document.amountReceived!)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(labels.change),
            pw.Text(money(document.changeAmount ?? Money.zero)),
          ],
        ),
      ],
      if (document.note != null && document.note!.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          '${labels.note}: ${document.note}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    ];
  }

  /// Receipt footer (thank you message).
  pw.Widget _buildFooter(ReceiptDocument document) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            document.footer,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  /// Test seam: builds PDF from sale using stored-field SSOT.
  pw.Document buildDocumentForTest({
    required Sale sale,
    required Settings settings,
    required ReceiptLabels labels,
    Map<String, Uint8List>? productImages,
    bool isReprint = false,
    String? thankYouFallback,
    String? notTaxInvoiceDisclaimer,
  }) {
    final document = _documentBuilder.fromSale(
      sale: sale,
      settings: settings,
      labels: labels,
      isReprint: isReprint,
      thankYouFallback: thankYouFallback,
      notTaxInvoiceDisclaimer: notTaxInvoiceDisclaimer,
    );
    return _buildDocument(
      document: document,
      baseFont: null,
      boldFont: null,
      productImages: productImages,
    );
  }

  /// Legacy helper for settings mocks / pre-sale only.
  /// Prefer [BuildReceiptDocument] + stored sale fields for completed sales.
  ({double subtotal, double vatAmount, double totalWithVat, bool isInclusive})?
  calculateVat({
    required double total,
    required double rate,
    required String mode,
    bool isTotalPreTax = true,
  }) {
    if (mode == 'NONE') return null;
    final r = rate / 100;
    if (mode == 'INCLUSIVE') {
      final subtotal = double.parse((total / (1 + r)).toStringAsFixed(2));
      final vatAmount = double.parse((total - subtotal).toStringAsFixed(2));
      return (
        subtotal: subtotal,
        vatAmount: vatAmount,
        totalWithVat: double.parse(total.toStringAsFixed(2)),
        isInclusive: true,
      );
    }
    if (isTotalPreTax) {
      final vatAmount = double.parse((total * r).toStringAsFixed(2));
      return (
        subtotal: double.parse(total.toStringAsFixed(2)),
        vatAmount: vatAmount,
        totalWithVat: double.parse((total + vatAmount).toStringAsFixed(2)),
        isInclusive: false,
      );
    }
    final vatAmount = double.parse((total * r / (1 + r)).toStringAsFixed(2));
    final subtotal = double.parse((total - vatAmount).toStringAsFixed(2));
    return (
      subtotal: subtotal,
      vatAmount: vatAmount,
      totalWithVat: double.parse(total.toStringAsFixed(2)),
      isInclusive: false,
    );
  }

  String _formatDate(DateTime dt, String format) {
    try {
      return DateFormat(format).add_Hm().format(dt);
    } catch (e) {
      AppLogger.warning('ReceiptPdfService._formatDate fallback', error: e);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }

  /// Maps settings `receiptSize` to PDF page format.
  static PdfPageFormat _pageFormatFor(String receiptSize) {
    switch (receiptSize.trim().toUpperCase()) {
      case 'A4':
        return PdfPageFormat.a4;
      case '58MM':
        return PdfPageFormat.roll57;
      case '80MM':
      default:
        return PdfPageFormat.roll80;
    }
  }
}
