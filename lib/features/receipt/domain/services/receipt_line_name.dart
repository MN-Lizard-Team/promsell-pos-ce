import 'package:promsell_pos_ce/shared/domain/entities/selected_product_option.dart';

/// Formats a receipt line product name including selected options.
///
/// Example: `Latte (Large, Oat milk)`.
String receiptLineName({
  required String productName,
  List<SelectedProductOption> selectedOptions = const [],
}) {
  if (selectedOptions.isEmpty) return productName;
  final opts = selectedOptions
      .map((o) => o.optionName.trim())
      .where((n) => n.isNotEmpty)
      .join(', ');
  if (opts.isEmpty) return productName;
  return '$productName ($opts)';
}
