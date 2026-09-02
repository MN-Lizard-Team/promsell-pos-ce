import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/cash_input_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_confirm_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_restaurant_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_status_listener.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_tender_helpers.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_confirm_dock.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_sticky_payable.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_total_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_input_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_method_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/customer_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/promotion_selector.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Checkout form body. Public API unchanged: `const CheckoutBody()`.
class CheckoutBody extends StatefulWidget {
  const CheckoutBody({super.key, this.selectedItemIds});

  /// When non-null, only these cart line IDs are sold.
  final List<String>? selectedItemIds;

  @override
  State<CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<CheckoutBody> {
  String _method = 'cash';
  bool _splitTender = false;

  /// Advanced split UI — collapsed by default (single-tender first).
  bool _splitSectionOpen = false;
  final _splitCashCtrl = TextEditingController();
  String _orderType = 'delivery';
  String _orderChannel = 'walkin';
  String? _selectedTableId;
  final _receivedCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _externalRefCtrl = TextEditingController();
  final _flags = CheckoutFlowFlags();
  double _effectiveTotal = 0;
  bool _cashUserEdited = false;
  bool _restaurantSeeded = false;

  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;

  /// Cash leg for change SSOT (Wave P2): split uses split field; pure cash uses bill.
  double get _cashTenderAmount {
    if (_splitTender) {
      return double.tryParse(_splitCashCtrl.text) ?? 0;
    }
    if (_method == 'cash') return _effectiveTotal;
    return 0;
  }

  /// Sale write change — never negative (cash leg SSOT).
  double get _change => CheckoutTenderHelpers.changeForCashLeg(
    received: _received,
    payableTotal: _effectiveTotal,
    cashTenderAmount: _cashTenderAmount,
  );

  /// UI ChangePreview — negative means shortfall ("Remaining").
  double get _changePreview {
    if (_cashTenderAmount <= 0) return 0;
    return _received - _cashTenderAmount;
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _flags.dispose();
    _receivedCtrl.dispose();
    _splitCashCtrl.dispose();
    _noteCtrl.dispose();
    _referenceCtrl.dispose();
    _externalRefCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_flags.submitted) return;
    _flags.submitted = true;
    setState(() {});
    HapticFeedback.mediumImpact();
    CheckoutConfirmController.confirm(
      context: context,
      method: _method,
      splitTender: _splitTender,
      splitCashCtrl: _splitCashCtrl,
      receivedCtrl: _receivedCtrl,
      noteCtrl: _noteCtrl,
      referenceCtrl: _referenceCtrl,
      externalRefCtrl: _externalRefCtrl,
      orderType: _orderType,
      orderChannel: _orderChannel,
      selectedTableId: _selectedTableId,
      selectedItemIds: widget.selectedItemIds,
      effectiveTotal: _effectiveTotal,
      received: _received,
    );
  }

