import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/repositories/report_repository.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/get_report_summary.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

/// Report period controller.
///
/// Data-path design (bounded-memory refactor):
///
/// * Ranges spanning **≤ [maxHydratedSpanDays] days** keep the original
///   fully-hydrated [WatchReport] path (`List<Sale>` + Dart calculator).
///   At most ~a month of sales is held in memory, which the cache eviction
///   below caps further.
/// * Longer ranges subscribe to the SQL-aggregated
///   `ReportRepository.watchReportAggregate` stream instead. Every metric
///   (summary totals, daily/hourly revenue, top products, customer counts,
///   profit, PromptPay) is computed by SQLite over the satang columns and
///   only a bounded display list (5 newest PromptPay bills) is hydrated —
///   memory no longer scales with the number of sales in the window.
///   The previous-period net revenue for these ranges comes from the
///   [GetReportSummary] use case (one-shot per range change; a comparison
///   baseline does not need live reactivity).
///
/// The stale-while-revalidate [_CacheEntry] snapshot mechanism (TTL, LRU
/// count cap, and soft memory ceiling) is shared by both paths.
@lazySingleton
class ReportCubit extends Cubit<ReportState> {
  ReportCubit({
    required WatchReport watchReport,
    required ReportRepository reportRepository,
    required ReportCalculatorService calculator,
    required GetReportSummary getReportSummary,
  }) : _watchReport = watchReport,
       _reportRepository = reportRepository,
       _calculator = calculator,
       _getReportSummary = getReportSummary,
       super(
         ReportState(
           from: DateRangePresets.today().$1,
           to: DateRangePresets.today().$2,
         ),
       );

  final WatchReport _watchReport;
  final ReportRepository _reportRepository;
  final ReportCalculatorService _calculator;
  final GetReportSummary _getReportSummary;
  StreamSubscription? _sub;
  StreamSubscription? _aggregateSub;
  StreamSubscription? _previousSub;
  StreamSubscription? _tableSub;

  /// Longest range still served through full hydration. Beyond this the
  /// SQL-aggregate path keeps memory bounded regardless of sales volume.
  static const int maxHydratedSpanDays = 31;

  /// Cached productId → Product map for profit/margin calculations.
  /// Refreshed on each new range subscription so deleted/updated products
  /// are reflected. Null while the first fetch is in flight.
  Map<String, Product>? _productLookup;

  /// Monotonic request id so late stream events from a cancelled range
  /// cannot overwrite the active period (Wave R1).
  int _rangeGen = 0;
  Future<void> _rangeQueue = Future<void>.value();

  /// Stale-while-revalidate snapshot only — never skip live subscription.
  /// Entries expire after [_cacheTtl] to avoid showing stale data when the
  /// user re-visits a range after a long absence.
  final Map<String, _CacheEntry> _cache = {};

  /// Home deep-link: switch Report shell page to History sub-tab.
  final _tabRequests = StreamController<int>.broadcast();
  Stream<int> get tabRequests => _tabRequests.stream;
  int? _pendingTabIndex;

  static String _cacheKey(DateTime from, DateTime to) =>
      '${DateTime(from.year, from.month, from.day).millisecondsSinceEpoch}|'
      '${DateTime(to.year, to.month, to.day).millisecondsSinceEpoch}';

  /// Cache validity window. Entries older than this are treated as misses.
  static const _cacheTtl = Duration(minutes: 5);

  /// Maximum number of cached report ranges (LRU by storedAt).
  static const _maxCachedRanges = 10;

  /// Soft memory ceiling for cached report data (bytes). When the total
  /// estimated size of cached entries exceeds this, entries are evicted
  /// oldest-first regardless of [_maxCachedRanges]. Prevents unbounded
  /// memory growth when the user browses many long date ranges.
  static const _maxCacheMemoryBytes = 50 * 1024 * 1024; // 50 MB

  /// Request History sub-tab (works even when ReportPage is already mounted).
  void requestHistoryTab() {
    if (_tabRequests.hasListener) {
      if (!_tabRequests.isClosed) _tabRequests.add(1);
      return;
    }
    _pendingTabIndex = 1;
  }

  /// Consumes a pending sub-tab index once (init / first frame).
  int? takePendingTabIndex() {
    final v = _pendingTabIndex;
    _pendingTabIndex = null;
    return v;
  }

