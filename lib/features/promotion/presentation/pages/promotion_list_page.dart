import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_bloc.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_event.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_state.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/pages/promotion_form_page.dart';

class PromotionListPage extends StatelessWidget {
  const PromotionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<PromotionBloc>()..add(const PromotionsSubscribed()),
      child: const _PromotionListView(),
    );
  }
}

class _PromotionListView extends StatefulWidget {
  const _PromotionListView();

  @override
  State<_PromotionListView> createState() => _PromotionListViewState();
}

class _PromotionListViewState extends State<_PromotionListView> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<PromotionBloc>().add(const PromotionSearchChanged(''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocListener<PromotionBloc, PromotionState>(
      listenWhen: (prev, curr) =>
          curr.status == PromotionStatus.failure &&
          prev.status != PromotionStatus.failure,
      listener: (ctx, state) {
        AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.errorOccurred);
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchPromotions,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: theme.textTheme.titleMedium,
                  onChanged: (q) => context.read<PromotionBloc>().add(
                    PromotionSearchChanged(q),
                  ),
                )
              : Text(l10n.promotionsTitle),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<PromotionBloc, PromotionState>(
            builder: (context, state) {
              final promotions = state.filtered;

              if (state.status == PromotionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (promotions.isEmpty) {
                return _EmptyState(
                  hasSearch: state.searchQuery.isNotEmpty,
                  onAdd: () => _showAddForm(context),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: promotions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final promotion = promotions[index];
                  return _PromotionTile(
                    promotion: promotion,
                    onTap: () => _showEditForm(context, promotion),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddForm(context),
          heroTag: 'promotion_add_fab',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddForm(BuildContext context) async {
    final bloc = context.read<PromotionBloc>();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const PromotionFormPage()),
      ),
    );
  }

  Future<void> _showEditForm(BuildContext context, Promotion promotion) async {
    final bloc = context.read<PromotionBloc>();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: PromotionFormPage(promotion: promotion),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch, required this.onAdd});
  final bool hasSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.local_offer_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? l10n.noPromotionsFound : l10n.noPromotionsYet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch ? l10n.tryDifferentSearch : l10n.addFirstPromotion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(l10n.addPromotion),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PromotionTile extends StatelessWidget {
  const _PromotionTile({required this.promotion, required this.onTap});
  final Promotion promotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isActive = promotion.isCurrentlyActive;
    final valueLabel = promotion.type == PromotionType.percent
        ? l10n.promotionPercentOff(promotion.value.toStringAsFixed(0))
        : l10n.promotionAmountOff(promotion.value.toStringAsFixed(2));
    final endLabel = promotion.endDate != null
        ? _formatDate(promotion.endDate!)
        : l10n.promotionNoEndDate;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            promotion.type == PromotionType.percent
                ? Icons.percent_outlined
                : Icons.attach_money,
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.outline,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                promotion.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? l10n.promotionActive : l10n.promotionInactive,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              valueLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (promotion.minPurchaseAmount.isPositive) ...[
              const SizedBox(height: 2),
              Text(
                l10n.promotionMinPurchase(
                  promotion.minPurchaseAmount.value.toStringAsFixed(2),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              '${_formatDate(promotion.startDate)} - $endLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
