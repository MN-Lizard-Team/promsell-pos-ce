import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/core/widgets/sticky_action_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart'
    show parseCategoryIcon;
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductPreviewPage extends StatelessWidget {
  const ProductPreviewPage({super.key, required this.product});

  final Product product;

  void _showEdit(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: ProductFormPage(product: product),
        ),
      ),
    );
  }

  Future<void> _editStock(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.stock,
      initialValue: product.stock.toString(),
      productName: product.name,
    );
    if (!context.mounted) return;
    final stock = int.tryParse(result ?? '');
    if (stock != null && stock >= 0 && stock != product.stock) {
      context.read<ProductBloc>().add(
        ProductUpdated(product.copyWith(stock: stock)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final catState = context.watch<CategoryBloc>().state;
    final cat = catState.categories
        .where((c) => c.id == product.categoryId)
        .firstOrNull;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      bottomNavigationBar: StickyActionBar(
        primaryLabel: l10n.edit,
        onPrimary: () => _showEdit(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(product: product, category: cat),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PriceCard(product: product, currency: currency),
                  const SizedBox(height: 12),
                  _StockCard(
                    product: product,
                    currency: currency,
                    onEditStock: () => _editStock(context),
                  ),
                  const SizedBox(height: 12),
                  _CodesCard(product: product),
                  const SizedBox(height: 12),
                  _SystemInfoCard(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Hero — image with gradient overlay, name, category, status
// ──────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.product, this.category});
  final Product product;
  final Category? category;

  bool get _hasImage =>
      (product.imagePath != null && product.imagePath!.isNotEmpty) ||
      (product.imageUrl != null && product.imageUrl!.isNotEmpty);

  void _showFullImage(BuildContext context) {
    if (!_hasImage) return;
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: product.imagePath,
        imageUrl: product.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final style = category != null
        ? CategoryStyleResolver.resolve(category!.name)
        : null;

    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _hasImage
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      style?.color.withValues(alpha: 0.3) ??
                          theme.colorScheme.primaryContainer,
                      style?.color.withValues(alpha: 0.1) ??
                          theme.colorScheme.tertiaryContainer,
                    ],
                  ),
          ),
          child: _hasImage
              ? GestureDetector(
                  onTap: () => _showFullImage(context),
                  child: _buildImage(),
                )
              : Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 80,
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (category != null) ...[
                      Icon(
                        parseCategoryIcon(category!.iconName),
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category!.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ] else
                      Text(
                        l10n.noCategory,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    const Spacer(),
                    _StatusChip(active: product.isActive),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      return Image.file(
        File(product.imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return CachedNetworkImage(
      imageUrl: product.imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = active ? Colors.green : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.visibility_off_outlined,
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            active ? l10n.productPreviewActive : l10n.inactive,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Price — 3 stat tiles: Selling Price, Cost, Margin
// ──────────────────────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.product, required this.currency});
  final Product product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final profit = product.price - product.cost;
    final marginPct = product.price > 0 ? (profit / product.price * 100) : 0.0;

    return _Card(
      icon: Icons.payments_outlined,
      title: l10n.tabPrice,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.sellingPrice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                MoneyText(
                  value: product.price,
                  currency: currency,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.productPreviewCost,
                  value: MoneyText(
                    value: product.cost,
                    currency: currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: l10n.profit,
                  value: Row(
                    children: [
                      MoneyText(
                        value: profit,
                        currency: currency,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: profit >= 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${marginPct.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: profit >= 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  icon: profit >= 0 ? Icons.trending_up : Icons.trending_down,
                  iconColor: profit >= 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });
  final String label;
  final Widget value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          value,
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Stock — big number, status, stock value, edit button
// ──────────────────────────────────────────────────────────────
class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.product,
    required this.currency,
    this.onEditStock,
  });
  final Product product;
  final String currency;
  final VoidCallback? onEditStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final stockInfo = _resolveStock(context);
    final stockValue = product.stock * product.cost;

    return _Card(
      icon: Icons.inventory_2_outlined,
      title: l10n.tabStock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.trackStock)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: stockInfo.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.stock.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: stockInfo.color,
                          fontSize: 26,
                        ),
                      ),
                      Text(
                        l10n.quantityLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: stockInfo.color.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            stockInfo.icon,
                            size: 16,
                            color: stockInfo.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stockInfo.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: stockInfo.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: l10n.productPreviewStockValue,
                        value: MoneyText(
                          value: stockValue,
                          currency: currency,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (onEditStock != null)
                        FilledButton.tonalIcon(
                          onPressed: onEditStock,
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(l10n.edit),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.disabled,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) _resolveStock(
    BuildContext context,
  ) {
    final l10n = context.l10n;
    if (product.stock == 0) {
      return (
        color: Theme.of(context).colorScheme.error,
        icon: Icons.error,
        label: l10n.outOfStock,
      );
    }
    if (product.stock <= 5) {
      return (
        color: Theme.of(context).colorScheme.tertiary,
        icon: Icons.warning,
        label: l10n.lowStock,
      );
    }
    return (
      color: Theme.of(context).colorScheme.primary,
      icon: Icons.check_circle,
      label: l10n.lowStockWarning.replaceAll(' warning', ''),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Codes — SKU, Barcode, Barcode image with actions
// ──────────────────────────────────────────────────────────────
class _CodesCard extends StatelessWidget {
  const _CodesCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSku = product.sku != null && product.sku!.isNotEmpty;
    final hasBarcode = product.barcode != null && product.barcode!.isNotEmpty;

    return _Card(
      icon: Icons.qr_code_2,
      title: l10n.skuLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: l10n.skuLabel,
            value: SelectableText(
              hasSku ? product.sku! : l10n.na,
              style: _valueStyle(context, dimmed: !hasSku),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: l10n.barcodeLabel,
            value: SelectableText(
              hasBarcode ? product.barcode! : l10n.na,
              style: _valueStyle(context, dimmed: !hasBarcode),
            ),
          ),
          if (hasBarcode) ...[
            const SizedBox(height: 12),
            _BarcodeImage(barcode: product.barcode!, productName: product.name),
          ],
        ],
      ),
    );
  }

  TextStyle _valueStyle(BuildContext context, {bool dimmed = false}) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: dimmed
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface,
        ) ??
        const TextStyle();
  }
}

// ──────────────────────────────────────────────────────────────
// Barcode image + actions (view, save, print)
// ──────────────────────────────────────────────────────────────
class _BarcodeImage extends StatefulWidget {
  const _BarcodeImage({required this.barcode, required this.productName});
  final String barcode;
  final String productName;

  @override
  State<_BarcodeImage> createState() => _BarcodeImageState();
}

class _BarcodeImageState extends State<_BarcodeImage> {
  final GlobalKey _repaintKey = GlobalKey();

  Barcode _resolveType() {
    final clean = widget.barcode.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'^\d{13}$').hasMatch(clean)) return Barcode.ean13();
    if (RegExp(r'^\d{8}$').hasMatch(clean)) return Barcode.ean8();
    if (RegExp(r'^\d{12}$').hasMatch(clean)) return Barcode.upcA();
    return Barcode.code128();
  }

  Future<Uint8List> _captureBarcode() async {
    final boundary =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _viewFullImage() async {
    final pngBytes = await _captureBarcode();
    if (!mounted) return;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/barcode_${widget.barcode}.png');
    await file.writeAsBytes(pngBytes);
    if (!mounted) return;
    ImageViewerDialog.showSingle(context, FileImage(file));
  }

  Future<pw.Document> _buildPdfDoc() async {
    final pngBytes = await _captureBarcode();
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

  Future<void> _saveAsPdf() async {
    final doc = await _buildPdfDoc();
    final pdfBytes = await doc.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/barcode_${widget.barcode}.pdf');
    await file.writeAsBytes(pdfBytes);
    if (!mounted) return;
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _print() async {
    final doc = await _buildPdfDoc();
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
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
                        'Unsupported format',
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
                showSnackBar: false,
              ),
              _BarcodeActionButton(
                icon: Icons.save_alt,
                label: l10n.barcodeSave,
                onTap: _saveAsPdf,
              ),
              _BarcodeActionButton(
                icon: Icons.print_outlined,
                label: l10n.barcodePrint,
                onTap: _print,
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
    this.showSnackBar = true,
  });
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final bool showSnackBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        if (!showSnackBar) {
          await onTap();
          return;
        }
        final sm = ScaffoldMessenger.of(context);
        await onTap();
        if (context.mounted) {
          sm.showSnackBar(
            SnackBar(
              content: Text(label),
              duration: const Duration(milliseconds: 800),
            ),
          );
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

// ──────────────────────────────────────────────────────────────
// System Info — product ID, created, updated
// ──────────────────────────────────────────────────────────────
class _SystemInfoCard extends StatelessWidget {
  const _SystemInfoCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );
    final timeFormat = DateFormat.Hm(
      Localizations.localeOf(context).languageCode,
    );

    return _Card(
      icon: Icons.info_outline,
      title: l10n.productPreviewSystemInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: l10n.productPreviewProductId,
            value: SelectableText(
              product.id,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: l10n.dateCreated,
            value: Text(
              '${dateFormat.format(product.createdAt)} ${timeFormat.format(product.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: l10n.dateUpdated,
            value: Text(
              '${dateFormat.format(product.updatedAt)} ${timeFormat.format(product.updatedAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, title: title),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }
}
