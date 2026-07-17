import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_preview_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/confirm_delete_dialog.dart';

/// Resolves shared catalog blocs from the nearest provider, or DI fallback.
///
/// Using only [context.read] fails when the caller is outside a
/// [BlocProvider] (e.g. some overlay/root-nav paths after hot reload).
(ProductBloc, CategoryBloc) _catalogBlocs(BuildContext context) {
  ProductBloc productBloc;
  CategoryBloc categoryBloc;
  try {
    productBloc = context.read<ProductBloc>();
  } catch (_) {
    productBloc = sl<ProductBloc>();
  }
  try {
    categoryBloc = context.read<CategoryBloc>();
  } catch (_) {
    categoryBloc = sl<CategoryBloc>();
  }
  return (productBloc, categoryBloc);
}

/// Opens product edit. Returns `true` when the form saved successfully.
Future<bool> showProductEditPage(BuildContext context, Product product) async {
  final (productBloc, categoryBloc) = _catalogBlocs(context);
  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
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
  return result ?? false;
}

/// Create product (optional barcode prefill from sale not-found scan).
///
/// Returns the saved [Product] when create succeeds, otherwise `null`.
/// Prefer this over [showProductCreatePage] when the caller needs the entity
/// (e.g. open preview after create).
Future<Product?> showProductCreatePageForResult(
  BuildContext context, {
  String? initialBarcode,
}) async {
  final (productBloc, categoryBloc) = _catalogBlocs(context);
  final result = await Navigator.of(context, rootNavigator: true).push<Object?>(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: categoryBloc),
          BlocProvider(create: (_) => sl<ProductFormCubit>()),
        ],
        child: ProductFormPage(initialBarcode: initialBarcode),
      ),
    ),
  );
  if (result is Product) return result;
  // Backward-compatible: some paths may still pop `true`.
  if (result == true) {
    final products = productBloc.state.products;
    if (products.isNotEmpty) return products.first;
  }
  return null;
}

/// Create product. Returns `true` when the form saved successfully.
Future<bool> showProductCreatePage(
  BuildContext context, {
  String? initialBarcode,
  bool openPreviewOnSuccess = false,
}) async {
  final product = await showProductCreatePageForResult(
    context,
    initialBarcode: initialBarcode,
  );
  if (product == null) return false;
  if (openPreviewOnSuccess && context.mounted) {
    showProductPreviewPage(context, product);
  }
  return true;
}

void showProductPreviewPage(BuildContext context, Product product) {
  final (productBloc, categoryBloc) = _catalogBlocs(context);
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: ProductPreviewPage(
          product: product,
          generateBarcode: sl<GenerateBarcode>(),
          watchInventoryLogs: sl<WatchInventoryLogs>(),
        ),
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

/// Confirms delete, waits for [ProductBloc] success/failure, then returns.
///
/// Returns `true` only when the product is removed from bloc state (DB OK).
/// On failure shows an error snackbar and returns `false` (swipe won't dismiss).
Future<bool> confirmDeleteProduct(
  BuildContext context,
  Product product, {
  bool popOnConfirm = false,
}) async {
  final ok = await showConfirmDeleteDialog(context, product.name);
  if (!ok || !context.mounted) return false;

  final bloc = context.read<ProductBloc>();
  final id = product.id;
  final completer = Completer<bool>();
  late final StreamSubscription<ProductState> sub;
  final nav = Navigator.of(context, rootNavigator: true);

  // Lightweight progress while delete is in flight.
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
  );

  sub = bloc.stream.listen((state) {
    if (completer.isCompleted) return;
    if (state.saveStatus == ProductSaveStatus.error) {
      completer.complete(false);
      return;
    }
    final gone = !state.products.any((p) => p.id == id);
    if (gone &&
        (state.saveStatus == ProductSaveStatus.saved ||
            state.saveStatus == ProductSaveStatus.idle)) {
      completer.complete(true);
    }
  });

  bloc.add(ProductDeleted(id));

  // Already removed (e.g. optimistic path / mock) — resolve immediately.
  if (!bloc.state.products.any((p) => p.id == id) && !completer.isCompleted) {
    completer.complete(true);
  }

  bool success;
  try {
    success = await completer.future.timeout(const Duration(seconds: 12));
  } on TimeoutException {
    success = false;
  } finally {
    await sub.cancel();
    if (nav.canPop()) {
      nav.pop(); // dismiss loading
    }
  }

  if (!context.mounted) return success;

  if (!success) {
    final msg =
        bloc.state.error?.displayMessage(context.l10n) ??
        context.l10n.errorOccurred;
    AppSnackBar.error(context, msg);
    return false;
  }

  if (popOnConfirm) {
    Navigator.pop(context);
  }
  return true;
}
