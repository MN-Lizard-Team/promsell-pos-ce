import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/shell/main_shell_scope.dart';
import 'package:promsell_pos_ce/features/customer/presentation/pages/customer_list_page.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';
import 'package:promsell_pos_ce/features/home/domain/entities/home_data.dart';
import 'package:promsell_pos_ce/features/home/domain/usecases/load_home_data.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_header.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_hero_dashboard_card.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_menu_grid.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_promotion_banner.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_stats_row.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_bloc.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_event.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_state.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/pages/promotion_list_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Future<HomeData>? _dataFuture;
  late final ProductBloc _productBloc;
  late final PromotionBloc _promotionBloc;
  late final LoadHomeData _loadHomeData;
  DateTime? _lastFetchTime;
  ProductStatus? _lastCatalogStatus;

  @override
  void initState() {
    super.initState();
    _productBloc = sl<ProductBloc>()..add(const ProductsSubscribed());
    _promotionBloc = sl<PromotionBloc>()..add(const PromotionsSubscribed());
    _loadHomeData = sl<LoadHomeData>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      HomePage.routeObserver.subscribe(this, route);
    }
    _dataFuture ??= _fetchHomeData();
  }

  @override
  void dispose() {
    HomePage.routeObserver.unsubscribe(this);
    _promotionBloc.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    final now = DateTime.now();
    if (_lastFetchTime != null &&
        now.difference(_lastFetchTime!).inSeconds < 30) {
      return;
    }
    _dataFuture = _fetchHomeData();
    setState(() {});
  }

  Future<HomeData> _fetchHomeData() {
    _lastFetchTime = DateTime.now();
    return _loadHomeData();
  }

  void _retryLoad() {
    _dataFuture = _fetchHomeData();
    setState(() {});
  }

  void _onCatalogStateChanged(ProductState productState) {
    final newStatus = productState.status;
    if (newStatus == _lastCatalogStatus) return;
    _lastCatalogStatus = newStatus;
    if (newStatus == ProductStatus.success ||
        newStatus == ProductStatus.failure) {
      _dataFuture = _fetchHomeData();
      setState(() {});
    }
  }

  void _menuTapCallback(HomeMenuItem item) => _onMenuTap(item, context);

  void _onMenuTap(HomeMenuItem item, BuildContext context) {
    final shell = MainShellScope.maybeOf(context);
    switch (item) {
      case HomeMenuItem.sell:
        // Same as bottom-nav Sale: switch tab, keep cart (no silent clear).
        shell?.goToTab(2);
      case HomeMenuItem.products:
        shell?.goToTab(1);
      case HomeMenuItem.customers:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerListPage()),
        );
      case HomeMenuItem.promotions:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PromotionListPage()),
        );
      case HomeMenuItem.history:
        // Shell Report tab + History sub-tab (no second ReportPage push).
        sl<ReportCubit>().requestHistoryTab();
        shell?.goToTab(3);
      case HomeMenuItem.closeDay:
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DailyClosePage(date: today)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final l10n = context.l10n;

    final bottomNavHeight = kBottomNavigationBarHeight;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final headerContentHeight = viewPadding.top + 16 + 72;
    final headerOverlap = 0;
    final spacerHeight = headerContentHeight + headerOverlap;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocListener<ProductBloc, ProductState>(
          bloc: _productBloc,
          listenWhen: (prev, next) => prev.status != next.status,
          listener: (context, state) => _onCatalogStateChanged(state),
          child: RefreshIndicator(
            onRefresh: () async {
              _dataFuture = _fetchHomeData();
              setState(() {});
              await _dataFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomNavHeight + 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: HomeHeader(
                      shopName: settings.shopName,
                      onMenuTap: () {
                        MainShellScope.maybeOf(context)?.goToTab(4);
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: spacerHeight),
                      FutureBuilder<HomeData>(
                        future: _dataFuture,
                        builder: (context, snapshot) {
                          final data = snapshot.data;
                          final isLoading =
                              snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              data == null;
                          final hasError = snapshot.hasError && data == null;
                          final catalogReady =
                              _productBloc.state.status ==
                                  ProductStatus.success ||
                              _productBloc.state.status ==
                                  ProductStatus.failure;
                          final costReady =
                              (data?.costReady ?? false) || catalogReady;

                          // Fail-closed: never paint ฿0 as a real quiet day on error.
                          final revenue = hasError
                              ? Money.zero
                              : (data?.todayRevenue ?? Money.zero);
                          final cost = hasError
                              ? Money.zero
                              : (data?.todayCost ?? Money.zero);
                          final profit = revenue.subtractUnclamped(cost);
                          final metricsUnknown = hasError;
                          final costUnknown = !hasError && !costReady;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              HomeHeroDashboardCard(
                                todayRevenue: revenue,
                                todaySalesCount: hasError
                                    ? 0
                                    : (data?.todaySalesCount ?? 0),
                                trendData: hasError
                                    ? const [0, 0, 0, 0, 0, 0, 0]
                                    : (data?.trendData ??
                                          const [0, 0, 0, 0, 0, 0, 0]),
                                currency: settings.currency,
                                isLoading: isLoading || hasError,
                                onTap: () => WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                      MainShellScope.maybeOf(
                                        context,
                                      )?.goToTab(3);
                                    }),
                              ),
                              const SizedBox(height: 8),
                              HomeStatsRow(
                                revenue: revenue,
                                cost: cost,
                                profit: profit,
                                currency: settings.currency,
                                isLoading: isLoading,
                                metricsUnknown: metricsUnknown,
                                costUnknown: costUnknown,
                              ),
                              if (hasError)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    8,
                                    24,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.homeLoadError,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _retryLoad,
                                        child: Text(l10n.retry),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      HomeMenuGridTapHandler(
                        onTap: _menuTapCallback,
                        child: const HomeMenuGrid(),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<PromotionBloc, PromotionState>(
                        bloc: _promotionBloc,
                        builder: (context, state) {
                          final active = state.promotions
                              .where((p) => p.isCurrentlyActive)
                              .toList();
                          final promo = active.isNotEmpty ? active.first : null;
                          return HomePromotionBanner(
                            promotion: promo,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PromotionListPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
