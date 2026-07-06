import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
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
import 'package:promsell_pos_ce/features/product/presentation/pages/product_list_page.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_bloc.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_event.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_state.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/pages/promotion_list_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/report_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';

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

    final todayCompleted = results[0].where((s) => !s.isVoided).toList();

    final todayRevenue = todayCompleted.fold(
      0.0,
      (sum, s) => sum + s.totalAmount,
    );

    final trendData = _buildTrendData(results[1], todayStart);

    return _HomeData(
      todayRevenue: todayRevenue,
      trendData: trendData,
      todaySales: todayCompleted,
      todaySalesCount: todayCompleted.length,
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
        dailyRevenue[6 - dayDiff] += sale.totalAmount;
      }
    }
    return dailyRevenue;
  }

  static double _calculateCost(
    List<Sale> todaySales,
    ProductState productState,
  ) {
    final costById = <String, double>{};
    for (final p in productState.products) {
      costById[p.id] = p.cost;
    }
    double totalCost = 0.0;
    for (final sale in todaySales) {
      for (final item in sale.items) {
        final cost = costById[item.productId] ?? 0.0;
        totalCost += cost * item.qty;
      }
    }
    return totalCost;
  }

  void _onMenuTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        sl<DraftBloc>().add(const DraftCreated());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalePage()),
        );
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListPage()),
        );
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerListPage()),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PromotionListPage()),
        );
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ReportPage(initialTabIndex: 1),
          ),
        );
      case 5:
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DailyClosePage(date: today)),
        );
      default:
        break;
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
                    onMenuTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
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
                            snapshot.connectionState == ConnectionState.waiting;
                        final hasError = snapshot.hasError;

                        return BlocBuilder<ProductBloc, ProductState>(
                          bloc: _productBloc,
                          builder: (context, productState) {
                            final revenue = data?.todayRevenue ?? 0;
                            final cost = data != null
                                ? _calculateCost(data.todaySales, productState)
                                : 0.0;
                            final profit = revenue - cost;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                HomeHeroDashboardCard(
                                  todayRevenue: revenue,
                                  todaySalesCount: data?.todaySalesCount ?? 0,
                                  trendData:
                                      data?.trendData ?? [0, 0, 0, 0, 0, 0, 0],
                                  isLoading: isLoading,
                                  onTap: () => WidgetsBinding.instance
                                      .addPostFrameCallback(
                                        (_) => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ReportPage(),
                                          ),
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                HomeStatsRow(
                                  revenue: revenue,
                                  cost: cost,
                                  profit: profit,
                                  isLoading: isLoading,
                                ),
                                if (hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Failed to load data',
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
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    HomeMenuGridTapHandler(
                      onTap: (i) => _onMenuTap(i, context),
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
  });

  final double todayRevenue;
  final List<double> trendData;
  final List<Sale> todaySales;
  final int todaySalesCount;
}
