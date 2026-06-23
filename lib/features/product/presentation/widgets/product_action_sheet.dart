import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';

class ProductActionSheet extends StatelessWidget {
  const ProductActionSheet({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<ProductBloc>();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(theme: theme),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(context.l10n.edit),
            onTap: () {
              Navigator.pop(context);
              _showEdit(context);
            },
          ),
          ListTile(
            leading: Icon(
              product.isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            title: Text(
              product.isActive
                  ? context.l10n.deactivate
                  : context.l10n.activate,
            ),
            onTap: () {
              Navigator.pop(context);
              bloc.add(
                ProductUpdated(product.copyWith(isActive: !product.isActive)),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              context.l10n.delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDelete(context);
              if (confirmed) {
                bloc.add(ProductDeleted(product.id));
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: ProductFormPage(product: product),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteProduct),
        content: Text(context.l10n.confirmDeleteProduct(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

void showProductActionSheet(BuildContext context, Product product) {
  HapticFeedback.mediumImpact();
  final bloc = context.read<ProductBloc>();
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: ProductActionSheet(product: product),
    ),
  );
}
