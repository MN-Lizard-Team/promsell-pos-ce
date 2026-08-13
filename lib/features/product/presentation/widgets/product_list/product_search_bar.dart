import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/svg_icon.dart';
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

    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (p, c) => p.searchQuery != c.searchQuery,
      builder: (context, state) {
        final query = state.searchQuery.trim();
        if (controller != null && controller!.text != state.searchQuery) {
          // Preserve cursor position when the user is actively editing;
          // only force cursor to end when text was replaced externally.
          final oldText = controller!.text;
          final oldSel = controller!.selection;
          controller!.text = state.searchQuery;
          if (oldSel.isValid && oldText.isNotEmpty) {
            final newOffset = oldSel.baseOffset.clamp(
              0,
              state.searchQuery.length,
            );
            controller!.selection = TextSelection.collapsed(offset: newOffset);
          } else {
            controller!.selection = TextSelection.collapsed(
              offset: state.searchQuery.length,
            );
          }
        }

        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('product-open-search'),
            onTap: () => _navigateToSearch(context),
            borderRadius: BorderRadius.circular(12),
            child: Semantics(
              label: query.isEmpty
                  ? l10n.searchProducts
                  : '${l10n.searchActive}: $query',
              hint: l10n.tapToSearch,
              button: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 24, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        query.isEmpty ? l10n.searchProductsHint : query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontFamily: 'NotoSansThai',
                        ),
                      ),
                    ),
                    // Visual indicator that this is a navigation trigger, not
                    // an editable field — chevron-right makes it discoverable.
                    if (query.isEmpty)
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                    if (query.isNotEmpty)
                      IconButton(
                        tooltip: l10n.clear,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: Icon(
                          Icons.clear,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () => _clearSearch(context),
                      ),
                    if (SearchSurfaceConfig.catalogListSticky.barcodeVisible(
                      context.select(
                        (SettingsCubit c) =>
                            c.state.settings.barcodeScanEnabled,
                      ),
                    ))
                      IconButton(
                        tooltip: l10n.scanBarcode,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: SvgIcon(
                          'barcode-scan-icon',
                          size: 24,
                          color: cs.primary,
                        ),
                        onPressed: () => _onScan(context),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
