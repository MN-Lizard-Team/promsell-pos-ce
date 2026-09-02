import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/get_sale_history_page.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_search_page.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_tab_view.dart';
import 'package:promsell_pos_ce/features/report/data/services/report_export_service.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/export/report_export_sheet.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_overview_body.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class _ReportTabSelector extends StatelessWidget {
  const _ReportTabSelector({
    required this.controller,
    required this.scheme,
    required this.reportLabel,
    required this.historyLabel,
  });

  final TabController controller;
  final ColorScheme scheme;
  final String reportLabel;
  final String historyLabel;

  @override
  Widget build(BuildContext context) {
    final selected = controller.index;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: selected == 0 ? reportLabel : historyLabel,
      child: Material(
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: _ReportTabButton(
                  label: reportLabel,
                  icon: TablerIcons.chartBar,
                  selected: selected == 0,
                  foregroundColor: selected == 0
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  backgroundColor: selected == 0
                      ? scheme.primary
                      : Colors.transparent,
                  onPressed: () => controller.animateTo(0),
                ),
              ),
              Expanded(
                child: _ReportTabButton(
                  label: historyLabel,
                  icon: TablerIcons.receipt,
                  selected: selected == 1,
                  foregroundColor: selected == 1
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  backgroundColor: selected == 1
                      ? scheme.primary
                      : Colors.transparent,
                  onPressed: () => controller.animateTo(1),
                  buttonKey: const Key(TestKeys.historySubTabButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTabButton extends StatelessWidget {
  const _ReportTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
    this.buttonKey,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  /// Stable E2E anchor (test-only, additive).
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: backgroundColor,
        child: InkWell(
          key: buttonKey,
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: foregroundColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontFamily: 'NotoSansThai',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, this.initialTabIndex});

  final int? initialTabIndex;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  late final ReportCubit _cubit;
  late final HistoryBloc _historyBloc;
  final _exportService = ReportExportService(sl<AppLockService>());
  StreamSubscription<int>? _tabRequestSub;
  bool _isExporting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ReportCubit>();
    _historyBloc = HistoryBloc(
      getSaleHistoryPage: sl<GetSaleHistoryPage>(),
      watchSaleHistory: sl<WatchSaleHistory>(),
      voidSale: sl<VoidSale>(),
    );
    final pending = _cubit.takePendingTabIndex();
    final initial = pending ?? widget.initialTabIndex?.clamp(0, 1) ?? 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initial,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _tabRequestSub = _cubit.tabRequests.listen((index) {
      if (!mounted) return;
      final i = index.clamp(0, 1);
      if (_tabController.index != i) {
        _tabController.animateTo(i);
      }
    });
    final today = DateRangePresets.today();
    _historyBloc.add(HistoryDateRangeChanged(from: today.$1, to: today.$2));
    final onHistory = initial == 1;
    if (!onHistory) {
      _cubit.openToday();
    } else if (_cubit.state.from == null || _cubit.state.to == null) {
      _cubit.openToday();
    }
  }

  @override
  void dispose() {
    _tabRequestSub?.cancel();
    _tabController.dispose();
    _historyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final onHistory = _tabController.index == 1;
    final settings = context.watch<SettingsCubit>().state.settings;
    final appLocale = settings.localeCode;
    final dateFmt = DateFormat(settings.dateFormat, appLocale);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _historyBloc),
      ],
      child: Scaffold(
        appBar: onHistory
            ? AppBar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                surfaceTintColor: Colors.transparent,
                elevation: pos.elevChrome,
                scrolledUnderElevation: pos.elevChrome,
                shadowColor: pos.shadowKey.withValues(
                  alpha: pos.shadowChromeAlpha,
                ),
                forceMaterialTransparency: false,
                toolbarHeight: 88,
                titleSpacing: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(pos.appBarBottomRadius),
                  ),
                ),
                titleTextStyle: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansThai',
                ),
                iconTheme: IconThemeData(color: scheme.onPrimary),
                actionsIconTheme: IconThemeData(color: scheme.onPrimary),
                title: BlocBuilder<ReportCubit, ReportState>(
                  buildWhen: (p, c) =>
                      p.sales.length != c.sales.length ||
                      p.from != c.from ||
                      p.to != c.to,
                  builder: (context, state) {
                    final count = state.sales.where((s) => !s.isVoided).length;
                    final from = state.from;
                    final to = state.to;
                    String subtitle;
                    if (from != null && to != null) {
                      final range =
                          '${dateFmt.format(from)}${context.l10n.dateRangeSeparator}${dateFmt.format(to)}';
                      subtitle = '$range  •  ${context.l10n.salesCount(count)}';
                    } else {
                      subtitle = context.l10n.salesCount(count);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.reportTitle),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onPrimary.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'NotoSansThai',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Material(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: const ValueKey('history-open-search'),
                        onTap: () =>
                            HistorySearchPage.push(context, _historyBloc),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 36),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 24,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.l10n.searchHistoryHint,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontFamily: 'NotoSansThai',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : AppBar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                surfaceTintColor: Colors.transparent,
                elevation: pos.elevChrome,
                scrolledUnderElevation: pos.elevChrome,
                shadowColor: pos.shadowKey.withValues(
                  alpha: pos.shadowChromeAlpha,
                ),
                forceMaterialTransparency: false,
                toolbarHeight: 88,
                titleSpacing: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(pos.appBarBottomRadius),
                  ),
                ),
                titleTextStyle: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansThai',
                ),
                iconTheme: IconThemeData(color: scheme.onPrimary),
                actionsIconTheme: IconThemeData(color: scheme.onPrimary),
                title: BlocBuilder<ReportCubit, ReportState>(
                  buildWhen: (p, c) =>
                      p.sales.length != c.sales.length ||
                      p.from != c.from ||
                      p.to != c.to,
                  builder: (context, state) {
                    final count = state.sales.where((s) => !s.isVoided).length;
                    final from = state.from;
                    final to = state.to;
                    String subtitle;
                    if (from != null && to != null) {
                      final range =
                          '${dateFmt.format(from)}${context.l10n.dateRangeSeparator}${dateFmt.format(to)}';
                      subtitle = '$range  •  ${context.l10n.salesCount(count)}';
                    } else {
                      subtitle = context.l10n.salesCount(count);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.reportTitle),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onPrimary.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'NotoSansThai',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  IconButton(
                    tooltip: context.l10n.exportReport,
                    onPressed: _isExporting
                        ? null
                        : () async {
                            final format = await ReportExportSheet.show(
                              context,
                            );
                            if (format != null && mounted) {
                              await _handleExport(format);
                            }
                          },
                    icon: _isExporting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: scheme.onPrimary,
                            ),
                          )
                        : Icon(TablerIcons.fileExport, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _ReportTabSelector(
                controller: _tabController,
                scheme: scheme,
                reportLabel: context.l10n.navReport,
                historyLabel: context.l10n.navHistory,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const ReportOverviewBody(),
                  HistoryTabView(
                    initialFrom: _cubit.state.from,
                    initialTo: _cubit.state.to,
                    syncWithReport: true,
                    historyBloc: _historyBloc,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(String value) async {
    final state = _cubit.state;
    final l10n = context.l10n;
    final today = DateRangePresets.today();
    final from = state.from ?? today.$1;
    final to = state.to ?? today.$2;
    if (_isExporting || state.status == ReportStatus.loading) return;
    // V092-B.3: prompt store PIN before exporting totals + cost + margin.
    final unlocked = await ensureAppUnlocked(
      context,
      title: l10n.appLockConfirmStock,
    );
    if (!unlocked || !context.mounted) return;
    _setExporting(true);
    final calculator = sl<ReportCalculatorService>();
    try {
      // Yield to the framework so the loading indicator paints before the
      // synchronous PDF/CSV generation blocks the UI isolate.
      await Future.microtask(() {});

      // Long ranges are served by the SQL-aggregate path where state.sales
      // is intentionally empty; exports then carry the aggregated totals and
      // per-sale rows are limited to what is hydrated in the aggregate.
      final agg = state.aggregate;
      final exportData = ReportData(
        sales: state.sales,
        from: from,
        to: to,
        totals: agg?.totals ?? calculator.periodTotals(state.sales),
        dailyRevenue: state.dailyRevenue,
        profit: state.profit,
      );

      if (value == 'pdf') {
        final pdfBytes = await _exportService.exportPdf(
          exportData,
          productLookup: state.productLookup,
          calculator: calculator,
          maxRows: 5000,
        );
        await _exportService.shareReport(
          filename: 'report_${_fileSuffix(from, to)}.pdf',
          pdfBytes: pdfBytes,
        );
      } else if (value == 'csv') {
        final csvContent = await _exportService.exportCsv(
          exportData,
          maxRows: 5000,
        );
        await _exportService.shareReport(
          filename: 'report_${_fileSuffix(from, to)}.csv',
          csvContent: csvContent,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
      }
    } finally {
      _setExporting(false);
    }
  }

  void _setExporting(bool value) {
    if (mounted) setState(() => _isExporting = value);
  }

  /// Builds a filename suffix that includes the full date range so exports
  /// of multi-day periods are unambiguous.
  String _fileSuffix(DateTime from, DateTime to) {
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(to);
    final isSameDay = DateUtils.isSameDay(from, to);
    return isSameDay ? f : '${f}_to_$t';
  }
}
