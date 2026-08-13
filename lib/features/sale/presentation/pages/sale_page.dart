import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_product_search_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/barcode_wedge_listener.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_app_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_bloc_listeners.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_day_closed_banner.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_delivery_layout.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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
            SearchSurfaceConfig.saleFullSearch.historyKey,
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
  final _isRestoringNotifier = ValueNotifier<bool>(false);

  /// Kept for [SaleCatalog] API; catalog search is empty while on Sale shell.
  final _searchController = TextEditingController();
  ViewMode _viewMode = ViewMode.list;

  Future<void> _openSaleSearch() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProductBloc>()),
            BlocProvider.value(value: context.read<CategoryBloc>()),
            BlocProvider.value(value: context.read<CartBloc>()),
            BlocProvider.value(value: context.read<SettingsCubit>()),
            BlocProvider.value(value: context.read<SearchHistoryCubit>()),
          ],
          child: const SaleProductSearchPage(),
        ),
      ),
    );
    if (!mounted) return;
    _searchController.clear();
    context.read<ProductBloc>().add(const ProductSearchChanged(''));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductBloc>().add(
        const ProductSurfaceEntered(ProductSurface.sale),
      );
    });
  }

  @override
  void dispose() {
    _isRestoringNotifier.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    disposeTextEditingControllerAfterFrame(_searchController);
    try {
      sl<ProductBloc>().add(const ProductSearchChanged(''));
    } on StateError {
      // Bloc already closed — safe to ignore during dispose.
    }
    super.dispose();
  }

  ProductBloc _resolveProductBloc(BuildContext context) {
    try {
      return context.read<ProductBloc>();
    } catch (_) {
      return sl<ProductBloc>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productBloc = _resolveProductBloc(context);
    final pos = context.posTheme;

    return SaleBlocListeners(
      productBloc: productBloc,
      isRestoring: _isRestoringNotifier,
      onRestoringReset: () => _isRestoringNotifier.value = false,
      child: BarcodeWedgeListener(
        enabled: context
            .watch<SettingsCubit>()
            .state
            .settings
            .barcodeScanEnabled,
        onBarcode: (code) {
          context.read<CartBloc>().add(CartBarcodeScanned(code));
        },
        child: Scaffold(
          backgroundColor: pos.catalogBackground,
          appBar: SaleAppBar(onSearchTap: _openSaleSearch),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SaleDayClosedBanner(),
                Expanded(
                  child: Padding(
                    padding: pos.catalogPadding,
                    child: SaleDeliveryLayout(
                      searchController: _searchController,
                      viewMode: _viewMode,
                      onViewModeChanged: (v) => setState(() => _viewMode = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
