import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DraftSearchBar extends StatelessWidget {
  const DraftSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.l10n,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: l10n.searchDrafts,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onClear,
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }
}
