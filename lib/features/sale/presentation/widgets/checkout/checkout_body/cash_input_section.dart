import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

class CashInputSection extends StatelessWidget {
  const CashInputSection({
    super.key,
    required this.quickAmounts,
    required this.receivedController,
    required this.currency,
    required this.effectiveTotal,
    required this.onReceivedChanged,
    required this.change,
  });

  final List<double> quickAmounts;
  final TextEditingController receivedController;
  final String currency;
  final double effectiveTotal;
  final ValueChanged<double> onReceivedChanged;
  final double change;

  double get _received => double.tryParse(receivedController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts
              .asMap()
              .entries
              .map(
                (entry) => FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'NotoSansThai',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () => onReceivedChanged(entry.value),
                  child: Text(
                    entry.key == 0
                        ? context.l10n.quickCashExact
                        : '$currency${entry.value.toStringAsFixed(2)}',
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: receivedController,
          decoration: InputDecoration(
            labelText: context.l10n.receivedAmount(currency),
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          autofocus: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 10),
        ChangePreview(
          change: change,
          currency: currency,
          visible: _received > 0,
        ),
      ],
    );
  }
}
