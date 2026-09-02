import 'package:flutter/widgets.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

String normalizePaymentMethod(String method) {
  switch (method) {
    case 'เงินสด':
    case 'cash':
      return 'cash';
    case 'โอน':
    case 'transfer':
      return 'transfer';
    case 'บัตร':
    case 'card':
      return 'card';
    case 'promptpay':
      return 'promptpay';
    case 'mixed':
      return 'mixed';
    default:
      return method;
  }
}

String localizePaymentMethod(BuildContext context, String method) {
  final l10n = context.l10n;
  switch (normalizePaymentMethod(method)) {
    case 'cash':
      return l10n.cash;
    case 'transfer':
      return l10n.transfer;
    case 'card':
      return l10n.card;
    case 'promptpay':
      return l10n.promptpay;
    case 'mixed':
      return l10n.paymentMixed;
    default:
      return method;
  }
}

/// Compact payment summary for history list / receipt header.
String formatSalePaymentSummary(
  BuildContext context,
  Sale sale, {
  String? currency,
}) {
  final cur = currency ?? '฿';
  if (sale.payments.length > 1) {
    return sale.payments
        .map((p) {
          final label = localizePaymentMethod(context, p.method);
          final amt = CurrencyFormatter.formatGroupedWithSymbol(
            p.amount.value,
            cur,
          );
          return '$label $amt';
        })
        .join(' + ');
  }
  if (sale.payments.length == 1) {
    return localizePaymentMethod(context, sale.payments.first.method);
  }
  return localizePaymentMethod(context, sale.paymentMethod);
}

String maskPaymentReference(String reference, {int visibleSuffix = 4}) {
  final value = reference.trim();
  if (value.isEmpty) return value;
  if (value.length <= visibleSuffix) return '••••';
  return '${List.filled(value.length - visibleSuffix, '•').join()}${value.substring(value.length - visibleSuffix)}';
}

List<String> formatSalePaymentLines(
  BuildContext context,
  Sale sale, {
  String? currency,
}) {
  final cur = currency ?? '฿';
  if (sale.payments.isEmpty) {
    return [localizePaymentMethod(context, sale.paymentMethod)];
  }
  return [
    for (final p in sale.payments)
      '${localizePaymentMethod(context, p.method)}  '
          '${CurrencyFormatter.formatGroupedWithSymbol(p.amount.value, cur)}'
          '${p.reference != null && p.reference!.isNotEmpty ? ' (${maskPaymentReference(p.reference!)})' : ''}',
  ];
}

/// True when any tender line (or single method) is PromptPay.
bool saleIncludesPromptPay(Sale sale) {
  if (sale.payments.isNotEmpty) {
    return sale.payments.any(
      (p) => normalizePaymentMethod(p.method) == 'promptpay',
    );
  }
  return normalizePaymentMethod(sale.paymentMethod) == 'promptpay';
}

Money saleCashTenderTotal(Sale sale) {
  if (sale.payments.isEmpty) {
    return normalizePaymentMethod(sale.paymentMethod) == 'cash'
        ? sale.totalAmount
        : Money.zero;
  }
  return sale.payments
      .where((p) => normalizePaymentMethod(p.method) == 'cash')
      .fold(Money.zero, (s, p) => s + p.amount);
}