  /// Resets range to today and (re)subscribes. Call when opening Report page.
  Future<void> openToday() async {
    final range = DateRangePresets.today();
    await changeDateRange(range.$1, range.$2);
  }

  Future<void> load() async {
    final from = state.from ?? DateRangePresets.today().$1;
    final to = state.to ?? DateRangePresets.today().$2;
    // Pull-to-refresh must re-subscribe (force miss).
    await changeDateRange(from, to, forceRefresh: true);
  }

  /// Changes the active period and attaches a live subscription for it:
  /// hydrated [WatchReport] within the span threshold, SQL aggregates beyond.
  ///
  /// [forceRefresh] skips showing cached data during loading (still re-watches).
  Future<void> changeDateRange(
    DateTime from,
    DateTime to, {
    bool forceRefresh = false,
  }) {
    final request = _rangeQueue.then((_) {
      return _changeDateRangeNow(from, to, forceRefresh: forceRefresh);
    });
    _rangeQueue = request.catchError((Object error, StackTrace stack) {
      AppLogger.error(
        'ReportCubit._rangeQueue failed',
        error: error,
        stack: stack,
      );
    });
    return request;
  }

  Future<void> _changeDateRangeNow(
    DateTime from,
    DateTime to, {
    required bool forceRefresh,
  }) async {
    if (to.isBefore(from)) {
      final swapped = from;
      from = to;
      to = swapped;
    }
    final key = _cacheKey(from, to);
    final gen = ++_rangeGen;

    await _sub?.cancel();
    await _aggregateSub?.cancel();
    await _previousSub?.cancel();
    await _tableSub?.cancel();
    if (isClosed || gen != _rangeGen) return;
    _sub = null;
    _aggregateSub = null;
    _previousSub = null;
    _tableSub = null;
    _subscribeTableStats(from: from, to: to, gen: gen);

    final useSqlPath = (to.difference(from).inDays + 1) > maxHydratedSpanDays;

    if (useSqlPath) {
      await _subscribeAggregate(key: key, from: from, to: to, gen: gen);
      return;
    }

    // Refresh product cost lookup for profit analytics (fire-and-forget;
    // _applySales will use whatever is available and re-emit when it lands).
    unawaited(_refreshProductLookup(gen));

    final cached = forceRefresh ? null : _cache[key]?.dataIfFresh;
    final span = to.difference(from).inDays + 1;
    final previousTo = from.subtract(const Duration(days: 1));
    final previousFrom = previousTo.subtract(Duration(days: span - 1));
    emit(
      state.copyWith(
        from: from,
        to: to,
        status: cached == null ? ReportStatus.loading : ReportStatus.success,
        sales: cached?.sales ?? const [],
        previousSales: const [],
        aggregate: null,
        previousSummary: null,
        dailyRevenue: cached?.dailyRevenue ?? const [],
        profit: cached?.profit,
        previousProfit: null,
      ),
    );

    final subscription = _watchReport(from: from, to: to).listen(
      (sales) {
        if (isClosed || gen != _rangeGen) return;
        _applySales(key, from, to, sales, gen);
      },
      onError: (e) {
        AppLogger.error('ReportCubit.changeDateRange failed', error: e);
        if (isClosed || gen != _rangeGen) return;
        emit(
          state.copyWith(
            status: ReportStatus.failure,
            sales: const [],
            dailyRevenue: const [],
            profit: null,
            previousProfit: null,
          ),
        );
      },
    );
    if (isClosed || gen != _rangeGen) {
      await subscription.cancel();
      return;
    }
    _sub = subscription;

    _previousSub = _watchReport(from: previousFrom, to: previousTo).listen(
      (previousSales) {
        if (isClosed || gen != _rangeGen) return;
        emit(state.copyWith(previousSales: previousSales));
      },
      onError: (error) {
        AppLogger.error('ReportCubit.previousPeriod failed', error: error);
        if (isClosed || gen != _rangeGen) return;
        // Clear previous sales so the UI doesn't show stale comparison data
        // when the previous period query failed.
        emit(state.copyWith(previousSales: const [], previousProfit: null));
      },
    );
  }

  void _subscribeTableStats({
    required DateTime from,
    required DateTime to,
    required int gen,
  }) {
    _tableSub = _reportRepository
        .watchTableSalesStats(from: from, to: to)
        .listen(
          (rows) {
            if (isClosed || gen != _rangeGen) return;
            emit(state.copyWith(tableBreakdown: rows));
          },
          onError: (Object error, StackTrace stack) {
            AppLogger.error(
              'ReportCubit.tableBreakdown failed',
              error: error,
              stack: stack,
            );
            if (!isClosed && gen == _rangeGen) {
              emit(state.copyWith(tableBreakdown: const []));
            }
          },
        );
  }

