import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class CategorySearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CategorySearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(
      title: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.searchCategories,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClose,
          ),
        ),
        onChanged: onChanged,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onClose,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CategoryBulkAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CategoryBulkAppBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onBulkDelete,
  });

  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onBulkDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(
      title: Text(l10n.bulkSelected(selectedCount)),
      leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      actions: [
        if (selectedCount > 0)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onBulkDelete,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
