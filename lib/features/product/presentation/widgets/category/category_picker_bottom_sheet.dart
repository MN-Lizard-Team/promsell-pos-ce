import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_form_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_picker_list_view.dart';

class CategoryPickerBottomSheet extends StatelessWidget {
  const CategoryPickerBottomSheet({
    super.key,
    this.selectedId,
    this.showNoneOption = false,
  });

  final String? selectedId;
  final bool showNoneOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.25,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                Text(
                  context.l10n.chooseCategory,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: context.l10n.addCategory,
                  icon: const Icon(Icons.add),
                  onPressed: () => _createCategory(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CategoryPickerListView(
                selectedId: selectedId,
                showNoneOption: showNoneOption,
                onSelected: (Category cat) => Navigator.pop(context, cat),
                emptyAction: () => _createCategory(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCategory(BuildContext context) async {
    final result = await showDialog<CategoryFormResult>(
      context: context,
      builder: (_) => const CategoryFormDialog(),
    );
    if (result == null || !context.mounted) return;

    final bloc = context.read<CategoryBloc>();
    bloc.add(
      CategoryAdded(
        name: result.name,
        sortOrder: result.sortOrder,
        color: result.color,
        iconName: result.iconName,
      ),
    );
    final saved = await bloc.stream.firstWhere(
      (state) => state.saveStatus != CategorySaveStatus.saving,
    );
    if (saved.saveStatus == CategorySaveStatus.error) {
      if (context.mounted) {
        AppSnackBar.error(
          context,
          saved.errorMessage ?? context.l10n.errorOccurred,
        );
      }
      return;
    }
    final category = await bloc.stream
        .expand((state) => state.categories)
        .firstWhere((item) => item.name == result.name);
    if (context.mounted) Navigator.pop(context, category);
  }
}

Future<Category?> showCategoryPicker(
  BuildContext context, {
  String? selectedId,
  bool showNoneOption = false,
}) async {
  final bloc = BlocProvider.of<CategoryBloc>(context);
  final result = await showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: CategoryPickerBottomSheet(
        selectedId: selectedId,
        showNoneOption: showNoneOption,
      ),
    ),
  );
  return result;
}
