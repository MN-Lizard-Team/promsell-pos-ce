import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

void showBatchGenerateDialog(BuildContext context) {
  final state = context.read<ProductBloc>().state;
  final l10n = context.l10n;
  final withoutBarcode = state.products
      .where((p) => p.barcode == null || p.barcode!.isEmpty)
      .length;

  if (withoutBarcode == 0) {
    AppSnackBar.info(context, l10n.batchGenerateNone);
    return;
  }

  showDialog(
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
            Navigator.of(ctx).pop();
            final prefix = context
                .read<SettingsCubit>()
                .state
                .settings
                .barcodeAutoGeneratePrefix;
            context.read<ProductBloc>().add(
              BarcodesBatchGenerated(prefix: prefix),
            );
          },
          child: Text(l10n.generateBarcode),
        ),
      ],
    ),
  );
}
