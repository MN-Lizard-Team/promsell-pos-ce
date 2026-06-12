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
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.chooseCategory),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
          body: SafeArea(
            child: CategoryPickerListView(
              selectedId: _selectedId,
              useListTile: true,
              showNoneOption: true,
              onSelected: (Category cat) => Navigator.pop(context, cat),
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
