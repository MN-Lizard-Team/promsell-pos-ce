import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/codes_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/product_preview_image.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/price_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/stock_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/system_info_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_mixin.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductPreviewPage extends StatefulWidget {
  const ProductPreviewPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductPreviewPage> createState() => _ProductPreviewPageState();
}

class _ProductPreviewPageState extends State<ProductPreviewPage>
    with QuickEditMixin {
  late Product _currentProduct;
  double _expandRatio = 1.0;
  double _imageAreaHeight = 0;
  double _swipeStartY = 0;
  double _swipeDeltaY = 0;

  @override
  Product get product => _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  Product _latestProduct() {
    final products = context.read<ProductBloc>().state.products;
    return products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => _currentProduct,
    );
  }

  void _showEdit(BuildContext context) {
    final latest = _latestProduct();
    showProductEditPage(context, latest);
  }

  Future<void> _editStock(BuildContext context) async {
    final latest = _latestProduct();
    if (latest != _currentProduct) {
      setState(() => _currentProduct = latest);
    }
    await quickEditStock(context);
  }

  void _confirmDelete(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.confirmDeleteProduct(widget.product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                ProductDeleted(widget.product.id),
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              AppSnackBar.info(context, l10n.productDeleted);
            },
            child: Text(
              l10n.delete,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleActive(BuildContext context) {
    final l10n = context.l10n;
    final latest = _latestProduct();
    context.read<ProductBloc>().add(
      ProductUpdated(latest.copyWith(isActive: !latest.isActive)),
    );
    AppSnackBar.info(
      context,
      latest.isActive ? l10n.productDeactivated : l10n.productActivated,
    );
  }

  void _showFullImage() {
    if (!ProductPreviewImage.hasImage(_currentProduct)) return;
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: _currentProduct.imagePath,
        imageUrl: _currentProduct.imageUrl,
      ),
    );
  }

  Future<void> _generateBarcode(BuildContext context) async {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;
    final prefix = settings.barcodeAutoGeneratePrefix;
    try {
      final barcode = await sl<GenerateBarcode>()(
        prefix: prefix,
        excludeId: widget.product.id,
      );
      if (!context.mounted) return;
      context.read<ProductBloc>().add(
        ProductUpdated(_currentProduct.copyWith(barcode: barcode)),
      );
      AppSnackBar.success(context, l10n.barcodeGenerated);
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, l10n.errorOccurred);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final catState = context.watch<CategoryBloc>().state;
    final productState = context.watch<ProductBloc>().state;

    final product = _currentProduct;
    final cat = catState.categories
        .where((c) => c.id == product.categoryId)
        .firstOrNull;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.32).clamp(200.0, 320.0);
    _imageAreaHeight = heroHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: StickyActionBar(
        primaryLabel: l10n.edit,
        onPrimary: () => _showEdit(context),
        secondaryLabel: l10n.tabStock,
        onSecondary: () => _editStock(context),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listenWhen: (prev, curr) =>
            (curr.saveStatus == ProductSaveStatus.saved &&
                prev.saveStatus != ProductSaveStatus.saved) ||
            (curr.saveStatus == ProductSaveStatus.error &&
                prev.saveStatus != ProductSaveStatus.error),
        listener: (context, state) {
          if (state.saveStatus == ProductSaveStatus.error &&
              state.errorMessage != null &&
              mounted) {
            AppSnackBar.error(context, context.l10n.productUpdateError);
            return;
          }
          final updated = state.products
              .where((p) => p.id == widget.product.id)
              .firstOrNull;
          if (updated != null && mounted) {
            setState(() => _currentProduct = updated);
          }
        },
        child: Listener(
          onPointerDown: (event) {
            if (event.position.dy <= _imageAreaHeight) {
              _swipeStartY = event.position.dy;
              _swipeDeltaY = 0;
            }
          },
          onPointerMove: (event) {
            if (_swipeStartY > 0) {
              _swipeDeltaY = _swipeStartY - event.position.dy;
            }
          },
          onPointerUp: (event) {
            if (_swipeStartY > 0 && _swipeDeltaY > 50) {
              HapticFeedback.lightImpact();
              _showFullImage();
            }
            _swipeStartY = 0;
            _swipeDeltaY = 0;
          },
          onPointerCancel: (_) {
            if (_swipeStartY > 0 && _swipeDeltaY > 50) {
              HapticFeedback.lightImpact();
              _showFullImage();
            }
            _swipeStartY = 0;
            _swipeDeltaY = 0;
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: heroHeight,
                pinned: true,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Color.lerp(
                  Theme.of(context).colorScheme.onSurface,
                  Colors.white,
                  _expandRatio,
                )!,
                leading: const BackButton(),
                actions: [
                  IconButton(
                    icon: Icon(
                      product.isActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    tooltip: product.isActive ? l10n.deactivate : l10n.activate,
                    onPressed: () => _toggleActive(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.delete,
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
                title: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color.lerp(
                      Theme.of(context).colorScheme.onSurface,
                      Colors.white,
                      _expandRatio,
                    ),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final hasImg = ProductPreviewImage.hasImage(product);
                    final expandRatio = hasImg
                        ? ((constraints.maxHeight - kToolbarHeight) /
                                  (heroHeight - kToolbarHeight))
                              .clamp(0.0, 1.0)
                        : 0.0;
                    if ((expandRatio - _expandRatio).abs() > 0.01) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _expandRatio = expandRatio);
                      });
                    }
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final baseScrim = isDark ? 0.3 : 0.35;
                    final scrimMax = isDark ? 0.3 : 0.6;
                    final scrimOpacity = (expandRatio * scrimMax).clamp(
                      0.0,
                      scrimMax,
                    );
                    return FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          ProductPreviewImage(
                            product: product,
                            category: cat,
                            height: heroHeight,
                          ),
                          PreviewOverlay(
                            product: product,
                            category: cat,
                            hasImage: hasImg,
                          ),
                          if (hasImg)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: kToolbarHeight * 2.5,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(
                                          alpha: baseScrim + scrimOpacity,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                bottom: productState.status == ProductStatus.loading
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(4),
                        child: LinearProgressIndicator(),
                      )
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PriceCard(product: product, currency: currency),
                      const SizedBox(height: 16),
                      StockCard(
                        product: product,
                        currency: currency,
                        onEditStock: () => _editStock(context),
                      ),
                      const SizedBox(height: 16),
                      CodesCard(
                        product: product,
                        onGenerateBarcode:
                            product.barcode == null || product.barcode!.isEmpty
                            ? () => _generateBarcode(context)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SystemInfoCard(product: product),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
