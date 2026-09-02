import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';

class TableSelector extends StatelessWidget {
  const TableSelector({
    required this.selectedTableId,
    required this.onSelected,
    super.key,
  });

  final String? selectedTableId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        if (state.tables.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.noTablesAvailable,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        // Effectively-occupied tables (an active draft bill binds them) are
        // not selectable — claiming them would silently fail at save time.
        // The current selection stays listed so editing a dine-in bill that
        // already holds that table keeps working.
        final selectable = state.tables
            .where(
              (t) =>
                  t.status != TableStatus.occupied || t.id == selectedTableId,
            )
            .toList(growable: false);
        return DropdownButtonFormField<String?>(
          key: const Key(TestKeys.tableSelectorField),
          initialValue: selectedTableId,
          decoration: InputDecoration(
            labelText: l10n.selectTable,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIcon: const Icon(Icons.table_restaurant_outlined),
          ),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(l10n.noTable)),
            ...selectable.map(
              (t) => DropdownMenuItem<String?>(
                value: t.id,
                child: Text(
                  t.zone != null && t.zone!.isNotEmpty
                      ? '${t.name} (${t.zone})'
                      : t.name,
                ),
              ),
            ),
          ],
          onChanged: onSelected,
        );
      },
    );
  }
}