  /// one-shot SQL summary for the previous period (hero-card comparison).
  Future<void> _subscribeAggregate({
    required String key,
    required DateTime from,
    required DateTime to,
    required int gen,
  }) async {
    final cached = _cache[key];
    final cachedAggregate = cached?.aggregateIfFresh;
    final cachedData = cached?.dataIfFresh;
    emit(
      state.copyWith(
        from: from,
        to: to,
        status: cachedData == null && cachedAggregate == null
            ? ReportStatus.loading
            : ReportStatus.success,
        aggregate: cachedAggregate,
        previousSummary: null,
        previousSales: const [],
        sales: const [],
        dailyRevenue: cachedData?.dailyRevenue ?? const [],
        profit: cachedData?.profit,
        previousProfit: null,
      ),
    );

    final span = to.difference(from).inDays + 1;
    final previousTo = from.subtract(const Duration(days: 1));
    final previousFrom = previousTo.subtract(Duration(days: span - 1));

    // Deliberate wiring of GetReportSummary: a comparison baseline only
    // changes when the selected range changes, so a one-shot query is
    // enough — no table-update subscription needed for it.
    unawaited(
      _getReportSummary(from: previousFrom, to: previousTo)
          .then((summary) {
            if (isClosed || gen != _rangeGen) return;
            emit(state.copyWith(previousSummary: summary));
          })
          .catchError((Object e) {
            AppLogger.error('ReportCubit.previousSummary failed', error: e);
          }),
    );

    final subscription = _reportRepository
        .watchReportAggregate(from: from, to: to)
        .listen(
          (aggregate) {
            if (isClosed || gen != _rangeGen) return;
            _applyAggregate(key, from, to, aggregate, gen);
          },
          onError: (e) {
            AppLogger.error('ReportCubit.aggregate failed', error: e);
            if (isClosed || gen != _rangeGen) return;
            emit(state.copyWith(status: ReportStatus.failure));
          },
        );
    if (isClosed || gen != _rangeGen) {
      await subscription.cancel();
      return;
    }
    _aggregateSub = subscription;
  }

  void _applyAggregate(
    String key,
    DateTime from,
    DateTime to,
    ReportAggregate aggregate,
    int gen,
  ) {
    final profit = aggregate.profit ?? _buildProfit(state.sales);
    final data = ReportData(
      sales: const [],
      from: from,
      to: to,
      totals: aggregate.totals,
      dailyRevenue: aggregate.dailyRevenue,
      profit: aggregate.profit,
    );
    emit(
      state.copyWith(
        status: ReportStatus.success,
        aggregate: aggregate,
        // Hydrated list stays intentionally empty on this path — every
        // metric comes from [aggregate]; only its bounded display list
        // (5 newest PromptPay bills) carries raw Sale objects.
        sales: const [],
        dailyRevenue: aggregate.dailyRevenue,
        profit: profit,
        productLookup: _productLookup ?? const {},
        lastUpdated: DateTime.now(),
      ),
    );
    _cache[key] = _CacheEntry(
      data: data,
      storedAt: DateTime.now(),
      aggregate: aggregate,
    );
    _evictCache();
  }

  void _applySales(
    String key,
    DateTime from,
    DateTime to,
    List<Sale> sales,
    int gen,
  ) {
    final daily = _calculator.dailyRevenueBetween(sales, from, to);
    final profit = _buildProfit(sales);
    final data = ReportData(
      sales: sales,
      from: from,
      to: to,
      totals: _calculator.periodTotals(sales),
      dailyRevenue: daily,
      profit: profit,
      previousPeriod: state.previousSales.isEmpty
          ? null
          : ReportData(
              sales: state.previousSales,
              from: from.subtract(
                Duration(days: to.difference(from).inDays + 1),
              ),
              to: from.subtract(const Duration(days: 1)),
              totals: _calculator.periodTotals(state.previousSales),
              dailyRevenue: const [],
              profit: _buildProfit(state.previousSales),
            ),
    );
    emit(
      state.copyWith(
        status: ReportStatus.success,
        sales: sales,
        dailyRevenue: daily,
        profit: profit,
        previousProfit: data.previousPeriod?.profit,
        productLookup: _productLookup ?? const {},
        lastUpdated: DateTime.now(),
      ),
    );
    _cache[key] = _CacheEntry(data: data, storedAt: DateTime.now());
    _evictCache();
  }

