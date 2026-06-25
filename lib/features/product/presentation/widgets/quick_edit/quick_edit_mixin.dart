import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_sheet.dart';

mixin QuickEditMixin<T extends StatefulWidget> on State<T> {
  Product get product;

  Future<void> quickEditName(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.name,
      initialValue: product.name,
      productName: product.name,
    );
    if (!context.mounted) return;
    final trimmed = result?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    if (trimmed == product.name) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quickEditNameCancelled)));
      return;
    }
    if (trimmed.length > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quickEditNameInvalid)));
      return;
    }
    context.read<ProductBloc>().add(
      ProductUpdated(product.copyWith(name: trimmed)),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.quickEditNameSaved)));
  }

  Future<void> quickEditPrice(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.price,
      initialValue: product.price.toStringAsFixed(2),
      productName: product.name,
    );
    if (!context.mounted) return;
    final price = double.tryParse(result?.trim() ?? '');
    if (price == null || price < 0) {
      if (result != null && result.trim().isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.quickEditPriceInvalid)));
      }
      return;
    }
    if (price == product.price) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quickEditPriceCancelled)));
      return;
    }
    context.read<ProductBloc>().add(
      ProductUpdated(product.copyWith(price: price)),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.quickEditPriceSaved)));
  }

  Future<void> quickEditStock(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.stock,
      initialValue: product.stock.toString(),
      productName: product.name,
    );
    if (!context.mounted) return;
    final stock = int.tryParse(result ?? '');
    if (stock == null || stock < 0) {
      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.stockUpdateInvalid)));
      }
      return;
    }
    if (stock == product.stock) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.stockUpdateCancelled)));
      return;
    }
    context.read<ProductBloc>().add(
      ProductUpdated(product.copyWith(stock: stock)),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.stockUpdated)));
  }
}
