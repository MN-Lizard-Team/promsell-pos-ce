import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

/// v35 — kitchen-fire + per-table analytics migration test.
///
/// Verifies that:
/// 1. Upgrading from v34 preserves every draft_carts / draft_cart_items /
///    sales row and leaves the new columns (`guest_count`, `opened_at`,
///    `fired_at`) NULL — there is no backfill by design; `opened_at` is
///    stamped by app logic when a cart is opened.
/// 2. The new columns are writable/readable after the upgrade.
/// 3. Fresh installs create all three tables with the new columns and the
///    resulting schema matches the upgraded schema exactly (parity).
///
/// Simulation approach (mirrors v33_table_integrity_migration_test): open a
/// fresh AppDatabase.forTesting(NativeDatabase(file)) so all tables exist at
/// today's shape, drop the five v35 columns to rewind to a faithful v34,
/// seed rows, set user_version to 34, then reopen to trigger the real
/// onUpgrade step.
void main() {
  /// Epoch seconds base — drift stores DateTime as INTEGER unix seconds.
  final t = DateTime(2026, 1, 10).millisecondsSinceEpoch ~/ 1000;

  /// Columns added by v35 per table — dropped again to rewind a fresh
  /// database back into a faithful v34 shape.
  const v35ColumnsByTable = <String, List<String>>{
    'draft_carts': ['guest_count', 'opened_at'],
    'draft_cart_items': ['fired_at'],
    'sales': ['guest_count', 'opened_at'],
  };

  Future<({AppDatabase db, File dbFile})> createV34DatabaseWithRows(
    String fileName,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp('promsell_v35_');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}$fileName');

    final legacyDb = AppDatabase.forTesting(NativeDatabase(dbFile));
    await legacyDb.customSelect('SELECT 1').get();

    // Rewind: remove everything v35 adds so the file is a faithful v34.
    for (final entry in v35ColumnsByTable.entries) {
      for (final column in entry.value) {
        await legacyDb.customStatement(
          'ALTER TABLE ${entry.key} DROP COLUMN $column',
        );
      }
    }

    // Realistic v34 data: carts on restaurant tables with items, plus sales.
    Future<void> insertCart(String id, String? tableId) async {
      final tableIdSql = tableId == null ? 'NULL' : "'$tableId'";
      await legacyDb.customStatement(
        'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
        "VALUES ('$id', $tableIdSql, $t, $t)",
      );
    }

    await insertCart('cart-open', 'T1');
    await insertCart('cart-open-2', 'T2');
    await insertCart('cart-no-table', null);

    Future<void> insertItem(String id, String cartId) async {
      await legacyDb.customStatement(
        'INSERT INTO draft_cart_items '
        '(id, cart_id, product_id, product_name, price, qty) '
        "VALUES ('$id', '$cartId', 'p-1', 'Pad Thai', 120.0, 2)",
      );
    }

    await insertItem('item-1', 'cart-open');
    await insertItem('item-2', 'cart-open-2');

    Future<void> insertSale(String id, String? tableId) async {
      final tableIdSql = tableId == null ? 'NULL' : "'$tableId'";
      await legacyDb.customStatement(
        'INSERT INTO sales (id, total_amount, payment_method, order_type, '
        'table_id, created_at, updated_at) '
        "VALUES ('$id', 250.0, 'cash', 'dinein', $tableIdSql, $t, $t)",
      );
    }

    await insertSale('sale-1', 'T1');
    await insertSale('sale-takeout', null);

    await legacyDb.customStatement('PRAGMA user_version = 34');
    await legacyDb.close();

    final upgraded = AppDatabase.forTesting(NativeDatabase(dbFile));
    // Opening triggers the 34 -> current onUpgrade chain, including the v35
    // additive-column step under test here.
    await upgraded.customSelect('SELECT 1').get();
    return (db: upgraded, dbFile: dbFile);
  }

  /// name/type/notnull triple for every column of [table], in declared order.
  Future<List<Map<String, Object?>>> columnInfo(
    AppDatabase db,
    String table,
  ) async {
    final rows = await db.customSelect('PRAGMA table_info("$table")').get();
    return [
      for (final row in rows)
        {
          'name': row.read<String>('name'),
          'type': row.read<String>('type'),
          'notnull': row.read<int>('notnull'),
        },
    ];
  }

  test(
    'v34 database upgrades to v35 preserving rows with new columns NULL',
    () async {
      final harness = await createV34DatabaseWithRows('v35_upgrade.db');
      final db = harness.db;

      try {
        final version = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), 35);

        // Every seeded row survived the upgrade.
        final cartCount = await db
            .customSelect('SELECT COUNT(*) AS c FROM draft_carts')
            .getSingle();
        expect(cartCount.read<int>('c'), 3);
        final itemCount = await db
            .customSelect('SELECT COUNT(*) AS c FROM draft_cart_items')
            .getSingle();
        expect(itemCount.read<int>('c'), 2);
        final saleCount = await db
            .customSelect('SELECT COUNT(*) AS c FROM sales')
            .getSingle();
        expect(saleCount.read<int>('c'), 2);

        // No backfill: every v35 column starts NULL on pre-existing rows.
        final nonNullCarts = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM draft_carts '
              'WHERE guest_count IS NOT NULL OR opened_at IS NOT NULL',
            )
            .getSingle();
        expect(nonNullCarts.read<int>('c'), 0);
        final nonNullItems = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM draft_cart_items '
              'WHERE fired_at IS NOT NULL',
            )
            .getSingle();
        expect(nonNullItems.read<int>('c'), 0);
        final nonNullSales = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM sales '
              'WHERE guest_count IS NOT NULL OR opened_at IS NOT NULL',
            )
            .getSingle();
        expect(nonNullSales.read<int>('c'), 0);

        // The upgraded columns are usable by the kitchen-fire flow.
        await db.customStatement(
          'UPDATE draft_carts SET guest_count = 4, opened_at = $t '
          "WHERE id = 'cart-open'",
        );
        await db.customStatement(
          "UPDATE draft_cart_items SET fired_at = $t WHERE id = 'item-1'",
        );
        await db.customStatement(
          "UPDATE sales SET guest_count = 4 WHERE id = 'sale-1'",
        );

        final openedCart = await db
            .customSelect(
              'SELECT guest_count, opened_at FROM draft_carts '
              "WHERE id = 'cart-open'",
            )
            .getSingle();
        expect(openedCart.read<int>('guest_count'), 4);
        expect(openedCart.read<int?>('opened_at'), t);

        final firedItem = await db
            .customSelect(
              "SELECT fired_at FROM draft_cart_items WHERE id = 'item-1'",
            )
            .getSingle();
        expect(firedItem.read<int?>('fired_at'), t);

        final saleWithGuests = await db
            .customSelect("SELECT guest_count FROM sales WHERE id = 'sale-1'")
            .getSingle();
        expect(saleWithGuests.read<int>('guest_count'), 4);
      } finally {
        await db.close();
        await harness.dbFile.parent.delete(recursive: true);
      }
    },
  );

  test(
    'fresh install creates the v35 columns matching the upgraded schema',
    () async {
      final harness = await createV34DatabaseWithRows('v35_parity.db');
      final db = harness.db;

      try {
        final fresh = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(fresh.close);
        await fresh.customSelect('SELECT 1').get();

        for (final table in v35ColumnsByTable.keys) {
          final freshInfo = await columnInfo(fresh, table);
          final upgradedInfo = await columnInfo(db, table);

          // Parity: fresh installs and upgrades end up with identical schema.
          expect(upgradedInfo, freshInfo, reason: '$table schema mismatch');

          // The new columns exist as nullable INTEGERs on the fresh install.
          final addedColumns = v35ColumnsByTable[table]!;
          final names = freshInfo.map((c) => c['name']).toList();
          expect(names, containsAll(addedColumns));
          final added = freshInfo
              .where((c) => addedColumns.contains(c['name']))
              .toList();
          expect(added, hasLength(addedColumns.length));
          for (final column in added) {
            expect(
              column['type'],
              'INTEGER',
              reason: '$table.${column['name']}',
            );
            expect(column['notnull'], 0, reason: '$table.${column['name']}');
          }
        }
      } finally {
        await db.close();
        await harness.dbFile.parent.delete(recursive: true);
      }
    },
  );
}