  /// Evicts cache entries exceeding both count and memory limits.
  /// Oldest entries (by storedAt) are removed first.
  void _evictCache() {
    // Count-based eviction.
    while (_cache.length > _maxCachedRanges) {
      final oldest = _cache.entries.reduce(
        (a, b) => a.value.storedAt.isBefore(b.value.storedAt) ? a : b,
      );
      _cache.remove(oldest.key);
    }
    // Memory-based eviction: estimate bytes per entry from sales list size.
    // Each Sale with ~5 items is roughly ~1 KB (Equatable props + Money).
    var totalBytes = 0;
    for (final entry in _cache.values) {
      totalBytes += entry.estimatedBytes;
    }
    while (totalBytes > _maxCacheMemoryBytes && _cache.isNotEmpty) {
      final oldest = _cache.entries.reduce(
        (a, b) => a.value.storedAt.isBefore(b.value.storedAt) ? a : b,
      );
      totalBytes -= oldest.value.estimatedBytes;
      _cache.remove(oldest.key);
    }
  }

  /// Builds [ProfitAnalytics] for [sales] using the cached product lookup.
  /// Returns null when the lookup has not loaded yet.
  ProfitAnalytics? _buildProfit(List<Sale> sales) {
    final lookup = _productLookup;
    if (lookup == null) return null;
    if (sales.isEmpty) return ProfitAnalytics.empty;
    return _calculator.profitAnalytics(sales, lookup);
  }

  /// Fetches products that appear in the current period and stores them as a
  /// productId → Product map. Re-emits the current sales snapshot so profit
  /// metrics appear once the lookup lands, even if the sales stream has
  /// already delivered data.
  Future<void> _refreshProductLookup(int gen) async {
    try {
      final productIds = state.sales
          .expand((s) => s.items)
          .map((i) => i.productId)
          .toSet()
          .toList();
      // If no sales yet, fetch nothing — lookup will be empty until sales
      // arrive, then a subsequent range change will trigger a real fetch.
      final lookup = productIds.isEmpty
          ? <String, Product>{}
          : await _reportRepository.getProductCostLookup(productIds);
      if (isClosed || gen != _rangeGen) return;
      _productLookup = lookup;
      // Re-apply current sales so profit metrics are computed with the new
      // lookup. Only re-emit if we already have sales (success state).
      if (state.sales.isNotEmpty && state.status == ReportStatus.success) {
        final key = _cacheKey(state.from!, state.to!);
        _applySales(key, state.from!, state.to!, state.sales, gen);
      }
    } catch (e) {
      AppLogger.error('ReportCubit._refreshProductLookup failed', error: e);
    }
  }

  /// Drop all snapshots (e.g. after external invalidation hooks).
  void clearCache() => _cache.clear();

  @override
  Future<void> close() {
    _sub?.cancel();
    _aggregateSub?.cancel();
    _previousSub?.cancel();
    _tableSub?.cancel();
    _cache.clear();
    unawaited(_tabRequests.close());
    return super.close();
  }
}

/// Cache entry with a timestamp for TTL-based eviction.
class _CacheEntry {
  const _CacheEntry({
    required this.data,
    required this.storedAt,
    this.aggregate,
  });

  final ReportData data;
  final DateTime storedAt;

  /// SQL-aggregate bundle when this entry was produced by the long-range
  /// path; null for hydrated entries.
  final ReportAggregate? aggregate;

  /// Returns [data] if still within the TTL window, otherwise null.
  ReportData? get dataIfFresh {
    final age = DateTime.now().difference(storedAt);
    return age < ReportCubit._cacheTtl ? data : null;
  }

  /// Returns [aggregate] if still within the TTL window, otherwise null.
  ReportAggregate? get aggregateIfFresh {
    final age = DateTime.now().difference(storedAt);
    return age < ReportCubit._cacheTtl ? aggregate : null;
  }

  /// Rough memory estimate: ~1 KB per Sale (including items + payments).
  /// Aggregate-path snapshots carry no hydrated list, so they cost ~1 KB —
  /// small enough that only the count cap matters for them.
  int get estimatedBytes =>
      data.sales.isEmpty ? 1024 : data.sales.length * 1024;
}
