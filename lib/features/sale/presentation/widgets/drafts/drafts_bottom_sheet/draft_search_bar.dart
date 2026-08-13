import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Bill search field.
///
/// [embeddedInAppBar] = inline field on primary AppBar (onPrimary ink, no white box).
class DraftSearchBar extends StatelessWidget {
  const DraftSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.l10n,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
    this.embeddedInAppBar = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String query;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  /// Inline AppBar field — ink on primary, not a floating white pill.
  final bool embeddedInAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (embeddedInAppBar) {
      final onBar = scheme.onPrimary;
      final hint = onBar.withValues(alpha: 0.72);
      return TextField(
        key: const ValueKey('sale_bills_search'),
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        cursorColor: onBar,
        style: theme.textTheme.titleMedium?.copyWith(
          fontFamily: 'NotoSansThai',
          fontWeight: FontWeight.w600,
          color: onBar,
        ),
        decoration: InputDecoration(
          hintText: l10n.searchDrafts,
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'NotoSansThai',
            fontWeight: FontWeight.w500,
            color: hint,
          ),
          // No prefix search icon — already entered via toolbar search.
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  icon: Icon(Icons.clear, size: 20, color: onBar),
                  onPressed: onClear,
                )
              : null,
          isDense: true,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      );
    }

    return TextField(
      key: const ValueKey('sale_bills_search'),
      controller: controller,
      focusNode: focusNode,
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
