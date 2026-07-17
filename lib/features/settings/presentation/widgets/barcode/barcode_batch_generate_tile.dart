import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_barcode_eligibility.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/batch_barcode_feedback.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class BarcodeBatchGenerateTile extends StatelessWidget {
  const BarcodeBatchGenerateTile({
    super.key,
    required this.settings,
    required this.st,
  });

  final Settings settings;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final productBloc = GetIt.I<ProductBloc>();

    return BlocProvider.value(
      value: productBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProductBloc, ProductState>(
            listenWhen: batchBarcodeResultChanged,
            listener: (ctx, state) {
              showBatchBarcodeResultSnack(ctx, productBloc, state);
            },
          ),
          BlocListener<ProductBloc, ProductState>(
            listenWhen: batchBarcodeFailed,
            listener: (ctx, state) {
              showBatchBarcodeFailureSnack(ctx, state);
            },
          ),
        ],
        child: BlocBuilder<ProductBloc, ProductState>(
          buildWhen: (p, c) =>
              p.products != c.products ||
              p.isBatchGenerating != c.isBatchGenerating,
          builder: (context, state) {
            final withoutBarcode = countProductsNeedingBarcode(state.products);
            final busy = state.isBatchGenerating;

            return ListTile(
              leading: Container(
                width: st.iconSize,
                height: st.iconSize,
                decoration: BoxDecoration(
                  color: st.iconContainerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: busy
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.barcode_reader,
                        color: st.softAccent,
                        size: 24,
                      ),
              ),
              title: Text(
                l10n.batchGenerateBarcodes,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                withoutBarcode > 0
                    ? l10n.productsWithoutBarcode(withoutBarcode)
                    : l10n.batchGenerateNone,
                style: TextStyle(fontSize: 13, color: st.softTextSecondary),
              ),
              trailing: FilledButton.tonal(
                onPressed: busy || withoutBarcode == 0
                    ? null
                    : () => _showBatchConfirmDialog(
                        context,
                        productBloc,
                        withoutBarcode,
                        settings.barcodeAutoGeneratePrefix,
                      ),
                child: Text(l10n.generateBarcode),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBatchConfirmDialog(
    BuildContext context,
    ProductBloc productBloc,
    int count,
    String prefix,
  ) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.batchGenerateConfirmTitle),
        content: Text(l10n.batchGenerateConfirmBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (productBloc.state.isBatchGenerating) return;
              Navigator.of(ctx).pop();
              productBloc.add(BarcodesBatchGenerated(prefix: prefix));
            },
            child: Text(l10n.generateBarcode),
          ),
        ],
      ),
    );
  }
}
