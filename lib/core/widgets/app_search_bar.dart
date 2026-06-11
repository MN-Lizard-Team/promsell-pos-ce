import 'dart:async';

import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.recentSearches = const [],
    this.onRecentTap,
    this.onRecentDismiss,
    this.isFocused = false,
    this.onFocusChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<String> recentSearches;
  final ValueChanged<String>? onRecentTap;
  final ValueChanged<String>? onRecentDismiss;
  final bool isFocused;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showRecents =
        widget.isFocused &&
        widget.controller.text.isEmpty &&
        widget.recentSearches.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchBar(
          controller: widget.controller,
          focusNode: widget.focusNode,
          hintText: widget.hintText,
          leading: const Icon(Icons.search),
          trailing: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    _debounceTimer?.cancel();
                    widget.onChanged?.call('');
                  },
                );
              },
            ),
          ],
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHighest,
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: theme.colorScheme.outline),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: _onSearchChanged,
          onSubmitted: widget.onSubmitted,
        ),
        if (showRecents) ...[
          const SizedBox(height: 8),
          _RecentSearchesPanel(
            searches: widget.recentSearches,
            onTap: widget.onRecentTap,
            onDismiss: widget.onRecentDismiss,
          ),
        ],
      ],
    );
  }
}

class _RecentSearchesPanel extends StatelessWidget {
  const _RecentSearchesPanel({
    required this.searches,
    this.onTap,
    this.onDismiss,
  });

  final List<String> searches;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Recent searches',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...searches.map(
            (q) => InkWell(
              onTap: () => onTap?.call(q),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => onDismiss?.call(q),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
