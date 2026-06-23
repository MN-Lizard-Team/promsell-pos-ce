import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit_sheet.dart';

mixin QuickEditMixin<T extends StatefulWidget> on State<T> {
  Product get product;

  Future<void> quickEditName(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.name,
      initialValue: product.name,
      productName: product.name,
    );
    if (!context.mounted) return;
    if (result != null && result.isNotEmpty && result != product.name) {
      context.read<ProductBloc>().add(
        ProductUpdated(product.copyWith(name: result)),
      );
    }
  }

  Future<void> quickEditPrice(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.price,
      initialValue: product.price.toStringAsFixed(2),
      productName: product.name,
    );
    if (!context.mounted) return;
    final price = double.tryParse(result ?? '');
    if (price != null && price >= 0 && price != product.price) {
      context.read<ProductBloc>().add(
        ProductUpdated(product.copyWith(price: price)),
      );
    }
  }

  Future<void> quickEditStock(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.stock,
      initialValue: product.stock.toString(),
      productName: product.name,
    );
    if (!context.mounted) return;
    final stock = int.tryParse(result ?? '');
    if (stock != null && stock >= 0 && stock != product.stock) {
      context.read<ProductBloc>().add(
        ProductUpdated(product.copyWith(stock: stock)),
      );
    }
  }
}
