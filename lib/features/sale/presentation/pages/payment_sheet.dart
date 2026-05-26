import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({super.key, required this.total});
  final double total;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _method = 'cash';
  final _receivedCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;
  double get _change => _received - widget.total;

  @override
  void dispose() {
    _receivedCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final saleBloc = context.read<SaleBloc>();
    final note = saleBloc.state.note;
    saleBloc.add(
      SaleConfirmed(
        paymentMethod: _method,
        amountReceived: _method == 'cash' ? _received : null,
        changeAmount: _method == 'cash' && _change >= 0 ? _change : null,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (_, curr) =>
          curr.status == SaleStatus.success ||
          curr.status == SaleStatus.failure,
      listener: (ctx, state) {
        if (state.status == SaleStatus.success) {
          Navigator.pop(ctx);
        } else if (state.status == SaleStatus.failure) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? ctx.l10n.saleError),
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.paymentTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.totalAmount,
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '$currency${widget.total.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'cash', label: Text(context.l10n.cash)),
                ButtonSegment(
                  value: 'transfer',
                  label: Text(context.l10n.transfer),
                ),
                ButtonSegment(value: 'card', label: Text(context.l10n.card)),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            if (_method == 'cash') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _receivedCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.receivedAmount.replaceAll(
                    '฿',
                    currency,
                  ),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              if (_received > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.change,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '$currency${_change >= 0 ? _change.toStringAsFixed(2) : '0.00'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _change >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.notePlaceholder,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              textInputAction: TextInputAction.done,
              maxLines: 1,
              onChanged: (v) =>
                  context.read<SaleBloc>().add(SaleNoteChanged(v)),
            ),
            const SizedBox(height: 20),
            BlocBuilder<SaleBloc, SaleState>(
              builder: (_, state) {
                final isProcessing = state.status == SaleStatus.processing;
                return FilledButton(
                  onPressed: isProcessing
                      ? null
                      : (_method != 'cash' || (_received >= widget.total)
                            ? _confirm
                            : null),
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(context.l10n.confirmPayment),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
