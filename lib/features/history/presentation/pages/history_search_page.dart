import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_app_bar_field.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/history/presentation/widgets/tiles/sale_expansion_tile.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Full-screen search page pushed from the History tab AppBar.
///
/// Auto-focuses the search field on open and dispatches
/// [HistorySearchChanged] events to the existing [HistoryBloc].
class HistorySearchPage extends StatefulWidget {
  const HistorySearchPage({super.key});

  /// Push the search page, providing the [HistoryBloc] from the caller so
  /// search results stay in sync with the History tab list.
  static Future<void> push(BuildContext context, HistoryBloc bloc) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const HistorySearchPage()),
      ),
    );
  }

  @override
  State<HistorySearchPage> createState() => _HistorySearchPageState();
}

class _HistorySearchPageState extends State<HistorySearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPopping = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    disposeTextEditingControllerAfterFrame(_controller);
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<HistoryBloc>().add(HistorySearchChanged(query));
      }
    });
  }

  Future<void> _popWithCleanup() async {
    if (_isPopping) return;
    _isPopping = true;
    _focusNode.unfocus();
    context.read<HistoryBloc>().add(const HistorySearchChanged(''));
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    context.read<HistoryBloc>().add(const HistorySearchChanged(''));
    _focusNode.requestFocus();
  }

  String? _buildRangeLabel(
    BuildContext context,
    HistoryState state,
    DateFormat fmt,
  ) {
    final from = state.from ?? DateRangePresets.today().$1;
    final to = state.to ?? DateRangePresets.today().$2;
    return '${fmt.format(from)} – ${fmt.format(to)}';
  }

  Widget _buildRangeChip(BuildContext context, String rangeLabel) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            context.l10n.searchingInRange(rangeLabel),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFamily: 'NotoSansThai',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final fmt = DateFormat('${settings.dateFormat} HH:mm', settings.localeCode);

    final query = _controller.text;
    final scheme = Theme.of(context).colorScheme;

    if (_isPopping) return const SizedBox.shrink();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _popWithCleanup();
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 56,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithCleanup,
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SearchAppBarField(
              controller: _controller,
              focusNode: _focusNode,
              hintText: context.l10n.searchHistoryHint,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _focusNode.unfocus(),
              onClear: _clearSearch,
              showClear: query.isNotEmpty,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<HistoryBloc, HistoryState>(
            buildWhen: (p, c) =>
                p.filteredSales != c.filteredSales ||
                p.status != c.status ||
                p.searchQuery != c.searchQuery ||
                p.from != c.from ||
                p.to != c.to,
            builder: (ctx, state) {
              final rangeLabel = _buildRangeLabel(ctx, state, fmt);
              if (state.status == HistoryStatus.loading) {
                return Column(
                  children: [
                    if (rangeLabel != null) _buildRangeChip(ctx, rangeLabel),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
              if (state.status == HistoryStatus.failure) {
                return Column(
                  children: [
                    if (rangeLabel != null) _buildRangeChip(ctx, rangeLabel),
                    Expanded(
                      child: AppEmptyState(
                        icon: TablerIcons.alertCircle,
                        title: state.errorMessage ?? ctx.l10n.errorOccurred,
                        actionLabel: ctx.l10n.retry,
                        onAction: () => ctx.read<HistoryBloc>().add(
                          const HistorySubscribed(),
                        ),
                      ),
                    ),
                  ],
                );
              }
              final filtered = state.filteredSales;
              if (filtered.isEmpty) {
                final searching = state.searchQuery.trim().isNotEmpty;
                return Column(
                  children: [
                    if (rangeLabel != null) _buildRangeChip(ctx, rangeLabel),
                    Expanded(
                      child: AppEmptyState(
                        icon: TablerIcons.receiptOff,
                        title: searching
                            ? ctx.l10n.noResultsInDateRange
                            : ctx.l10n.startTypingToSearch,
                        actionLabel: searching ? ctx.l10n.clearSearch : null,
                        onAction: searching ? _clearSearch : null,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  if (rangeLabel != null) _buildRangeChip(ctx, rangeLabel),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ctx.l10n.searchResultsCount(filtered.length),
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          fontFamily: 'NotoSansThai',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final sale = filtered[i];
                        return SaleExpansionTile(
                          key: ValueKey(sale.id),
                          sale: sale,
                          dateFormat: fmt.format(sale.createdAt),
                          isVoiding: state.voidingSaleId == sale.id,
                          voidBusy: state.voidingSaleId != null,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
