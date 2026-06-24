import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';

class ProductPricingTab extends StatelessWidget {
  const ProductPricingTab({
    super.key,
    required this.priceCtrl,
    required this.costCtrl,
    required this.currency,
  });

  final TextEditingController priceCtrl;
  final TextEditingController costCtrl;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FormSectionCard(
        icon: Icons.sell_outlined,
        title: context.l10n.priceLabel(currency),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductTextField(
              controller: priceCtrl,
              labelText: context.l10n.priceLabel(currency),
              icon: Icons.sell_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.priceRequired;
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return context.l10n.invalidPrice;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ProductTextField(
              controller: costCtrl,
              labelText: context.l10n.costLabel(currency),
              icon: Icons.price_change_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return context.l10n.invalidPrice;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
