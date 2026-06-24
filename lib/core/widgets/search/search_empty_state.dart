import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.query, this.onClear});

  final String query;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off,
      title: query.isEmpty
          ? context.l10n.startTypingToSearch
          : '${context.l10n.noMatchingProducts} "$query"',
      message: query.isEmpty
          ? context.l10n.searchByNameSkuBarcode
          : context.l10n.tryDifferentKeyword,
      actionLabel: query.isEmpty ? null : context.l10n.clearSearch,
      onAction: onClear,
    );
  }
}
