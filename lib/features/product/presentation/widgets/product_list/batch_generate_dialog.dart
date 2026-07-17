import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_barcode_eligibility.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

void showBatchGenerateDialog(BuildContext context) {
  ProductBloc productBloc;
  try {
    productBloc = context.read<ProductBloc>();
  } catch (_) {
    productBloc = sl<ProductBloc>();
  }
  final state = productBloc.state;
  final l10n = context.l10n;

  if (state.isBatchGenerating) return;

  final withoutBarcode = countProductsNeedingBarcode(state.products);

  if (withoutBarcode == 0) {
    AppSnackBar.info(context, l10n.batchGenerateNone);
    return;
  }

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.batchGenerateConfirmTitle),
      content: Text(l10n.batchGenerateConfirmBody(withoutBarcode)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (productBloc.state.isBatchGenerating) return;
            Navigator.of(ctx).pop();
            final prefix = context
                .read<SettingsCubit>()
                .state
                .settings
                .barcodeAutoGeneratePrefix;
            productBloc.add(BarcodesBatchGenerated(prefix: prefix));
          },
          child: Text(l10n.generateBarcode),
        ),
      ],
    ),
  );
}
