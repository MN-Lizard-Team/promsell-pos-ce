import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';

/// Shows batch barcode snack and consumes [ProductState.batchResultMessage].
void showBatchBarcodeResultSnack(
  BuildContext context,
  ProductBloc bloc,
  ProductState state,
) {
  final message = state.batchResultMessage;
  if (message == null) return;
  final l10n = context.l10n;
  final count = int.tryParse(message) ?? 0;
  if (count <= 0) {
    AppSnackBar.info(context, l10n.batchGenerateNone);
  } else {
    AppSnackBar.success(context, l10n.batchGenerateSuccess(count));
  }
  bloc.add(const ProductBatchResultConsumed());
}

/// Error snack when batch generation fails.
void showBatchBarcodeFailureSnack(BuildContext context, ProductState state) {
  final l10n = context.l10n;
  AppSnackBar.error(
    context,
    state.error?.displayMessage(l10n) ?? l10n.batchGenerateFailed,
  );
}

bool batchBarcodeResultChanged(ProductState prev, ProductState curr) {
  return prev.batchResultMessage != curr.batchResultMessage &&
      curr.batchResultMessage != null;
}

bool batchBarcodeFailed(ProductState prev, ProductState curr) {
  if (curr.status != ProductStatus.failure) return false;
  if (!prev.isBatchGenerating || curr.isBatchGenerating) return false;
  final err = curr.error;
  return err is DatabaseError && err.operation == 'barcode_generation';
}

/// True when a catalog failure should show the generic error snack
/// (excludes batch barcode failures handled separately).
bool productCatalogFailureChanged(ProductState prev, ProductState curr) {
  final becameFailure =
      curr.status == ProductStatus.failure &&
      prev.status != ProductStatus.failure;
  final saveError =
      curr.saveStatus == ProductSaveStatus.error &&
      prev.saveStatus != ProductSaveStatus.error;
  if (saveError) return true;
  if (!becameFailure) return false;
  final err = curr.error;
  if (err is DatabaseError && err.operation == 'barcode_generation') {
    return false;
  }
  return true;
}
