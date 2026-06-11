import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/stock_stepper.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum QuickEditField { name, price, stock }

class QuickEditSheet extends StatefulWidget {
  const QuickEditSheet({
    super.key,
    required this.field,
    required this.initialValue,
    this.productName,
  });

  final QuickEditField field;
  final String initialValue;
  final String? productName;

  @override
  State<QuickEditSheet> createState() => _QuickEditSheetState();
}

class _QuickEditSheetState extends State<QuickEditSheet> {
  late final _ctrl = TextEditingController(text: widget.initialValue);
  late int _stockValue;

  @override
  void initState() {
    super.initState();
    _stockValue = int.tryParse(widget.initialValue) ?? 0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _title(context, currency),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.productName != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.productName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 20),
              if (widget.field == QuickEditField.stock)
                StockStepper(
                  value: _stockValue,
                  onChanged: (v) => setState(() => _stockValue = v),
                  onQtyTap: () => _showStockDialog(context),
                )
              else
                TextField(
                  controller: _ctrl,
                  keyboardType: _keyboardType,
                  inputFormatters: _inputFormatters,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: _hint(context, currency),
                    prefixIcon: widget.field == QuickEditField.price
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              currency,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : null,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 0,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final result = widget.field == QuickEditField.stock
                            ? _stockValue.toString()
                            : _ctrl.text.trim();
                        Navigator.pop(context, result);
                      },
                      child: Text(context.l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(BuildContext context, String currency) {
    switch (widget.field) {
      case QuickEditField.name:
        return context.l10n.edit;
      case QuickEditField.price:
        return context.l10n.priceLabel(currency);
      case QuickEditField.stock:
        return context.l10n.quantityLabel;
    }
  }

  String _hint(BuildContext context, String currency) {
    switch (widget.field) {
      case QuickEditField.name:
        return context.l10n.productNameLabel;
      case QuickEditField.price:
        return '0.00';
      case QuickEditField.stock:
        return '0';
    }
  }

  TextInputType? get _keyboardType {
    switch (widget.field) {
      case QuickEditField.name:
        return TextInputType.text;
      case QuickEditField.price:
        return const TextInputType.numberWithOptions(decimal: true);
      case QuickEditField.stock:
        return TextInputType.number;
    }
  }

  List<TextInputFormatter>? get _inputFormatters {
    switch (widget.field) {
      case QuickEditField.name:
        return null;
      case QuickEditField.price:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))];
      case QuickEditField.stock:
        return [FilteringTextInputFormatter.digitsOnly];
    }
  }

  void _showStockDialog(BuildContext context) {
    final ctrl = TextEditingController(text: '$_stockValue');
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.quantityLabel),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: InputDecoration(labelText: l10n.quantityLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text);
              if (qty != null && qty >= 0) {
                Navigator.pop(context);
                setState(() => _stockValue = qty);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

Future<String?> showQuickEditSheet(
  BuildContext context, {
  required QuickEditField field,
  required String initialValue,
  String? productName,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => QuickEditSheet(
      field: field,
      initialValue: initialValue,
      productName: productName,
    ),
  );
}
