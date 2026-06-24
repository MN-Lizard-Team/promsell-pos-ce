import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_create_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_search_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class DraftsBottomSheet extends StatefulWidget {
  const DraftsBottomSheet({super.key});

  @override
  State<DraftsBottomSheet> createState() => _DraftsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<DraftBloc>(),
        child: const DraftsBottomSheet(),
      ),
    );
  }
}

class _DraftsBottomSheetState extends State<DraftsBottomSheet> {
  late Future<List<DraftCart>> _draftsFuture;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
    _draftsFuture = sl<DraftCartRepository>().listDrafts();
  });

  List<DraftCart> _filterAndSort(List<DraftCart> drafts, String? activeId) {
    var result = List<DraftCart>.from(drafts);
    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      result = result
          .where((d) => (d.name ?? '').toLowerCase().contains(lower))
          .toList();
    }
    result.sort((a, b) {
      final aActive = a.id == activeId ? 1 : 0;
      final bActive = b.id == activeId ? 1 : 0;
      if (aActive != bActive) return bActive - aActive;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<DraftBloc, DraftState>(
      listenWhen: (prev, curr) => prev.activeDraftId != curr.activeDraftId,
      listener: (ctx, st) => _reload(),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    l10n.draftsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => _showCreateDialog(context, l10n),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.newDraft),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DraftSearchBar(
                controller: _searchCtrl,
                query: _query,
                l10n: l10n,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<DraftCart>>(
                  future: _draftsFuture,
                  builder: (_, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allDrafts = snap.data ?? [];
                    final activeDraftId = context
                        .read<DraftBloc>()
                        .state
                        .activeDraftId;
                    final drafts = _filterAndSort(allDrafts, activeDraftId);
                    if (drafts.isEmpty && _query.isNotEmpty) {
                      return AppEmptyState(
                        icon: Icons.search_off,
                        title: l10n.noMatchingDrafts,
                      );
                    }
                    return ListView.builder(
                      controller: scrollCtrl,
                      itemCount: drafts.length,
                      itemBuilder: (_, i) {
                        final draft = drafts[i];
                        final isActive = draft.id == activeDraftId;
                        return DraftTile(
                          id: draft.id,
                          name: draft.name,
                          itemCount: draft.itemCount,
                          total: draft.total,
                          currency: currency,
                          isActive: isActive,
                          updatedAt: draft.updatedAt,
                          l10n: l10n,
                          theme: theme,
                          onSwitch: isActive
                              ? null
                              : () {
                                  context.read<DraftBloc>().add(
                                    DraftSwitched(draft.id),
                                  );
                                  Navigator.pop(context);
                                },
                          onDelete: drafts.length > 1
                              ? () {
                                  context.read<DraftBloc>().add(
                                    DraftDeleted(draft.id),
                                  );
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    _reload,
                                  );
                                }
                              : null,
                          onRename: (name) {
                            context.read<DraftBloc>().add(
                              DraftRenamed(draftId: draft.id, name: name),
                            );
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              _reload,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, AppLocalizations l10n) {
    final bloc = context.read<DraftBloc>();
    DraftCreateDialog.show(context, l10n).then((name) {
      if (name != null) {
        bloc.add(DraftCreated(name: name));
        Future.delayed(const Duration(milliseconds: 300), _reload);
      }
    });
  }
}
