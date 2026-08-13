import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/domain/services/receipt_line_name.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_tender_helpers.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Pure functions for checkout confirmation and receipt dialog construction.
abstract final class CheckoutConfirmController {
  CheckoutConfirmController._();

  /// Build tenders and dispatch [CheckoutConfirmed] to [CheckoutBloc].
  static void confirm({
    required BuildContext context,
    required String method,
    required bool splitTender,
    required TextEditingController splitCashCtrl,
    required TextEditingController receivedCtrl,
    required TextEditingController noteCtrl,
    required TextEditingController referenceCtrl,
    required TextEditingController externalRefCtrl,
    required String orderType,
    required String orderChannel,
    required String? selectedTableId,
    required double effectiveTotal,
    required double received,
  }) {
    final note = noteCtrl.text.trim();
    final reference = referenceCtrl.text.trim();
    final settings = context.read<SettingsCubit>().state.settings;
    final cartState = context.read<CartBloc>().state;
    final isRestaurant = settings.isRestaurantMode;
    final payable = cartState.payableTotals(settings);
    final tenders = CheckoutTenderHelpers.buildTenders(
      splitTender: splitTender,
      method: method,
      payableTotal: payable.payableTotal,
      reference: reference,
      splitCashText: splitCashCtrl.text,
    );
    final headerMethod = tenders.length == 1 ? tenders.first.method : 'mixed';
    final cashTender = tenders
        .where((p) => p.method == 'cash')
        .fold(Money.zero, (s, p) => s + p.amount);
    // Wave P2: change always from cash leg (ignore caller full-bill change).
    final effectiveReceived = cashTender > Money.zero
        ? Money.fromDouble(received > 0 ? received : cashTender.value)
        : payable.payableTotal;
    final effectiveChange = cashTender > Money.zero
        ? Money.fromDouble(
            CheckoutTenderHelpers.changeForCashLeg(
              received: effectiveReceived.value,
              payableTotal: payable.payableTotal.value,
              cashTenderAmount: cashTender.value,
            ),
          )
        : Money.zero;
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
        amountReceived: effectiveReceived,
        changeAmount: effectiveChange,
        note: note.isEmpty ? null : note,
        paymentReference: reference.isEmpty ? null : reference,
        orderType: isRestaurant ? orderType : 'delivery',
        orderChannel: isRestaurant ? orderChannel : 'walkin',
        externalOrderRef: isRestaurant && orderType == 'delivery'
            ? (externalRefCtrl.text.trim().isEmpty
                  ? null
                  : externalRefCtrl.text.trim())
            : null,
        tableId: isRestaurant && orderType == 'dinein' ? selectedTableId : null,
        serviceChargeRate: payable.serviceChargeRate,
        serviceChargeAmount: payable.serviceChargeAmount,
      ),
    );
  }

  /// Resolve customer/promotion names and show the receipt preview dialog.
  static Future<void> showReceiptDialog(
    BuildContext context, {
    required Settings settings,
    required CartState cartState,
    required String method,
    required double effectiveTotal,
    required double received,
    required double change,
    required TextEditingController noteCtrl,
    required dynamic vatInfo,
    double cashTenderAmount = 0,
  }) async {
    String? customerName;
    final customerId = cartState.customerId;
    if (customerId != null) {
      try {
        final customer = await sl<CustomerRepository>().getCustomerById(
          customerId,
        );
        customerName = customer?.name;
      } catch (e, stack) {
        AppLogger.warning(
          'Failed to fetch customer for receipt',
          error: e,
          stack: stack,
        );
      }
    }
    String? promotionName;
    final promotionId = cartState.promotionId;
    if (promotionId != null) {
      try {
        final promo = await sl<PromotionRepository>().getPromotionById(
          promotionId,
        );
        promotionName = promo?.name;
      } catch (e, stack) {
        AppLogger.warning(
          'Failed to fetch promotion for receipt',
          error: e,
          stack: stack,
        );
      }
    }
    if (!context.mounted) return;
    final payable = cartState.payableTotals(settings);
    final l = context.l10n;
    final labels = ReceiptLabels(
      receipt: l.receiptLabelReceipt,
      payment: l.receiptLabelPayment,
      paymentMethodLabel: localizePaymentMethod(context, method),
      total: l.receiptLabelTotal,
      received: l.receiptLabelReceived,
      change: l.receiptLabelChange,
      note: l.receiptLabelNote,
      vat: l.receiptLabelVat,
      vatIncluded: l.receiptLabelVatIncluded(settings.vatRate),
      subtotal: l.receiptLabelSubtotal,
      itemDiscounts: l.receiptItemDiscounts,
      cartDiscount: l.receiptCartDiscount,
      serviceCharge: l.serviceCharge,
      customer: l.receiptLabelCustomer,
      customerName: customerName,
      promotion: l.receiptLabelPromotion,
      promotionName: promotionName,
      // Row **title** only — amount is a separate money column.
      promotionDiscount: l.receiptLabelPromotionDiscount,
      notTaxInvoice: l.receiptNotTaxInvoice,
      taxId: l.receiptTaxId,
      taxInvoice: l.receiptTaxInvoice,
      thankYou: l.receiptThankYouDefault,
    );
    final style = switch (settings.receiptPreviewStyle) {
      'card' => ReceiptPreviewStyle.card,
      'none' => ReceiptPreviewStyle.none,
      _ => ReceiptPreviewStyle.thermal,
    };
    final items = cartState.items
        .map(
          (i) => ReceiptPreviewItem(
            name: receiptLineName(
              productName: i.product.name,
              selectedOptions: i.selectedOptions,
            ),
            qty: i.qty,
            price: i.product.price.value,
            subtotal: i.subtotal.value,
            imagePath: i.product.imagePath,
            imageThumbnailPath: i.product.imageThumbnailPath,
            imageUrl: i.product.imageUrl,
          ),
        )
        .toList();
    final showCash = cashTenderAmount > 0 || method == 'cash';
    CheckoutReceiptDialog.show(
      context,
      settings: settings,
      labels: labels,
      style: style,
      items: items,
      total: effectiveTotal,
      vatInfo: vatInfo,
      paymentMethod: labels.paymentMethodLabel,
      amountReceived: showCash ? received : null,
      changeAmount: showCash ? change : null,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      cartDiscount: cartState.hasCartDiscount
          ? cartState.cartDiscountAmount.value
          : null,
      promotionDiscount: cartState.promotionDiscountAmount > 0
          ? cartState.promotionDiscountAmount
          : null,
      serviceCharge: payable.serviceChargeAmount.isPositive
          ? payable.serviceChargeAmount.value
          : null,
      serviceChargeRate: payable.serviceChargeRate > 0
          ? payable.serviceChargeRate
          : null,
      notTaxInvoiceDisclaimer: l.receiptNotTaxInvoice,
    );
  }
}
