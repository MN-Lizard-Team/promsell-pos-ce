import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:share_plus/share_plus.dart';

class BarcodeImageWidget extends StatefulWidget {
  const BarcodeImageWidget({
    super.key,
    required this.barcode,
    required this.productName,
  });

  final String barcode;
  final String productName;

  @override
  State<BarcodeImageWidget> createState() => _BarcodeImageWidgetState();
}

class _BarcodeImageWidgetState extends State<BarcodeImageWidget> {
  final GlobalKey _repaintKey = GlobalKey();

  Barcode _resolveType() {
    final clean = widget.barcode.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'^\d{13}$').hasMatch(clean)) return Barcode.ean13();
    if (RegExp(r'^\d{8}$').hasMatch(clean)) return Barcode.ean8();
    if (RegExp(r'^\d{12}$').hasMatch(clean)) return Barcode.upcA();
    return Barcode.code128();
  }

  Future<Uint8List?> _captureBarcode() async {
    try {
      final context = _repaintKey.currentContext;
      if (context == null) return null;
      final boundary = context.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageWidget._captureBarcode failed',
        error: e,
        stack: stack,
      );
      return null;
    }
  }

  Future<void> _viewFullImage() async {
    final pngBytes = await _captureBarcode();
    if (pngBytes == null) return;
    if (!mounted) return;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/barcode_${widget.barcode}.png');
    await file.writeAsBytes(pngBytes);
    if (!mounted) return;
    ImageViewerDialog.showSingle(context, FileImage(file));
  }

  Future<pw.Document?> _buildPdfDoc() async {
    final pngBytes = await _captureBarcode();
    if (pngBytes == null) return null;
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm,
          40 * PdfPageFormat.mm,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              widget.productName,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Image(pw.MemoryImage(pngBytes)),
            pw.SizedBox(height: 2),
            pw.Text(widget.barcode, style: const pw.TextStyle(fontSize: 7)),
          ],
        ),
      ),
    );
    return doc;
  }

  Future<bool> _saveAsPdf() async {
    try {
      final doc = await _buildPdfDoc();
      if (doc == null) return false;
      final pdfBytes = await doc.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/barcode_${widget.barcode}.pdf');
      await file.writeAsBytes(pdfBytes);
      if (!mounted) return false;
      await Share.shareXFiles([XFile(file.path)]);
      return true;
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageWidget._saveAsPdf failed',
        error: e,
        stack: stack,
      );
      return false;
    }
  }

  Future<bool> _print() async {
    try {
      final doc = await _buildPdfDoc();
      if (doc == null) return false;
      await Printing.layoutPdf(onLayout: (_) async => doc.save());
      return true;
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageWidget._print failed',
        error: e,
        stack: stack,
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: _resolveType(),
                    data: widget.barcode,
                    width: double.infinity,
                    height: 80,
                    color: Colors.black,
                    errorBuilder: (_, error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l10n.unsupportedFormat,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.barcode,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 1.2,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BarcodeActionButton(
                icon: Icons.zoom_out_map,
                label: l10n.barcodeViewFull,
                onTap: _viewFullImage,
              ),
              _BarcodeActionButton(
                icon: Icons.save_alt,
                label: l10n.barcodeSave,
                onTap: _saveAsPdf,
                successMessage: l10n.barcodeSavedSuccess,
                errorMessage: l10n.barcodeSaveError,
              ),
              _BarcodeActionButton(
                icon: Icons.print_outlined,
                label: l10n.barcodePrint,
                onTap: _print,
                successMessage: l10n.barcodePrintedSuccess,
                errorMessage: l10n.barcodePrintError,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarcodeActionButton extends StatelessWidget {
  const _BarcodeActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.successMessage,
    this.errorMessage,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final String? successMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final sm = ScaffoldMessenger.of(context);
        try {
          await onTap();
          if (context.mounted && successMessage != null) {
            sm.showSnackBar(
              SnackBar(
                content: Text(successMessage!),
                duration: const Duration(milliseconds: 800),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            sm.showSnackBar(
              SnackBar(
                content: Text(errorMessage ?? label),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
