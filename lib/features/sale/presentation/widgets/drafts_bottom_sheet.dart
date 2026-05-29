import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
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
      builder: (_) => BlocProvider.value(
        value: context.read<SaleBloc>(),
        child: const DraftsBottomSheet(),
      ),
    );
  }
}

class _DraftsBottomSheetState extends State<DraftsBottomSheet> {
  late Future<List<DraftCart>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => setState(() {
    _draftsFuture = sl<DraftCartRepository>().listDrafts();
  });

  void _showCreateDialog(BuildContext context, dynamic l10n) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.newDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
              context.read<SaleBloc>().add(SaleDraftCreated(name: name));
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<SaleBloc, SaleState>(
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
              Expanded(
                child: FutureBuilder<List<DraftCart>>(
                  future: _draftsFuture,
                  builder: (_, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final drafts = snap.data ?? [];
                    final activeDraftId = context
                        .read<SaleBloc>()
                        .state
                        .activeDraftId;
                    return ListView.builder(
                      controller: scrollCtrl,
                      itemCount: drafts.length,
                      itemBuilder: (_, i) {
                        final draft = drafts[i];
                        final isActive = draft.id == activeDraftId;
                        return _DraftTile(
                          id: draft.id,
                          name: draft.name,
                          itemCount: draft.itemCount,
                          total: draft.total,
                          currency: currency,
                          isActive: isActive,
                          l10n: l10n,
                          theme: theme,
                          onSwitch: isActive
                              ? null
                              : () {
                                  context.read<SaleBloc>().add(
                                    SaleDraftSwitched(draft.id),
                                  );
                                  Navigator.pop(context);
                                },
                          onDelete: drafts.length > 1
                              ? () {
                                  context.read<SaleBloc>().add(
                                    SaleDraftDeleted(draft.id),
                                  );
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    _reload,
                                  );
                                }
                              : null,
                          onRename: (name) {
                            context.read<SaleBloc>().add(
                              SaleDraftRenamed(draftId: draft.id, name: name),
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
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.total,
    required this.currency,
    required this.isActive,
    required this.l10n,
    required this.theme,
    required this.onSwitch,
    required this.onDelete,
    required this.onRename,
  });

  final String id;
  final String? name;
  final int itemCount;
  final double total;
  final String currency;
  final bool isActive;
  final dynamic l10n;
  final ThemeData theme;
  final VoidCallback? onSwitch;
  final VoidCallback? onDelete;
  final void Function(String)? onRename;

  @override
  Widget build(BuildContext context) {
    final displayName = name?.isNotEmpty == true ? name! : 'Draft';
    return ListTile(
      leading: Icon(
        Icons.receipt_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      title: Text(
        isActive ? '$displayName (${l10n.activeDraftLabel})' : displayName,
        style: isActive
            ? TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              )
            : null,
      ),
      subtitle: Text('$itemCount items · $currency${total.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRename != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l10n.renameDraft,
              onPressed: () => _showRenameDialog(context, displayName),
            ),
          if (onDelete != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              tooltip: l10n.deleteDraft,
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      onTap: onSwitch,
    );
  }

  void _showRenameDialog(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.renameDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: context.l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onRename?.call(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteDraft),
        content: Text(context.l10n.deleteDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.deleteDraft),
          ),
        ],
      ),
    );
  }
}
