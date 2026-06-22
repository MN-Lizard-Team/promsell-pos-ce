import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_picker_list_view.dart';

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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.chooseCategory,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CategoryPickerListView(
                selectedId: selectedId,
                showNoneOption: showNoneOption,
                onSelected: (Category cat) => Navigator.pop(context, cat),
              ),
            ),
          ],
        ),
      ),
    );
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
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: CategoryPickerBottomSheet(
        selectedId: selectedId,
        showNoneOption: showNoneOption,
      ),
    ),
  );
  if (result == null) return null;
  if (result.id.isEmpty) return null;
  return result;
}
