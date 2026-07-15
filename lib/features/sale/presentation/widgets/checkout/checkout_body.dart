import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/promptpay_payment_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/cash_input_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_total_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/order_channel_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/order_type_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/table_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_input_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_method_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/sale_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/customer_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/promotion_selector.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CheckoutBody extends StatefulWidget {
  const CheckoutBody({super.key});

  @override
  State<CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<CheckoutBody> {
  String _method = 'cash';
  bool _splitTender = false;
  final _splitCashCtrl = TextEditingController();
  String _orderType = 'delivery';
  String _orderChannel = 'walkin';
  String? _selectedTableId;
  final _receivedCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _externalRefCtrl = TextEditingController();
  bool _submitted = false;
  bool _inPaymentFlow = false;
  double _effectiveTotal = 0;
  Timer? _processingTimeoutTimer;
  bool _cashUserEdited = false;
  bool _restaurantSeeded = false;

  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;
  double get _change => _received - _effectiveTotal;

  void _startProcessingTimeout(BuildContext ctx) {
    _processingTimeoutTimer?.cancel();
    _processingTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted) return;
      // Do not unlock _submitted while CreateSale may still complete.
      AppSnackBar.error(ctx, ctx.l10n.saleTimeout);
    });
  }

  void _cancelProcessingTimeout() {
    _processingTimeoutTimer?.cancel();
    _processingTimeoutTimer = null;
  }

  /// Pop PromptPay and payment shell until sale/catalog host remains.
  void _popCheckoutShells(
    NavigatorState nav, {
    required bool includePromptPay,
  }) {
    var poppedPrompt = false;
    var poppedShell = false;
    while (nav.canPop()) {
      final name = ModalRoute.of(nav.context)?.settings.name;
      if (includePromptPay &&
          !poppedPrompt &&
          name == SalePaymentRoutes.promptPay) {
        nav.pop();
        poppedPrompt = true;
        continue;
      }
      if (!poppedShell &&
          (name == SalePaymentRoutes.paymentSheet ||
              name == SalePaymentRoutes.checkoutPage)) {
        nav.pop();
        poppedShell = true;
        break;
      }
      // Fallback when route names missing (tests / legacy): pop once or twice.
      if (name == null || !SalePaymentRoutes.isCheckoutShell(name)) {
        if (includePromptPay && !poppedPrompt) {
          nav.pop();
          poppedPrompt = true;
          if (nav.canPop()) {
            nav.pop();
            poppedShell = true;
          }
        } else if (!poppedShell && nav.canPop()) {
          nav.pop();
          poppedShell = true;
        }
        break;
      }
      break;
    }
  }

  @override
  void dispose() {
    _cancelProcessingTimeout();
    _receivedCtrl.dispose();
    _splitCashCtrl.dispose();
    _noteCtrl.dispose();
    _referenceCtrl.dispose();
    _externalRefCtrl.dispose();
    super.dispose();
  }

  void _seedRestaurantFromCart(CartState cart, Settings settings) {
    if (_restaurantSeeded || !settings.isRestaurantMode) return;
    _restaurantSeeded = true;
    final ot = cart.orderType;
    _orderType = ot.isNotEmpty ? ot : 'dinein';
    final ch = cart.orderChannel;
    _orderChannel = ch.isNotEmpty ? ch : 'walkin';
    _selectedTableId = cart.tableId;
    final ext = cart.externalOrderRef;
    if (ext != null && ext.isNotEmpty) {
      _externalRefCtrl.text = ext;
    }
  }

  void _syncOrderTypeToCart(String orderType) {
    context.read<CartBloc>().add(CartOrderTypeChanged(orderType));
    if (orderType != 'dinein') {
      context.read<CartBloc>().add(const CartTableAssigned(null));
    }
  }

  void _syncOrderChannelToCart(String channel) {
    context.read<CartBloc>().add(CartOrderChannelChanged(channel));
  }

  void _syncTableToCart(String? tableId) {
    context.read<CartBloc>().add(CartTableAssigned(tableId));
  }

  void _maybePrefillCash(double payable) {
    if (_method != 'cash' || _cashUserEdited) return;
    if (payable <= 0) return;
    final text = payable.toStringAsFixed(2);
    if (_receivedCtrl.text != text) {
      _receivedCtrl.text = text;
    }
  }

  void _setReceived(double value, {bool fromUser = true}) {
    if (fromUser) _cashUserEdited = true;
    _receivedCtrl.text = value.toStringAsFixed(2);
    HapticFeedback.selectionClick();
    setState(() {});
  }

  List<SalePayment> _buildTenders(Money payableTotal) {
    if (!_splitTender) {
      return [
        SalePayment(
          method: _method,
          amount: payableTotal,
          reference: _referenceCtrl.text.trim().isEmpty
              ? null
              : _referenceCtrl.text.trim(),
        ),
      ];
    }
    final cashPart = Money.fromDouble(
      double.tryParse(_splitCashCtrl.text) ?? 0,
    );
    final other = (payableTotal - cashPart).clampToZero();
    final otherMethod = _method == 'cash' ? 'promptpay' : _method;
    return [
      if (cashPart > Money.zero)
        SalePayment(method: 'cash', amount: cashPart, sortOrder: 0),
      if (other > Money.zero)
        SalePayment(
          method: otherMethod,
          amount: other,
          reference: _referenceCtrl.text.trim().isEmpty
              ? null
              : _referenceCtrl.text.trim(),
          sortOrder: 1,
        ),
    ];
  }

  void _confirm() {
    if (_submitted) return;
    _submitted = true;
    setState(() {});
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    final reference = _referenceCtrl.text.trim();
    final settings = context.read<SettingsCubit>().state.settings;
    final cartState = context.read<CartBloc>().state;
    final isRestaurant = settings.isRestaurantMode;
    final payable = cartState.payableTotals(settings);
    final tenders = _buildTenders(payable.payableTotal);
    final headerMethod = tenders.length == 1 ? tenders.first.method : 'mixed';
    final cashTender = tenders
        .where((p) => p.method == 'cash')
        .fold(Money.zero, (s, p) => s + p.amount);
    context.read<CheckoutBloc>().add(
      CheckoutConfirmed(
        paymentMethod: headerMethod,
        payments: tenders,
        vatMode: settings.vatMode,
        vatRate: settings.vatRate,
        cartDiscountType: cartState.cartDiscountType,
        cartDiscountValue: cartState.cartDiscountValue,
        cartDiscountAmount: cartState.hasCartDiscount
            ? cartState.cartDiscountAmount
            : null,
        amountReceived: cashTender > Money.zero
            ? Money.fromDouble(_received > 0 ? _received : cashTender.value)
            : payable.payableTotal,
        changeAmount: cashTender > Money.zero && _change >= 0
            ? Money.fromDouble(_change)
            : Money.zero,
        note: note.isEmpty ? null : note,
        paymentReference: reference.isEmpty ? null : reference,
        orderType: isRestaurant ? _orderType : 'delivery',
        orderChannel: isRestaurant ? _orderChannel : 'walkin',
        externalOrderRef: isRestaurant && _orderType == 'delivery'
            ? (_externalRefCtrl.text.trim().isEmpty
                  ? null
                  : _externalRefCtrl.text.trim())
            : null,
        tableId: isRestaurant && _orderType == 'dinein'
            ? _selectedTableId
            : null,
        serviceChargeRate: payable.serviceChargeRate,
        serviceChargeAmount: payable.serviceChargeAmount,
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

  String _localizeCheckoutError(BuildContext ctx, String? key) {
    return switch (key) {
      'cartEmpty' => ctx.l10n.cartEmpty,
      'insufficientStock' => ctx.l10n.insufficientStock,
      'productNotFound' => ctx.l10n.productNotFound,
      'productInactive' => ctx.l10n.productInactive,
      'customerNotFound' => ctx.l10n.customerNotFound,
      'promotionNotFound' => ctx.l10n.promotionNotFound,
      'saleNotFound' => ctx.l10n.saleNotFound,
      'saleAlreadyVoided' => ctx.l10n.saleAlreadyVoided,
      'notFound' => ctx.l10n.notFound,
      'validationError' => ctx.l10n.validationError,
      'databaseError' => ctx.l10n.databaseError,
      'saleError' => ctx.l10n.saleError,
      'dayClosed' => ctx.l10n.dayClosedMessage,
      'paymentMismatch' => ctx.l10n.paymentMismatch,
      null => ctx.l10n.saleError,
      _ => ctx.l10n.saleError,
    };
  }

  Future<void> _showReceiptDialog(
    BuildContext context, {
    required Settings settings,
    required CartState cartState,
    required dynamic vatInfo,
  }) async {
    String? customerName;
    final customerId = cartState.customerId;
    if (customerId != null) {
      final customer = await sl<CustomerRepository>().getCustomerById(
        customerId,
      );
      customerName = customer?.name;
    }
    String? promotionName;
    final promotionId = cartState.promotionId;
    if (promotionId != null) {
      final promo = await sl<PromotionRepository>().getPromotionById(
        promotionId,
      );
      promotionName = promo?.name;
    }
    if (!context.mounted) return;
    final promoDiscountLabel = cartState.promotionDiscountAmount > 0
        ? '${settings.currency}${cartState.promotionDiscountAmount.toStringAsFixed(2)}'
        : null;
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
      customer: context.l10n.receiptLabelCustomer,
      customerName: customerName,
      promotion: context.l10n.receiptLabelPromotion,
      promotionName: promotionName,
      promotionDiscount: promoDiscountLabel,
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
            price: i.product.price.value,
            subtotal: i.subtotal.value,
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
          // Snack-only timeout; keep _submitted locked while CreateSale runs.
          _startProcessingTimeout(ctx);
          return;
        }
        if (state.status == CheckoutStatus.waitingPayment) {
          _inPaymentFlow = true;
          _cancelProcessingTimeout();
          final cartState = ctx.read<CartBloc>().state;
          final settings = ctx.read<SettingsCubit>().state.settings;
          // Split tender: QR only for PromptPay share; full bill when PP-only.
          final qrTotal = state.promptPayAmount ?? _effectiveTotal;
          Navigator.of(ctx).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: SalePaymentRoutes.promptPay),
              builder: (_) => PromptPayPaymentPage(
                total: qrTotal,
                billTotal:
                    (state.promptPayAmount != null &&
                        (state.promptPayAmount! - _effectiveTotal).abs() >
                            0.009)
                    ? _effectiveTotal
                    : null,
                currency: settings.currency,
                promptpayId: settings.promptpayId,
                settings: settings,
                bloc: ctx.read<CheckoutBloc>(),
                items: state.frozenItems ?? cartState.items,
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
          final sale = state.lastSale;
          final settings = ctx.read<SettingsCubit>().state.settings;
          final checkoutBloc = ctx.read<CheckoutBloc>();
          final nav = Navigator.of(ctx);

          // Capture host (under payment UI) before popping routes.
          final hostContext = nav.context;

          _popCheckoutShells(nav, includePromptPay: wasInFlow);

          checkoutBloc.add(const CheckoutReset());

          final showReceipt =
              sale != null &&
              settings.showPostSalePreview &&
              settings.receiptPreviewStyle != 'none';
          if (showReceipt) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!hostContext.mounted) return;
              SaleReceiptDialog.show(hostContext, sale, settings);
            });
          }
          return;
        }
        // PromptPay cancelled / timed out → only the PromptPay route was pushed.
        if (state.status == CheckoutStatus.idle && _inPaymentFlow) {
          _cancelProcessingTimeout();
          _inPaymentFlow = false;
          _submitted = false;
          final nav = Navigator.of(ctx);
          final name = ModalRoute.of(nav.context)?.settings.name;
          if (nav.canPop() &&
              (name == SalePaymentRoutes.promptPay || name == null)) {
            nav.pop();
          }
          return;
        }
        if (state.status == CheckoutStatus.failure) {
          _cancelProcessingTimeout();
          final wasInFlow = _inPaymentFlow;
          _inPaymentFlow = false;
          _submitted = false;
          if (wasInFlow) {
            final nav = Navigator.of(ctx);
            final name = ModalRoute.of(nav.context)?.settings.name;
            if (nav.canPop() &&
                (name == SalePaymentRoutes.promptPay || name == null)) {
              nav.pop();
            }
          }
          final msg = _localizeCheckoutError(ctx, state.errorMessage);
          AppSnackBar.error(ctx, msg);
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (_, cartState) {
          final settings = context.read<SettingsCubit>().state.settings;
          final currency = settings.currency;
          final isRestaurant = settings.isRestaurantMode;
          final payable = cartState.payableTotals(settings);
          final serviceChargeAmount = payable.serviceChargeAmount.value;
          _effectiveTotal = payable.payableTotal.value;
          _seedRestaurantFromCart(cartState, settings);
          _maybePrefillCash(_effectiveTotal);
          final ({
            double subtotal,
            double vatAmount,
            double totalWithVat,
            bool isInclusive,
          })?
          vatInfo = payable.vatMode == 'NONE' || payable.vatAmount.isZero
              ? null
              : (
                  subtotal: payable.netOfVat.value,
                  vatAmount: payable.vatAmount.value,
                  totalWithVat: payable.payableTotal.value,
                  isInclusive: payable.isVatInclusive,
                );

          // Scroll + sticky confirm (keyboard inset owned by PaymentSheet shell).
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormSectionCard(
                        icon: Icons.person_outline,
                        title: context.l10n.selectCustomer,
                        child: BlocBuilder<CartBloc, CartState>(
                          buildWhen: (p, c) =>
                              p.customerId != c.customerId ||
                              p.promotionId != c.promotionId,
                          builder: (context, cart) {
                            final dense =
                                cart.customerId != null ||
                                cart.promotionId != null;
                            return Column(
                              children: [
                                CustomerSelector(dense: dense),
                                PromotionSelector(dense: dense),
                              ],
                            );
                          },
                        ),
                      ),
                      if (isRestaurant) ...[
                        const SizedBox(height: 12),
                        FormSectionCard(
                          icon: Icons.restaurant_outlined,
                          title: context.l10n.orderType,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OrderTypeSelector(
                                orderType: _orderType,
                                onChanged: (v) {
                                  setState(() => _orderType = v);
                                  _syncOrderTypeToCart(v);
                                },
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.l10n.orderChannel,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              OrderChannelSelector(
                                orderChannel: _orderChannel,
                                onChanged: (v) {
                                  setState(() => _orderChannel = v);
                                  _syncOrderChannelToCart(v);
                                },
                              ),
                              if (_orderType == 'dinein') ...[
                                const SizedBox(height: 12),
                                TableSelector(
                                  selectedTableId: _selectedTableId,
                                  onSelected: (v) {
                                    setState(() => _selectedTableId = v);
                                    _syncTableToCart(v);
                                  },
                                ),
                              ],
                              if (_orderType == 'delivery') ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _externalRefCtrl,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.externalOrderRef,
                                    hintText: context.l10n.externalOrderRefHint,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      CheckoutTotalCard(
                        itemsSubtotal: cartState.itemsSubtotal.value,
                        itemsDiscountTotal: cartState.items.fold(
                          0.0,
                          (s, i) => s + i.discountAmount.value,
                        ),
                        hasCartDiscount: cartState.hasCartDiscount,
                        cartDiscountAmount: cartState.cartDiscountAmount.value,
                        promotionDiscountAmount:
                            cartState.promotionDiscountAmount,
                        serviceChargeAmount: serviceChargeAmount,
                        vatInfo: vatInfo,
                        vatRate: settings.vatRate,
                        effectiveTotal: _effectiveTotal,
                        currency: currency,
                      ),
                      const SizedBox(height: 12),
                      FormSectionCard(
                        icon: Icons.payments_outlined,
                        title: context.l10n.paymentTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PaymentMethodSelector(
                              method: _method,
                              promptpayEnabled: settings.promptpayId.isNotEmpty,
                              onChanged: (m) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _method = m;
                                  _referenceCtrl.clear();
                                  if (m == 'cash') {
                                    _cashUserEdited = false;
                                  }
                                });
                              },
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(context.l10n.splitTenderTitle),
                              subtitle: Text(context.l10n.splitTenderSubtitle),
                              value: _splitTender,
                              onChanged: (v) {
                                setState(() {
                                  _splitTender = v;
                                  if (v && _splitCashCtrl.text.isEmpty) {
                                    _splitCashCtrl.text = (_effectiveTotal / 2)
                                        .toStringAsFixed(2);
                                  }
                                  if (v && _method == 'cash') {
                                    _method = settings.promptpayId.isNotEmpty
                                        ? 'promptpay'
                                        : 'transfer';
                                  }
                                });
                              },
                            ),
                            if (_splitTender) ...[
                              TextField(
                                controller: _splitCashCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: context.l10n.splitCashAmount,
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 8),
                            ],
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
                          ],
                        ),
                      ),
                      if (settings.showPreSalePreview &&
                          settings.receiptPreviewStyle != 'none' &&
                          !cartState.isEmpty) ...[
                        const SizedBox(height: 20),
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
                    ],
                  ),
                ),
              ),
              Material(
                elevation: 8,
                color: Theme.of(context).colorScheme.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: BlocBuilder<CheckoutBloc, CheckoutState>(
                      builder: (_, checkoutState) {
                        final isProcessing =
                            checkoutState.status == CheckoutStatus.processing;
                        final canConfirm =
                            !cartState.isEmpty &&
                            (_splitTender
                                ? (() {
                                    final cash =
                                        double.tryParse(_splitCashCtrl.text) ??
                                        0;
                                    return cash > 0 && cash < _effectiveTotal;
                                  })()
                                : (_method != 'cash' ||
                                      _received >= _effectiveTotal));
                        final pos = context.posTheme;

                        return FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 56),
                            backgroundColor: pos.ctaFill,
                            foregroundColor: pos.ctaOnFill,
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
                              : const Icon(
                                  Icons.check_circle_outline,
                                  size: 24,
                                ),
                          label: Text(
                            context.l10n.confirmPaymentAmount(
                              currency,
                              _effectiveTotal.toStringAsFixed(2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
