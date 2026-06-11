import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/category_management_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_picker_list_view.dart';

class CategoryPickerPage extends StatefulWidget {
  const CategoryPickerPage({super.key, this.selectedId});
  final String? selectedId;

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CategoryBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.chooseCategory),
          actions: [
            TextButton(
              onPressed: _selectedId == null
                  ? null
                  : () {
                      final cats = context
                          .read<CategoryBloc>()
                          .state
                          .categories;
                      if (cats.isEmpty) {
                        Navigator.pop(context);
                        return;
                      }
                      final selected = cats.firstWhere(
                        (c) => c.id == _selectedId,
                        orElse: () => cats.first,
                      );
                      Navigator.pop(context, selected);
                    },
              child: Text(context.l10n.save),
            ),
          ],
        ),
        body: SafeArea(
          child: CategoryPickerListView(
            selectedId: _selectedId,
            useListTile: true,
            onSelected: (Category cat) => setState(() => _selectedId = cat.id),
            emptyAction: () => _goToManagement(context),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => _goToManagement(context),
              icon: const Icon(Icons.settings_outlined),
              label: Text(context.l10n.manageCategories),
            ),
          ),
        ),
      ),
    );
  }

  void _goToManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
    );
  }
}
