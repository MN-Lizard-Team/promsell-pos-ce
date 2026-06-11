import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/modern_product_tile.dart';

/// Deprecated: use [ModernProductTile] instead.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => ModernProductTile(product: product);
}
