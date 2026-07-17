import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_search_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Search control for the product list app bar (sits on primary-colored bar).
///
/// Visual: white filled field + dark text/icons for contrast on teal primary.
class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({super.key, this.controller});

  final TextEditingController? controller;

  Future<void> _onScan(BuildContext context) async {
    final settings = context.read<SettingsCubit>().state.settings;
    final productBloc = context.read<ProductBloc>();
    final barcode = await showProductBarcodeScanner(
      context,
      beepOnScan: settings.barcodeBeepOnScan,
      formats: barcodeFormatsFromNames(settings.barcodeEnabledFormats),
      autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
      continuousScan: false,
      currency: settings.currency,
    );
    if (barcode == null || !context.mounted) return;

    final code = barcode.trim();
    controller?.text = code;
    productBloc.add(ProductSearchChanged(code));

    final exact = resolveExactBarcodeMatches(productBloc.state.products, code);
    if (exact.length == 1) {
      showProductPreviewPage(context, exact.first);
    } else if (exact.isEmpty) {
      final l10n = context.l10n;
      AppSnackBar.withAction(
        context,
        l10n.barcodeNotFound,
        actionLabel: l10n.createProductFromBarcode,
        onAction: () async {
          final product = await showProductCreatePageForResult(
            context,
            initialBarcode: code,
          );
          if (!context.mounted) return;
          if (product != null) {
            productBloc.add(ProductSearchChanged(code));
            showProductPreviewPage(context, product);
          }
        },
      );
    } else {
      AppSnackBar.info(
        context,
        context.l10n.barcodeAmbiguousCount(exact.length),
      );
    }
  }

  void _clearSearch(BuildContext context) {
    controller?.clear();
    context.read<ProductBloc>().add(const ProductSearchChanged(''));
  }

  void _navigateToSearch(BuildContext context) {
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
          child: const ProductSearchPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cs = theme.colorScheme;

    // Field sits on primary app bar → solid light surface + dark content.
    const fieldFill = Colors.white;
    final textColor = cs.onSurface;
    final muted = cs.onSurfaceVariant;

    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (p, c) => p.searchQuery != c.searchQuery,
      builder: (context, state) {
        final query = state.searchQuery.trim();
        if (controller != null && controller!.text != state.searchQuery) {
          controller!.value = TextEditingValue(
            text: state.searchQuery,
            selection: TextSelection.collapsed(
              offset: state.searchQuery.length,
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: Material(
                color: fieldFill,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _navigateToSearch(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: muted, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            query.isEmpty ? l10n.searchByNameSkuBarcode : query,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: query.isEmpty ? muted : textColor,
                              fontWeight: query.isEmpty
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('product-list-search-clear-btn'),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(48, 48),
                  maximumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.clear, size: 18),
                tooltip: l10n.clear,
                onPressed: () => _clearSearch(context),
              ),
            ],
            if (SearchSurfaceConfig.catalogListSticky.barcodeVisible(
              context.select(
                (SettingsCubit c) => c.state.settings.barcodeScanEnabled,
              ),
            )) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('product-list-scan-barcode'),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(48, 48),
                  maximumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                ),
                // Linear barcode scan (retail), not QR-frame glyph.
                icon: const Icon(Icons.barcode_reader, size: 18),
                onPressed: () => _onScan(context),
                tooltip: l10n.scanBarcode,
              ),
            ],
          ],
        );
      },
    );
  }
}
