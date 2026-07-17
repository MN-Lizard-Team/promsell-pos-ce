import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/widgets/sheets/adjust_stock_sheet.dart';

/// Opens the adjust-stock bottom sheet (stable API for form/preview callers).
///
/// Returns the **new stock balance** on success, or `null` if cancelled / failed.
Future<int?> showAdjustStockDialog(
  BuildContext context, {
  required String productId,
  required String productName,
  required int currentStock,
  String? unit,
}) {
  return showAdjustStockSheet(
    context,
    productId: productId,
    productName: productName,
    currentStock: currentStock,
    unit: unit,
  );
}
