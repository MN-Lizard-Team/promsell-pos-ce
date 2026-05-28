import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart';

Future<bool> showAdjustStockDialog(
  BuildContext context, {
  required String productId,
  required String productName,
}) async {
  final qtyController = TextEditingController();
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.adjustStockTitle(productName)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(labelText: ctx.l10n.adjustQtyLabel),
              validator: (v) {
                if (v == null || v.isEmpty) return ctx.l10n.quantityRequired;
                final n = int.tryParse(v);
                if (n == null) return ctx.l10n.invalidQuantity;
                if (n == 0) return ctx.l10n.invalidQuantity;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: ctx.l10n.adjustReasonLabel,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? ctx.l10n.adjustReasonRequired
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, true);
            }
          },
          child: Text(ctx.l10n.save),
        ),
      ],
    ),
  );

  if (result == true && context.mounted) {
    try {
      await sl<AdjustStock>().call(
        productId: productId,
        qtyChange: int.parse(qtyController.text),
        reason: reasonController.text.trim(),
      );
      if (context.mounted) {
        AppSnackBar.success(context, context.l10n.adjustSuccess);
      }
      qtyController.dispose();
      reasonController.dispose();
      return true;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, e.toString());
      }
    }
  }
  qtyController.dispose();
  reasonController.dispose();
  return false;
}
