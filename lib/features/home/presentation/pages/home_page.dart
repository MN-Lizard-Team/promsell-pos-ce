import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/shell/main_shell_scope.dart';
import 'package:promsell_pos_ce/features/customer/presentation/pages/customer_list_page.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';
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
import 'package:promsell_pos_ce/features/report/presentation/pages/report_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Future<_HomeData>? _dataFuture;
  late final ProductBloc _productBloc;
  late final PromotionBloc _promotionBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = sl<ProductBloc>()..add(const ProductsSubscribed());
    _promotionBloc = sl<PromotionBloc>()..add(const PromotionsSubscribed());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      HomePage.routeObserver.subscribe(this, route);
    }
    _dataFuture ??= _loadHomeData();
  }

  @override
  void dispose() {
    HomePage.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _dataFuture = _loadHomeData();
    setState(() {});
  }

  Future<_HomeData> _loadHomeData() async {
    final saleRepo = sl<SaleRepository>();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.copyWith(
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
    );
    final weekStart = todayStart.subtract(const Duration(days: 6));

    final results = await Future.wait([
      saleRepo.getSales(from: todayStart, to: todayEnd),
      saleRepo.getSales(from: weekStart, to: todayEnd),
    ]);

    final todayTotals = SalesPeriodTotals.from(results[0]);
    final todayCompleted = results[0].where((s) => !s.isVoided).toList();

    final trendData = _buildTrendData(results[1], todayStart);
    final todayCost = _calculateCost(todayCompleted, _productBloc.state);

    final catalogReady = _isCatalogReady(_productBloc.state);
    return _HomeData(
      todayRevenue: todayTotals.netRevenue,
      trendData: trendData,
      todaySales: todayCompleted,
      todaySalesCount: todayTotals.salesCount,
      todayCost: todayCost,
      costReady: catalogReady,
    );
  }

  List<double> _buildTrendData(List<Sale> weekSales, DateTime todayStart) {
    final dailyRevenue = List<double>.filled(7, 0.0);
    for (final sale in weekSales) {
      if (sale.isVoided) continue;
      final dayDiff = todayStart
          .difference(
            DateTime(
              sale.createdAt.year,
              sale.createdAt.month,
              sale.createdAt.day,
            ),
          )
          .inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        dailyRevenue[6 - dayDiff] += sale.totalAmount.value;
      }
    }
    return dailyRevenue;
  }

  /// Catalog has settled (success/failure) so cost join is intentional, not a race.
  static bool _isCatalogReady(ProductState productState) {
    return productState.status == ProductStatus.success ||
        productState.status == ProductStatus.failure;
  }

  static Money _calculateCost(
    List<Sale> todaySales,
    ProductState productState,
  ) {
    final costById = <String, Money>{};
    for (final p in productState.products) {
      costById[p.id] = p.cost;
    }
    var totalCost = Money.zero;
    for (final sale in todaySales) {
      for (final item in sale.items) {
        final cost = costById[item.productId] ?? Money.zero;
        totalCost = totalCost + cost * item.qty;
      }
    }
    return totalCost;
  }

  void _retryLoad() {
    _dataFuture = _loadHomeData();
    setState(() {});
  }

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
        // Keep push so History opens Report sales tab (shell tab is overview).
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ReportPage(initialTabIndex: 1),
          ),
        );
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

    final bottomNavHeight = kBottomNavigationBarHeight;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final headerContentHeight = viewPadding.top + 16 + 72;
    final headerOverlap = 0;
    final spacerHeight = headerContentHeight + headerOverlap;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            _dataFuture = _loadHomeData();
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
                    FutureBuilder<_HomeData>(
                      future: _dataFuture,
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        final isLoading =
                            snapshot.connectionState ==
                                ConnectionState.waiting &&
                            data == null;
                        final hasError = snapshot.hasError && data == null;
                        final l10n = context.l10n;
                        final catalogReady = _isCatalogReady(
                          _productBloc.state,
                        );
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
                              isLoading: isLoading || hasError,
                              onTap: () => WidgetsBinding.instance
                                  .addPostFrameCallback((_) {
                                    MainShellScope.maybeOf(context)?.goToTab(3);
                                  }),
                            ),
                            const SizedBox(height: 8),
                            HomeStatsRow(
                              revenue: revenue,
                              cost: cost,
                              profit: profit,
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
                      onTap: (item) => _onMenuTap(item, context),
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
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.todayRevenue,
    required this.trendData,
    required this.todaySales,
    required this.todaySalesCount,
    required this.todayCost,
    required this.costReady,
  });

  final Money todayRevenue;
  final List<double> trendData;
  final List<Sale> todaySales;
  final int todaySalesCount;
  final Money todayCost;

  /// False while product catalog is still loading — cost/profit must not show as 0.
  final bool costReady;
}
