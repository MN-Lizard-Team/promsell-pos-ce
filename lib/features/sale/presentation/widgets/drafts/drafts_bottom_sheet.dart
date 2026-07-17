import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';

/// Compatibility entry for saved bills.
///
/// Prefer [SavedBillsPage.open]. Kept so older call sites / docs still compile
/// until fully migrated.
@Deprecated('Use SavedBillsPage.open')
class DraftsBottomSheet {
  DraftsBottomSheet._();

  static Future<void> show(BuildContext context) =>
      SavedBillsPage.open(context);
}
