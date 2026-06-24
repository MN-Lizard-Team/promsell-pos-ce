import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/modern_product_grid_card.dart';

/// Deprecated: use [ModernProductGridCard] instead.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => ModernProductGridCard(product: product);
}
