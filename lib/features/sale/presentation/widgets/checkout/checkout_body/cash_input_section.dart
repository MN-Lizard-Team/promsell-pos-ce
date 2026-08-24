import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
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

  /// Signed preview: &lt;0 shortfall, &gt;0 change due, ≈0 hide.
  final double change;

  double get _received => double.tryParse(receivedController.text) ?? 0;

  /// Hide noise when exact (change ≈ 0); keep shortfall + real change.
  bool get _showChangePreview =>
      _received > 0 && (change < -0.005 || change > 0.005);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.asMap().entries.map((entry) {
            final isExact = entry.key == 0;
            final amount = entry.value;
            final selected = (_received - amount).abs() < 0.009;
            final label = isExact
                ? context.l10n.quickCashExact
                : '$currency${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
            return PaymentCashChip(
              label: label,
              selected: selected,
              emphasized: isExact,
              onTap: () {
                HapticFeedback.selectionClick();
                onReceivedChanged(amount);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        TextFormField(
          key: const Key(TestKeys.cashReceivedField),
          controller: receivedController,
          decoration: InputDecoration(
            labelText: context.l10n.receivedAmount(currency),
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          autofocus: false,
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              onReceivedChanged(parsed);
            }
          },
        ),
        const SizedBox(height: 12),
        ChangePreview(
          change: change,
          currency: currency,
          visible: _showChangePreview,
        ),
      ],
    );
  }

  /// Prefill cash received field with exact payable amount if user hasn't edited.
  static void maybePrefillCash({
    required TextEditingController controller,
    required String method,
    required bool userEdited,
    required double payable,
  }) {
    if (method != 'cash' || userEdited) return;
    if (payable <= 0) return;
    final text = payable.toStringAsFixed(2);
    if (controller.text != text) {
      controller.text = text;
    }
  }

  /// Set received amount and trigger haptic + setState callback.
  static void setReceived({
    required TextEditingController controller,
    required double value,
    required ValueChanged<bool> onUserEdited,
    required VoidCallback onStateChanged,
  }) {
    onUserEdited(true);
    controller.text = value.toStringAsFixed(2);
    HapticFeedback.selectionClick();
    onStateChanged();
  }
}
