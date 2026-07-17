import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

/// Ranked product search hit (lower [rank] = better).
///
/// Rank ladder:
/// 0 barcode exact → 1 SKU exact → 2 name prefix →
/// 3 barcode prefix → 4 SKU prefix → 5 other contains.
class ProductSearchMatch {
  const ProductSearchMatch({
    required this.product,
    required this.rank,
    required this.matchField,
  });

  final Product product;
  final int rank;

  /// Primary field that drove the rank: `name` | `sku` | `barcode`.
  final String matchField;
}

/// Shared POS catalog search: name / SKU / barcode, case-insensitive.
///
/// By default excludes inactive products ([includeInactive] = false).
List<ProductSearchMatch> matchProducts(
  List<Product> products,
  String query, {
  bool includeInactive = false,
}) {
  final raw = query.trim();
  if (raw.isEmpty) return const [];

  final q = raw.toLowerCase();
  final hits = <ProductSearchMatch>[];

  for (final p in products) {
    if (!includeInactive && !p.isActive) continue;

    final name = p.name.toLowerCase();
    final sku = p.sku?.trim().toLowerCase();
    final barcode = p.barcode?.trim().toLowerCase();

    final nameHit = name.contains(q);
    final skuHit = sku != null && sku.contains(q);
    final barcodeHit = barcode != null && barcode.contains(q);
    if (!nameHit && !skuHit && !barcodeHit) continue;

    final int rank;
    final String field;
    if (barcode != null && barcode == q) {
      rank = 0;
      field = 'barcode';
    } else if (sku != null && sku == q) {
      rank = 1;
      field = 'sku';
    } else if (name.startsWith(q)) {
      rank = 2;
      field = 'name';
    } else if (barcode != null && barcode.startsWith(q)) {
      rank = 3;
      field = 'barcode';
    } else if (sku != null && sku.startsWith(q)) {
      rank = 4;
      field = 'sku';
    } else if (nameHit) {
      rank = 5;
      field = 'name';
    } else if (skuHit) {
      rank = 5;
      field = 'sku';
    } else {
      rank = 5;
      field = 'barcode';
    }

    hits.add(ProductSearchMatch(product: p, rank: rank, matchField: field));
  }

  hits.sort((a, b) {
    final cmp = a.rank.compareTo(b.rank);
    if (cmp != 0) return cmp;
    return a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase());
  });
  return hits;
}

/// Products only (same order as [matchProducts]).
List<Product> matchProductList(
  List<Product> products,
  String query, {
  bool includeInactive = false,
}) {
  return matchProducts(
    products,
    query,
    includeInactive: includeInactive,
  ).map((m) => m.product).toList();
}

/// Exact barcode matches (case-insensitive, trimmed). Includes inactive.
List<Product> resolveExactBarcodeMatches(List<Product> products, String code) {
  final upper = code.trim().toUpperCase();
  if (upper.isEmpty) return const [];
  return products
      .where(
        (p) => p.barcode != null && p.barcode!.trim().toUpperCase() == upper,
      )
      .toList();
}

/// Sort [products] by search rank for [query] (stable for non-matches at end).
List<Product> sortProductsBySearchRank(List<Product> products, String query) {
  final raw = query.trim();
  if (raw.isEmpty || products.isEmpty) return products;

  final ranked = matchProducts(products, raw, includeInactive: true);
  if (ranked.isEmpty) return products;

  final order = {
    for (var i = 0; i < ranked.length; i++) ranked[i].product.id: i,
  };
  final sorted = List<Product>.of(products)
    ..sort((a, b) {
      final ai = order[a.id] ?? 1 << 20;
      final bi = order[b.id] ?? 1 << 20;
      final cmp = ai.compareTo(bi);
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  return sorted;
}
