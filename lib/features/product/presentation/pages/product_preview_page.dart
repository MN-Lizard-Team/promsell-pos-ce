import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/codes_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/hero_section.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/price_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/stock_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/system_info_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductPreviewPage extends StatelessWidget {
  const ProductPreviewPage({super.key, required this.product});

  final Product product;

  void _showEdit(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: ProductFormPage(product: product),
        ),
      ),
    );
  }

  Future<void> _editStock(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.stock,
      initialValue: product.stock.toString(),
      productName: product.name,
    );
    if (!context.mounted) return;
    final stock = int.tryParse(result ?? '');
    if (stock != null && stock >= 0 && stock != product.stock) {
      context.read<ProductBloc>().add(
        ProductUpdated(product.copyWith(stock: stock)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final catState = context.watch<CategoryBloc>().state;
    final cat = catState.categories
        .where((c) => c.id == product.categoryId)
        .firstOrNull;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      bottomNavigationBar: StickyActionBar(
        primaryLabel: l10n.edit,
        onPrimary: () => _showEdit(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroSection(product: product, category: cat),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PriceCard(product: product, currency: currency),
                  const SizedBox(height: 12),
                  StockCard(
                    product: product,
                    currency: currency,
                    onEditStock: () => _editStock(context),
                  ),
                  const SizedBox(height: 12),
                  CodesCard(product: product),
                  const SizedBox(height: 12),
                  SystemInfoCard(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