  @override
  Widget build(BuildContext context) {
    _flags.onProcessingTimeout = () {
      if (mounted) setState(() {});
    };
    return CheckoutStatusListener(
      flags: _flags,
      effectiveTotal: _effectiveTotal,
      localizeError: CheckoutTenderHelpers.localizeCheckoutError,
      onFlagsChanged: () {
        if (mounted) setState(() {});
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (_, cartState) {
          final settings = context.read<SettingsCubit>().state.settings;
          final currency = settings.currency;
          final isRestaurant = settings.isRestaurantMode;
          final payable = cartState.payableTotals(settings);
          final serviceChargeAmount = payable.serviceChargeAmount.value;
          _effectiveTotal = payable.payableTotal.value;
          if (!_restaurantSeeded && isRestaurant) {
            _restaurantSeeded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final seeded = CheckoutRestaurantSection.seedFromCart(
                cartState,
                settings,
                alreadySeeded: false,
              );
              setState(() {
                _orderType = seeded.orderType;
                _orderChannel = seeded.orderChannel;
                _selectedTableId = seeded.tableId;
              });
              final ext = seeded.externalRef;
              if (ext != null && ext.isNotEmpty) {
                _externalRefCtrl.text = ext;
              }
            });
          }
          CashInputSection.maybePrefillCash(
            controller: _receivedCtrl,
            method: _method,
            userEdited: _cashUserEdited,
            payable: _effectiveTotal,
          );
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

          final pos = context.posTheme;
          final theme = Theme.of(context);
          final canConfirm =
              !cartState.isEmpty &&
              (_splitTender
                  ? (() {
                      final cash = double.tryParse(_splitCashCtrl.text) ?? 0;
                      return cash > 0 && cash < _effectiveTotal;
                    })()
                  : (_method != 'cash' || _received >= _effectiveTotal));

          // Tender-first IA: sticky payable → payment methods → inputs →
          // breakdown / customer / restaurant lower on the scroll.
          return ColoredBox(
            color: pos.catalogBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckoutStickyPayable(
                  amount: _effectiveTotal,
                  currency: currency,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tender block — ticket paper, no settings header
                        // (AppBar already says Payment / ชำระเงิน).
                        Material(
                          elevation: pos.elevFlat,
                          color: pos.billStubPaper,
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              pos.billStubRadius,
                            ),
                            side: BorderSide(color: pos.billStubBorder),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PaymentMethodSelector(
                                  method: _method,
                                  promptpayEnabled:
                                      settings.promptpayId.isNotEmpty,
                                  onChanged: (m) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _method = m;
                                      _referenceCtrl.clear();
                                      if (m == 'cash') {
                                        _cashUserEdited = false;
                                      }
                                      // Pure cash path: drop split.
                                      if (m == 'cash' && _splitTender) {
                                        _splitTender = false;
                                      }
                                    });
                                  },
                                ),
                                if (_method == 'cash')
                                  CashInputSection(
                                    quickAmounts:
                                        CheckoutTenderHelpers.quickAmounts(
                                          _effectiveTotal,
                                        ),
                                    receivedController: _receivedCtrl,
                                    currency: currency,
                                    effectiveTotal: _effectiveTotal,
                                    onReceivedChanged: (value) {
                                      _cashUserEdited = true;
                                      _receivedCtrl.text = value
                                          .toStringAsFixed(2);
                                      HapticFeedback.selectionClick();
                                      setState(() {});
                                    },
                                    change: _changePreview,
                                  )
                                else
                                  PaymentInputSection(
                                    method: _method,
                                    referenceController: _referenceCtrl,
                                    noteController: _noteCtrl,
                                    settings: settings,
                                  ),
                                // Split — advanced, collapsed (WS-E discoverability).
                                const SizedBox(height: 4),
                                InkWell(
                                  key: const ValueKey(
                                    'sale_split_tender_toggle',
                                  ),
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _splitSectionOpen = !_splitSectionOpen;
                                      if (!_splitSectionOpen && !_splitTender) {
                                        // keep closed
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.call_split,
                                          size: 18,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            context.l10n.splitTenderTitle,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  fontFamily: 'NotoSansThai',
                                                  fontWeight: FontWeight.w600,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                        if (_splitTender)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        Icon(
                                          _splitSectionOpen
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          size: 20,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_splitSectionOpen) ...[
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      context.l10n.splitTenderTitle,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    subtitle: Text(
                                      context.l10n.splitTenderSubtitle,
                                    ),
                                    value: _splitTender,
                                    onChanged: (v) {
                                      setState(() {
                                        _splitTender = v;
                                        if (v) {
                                          _splitSectionOpen = true;
                                          if (_splitCashCtrl.text.isEmpty) {
                                            _splitCashCtrl.text =
                                                (_effectiveTotal / 2)
                                                    .toStringAsFixed(2);
                                          }
                                          if (_method == 'cash') {
                                            _method =
                                                settings.promptpayId.isNotEmpty
                                                ? 'promptpay'
                                                : 'transfer';
                                          }
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
                                    Builder(
                                      builder: (context) {
                                        final other =
                                            CheckoutTenderHelpers.remainingOtherAmount(
                                              payableTotal: Money.fromDouble(
                                                _effectiveTotal,
                                              ),
                                              splitCashText:
                                                  _splitCashCtrl.text,
                                            );
                                        if (!other.isPositive) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            key: const ValueKey(
                                              'sale_split_remaining_leg',
                                            ),
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  context.l10n.remainingAmount,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ),
                                              MoneyText(
                                                value: other.value,
                                                currency: currency,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckoutTotalCard(
                          itemsSubtotal: cartState.itemsSubtotal.value,
                          itemsDiscountTotal: cartState.items.fold(
                            0.0,
                            (s, i) => s + i.discountAmount.value,
                          ),
                          hasCartDiscount: cartState.hasCartDiscount,
                          cartDiscountAmount:
                              cartState.cartDiscountAmount.value,
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
                          CheckoutRestaurantSection(
                            orderType: _orderType,
                            orderChannel: _orderChannel,
                            selectedTableId: _selectedTableId,
                            guestCount: cartState.guestCount,
                            externalRefCtrl: _externalRefCtrl,
                            onOrderTypeChanged: (v) {
                              setState(() => _orderType = v);
                              CheckoutRestaurantSection.syncOrderTypeToCart(
                                context,
                                v,
                              );
                            },
                            onOrderChannelChanged: (v) {
                              setState(() => _orderChannel = v);
                              CheckoutRestaurantSection.syncOrderChannelToCart(
                                context,
                                v,
                              );
                            },
                            onTableSelected: (v) {
                              setState(() => _selectedTableId = v);
                              CheckoutRestaurantSection.syncTableToCart(
                                context,
                                v,
                              );
                            },
                          ),
                        ],
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
                            // Cash leg only (split or pure cash) — not full-bill noise.
                            amountReceived: _cashTenderAmount > 0
                                ? _received
                                : null,
                            changeAmount: _cashTenderAmount > 0
                                ? _change
                                : null,
                            cartDiscount: cartState.hasCartDiscount
                                ? cartState.cartDiscountAmount.value
                                : null,
                            promotionDiscount:
                                cartState.promotionDiscountAmount > 0
                                ? cartState.promotionDiscountAmount
                                : null,
                            serviceCharge: serviceChargeAmount > 0
                                ? serviceChargeAmount
                                : null,
                            serviceChargeRate: payable.serviceChargeRate > 0
                                ? payable.serviceChargeRate
                                : null,
                            onTapPreview: () =>
                                CheckoutConfirmController.showReceiptDialog(
                                  context,
                                  settings: settings,
                                  cartState: cartState,
                                  method: _method,
                                  effectiveTotal: _effectiveTotal,
                                  received: _received,
                                  change: _change,
                                  noteCtrl: _noteCtrl,
                                  vatInfo: vatInfo,
                                  cashTenderAmount: _cashTenderAmount,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                CheckoutConfirmDock(
                  currency: currency,
                  effectiveTotal: _effectiveTotal,
                  canConfirm: canConfirm,
                  submitted: _flags.submitted,
                  onConfirm: _confirm,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
