import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/shell/main_shell_scope.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';

/// Shared navigation helpers for Report + History (UI-only; no money logic).
abstract final class ReportNavigation {
  /// Sale tab index in main shell NavigationBar.
  static const saleTabIndex = 2;

  static void goToSale(BuildContext context) {
    final shell = MainShellScope.maybeOf(context);
    if (shell != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      shell.goToTab(saleTabIndex);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Opens daily close for the calendar day of [to] (end of active range).
  static Future<void> openDailyClose(BuildContext context, DateTime? to) {
    final d = to ?? DateTime.now();
    final dateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(d.year, d.month, d.day));
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyClosePage(date: dateStr)),
    );
  }
}
