import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_panel.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/compact_cart_fab.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/cart_resize_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/drag_handle.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_app_bar_actions.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider.value(value: sl<CategoryBloc>()),
        BlocProvider.value(value: sl<CartBloc>()),
        BlocProvider.value(
          value: sl<DraftBloc>()..add(const DraftInitialized()),
        ),
        BlocProvider.value(value: sl<CheckoutBloc>()),
        BlocProvider(
          create: (_) => SearchHistoryCubit(
            sl<SettingsLocalDatasource>(),
            'sale_search_history',
          )..load(),
        ),
      ],
      child: const _SaleView(),
    );
  }
}

class _SaleView extends StatefulWidget {
  const _SaleView();

  @override
  State<_SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<_SaleView> {
  late final CartResizeController _resize;

  bool _hasStockOrPriceChange(List<Product> prev, List<Product> curr) {
    final prevMap = {for (final p in prev) p.id: p};
    for (final c in curr) {
      final p = prevMap[c.id];
      if (p == null) return true;
      if (p.stock != c.stock ||
          p.price != c.price ||
          p.isActive != c.isActive) {
        return true;
      }
    }
    return prev.length != curr.length;
  }

  @override
  void initState() {
    super.initState();
    _resize = CartResizeController();
  }

  @override
  void dispose() {
    _resize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final isExpanded =
        AdaptiveBreakpoints.isExpanded(context) ||
        (isLandscape && size.width >= 600);
    final compactCart = context.select(
      (SettingsCubit c) => c.state.settings.cartCompactMode,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) =>
              curr.status == ProductStatus.success &&
              prev.products != curr.products &&
              _hasStockOrPriceChange(prev.products, curr.products),
          listener: (context, state) {
            context.read<CartBloc>().add(CartProductsRefreshed(state.products));
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) =>
              prev.stockWarning != curr.stockWarning &&
              curr.stockWarning != null,
          listener: (context, state) {
            AppSnackBar.info(context, state.stockWarning!);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) =>
              prev.errorNonce != curr.errorNonce && curr.errorMessage != null,
          listener: (context, state) {
            final l10n = context.l10n;
            final msg = state.errorMessage == 'barcodeNotFound'
                ? l10n.barcodeNotFound
                : state.errorMessage == 'errorOccurred'
                ? l10n.errorOccurred
                : state.errorMessage!;
            AppSnackBar.error(context, msg);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) => prev.items != curr.items,
          listener: (context, state) {
            context.read<DraftBloc>().add(DraftAutoSaveRequested(state));
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.salePageTitle),
          actions: const [SaleAppBarActions()],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, isExpanded ? 12 : 8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: compactCart
                      ? const SaleCatalog()
                      : (isExpanded
                            ? _buildExpandedLayout()
                            : _buildCompactLayout()),
                ),
                if (compactCart) const CompactCartFab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCartH =
            (constraints.maxHeight * _resize.maxCartHeight(context) / 1 - 24)
                .clamp(_resize.minCartHeight(context), double.infinity);
        return Column(
          children: [
            const Expanded(child: SaleCatalog()),
            DragHandle(
              axis: Axis.vertical,
              isDragging: _resize.isDragging,
              semanticLabel: context.l10n.dragToResizeCart,
              onDragStart: _resize.onDragStart,
              onDragEnd: _resize.onDragEnd,
              onVerticalDragUpdate: (d) => _resize.onVerticalDrag(context, d),
              onVerticalDragEnd: (d) => _resize.onVerticalDragEnd(context, d),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _resize.cartHeight,
              builder: (context, cartHeight, _) {
                final effectiveH = cartHeight.clamp(
                  _resize.minCartHeight(context),
                  maxCartH,
                );
                return SizedBox(
                  height: effectiveH,
                  child: CartPanel(
                    expanded: false,
                    sizePreset: _resize.currentSizePreset(context),
                    onSizePresetChanged: (v) =>
                        _resize.onSizePresetChanged(context, v),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: SaleCatalog()),
        DragHandle(
          axis: Axis.horizontal,
          isDragging: _resize.isDragging,
          semanticLabel: context.l10n.dragToResizeCart,
          onDragStart: _resize.onDragStart,
          onDragEnd: _resize.onDragEnd,
          onHorizontalDragUpdate: (d) => _resize.onHorizontalDrag(context, d),
          onHorizontalDragEnd: _resize.onHorizontalDragEnd,
        ),
        ValueListenableBuilder<double>(
          valueListenable: _resize.cartWidth,
          builder: (context, cartWidth, child) {
            return SizedBox(
              width: cartWidth,
              child: CartPanel(
                expanded: true,
                widthPreset: _resize.currentWidthPreset(),
                onWidthPresetChanged: _resize.onWidthPresetChanged,
              ),
            );
          },
        ),
      ],
    );
  }
}
