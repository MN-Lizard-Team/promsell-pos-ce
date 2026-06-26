import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_preview_page.dart';

void showProductEditPage(BuildContext context, Product product) {
  final productBloc = context.read<ProductBloc>();
  final categoryBloc = context.read<CategoryBloc>();
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: categoryBloc),
          BlocProvider(create: (_) => sl<ProductFormCubit>()),
        ],
        child: ProductFormPage(product: product),
      ),
    ),
  );
}

void showProductPreviewPage(BuildContext context, Product product) {
  final productBloc = context.read<ProductBloc>();
  final categoryBloc = context.read<CategoryBloc>();
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: ProductPreviewPage(product: product),
      ),
    ),
  );
}

class DeleteBackground extends StatelessWidget {
  final double borderRadius;
  final EdgeInsets margin;

  const DeleteBackground({
    super.key,
    this.borderRadius = 14,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: margin,
      child: Icon(Icons.delete, color: theme.colorScheme.onError, size: 28),
    );
  }
}

Future<bool> confirmDeleteProduct(BuildContext context, Product product) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.deleteProduct),
      content: Text(l10n.confirmDeleteProduct(product.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            context.read<ProductBloc>().add(ProductDeleted(product.id));
            Navigator.pop(context, false);
          },
          child: Text(
            l10n.delete,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
