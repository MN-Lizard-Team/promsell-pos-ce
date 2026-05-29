import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/core/widgets/receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment_widgets.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({
    super.key,
    required this.preTaxTotal,
    required this.vatInfo,
  });

  final double preTaxTotal;
  final ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  vatInfo;

  double get effectiveTotal => vatInfo?.totalWithVat ?? preTaxTotal;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _method = 'cash';
  final _receivedCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  bool _submitted = false;

  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;
  double get _change => _received - widget.effectiveTotal;

  @override
  void dispose() {
    _receivedCtrl.dispose();
    _noteCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  void _setReceived(double value) {
    _receivedCtrl.text = value.toStringAsFixed(2);
    HapticFeedback.selectionClick();
    setState(() {});
  }

  void _confirm() {
    if (_submitted) return;
    _submitted = true;
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    final reference = _referenceCtrl.text.trim();
    final effectiveNote = reference.isEmpty
        ? note
        : [
            if (note.isNotEmpty) note,
            '${context.l10n.paymentReferenceOptional}: $reference',
          ].join('\n');
    final settings = context.read<SettingsCubit>().state.settings;
    final cartState = context.read<SaleBloc>().state;
    context.read<SaleBloc>().add(
      SaleConfirmed(
        paymentMethod: _method,
        vatMode: settings.vatMode,
        vatRate: settings.vatRate,
        cartDiscountType: cartState.cartDiscountType,
        cartDiscountValue: cartState.cartDiscountValue,
        cartDiscountAmount: cartState.hasCartDiscount
            ? cartState.cartDiscountAmount
            : null,
        amountReceived: _method == 'cash' ? _received : null,
        changeAmount: _method == 'cash' && _change >= 0 ? _change : null,
        note: effectiveNote.isEmpty ? null : effectiveNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (_, curr) =>
          curr.status == SaleStatus.failure ||
          curr.status == SaleStatus.success,
      listener: (ctx, state) {
        if (state.status == SaleStatus.success) {
          _submitted = false;
          Navigator.of(ctx).pop();
          return;
        }
        _submitted = false;
        AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.saleError);
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.paymentTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              BlocBuilder<SaleBloc, SaleState>(
                builder: (_, cartState) {
                  final hasItemDiscounts = cartState.items.any(
                    (i) => i.discountAmount > 0,
                  );
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (hasItemDiscounts || cartState.hasCartDiscount)
                            PaymentTotalRow(
                              label: context.l10n.receiptLabelSubtotal,
                              value: cartState.itemsSubtotal,
                              currency: currency,
                              style: theme.textTheme.bodyMedium,
                            ),
                          if (hasItemDiscounts)
                            PaymentTotalRow(
                              label: context.l10n.discountSectionLabel,
                              value: -cartState.items.fold(
                                0.0,
                                (s, i) => s + i.discountAmount,
                              ),
                              currency: currency,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          if (cartState.hasCartDiscount)
                            PaymentTotalRow(
                              label: context.l10n.cartDiscount,
                              value: -cartState.cartDiscountAmount,
                              currency: currency,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.totalAmount,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              MoneyText(
                                value: widget.effectiveTotal,
                                currency: currency,
                                style: theme.textTheme.headlineSmall,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'cash',
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(context.l10n.cash),
                  ),
                  ButtonSegment(
                    value: 'transfer',
                    icon: const Icon(Icons.qr_code_2_outlined),
                    label: Text(context.l10n.transfer),
                  ),
                  ButtonSegment(
                    value: 'card',
                    icon: const Icon(Icons.credit_card),
                    label: Text(context.l10n.card),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (selection) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _method = selection.first;
                    if (_method == 'cash') _referenceCtrl.clear();
                  });
                },
              ),
              if (_method == 'cash') ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts()
                      .asMap()
                      .entries
                      .map(
                        (entry) => ActionChip(
                          avatar: const Icon(
                            Icons.add_circle_outline,
                            size: 18,
                          ),
                          label: Text(
                            entry.key == 0
                                ? context.l10n.quickCashExact
                                : '$currency${entry.value.toStringAsFixed(2)}',
                          ),
                          onPressed: () => _setReceived(entry.value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _receivedCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.receivedAmount(currency),
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ChangePreview(
                  change: _change,
                  currency: currency,
                  visible: _received > 0,
                ),
              ] else ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.paymentReferenceOptional,
                    prefixIcon: const Icon(Icons.tag_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.notePlaceholder,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                textInputAction: TextInputAction.done,
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              BlocBuilder<SaleBloc, SaleState>(
                builder: (_, cartState) {
                  final settings = context
                      .watch<SettingsCubit>()
                      .state
                      .settings;
                  if (settings.showPreSalePreview &&
                      settings.receiptPreviewStyle != 'none' &&
                      !cartState.isEmpty) {
                    final labels = ReceiptLabels(
                      receipt: context.l10n.receiptLabelReceipt,
                      payment: context.l10n.receiptLabelPayment,
                      paymentMethodLabel: localizePaymentMethod(
                        context,
                        _method,
                      ),
                      total: context.l10n.receiptLabelTotal,
                      received: context.l10n.receiptLabelReceived,
                      change: context.l10n.receiptLabelChange,
                      note: context.l10n.receiptLabelNote,
                      vat: context.l10n.receiptLabelVat,
                      vatIncluded: context.l10n.receiptLabelVatIncluded(
                        settings.vatRate,
                      ),
                      subtotal: context.l10n.receiptLabelSubtotal,
                    );
                    final vatInfo = sl<ReceiptPdfService>().calculateVat(
                      total: cartState.total,
                      rate: settings.vatRate,
                      mode: settings.vatMode,
                    );
                    final style = switch (settings.receiptPreviewStyle) {
                      'card' => ReceiptPreviewStyle.card,
                      'none' => ReceiptPreviewStyle.none,
                      _ => ReceiptPreviewStyle.thermal,
                    };
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.receiptPreview,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: ReceiptPreview(
                            settings: settings,
                            labels: labels,
                            style: style,
                            items: cartState.items
                                .map(
                                  (i) => ReceiptPreviewItem(
                                    name: i.product.name,
                                    qty: i.qty,
                                    price: i.product.price,
                                    subtotal: i.subtotal,
                                  ),
                                )
                                .toList(),
                            total: cartState.total,
                            vatInfo: vatInfo,
                            paymentMethod: _method,
                            amountReceived: _method == 'cash'
                                ? _received
                                : null,
                            changeAmount: _method == 'cash' && _change >= 0
                                ? _change
                                : null,
                            note: _noteCtrl.text.trim().isEmpty
                                ? null
                                : _noteCtrl.text.trim(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<SaleBloc, SaleState>(
                builder: (_, state) {
                  final isProcessing = state.status == SaleStatus.processing;
                  final canConfirm =
                      _method != 'cash' || _received >= widget.effectiveTotal;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_method == 'cash' && !canConfirm && _received > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            context.l10n.insufficientCash,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      FilledButton.icon(
                        onPressed: isProcessing || !canConfirm
                            ? null
                            : _confirm,
                        icon: isProcessing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          context.l10n.confirmPaymentAmount(
                            currency,
                            widget.effectiveTotal.toStringAsFixed(2),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<double> _quickAmounts() {
    final total = widget.effectiveTotal;
    final roundedTen = (total / 10).ceil() * 10.0;
    final roundedHundred = (total / 100).ceil() * 100.0;
    final nextTen = roundedTen > total ? roundedTen : roundedTen + 10;
    final nextHundred = roundedHundred > total
        ? roundedHundred
        : roundedHundred + 100;
    return {total, nextTen, nextHundred}.where((v) => v > 0).toList()..sort();
  }
}
