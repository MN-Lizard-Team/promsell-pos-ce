part of 'app_database.dart';

/// Phase M (C1) satang dual-write migration helpers.
///
/// Extracted from [AppDatabaseMigrationLogic] to keep the main migration
/// file focused on the migration strategy. These helpers add nullable
/// INTEGER `*_satang` columns to all money tables and backfill from
/// existing REAL baht columns.
extension AppDatabaseSatangMigration on AppDatabase {
  /// Phase M (C1): Add nullable INTEGER `*_satang` columns to all money
  /// tables and backfill from existing REAL baht columns.
  ///
  /// NaN/Inf audit: the WHERE clause `baht = baht AND abs(baht) < 1e15`
  /// excludes NaN (NaN = NaN → NULL in SQLite) and Inf (abs > 1e15). Rows
  /// with non-finite baht are skipped — their satang column stays NULL,
  /// which C2 readers handle by falling back to REAL baht.
  ///
  /// Rounding: `CAST(ROUND(baht * 100) AS INTEGER)` matches Money.fromDouble
  /// half-up rounding for values within double precision range.
  Future<void> migrateV32SatangColumns() async {
    // (table, baht_column, satang_column) pairs for unconditional money
    // amount columns. Rates stay REAL; conditional amount-or-percent fields
    // are backfilled in the second pass below.
    const conversions = <(String, String, String)>[
      // products
      ('products', 'price', 'price_satang'),
      ('products', 'cost', 'cost_satang'),
      // product_options
      ('product_options', 'price_delta', 'price_delta_satang'),
      // sales
      ('sales', 'subtotal_amount', 'subtotal_amount_satang'),
      ('sales', 'discount_amount', 'discount_amount_satang'),
      ('sales', 'total_amount', 'total_amount_satang'),
      ('sales', 'vat_amount', 'vat_amount_satang'),
      ('sales', 'service_charge_amount', 'service_charge_amount_satang'),
      (
        'sales',
        'promotion_discount_amount',
        'promotion_discount_amount_satang',
      ),
      ('sales', 'amount_received', 'amount_received_satang'),
      ('sales', 'change_amount', 'change_amount_satang'),
      // sale_items
      ('sale_items', 'price', 'price_satang'),
      ('sale_items', 'discount_amount', 'discount_amount_satang'),
      ('sale_items', 'vat_amount', 'vat_amount_satang'),
      ('sale_items', 'subtotal', 'subtotal_satang'),
      // sale_payments
      ('sale_payments', 'amount', 'amount_satang'),
      // daily_closes
      ('daily_closes', 'opening_cash', 'opening_cash_satang'),
      ('daily_closes', 'expected_cash', 'expected_cash_satang'),
      ('daily_closes', 'counted_cash', 'counted_cash_satang'),
      ('daily_closes', 'over_short_amount', 'over_short_amount_satang'),
      ('daily_closes', 'total_revenue', 'total_revenue_satang'),
      ('daily_closes', 'total_void', 'total_void_satang'),
      ('daily_closes', 'vat_amount', 'vat_amount_satang'),
      ('daily_closes', 'discount_amount', 'discount_amount_satang'),
      // customers
      ('customers', 'total_spent', 'total_spent_satang'),
      // promotions
      ('promotions', 'min_purchase_amount', 'min_purchase_amount_satang'),
      // draft_carts
      (
        'draft_carts',
        'promotion_discount_amount',
        'promotion_discount_amount_satang',
      ),
      // draft_cart_items
      ('draft_cart_items', 'price', 'price_satang'),
    ];

    for (final (table, bahtCol, satangCol) in conversions) {
      await addColumnIfNotExists(table, satangCol, 'INTEGER');
      await backfillSatangColumn(table, bahtCol, satangCol);
    }

    const conditionalConversions = <(String, String, String, String)>[
      (
        'sales',
        'discount_value',
        'discount_value_satang',
        "UPPER(COALESCE(discount_type, '')) = 'AMOUNT'",
      ),
      (
        'promotions',
        'value',
        'value_satang',
        "UPPER(COALESCE(type, '')) = 'AMOUNT'",
      ),
      (
        'draft_carts',
        'cart_discount_value',
        'cart_discount_value_satang',
        "UPPER(COALESCE(cart_discount_type, '')) = 'AMOUNT'",
      ),
      (
        'draft_cart_items',
        'discount_value',
        'discount_value_satang',
        "UPPER(COALESCE(discount_type, '')) = 'AMOUNT'",
      ),
    ];
    for (final (table, bahtCol, satangCol, condition)
        in conditionalConversions) {
      await addColumnIfNotExists(table, satangCol, 'INTEGER');
      await backfillSatangColumn(
        table,
        bahtCol,
        satangCol,
        condition: condition,
      );
    }
  }

  Future<void> backfillSatangColumn(
    String table,
    String bahtCol,
    String satangCol, {
    String? condition,
  }) async {
    final conditionSql = condition == null ? '' : 'AND $condition ';
    await customStatement(
      'UPDATE $table SET $satangCol = CAST(ROUND($bahtCol * 100) AS INTEGER) '
      'WHERE $bahtCol IS NOT NULL '
      'AND $bahtCol = $bahtCol '
      'AND abs($bahtCol) < 1e15 '
      '$conditionSql'
      'AND $satangCol IS NULL',
    );
  }
}
