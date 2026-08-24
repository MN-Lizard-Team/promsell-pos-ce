part of 'app_database.dart';

/// Migration logic for [AppDatabase], extracted to keep the database class
/// focused on schema definition.
///
/// As a `part of` file, this extension has access to all generated table
/// types and the extension is automatically visible within the same library.
///
/// Helper methods (dedup, backfill, addColumn) are in
/// [AppDatabaseMigrationHelpers]. The Phase M satang migration is in
/// [AppDatabaseSatangMigration].
extension AppDatabaseMigrationLogic on AppDatabase {
  /// Builds the [MigrationStrategy] — called by [AppDatabase.migration].
  MigrationStrategy buildMigrationStrategy() => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await createIndexes();
      await seedDefaultSettings();
    },
    onUpgrade: (m, from, to) async {
      // Migration-safety tracking must never break or alter the real
      // migration, so every mark is best-effort and swallows its own errors
      // (e.g. MissingPluginException when path_provider is unavailable).
      Future<void> track(Future<void> Function() mark) async {
        try {
          await mark();
        } catch (_) {
          // Best-effort only — never obstruct the upgrade itself.
        }
      }

      final safety = MigrationSafetyService(this);
      await track(
        () => safety.markMigrationStart(fromVersion: from, toVersion: to),
      );
      try {
        await runUpgradeSteps(m, from);
        await track(
          () => safety.markMigrationSuccess(fromVersion: from, toVersion: to),
        );
      } catch (e) {
        await track(
          () => safety.markMigrationFailure(
            fromVersion: from,
            toVersion: to,
            error: e.toString(),
          ),
        );
        rethrow;
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode=WAL');
      await customStatement('PRAGMA foreign_keys=ON');
      await customStatement('PRAGMA synchronous=NORMAL');
      // Wait up to 5s for a locked database instead of failing immediately
      // (concurrent access from backup/restore or a second isolate).
      await customStatement('PRAGMA busy_timeout=5000');
    },
  );

  /// Incremental schema upgrades from [from] to [schemaVersion]. Extracted
  /// from the `onUpgrade` callback so migration-safety tracking can wrap it.
  Future<void> runUpgradeSteps(Migrator m, int from) async {
    // incremental table creation (replaces old drop+recreate)
    if (from < 2) {
      await m.createTable(draftCarts);
      await m.createTable(draftCartItems);
      await m.createTable(dailyCloses);
      await m.createTable(categories);
      await m.createTable(inventoryLogs);
      await m.createTable(appSettings);
      await seedDefaultSettings();
    }
    if (from < 3) {
      await addColumnIfNotExists('draft_carts', 'cart_discount_type', 'TEXT');
      await addColumnIfNotExists('draft_carts', 'cart_discount_value', 'REAL');
    }
    if (from < 4) {
      await addColumnIfNotExists('products', 'image_path', 'TEXT');
    }
    if (from < 5) {
      await seedR4Settings();
    }
    if (from < 6) {
      await addColumnIfNotExists('products', 'image_thumbnail_path', 'TEXT');
      await seedR45Settings();
    }
    if (from < 7) {
      await addColumnIfNotExists(
        'draft_carts',
        'is_archived',
        'INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (from < 8) {
      await seedR5Settings();
    }
    if (from < 9) {
      await addColumnIfNotExists(
        'daily_closes',
        'payment_breakdown',
        'TEXT NOT NULL DEFAULT \'{}\'',
      );
      await addColumnIfNotExists(
        'daily_closes',
        'vat_amount',
        'REAL NOT NULL DEFAULT 0',
      );
      await addColumnIfNotExists(
        'daily_closes',
        'discount_amount',
        'REAL NOT NULL DEFAULT 0',
      );
    }
    if (from < 10) {
      // Recreate daily_closes to make closed_at nullable.
      //
      // Never use INSERT ... SELECT * here. The old table holds exactly the
      // 16 v9-era columns listed below (13 base columns + payment_breakdown,
      // vat_amount, discount_amount added by the `from < 9` step above),
      // while today's DailyCloses has 27. A positional copy fails with
      // "table daily_closes has 27 columns but N values were supplied" and
      // would corrupt data even if the counts matched, because column ORDER
      // changed between eras (the three v9 columns now sit before `note`).
      // Naming only the v9-era columns on both sides leaves the newer
      // columns (satang dual-write, updated_at, deleted_at, version) at
      // their declared defaults.
      const v9Columns =
          'id, close_date, opening_cash, expected_cash, counted_cash, '
          'over_short_amount, total_revenue, total_void, sales_count, '
          'void_count, payment_breakdown, vat_amount, discount_amount, '
          'note, closed_at, device_id';
      await customStatement(
        'ALTER TABLE daily_closes RENAME TO daily_closes_old',
      );
      await m.createTable(dailyCloses);
      await customStatement(
        'INSERT INTO daily_closes ($v9Columns) '
        'SELECT $v9Columns FROM daily_closes_old',
      );
      await customStatement('DROP TABLE daily_closes_old');
    }
    // Add sync columns to all tables for Phase 2 multi-device readiness
    if (from < 11) {
      // SaleItems: add updatedAt, deletedAt, version, deviceId
      await addColumnIfNotExists(
        'sale_items',
        'updated_at',
        'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
      );
      await addColumnIfNotExists('sale_items', 'deleted_at', 'TEXT');
      await addColumnIfNotExists(
        'sale_items',
        'version',
        'INTEGER NOT NULL DEFAULT 1',
      );
      await addColumnIfNotExists('sale_items', 'device_id', 'TEXT');

      // DraftCartItems: add updatedAt, deletedAt, version, deviceId
      await addColumnIfNotExists(
        'draft_cart_items',
        'updated_at',
        'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
      );
      await addColumnIfNotExists('draft_cart_items', 'deleted_at', 'TEXT');
      await addColumnIfNotExists(
        'draft_cart_items',
        'version',
        'INTEGER NOT NULL DEFAULT 1',
      );
      await addColumnIfNotExists('draft_cart_items', 'device_id', 'TEXT');

      // DailyCloses: add updatedAt, deletedAt, version (deviceId already exists)
      await addColumnIfNotExists(
        'daily_closes',
        'updated_at',
        'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
      );
      await addColumnIfNotExists('daily_closes', 'deleted_at', 'TEXT');
      await addColumnIfNotExists(
        'daily_closes',
        'version',
        'INTEGER NOT NULL DEFAULT 1',
      );

      // InventoryLogs: add updatedAt, deletedAt, version (deviceId already exists)
      await addColumnIfNotExists(
        'inventory_logs',
        'updated_at',
        'TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
      );
      await addColumnIfNotExists('inventory_logs', 'deleted_at', 'TEXT');
      await addColumnIfNotExists(
        'inventory_logs',
        'version',
        'INTEGER NOT NULL DEFAULT 1',
      );

      // DraftCarts: add deletedAt, version (updatedAt, deviceId already exist)
      await addColumnIfNotExists('draft_carts', 'deleted_at', 'TEXT');
      await addColumnIfNotExists(
        'draft_carts',
        'version',
        'INTEGER NOT NULL DEFAULT 1',
      );

      // AppSettings: add version, deviceId
      await addColumnIfNotExists(
        'app_settings',
        'version',
        'INTEGER NOT NULL DEFAULT 1',
      );
      await addColumnIfNotExists('app_settings', 'device_id', 'TEXT');
    }
    // TEXT ISO8601 → INTEGER milliseconds (strftime is universally available)
    if (from < 12) {
      final conversions = [
        ('sale_items', 'updated_at'),
        ('sale_items', 'deleted_at'),
        ('draft_cart_items', 'updated_at'),
        ('draft_cart_items', 'deleted_at'),
        ('daily_closes', 'updated_at'),
        ('daily_closes', 'deleted_at'),
        ('inventory_logs', 'updated_at'),
        ('inventory_logs', 'deleted_at'),
        ('draft_carts', 'deleted_at'),
      ];
      for (final (table, column) in conversions) {
        // A failed conversion must abort the migration. Continuing would
        // advance schema_version while leaving mixed TEXT/INTEGER values.
        await customStatement(
          "UPDATE $table SET $column = CAST(strftime('%s', $column) AS INTEGER) * 1000 WHERE typeof($column) = 'text'",
        );
      }
    }
    if (from < 13) {
      await backfillDeviceId();
    }
    if (from < 14) {
      await backfillCategoryIds();
    }
    if (from < 15) {
      await addColumnIfNotExists('categories', 'color', 'TEXT');
      await addColumnIfNotExists('categories', 'icon_name', 'TEXT');
    }
    if (from < 16) {
      // Older databases may contain duplicate barcodes. Normalize first so
      // the invariant is established instead of failing before v17.
      await deduplicateBarcodes();
      await createBarcodeUniqueIndex();
    }
    if (from < 17) {
      // Keep this pass for databases that entered v17 without the index.
      await deduplicateBarcodes();
      await createBarcodeUniqueIndex();
    }
    if (from < 18) {
      await addColumnIfNotExists('products', 'barcode_image_path', 'TEXT');
    }
    if (from < 19) {
      await addColumnIfNotExists('sale_items', 'note', 'TEXT');
      await addColumnIfNotExists('draft_cart_items', 'note', 'TEXT');
    }
    if (from < 20) {
      // Sales: order type, channel, external ref, table, service charge
      await addColumnIfNotExists(
        'sales',
        'order_type',
        "TEXT NOT NULL DEFAULT 'delivery'",
      );
      await addColumnIfNotExists(
        'sales',
        'order_channel',
        "TEXT NOT NULL DEFAULT 'walkin'",
      );
      await addColumnIfNotExists('sales', 'external_order_ref', 'TEXT');
      await addColumnIfNotExists('sales', 'table_id', 'TEXT');
      await addColumnIfNotExists(
        'sales',
        'service_charge_rate',
        'REAL NOT NULL DEFAULT 0',
      );
      await addColumnIfNotExists(
        'sales',
        'service_charge_amount',
        'REAL NOT NULL DEFAULT 0',
      );

      // DraftCarts: order type, channel, external ref, table, service charge
      await addColumnIfNotExists(
        'draft_carts',
        'order_type',
        "TEXT NOT NULL DEFAULT 'delivery'",
      );
      await addColumnIfNotExists(
        'draft_carts',
        'order_channel',
        "TEXT NOT NULL DEFAULT 'walkin'",
      );
      await addColumnIfNotExists('draft_carts', 'external_order_ref', 'TEXT');
      await addColumnIfNotExists('draft_carts', 'table_id', 'TEXT');
      await addColumnIfNotExists('draft_carts', 'service_charge_rate', 'REAL');

      // SaleItems + DraftCartItems: product options JSON snapshot
      await addColumnIfNotExists('sale_items', 'product_options_json', 'TEXT');
      await addColumnIfNotExists(
        'draft_cart_items',
        'product_options_json',
        'TEXT',
      );

      // New tables for restaurant support
      await m.createTable(restaurantTables);
      await m.createTable(productOptionGroups);
      await m.createTable(productOptions);

      // Indexes for new tables
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_product_option_groups_product_id ON product_option_groups (product_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_product_options_group_id ON product_options (group_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_restaurant_tables_status ON restaurant_tables (status)',
      );

      // Seed default business type setting
      await batch((b) {
        b.insertAll(appSettings, [
          AppSettingsCompanion.insert(key: 'businessType', value: 'retail'),
          AppSettingsCompanion.insert(
            key: 'defaultServiceChargeRate',
            value: '0',
          ),
        ], mode: InsertMode.insertOrIgnore);
      });
    }
    if (from < 21) {
      // New tables: Customers + Promotions
      await m.createTable(customers);
      await m.createTable(promotions);

      // Add customerId + promotionId columns to Sales
      await addColumnIfNotExists('sales', 'customer_id', 'TEXT');
      await addColumnIfNotExists('sales', 'promotion_id', 'TEXT');
      await addColumnIfNotExists(
        'sales',
        'promotion_discount_amount',
        'REAL NOT NULL DEFAULT 0',
      );

      // Add customerId + promotionId columns to DraftCarts
      await addColumnIfNotExists('draft_carts', 'customer_id', 'TEXT');
      await addColumnIfNotExists('draft_carts', 'promotion_id', 'TEXT');
      await addColumnIfNotExists(
        'draft_carts',
        'promotion_discount_amount',
        'REAL NOT NULL DEFAULT 0',
      );

      // Indexes
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (name)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers (phone)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions (is_active)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales (customer_id)',
      );
    }
    if (from < 22) {
      await addColumnIfNotExists('products', 'description', 'TEXT');
    }
    // v23: Runtime validations only (barcode uniqueness, product delete guard)
    // No schema changes required
    if (from < 23) {
      // No-op: validations implemented in repository layer
    }
    // v24: Barcode UNIQUE INDEX + performance indexes
    if (from < 24) {
      // Re-run barcode deduplication to ensure uniqueness before creating index
      await deduplicateBarcodes();

      // Drop old non-conditional unique index if exists
      await customStatement('DROP INDEX IF EXISTS idx_products_barcode_unique');

      // Create conditional unique index (NULL and empty string allowed)
      await customStatement(
        "CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products(barcode) WHERE barcode IS NOT NULL AND barcode != ''",
      );

      // Add performance indexes
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at)',
      );
    }
    if (from < 25) {
      await addColumnIfNotExists('products', 'brand', 'TEXT');
      await addColumnIfNotExists('products', 'unit', 'TEXT');
      await addColumnIfNotExists('products', 'supplier', 'TEXT');
      await addColumnIfNotExists(
        'products',
        'is_recommended',
        'INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (from < 26) {
      // Keep one row per close_date (latest id wins), then unique index.
      await customStatement('''
DELETE FROM daily_closes WHERE id NOT IN (
  SELECT id FROM daily_closes
  GROUP BY close_date
  HAVING id = MAX(id)
)
''');
      await customStatement('DROP INDEX IF EXISTS idx_daily_closes_close_date');
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_closes_close_date_unique ON daily_closes (close_date)',
      );
    }
    if (from < 28) {
      await m.createTable(salePayments);
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sale_payments_sale_id '
        'ON sale_payments (sale_id)',
      );
    }
    if (from < 29) {
      // Add case-insensitive barcode column for indexed lookups.
      await addColumnIfNotExists('products', 'barcode_lower', 'TEXT');
      await customStatement(
        'UPDATE products SET barcode_lower = LOWER(barcode) '
        'WHERE barcode IS NOT NULL AND barcode != \'\'',
      );
      // Deduplicate case-insensitively before creating unique index.
      await deduplicateBarcodesLower();
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_lower_unique '
        'ON products(barcode_lower) '
        'WHERE barcode_lower IS NOT NULL AND barcode_lower != \'\'',
      );
    }
    if (from < 30) {
      // Add case-insensitive SKU column for indexed lookups.
      await addColumnIfNotExists('products', 'sku_lower', 'TEXT');
      await customStatement(
        'UPDATE products SET sku_lower = LOWER(sku) '
        'WHERE sku IS NOT NULL AND sku != \'\'',
      );
      // V092-C.2: dedupe SKU case-insensitively before creating the
      // unique index — same pattern as barcode (v29). Without this,
      // mixed-case duplicates (e.g. "ABC" vs "abc") stall the upgrade.
      await deduplicateSkuLower();
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_sku_lower_unique '
        'ON products(sku_lower) '
        'WHERE sku_lower IS NOT NULL AND sku_lower != \'\'',
      );
    }
    if (from < 31) {
      // V092-C.2: repair DBs that already ran v30 without dedupe.
      // Drop the unique index, dedupe, then recreate.
      await customStatement(
        'DROP INDEX IF EXISTS idx_products_sku_lower_unique',
      );
      await deduplicateSkuLower();
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_sku_lower_unique '
        'ON products(sku_lower) '
        'WHERE sku_lower IS NOT NULL AND sku_lower != \'\'',
      );
    }
    // Phase M (C1): Add INTEGER satang dual-write columns to all money
    // tables and backfill from existing REAL baht columns. Columns are
    // nullable so old rows without satang remain valid; C2 writers will
    // populate them, C2 readers will prefer satang with REAL fallback.
    // See WS-C-PHASE-M-MONEY.md for the full inventory and design.
    if (from < 32) {
      await migrateV32SatangColumns();
    }
    if (from < 27) {
      // Dedupe non-null receipt numbers (keep latest created_at), then unique.
      await customStatement('''
UPDATE sales
SET receipt_number = receipt_number || '-dup-' || id
WHERE receipt_number IS NOT NULL
  AND receipt_number != ''
  AND id NOT IN (
    SELECT id FROM sales
    WHERE receipt_number IS NOT NULL AND receipt_number != ''
    GROUP BY receipt_number
    HAVING id = MAX(id)
  )
''');
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_receipt_number_unique '
        'ON sales(receipt_number) '
        "WHERE receipt_number IS NOT NULL AND receipt_number != ''",
      );
    }
    // V092-C.3: run the idempotent index/trigger set at the end of every
    // upgrade so DBs upgraded from v2+ have all indexes/triggers. All
    // statements use IF NOT EXISTS so this is safe to repeat.
    await createIndexes();
  }

  Future<void> createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_category_id ON products (category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_is_active ON products (is_active)',
    );
    // Index for soft-delete filter (every query filters deletedAt.isNull()).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_deleted_at ON products (deleted_at)',
    );
    // Index for SKU uniqueness checks (case-insensitive via sku_lower).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_sku ON products (sku) '
      "WHERE sku IS NOT NULL AND sku != ''",
    );
    // Data integrity CHECK constraints (enforced at DB level).
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS chk_products_price_positive '
      'BEFORE INSERT ON products '
      'WHEN NEW.price <= 0 '
      'BEGIN SELECT RAISE(ABORT, \'Price must be greater than 0\'); END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS chk_products_price_positive_update '
      'BEFORE UPDATE ON products '
      'WHEN NEW.price <= 0 '
      'BEGIN SELECT RAISE(ABORT, \'Price must be greater than 0\'); END',
    );
    // Note: No CHECK constraint on stock — oversell allows negative stock.
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS chk_products_cost_nonneg '
      'BEFORE INSERT ON products '
      'WHEN NEW.cost IS NOT NULL AND NEW.cost < 0 '
      'BEGIN SELECT RAISE(ABORT, \'Cost cannot be negative\'); END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS chk_products_cost_nonneg_update '
      'BEFORE UPDATE ON products '
      'WHEN NEW.cost IS NOT NULL AND NEW.cost < 0 '
      'BEGIN SELECT RAISE(ABORT, \'Cost cannot be negative\'); END',
    );
    // Conditional unique index created in v24 migration
    await customStatement(
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products(barcode) WHERE barcode IS NOT NULL AND barcode != ''",
    );
    // Case-insensitive barcode index (v29)
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_lower_unique '
      'ON products(barcode_lower) '
      'WHERE barcode_lower IS NOT NULL AND barcode_lower != \'\'',
    );
    // V092-C.2: case-insensitive SKU unique index (v30/v31).
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_sku_lower_unique '
      'ON products(sku_lower) '
      'WHERE sku_lower IS NOT NULL AND sku_lower != \'\'',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales (created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_status ON sales (status)',
    );
    // P0 scaling: composite cursor index for paginated history/report queries
    // (cursor = (created_at DESC, id DESC)). Covers the ORDER BY + WHERE
    // clause of `querySalesPage` so the planner does not sort the full table.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_created_at_id_cursor '
      'ON sales (created_at DESC, id DESC) '
      'WHERE deleted_at IS NULL',
    );
    // P0 scaling: composite cursor index for paginated product catalog
    // (cursor = (created_at DESC, id DESC)). Covers `getProductsPage`.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_created_at_id_cursor '
      'ON products (created_at DESC, id DESC) '
      'WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_receipt_number_unique '
      'ON sales(receipt_number) '
      "WHERE receipt_number IS NOT NULL AND receipt_number != ''",
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items (sale_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_payments_sale_id ON sale_payments (sale_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items (product_id)',
    );
    // Ensure option-group index exists for fresh installs (also in v20 migration).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_product_option_groups_product_id '
      'ON product_option_groups (product_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inventory_logs_product_id ON inventory_logs (product_id)',
    );
    // P1 scaling: composite index for per-product log queries with date DESC.
    // Covers watchLogsByProduct (WHERE product_id = ? AND deleted_at IS NULL
    // ORDER BY created_at DESC LIMIT 200) so the planner avoids full scan +
    // sort on high-volume SKUs.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inventory_logs_product_id_created_at '
      'ON inventory_logs (product_id, created_at DESC) '
      'WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_draft_cart_items_cart_id ON draft_cart_items (cart_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_closes_close_date_unique ON daily_closes (close_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions (is_active)',
    );
  }

  Future<void> seedDefaultSettings() async {
    // Canonical keys must match [SettingsMapper] (camelCase).
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'shopName', value: ''),
        AppSettingsCompanion.insert(key: 'receiptNote', value: ''),
        AppSettingsCompanion.insert(key: 'vatRate', value: '7'),
        AppSettingsCompanion.insert(key: 'vatMode', value: 'NONE'),
        AppSettingsCompanion.insert(key: 'currency', value: '฿'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> seedR4Settings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'promptpayId', value: ''),
        AppSettingsCompanion.insert(key: 'receiptSize', value: '80mm'),
        AppSettingsCompanion.insert(key: 'backupReminderDays', value: '7'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> seedR5Settings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'accessibilityMode', value: 'false'),
        AppSettingsCompanion.insert(key: 'deviceId', value: ''),
        AppSettingsCompanion.insert(key: 'devicePrefix', value: ''),
        AppSettingsCompanion.insert(key: 'onboardingCompleted', value: 'false'),
        AppSettingsCompanion.insert(key: 'dailyCloseLock', value: 'false'),
        AppSettingsCompanion.insert(key: 'lastClosedDate', value: ''),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> seedR45Settings() async {
    await batch((b) {
      b.insertAll(appSettings, [
        AppSettingsCompanion.insert(key: 'imageMaxWidth', value: '800'),
        AppSettingsCompanion.insert(key: 'imageQuality', value: '80'),
      ], mode: InsertMode.insertOrIgnore);
    });
  }
}
