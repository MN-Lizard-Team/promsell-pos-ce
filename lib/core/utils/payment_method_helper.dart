import 'package:flutter/widgets.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

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
    default:
      return method;
  }
}
