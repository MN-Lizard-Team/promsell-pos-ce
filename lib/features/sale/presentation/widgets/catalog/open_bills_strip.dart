import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Horizontal chips of recent non-empty open bills (1-tap switch).
class OpenBillsStrip extends StatefulWidget {
  const OpenBillsStrip({super.key});

  @override
  State<OpenBillsStrip> createState() => _OpenBillsStripState();
}

class _OpenBillsStripState extends State<OpenBillsStrip> {
  Future<List<DraftCart>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = sl<DraftCartRepository>().listDrafts();
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final l10n = context.l10n;

    return BlocListener<DraftBloc, DraftState>(
      listenWhen: (p, c) =>
          p.activeDraftId != c.activeDraftId ||
          p.openBillCount != c.openBillCount ||
          (p.opNonce != c.opNonce && c.opStatus == DraftOpStatus.success),
      listener: (_, _) {
        if (!mounted) return;
        setState(_reload);
      },
      child: FutureBuilder<List<DraftCart>>(
        future: _future,
        builder: (context, snap) {
          final activeId = context.select(
            (DraftBloc b) => b.state.activeDraftId,
          );
          final bills = (snap.data ?? [])
              .where((d) => d.itemCount > 0 && d.id != activeId)
              .take(5)
              .toList();
          if (bills.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bills.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final d = bills[i];
                  final name = (d.name != null && d.name!.trim().isNotEmpty)
                      ? d.name!.trim()
                      : l10n.untitledDraft;
                  final due = d.payableTotal(
                    context.read<SettingsCubit>().state.settings,
                  );
                  final amount =
                      '$currency${due.value.toStringAsFixed(due.value == due.value.roundToDouble() ? 0 : 2)}';
                  return ActionChip(
                    avatar: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: Text(
                      '$name · $amount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () {
                      context.read<DraftBloc>().add(DraftSwitched(d.id));
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
