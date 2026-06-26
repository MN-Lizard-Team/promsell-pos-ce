import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/data/services/barcode_image_service.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:share_plus/share_plus.dart';

class BarcodeImageWidget extends StatefulWidget {
  const BarcodeImageWidget({
    super.key,
    required this.barcode,
    required this.productName,
    this.barcodeImagePath,
  });

  final String barcode;
  final String productName;
  final String? barcodeImagePath;

  @override
  State<BarcodeImageWidget> createState() => _BarcodeImageWidgetState();
}

class _BarcodeImageWidgetState extends State<BarcodeImageWidget> {
  final GlobalKey _repaintKey = GlobalKey();
  static final _barcodeImageService = BarcodeImageService();

  Barcode _resolveType() {
    final clean = widget.barcode.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'^\d{13}$').hasMatch(clean)) return Barcode.ean13();
    if (RegExp(r'^\d{8}$').hasMatch(clean)) return Barcode.ean8();
    if (RegExp(r'^\d{12}$').hasMatch(clean)) return Barcode.upcA();
    return Barcode.code128();
  }

  Future<Uint8List?> _captureBarcode() async {
    if (widget.barcodeImagePath != null) {
      try {
        final file = File(widget.barcodeImagePath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      } catch (e, stack) {
        AppLogger.error(
          'BarcodeImageWidget._captureBarcode read failed',
          error: e,
          stack: stack,
        );
      }
    }
    try {
      final context = _repaintKey.currentContext;
      if (context == null || !context.mounted) return null;
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

  Future<bool> _viewFullImage() async {
    if (widget.barcodeImagePath != null) {
      final file = File(widget.barcodeImagePath!);
      if (await file.exists()) {
        final viewContext = context;
        if (!viewContext.mounted) return false;
        ImageViewerDialog.showSingle(viewContext, FileImage(file));
        return true;
      }
    }
    final pngBytes = await _captureBarcode();
    if (pngBytes == null) return false;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/barcode_${widget.barcode}.png');
    await file.writeAsBytes(pngBytes);
    final viewContext = context;
    if (!viewContext.mounted) return false;
    ImageViewerDialog.showSingle(viewContext, FileImage(file));
    return true;
  }

  Future<bool> _copyBarcode() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.barcode));
      return true;
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageWidget._copyBarcode failed',
        error: e,
        stack: stack,
      );
      return false;
    }
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
      final viewContext = context;
      if (!viewContext.mounted) return false;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
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

  Future<bool> _saveAsImage(BarcodeImageFormat format) async {
    try {
      var pngBytes = await _captureBarcode();
      if (pngBytes == null) return false;
      var bytes = pngBytes;
      var ext = 'png';
      if (format == BarcodeImageFormat.jpeg) {
        final jpeg = await _barcodeImageService.encodeJpeg(pngBytes);
        if (jpeg == null) return false;
        bytes = jpeg;
        ext = 'jpg';
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/barcode_${widget.barcode}.$ext');
      await file.writeAsBytes(bytes);
      final viewContext = context;
      if (!viewContext.mounted) return false;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      return true;
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageWidget._saveAsImage failed',
        error: e,
        stack: stack,
      );
      return false;
    }
  }

  Future<bool> _showSaveOptions() async {
    final viewContext = context;
    final l10n = viewContext.l10n;
    final format = await showDialog<BarcodeImageFormat>(
      context: viewContext,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.barcodeSave),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, BarcodeImageFormat.png),
            child: const Text('PNG'),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(dialogContext, BarcodeImageFormat.jpeg),
            child: const Text('JPEG'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('PDF'),
          ),
        ],
      ),
    );
    if (format == null) return _saveAsPdf();
    return _saveAsImage(format);
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _hasSavedImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(widget.barcodeImagePath!),
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, error, stackTrace) =>
                            _buildBarcodeContent(context, theme, l10n),
                      ),
                    )
                  : _buildBarcodeContent(context, theme, l10n),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BarcodeActionButton(
                icon: Icons.copy,
                label: l10n.copyPromptpayId,
                onTap: _copyBarcode,
                successMessage: l10n.copyPromptpayId,
              ),
              _BarcodeActionButton(
                icon: Icons.zoom_out_map,
                label: l10n.barcodeViewFull,
                onTap: _viewFullImage,
                errorMessage: l10n.barcodeViewError,
              ),
              _BarcodeActionButton(
                icon: Icons.save_alt,
                label: l10n.barcodeSave,
                onTap: _showSaveOptions,
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

  bool get _hasSavedImage {
    final path = widget.barcodeImagePath;
    return path != null && path.isNotEmpty && File(path).existsSync();
  }

  Widget _buildBarcodeContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        BarcodeWidget(
          barcode: _resolveType(),
          data: widget.barcode,
          width: double.infinity,
          height: 120,
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
  final Future<bool> Function() onTap;
  final String? successMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () async {
            final sm = ScaffoldMessenger.of(context);
            try {
              final success = await onTap();
              if (!context.mounted) return;
              if (success && successMessage != null) {
                sm.showSnackBar(
                  SnackBar(
                    content: Text(successMessage!),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              } else if (!success && errorMessage != null) {
                sm.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage!),
                    duration: const Duration(seconds: 2),
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
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
