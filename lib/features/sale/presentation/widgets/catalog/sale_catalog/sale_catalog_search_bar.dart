import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/search/app_search_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';

class SaleCatalogSearchBar extends StatelessWidget {
  const SaleCatalogSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
      builder: (ctx, historyState) {
        return AppSearchBar(
          controller: controller,
          focusNode: focusNode,
          hintText: context.l10n.saleSearchProducts,
          isFocused: isFocused,
          recentSearches: historyState.searches,
          onChanged: (q) =>
              context.read<ProductBloc>().add(ProductSearchChanged(q)),
          onSubmitted: (q) {
            context.read<SearchHistoryCubit>().add(q);
          },
          onRecentTap: (q) {
            controller.text = q;
            context.read<ProductBloc>().add(ProductSearchChanged(q));
            focusNode.unfocus();
          },
          onRecentDismiss: (q) => context.read<SearchHistoryCubit>().remove(q),
        );
      },
    );
  }
}
