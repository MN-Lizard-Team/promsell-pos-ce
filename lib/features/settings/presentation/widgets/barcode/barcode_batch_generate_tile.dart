import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
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
    final withoutBarcode = productBloc.state.products
        .where((p) => p.barcode == null || p.barcode!.isEmpty)
        .length;

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.barcode_reader, color: st.softAccent, size: 24),
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
        onPressed: withoutBarcode == 0
            ? null
            : () => _showBatchConfirmDialog(
                context,
                withoutBarcode,
                settings.barcodeAutoGeneratePrefix,
              ),
        child: Text(l10n.generateBarcode),
      ),
    );
  }

  void _showBatchConfirmDialog(BuildContext context, int count, String prefix) {
    final l10n = context.l10n;
    showDialog(
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
              Navigator.of(ctx).pop();
              GetIt.I<ProductBloc>().add(
                BarcodesBatchGenerated(prefix: prefix),
              );
            },
            child: Text(l10n.generateBarcode),
          ),
        ],
      ),
    );
  }
}
