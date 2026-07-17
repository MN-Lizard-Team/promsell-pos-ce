import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';

/// App bar actions for Sale (drafts). Scanner lives in the search field.
class SaleAppBarActions extends StatelessWidget {
  const SaleAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DraftBloc, DraftState, int>(
      selector: (state) => state.openBillCount,
      builder: (ctx, openBillCount) => IconButton(
        icon: Badge(
          isLabelVisible: openBillCount > 0,
          label: openBillCount > 0
              ? Text(openBillCount > 99 ? '99+' : '$openBillCount')
              : null,
          child: const Icon(Icons.bookmarks_outlined),
        ),
        tooltip: ctx.l10n.draftsTitle,
        onPressed: () => SavedBillsPage.open(ctx),
      ),
    );
  }
}
