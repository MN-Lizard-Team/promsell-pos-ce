import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/promptpay_payment_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/cash_input_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_total_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_input_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_method_selector.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CheckoutBody extends StatefulWidget {
  const CheckoutBody({super.key});

  @override
  State<CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<CheckoutBody> {
  String _method = 'cash';
  final _receivedCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  bool _submitted = false;
  bool _inPaymentFlow = false;
  double _effectiveTotal = 0;
  Timer? _processingTimeoutTimer;

  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;
  double get _change => _received - _effectiveTotal;

  void _startProcessingTimeout(BuildContext ctx) {
    _processingTimeoutTimer?.cancel();
    _processingTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted) return;
      _submitted = false;
      _inPaymentFlow = false;
      AppSnackBar.error(ctx, ctx.l10n.saleTimeout);
    });
  }

  void _cancelProcessingTimeout() {
    _processingTimeoutTimer?.cancel();
    _processingTimeoutTimer = null;
  }

  @override
  void dispose() {
    _cancelProcessingTimeout();
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
    setState(() {});
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
    final cartState = context.read<CartBloc>().state;
    context.read<CheckoutBloc>().add(
      CheckoutConfirmed(
        paymentMethod: _method,
        vatMode: settings.vatMode,
        vatRate: settings.vatRate,
        cartDiscountType: cartState.cartDiscountType,
        cartDiscountValue: cartState.cartDiscountValue,
        cartDiscountAmount: cartState.hasCartDiscount
            ? cartState.cartDiscountAmount
            : null,
        amountReceived: _method == 'cash' ? _received : _effectiveTotal,
        changeAmount: _method == 'cash' && _change >= 0 ? _change : 0,
        note: effectiveNote.isEmpty ? null : effectiveNote,
      ),
    );
  }

  List<double> _quickAmounts() {
    final total = _effectiveTotal;
    final roundedTen = (total / 10).ceil() * 10.0;
    final roundedHundred = (total / 100).ceil() * 100.0;
    final nextTen = roundedTen > total ? roundedTen : roundedTen + 10;
    final nextHundred = roundedHundred > total
        ? roundedHundred
        : roundedHundred + 100;
    final unique = <double>{
      total,
      nextTen,
      nextHundred,
    }.where((v) => v > 0).toList()..sort();
    if (unique.length < 2) {
      unique.add(total + 20);
      unique.sort();
    }
    return unique;
  }

  void _showReceiptDialog(
    BuildContext context, {
    required Settings settings,
    required CartState cartState,
    required dynamic vatInfo,
  }) {
    final labels = ReceiptLabels(
      receipt: context.l10n.receiptLabelReceipt,
      payment: context.l10n.receiptLabelPayment,
      paymentMethodLabel: localizePaymentMethod(context, _method),
      total: context.l10n.receiptLabelTotal,
      received: context.l10n.receiptLabelReceived,
      change: context.l10n.receiptLabelChange,
      note: context.l10n.receiptLabelNote,
      vat: context.l10n.receiptLabelVat,
      vatIncluded: context.l10n.receiptLabelVatIncluded(settings.vatRate),
      subtotal: context.l10n.receiptLabelSubtotal,
      itemDiscounts: context.l10n.receiptItemDiscounts,
      cartDiscount: context.l10n.receiptCartDiscount,
    );
    final style = switch (settings.receiptPreviewStyle) {
      'card' => ReceiptPreviewStyle.card,
      'none' => ReceiptPreviewStyle.none,
      _ => ReceiptPreviewStyle.thermal,
    };
    final items = cartState.items
        .map(
          (i) => ReceiptPreviewItem(
            name: i.product.name,
            qty: i.qty,
            price: i.product.price,
            subtotal: i.subtotal,
            imagePath: i.product.imagePath,
            imageThumbnailPath: i.product.imageThumbnailPath,
            imageUrl: i.product.imageUrl,
          ),
        )
        .toList();
    CheckoutReceiptDialog.show(
      context,
      settings: settings,
      labels: labels,
      style: style,
      items: items,
      total: _effectiveTotal,
      vatInfo: vatInfo,
      paymentMethod: _method,
      amountReceived: _method == 'cash' ? _received : null,
      changeAmount: _method == 'cash' && _change >= 0 ? _change : null,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          (curr.status == CheckoutStatus.failure ||
              curr.status == CheckoutStatus.success ||
              curr.status == CheckoutStatus.waitingPayment ||
              curr.status == CheckoutStatus.idle ||
              curr.status == CheckoutStatus.processing),
      listener: (ctx, state) {
        if (state.status == CheckoutStatus.processing) {
          _startProcessingTimeout(ctx);
          return;
        }
        if (state.status == CheckoutStatus.waitingPayment) {
          _inPaymentFlow = true;
          _cancelProcessingTimeout();
          final cartState = ctx.read<CartBloc>().state;
          final settings = ctx.read<SettingsCubit>().state.settings;
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => PromptPayPaymentPage(
                total: _effectiveTotal,
                currency: settings.currency,
                promptpayId: settings.promptpayId,
                settings: settings,
                bloc: ctx.read<CheckoutBloc>(),
                items: cartState.items,
              ),
            ),
          );
          return;
        }
        if (state.status == CheckoutStatus.success) {
          _cancelProcessingTimeout();
          final wasInFlow = _inPaymentFlow;
          _inPaymentFlow = false;
          _submitted = false;
          if (wasInFlow) {
            Navigator.of(ctx).pop();
          }
          Navigator.of(ctx).pop();
          return;
        }
        if (state.status == CheckoutStatus.idle && _inPaymentFlow) {
          _cancelProcessingTimeout();
          _inPaymentFlow = false;
          _submitted = false;
          Navigator.of(ctx).pop();
          Navigator.of(ctx).pop();
          return;
        }
        if (state.status == CheckoutStatus.failure) {
          _cancelProcessingTimeout();
          final wasInFlow = _inPaymentFlow;
          _inPaymentFlow = false;
          _submitted = false;
          if (wasInFlow) {
            Navigator.of(ctx).pop();
          }
          final msg = state.errorMessage == 'cartEmpty'
              ? ctx.l10n.cartEmpty
              : state.errorMessage ?? ctx.l10n.saleError;
          AppSnackBar.error(ctx, msg);
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (_, cartState) {
          final settings = context.read<SettingsCubit>().state.settings;
          final currency = settings.currency;
          final vatInfo = sl<ReceiptPdfService>().calculateVat(
            total: cartState.total,
            rate: settings.vatRate,
            mode: settings.vatMode,
          );
          _effectiveTotal = vatInfo?.totalWithVat ?? cartState.total;

          return SingleChildScrollView(
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
                CheckoutTotalCard(
                  itemsSubtotal: cartState.itemsSubtotal,
                  itemsDiscountTotal: cartState.items.fold(
                    0.0,
                    (s, i) => s + i.discountAmount,
                  ),
                  hasCartDiscount: cartState.hasCartDiscount,
                  cartDiscountAmount: cartState.cartDiscountAmount,
                  vatInfo: vatInfo,
                  vatRate: settings.vatRate,
                  effectiveTotal: _effectiveTotal,
                  currency: currency,
                ),
                const SizedBox(height: 16),
                PaymentMethodSelector(
                  method: _method,
                  promptpayEnabled: settings.promptpayId.isNotEmpty,
                  onChanged: (m) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _method = m;
                      _referenceCtrl.clear();
                    });
                  },
                ),
                if (_method == 'cash')
                  CashInputSection(
                    quickAmounts: _quickAmounts(),
                    receivedController: _receivedCtrl,
                    currency: currency,
                    effectiveTotal: _effectiveTotal,
                    onReceivedChanged: _setReceived,
                    change: _change,
                  )
                else
                  PaymentInputSection(
                    method: _method,
                    referenceController: _referenceCtrl,
                    noteController: _noteCtrl,
                    settings: settings,
                  ),
                if (_method != 'promptpay' && _method != 'cash') ...[
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 20),
                BlocBuilder<CheckoutBloc, CheckoutState>(
                  builder: (_, checkoutState) {
                    final isProcessing =
                        checkoutState.status == CheckoutStatus.processing;
                    final canConfirm =
                        !cartState.isEmpty &&
                        (_method != 'cash' || _received >= _effectiveTotal);

                    return FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        textStyle: const TextStyle(
                          fontFamily: 'NotoSansThai',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: isProcessing || !canConfirm || _submitted
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              _confirm();
                            },
                      icon: isProcessing || _submitted
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 24),
                      label: Text(
                        context.l10n.confirmPaymentAmount(
                          currency,
                          _effectiveTotal.toStringAsFixed(2),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (settings.showPreSalePreview &&
                    settings.receiptPreviewStyle != 'none' &&
                    !cartState.isEmpty)
                  CheckoutReceiptPreview(
                    settings: settings,
                    items: cartState.items,
                    effectiveTotal: _effectiveTotal,
                    vatInfo: vatInfo,
                    method: _method,
                    noteText: _noteCtrl.text,
                    amountReceived: _method == 'cash' ? _received : null,
                    changeAmount: _method == 'cash' && _change >= 0
                        ? _change
                        : null,
                    onTapPreview: () => _showReceiptDialog(
                      context,
                      settings: settings,
                      cartState: cartState,
                      vatInfo: vatInfo,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
