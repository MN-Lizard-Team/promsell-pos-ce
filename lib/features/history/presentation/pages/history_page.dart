import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_tab_view.dart';

/// Full-screen History entry (legacy routes). Body matches Report → History tab
/// (today + presets) via [HistoryTabView].
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.historyTitle)),
      body: const HistoryTabView(),
    );
  }
}
