import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

/// v33 — restaurant table-integrity migration test.
///
/// Verifies that:
/// 1. Upgrading from v32 unlinks duplicate ACTIVE draft carts sharing a
///    table_id (latest updatedAt keeps it; tie-break highest rowid), while
///    archived/soft-deleted carts keep their binding untouched.
/// 2. The partial unique index `idx_draft_carts_table_id_unique` blocks a
///    second active cart on the same table.
/// 3. Archiving or soft-deleting the active cart frees the table for a new
///    cart (partial-index WHERE semantics).
/// 4. Both v33 indexes exist on fresh installs (onCreate path).
///
/// Simulation approach (mirrors phase_m_v32_satang_migration_test): open a
/// fresh AppDatabase.forTesting(NativeDatabase(file)) so all tables exist at
/// today's shape, drop the two v33 indexes, seed duplicates, rewind
/// user_version to 32, then reopen to trigger the real onUpgrade step.
void main() {
  /// Epoch seconds base — drift stores DateTime as INTEGER unix seconds.
  final t = DateTime(2026, 1, 10).millisecondsSinceEpoch ~/ 1000;

  Future<({AppDatabase db, File dbFile})> createV32DatabaseWithDuplicates(
    String fileName,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp('promsell_v33_');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}$fileName');

    final legacyDb = AppDatabase.forTesting(NativeDatabase(dbFile));
    await legacyDb.customSelect('SELECT 1').get();

    // Rewind: remove everything v33 adds so the file is a faithful v32.
    await legacyDb.customStatement(
      'DROP INDEX IF EXISTS idx_draft_carts_table_id_unique',
    );
    await legacyDb.customStatement('DROP INDEX IF EXISTS idx_sales_table_id');

    // T1 group: three active carts bound to one table. 'cart-keep' has the
    // most recent updated_at and must survive with its binding intact.
    Future<void> insertCart(
      String id,
      String? tableId, {
      int? archived,
      int? deletedAtSeconds,
      required int updatedAtSeconds,
    }) async {
      final tableIdSql = tableId == null ? 'NULL' : "'$tableId'";
      await legacyDb.customStatement(
        'INSERT INTO draft_carts '
        '(id, table_id, is_archived, deleted_at, created_at, updated_at) '
        "VALUES ('$id', $tableIdSql, "
        '${archived ?? 0}, ${deletedAtSeconds ?? 'NULL'}, '
        '$t, $updatedAtSeconds)',
      );
    }

    await insertCart('cart-old1', 'T1', updatedAtSeconds: t + 100);
    await insertCart('cart-keep', 'T1', updatedAtSeconds: t + 300);
    await insertCart('cart-old2', 'T1', updatedAtSeconds: t + 200);
    // Archived / soft-deleted carts on T1 are ignored by the dedup and by
    // the unique index — they must keep their table_id after the upgrade.
    await insertCart('cart-archived', 'T1', archived: 1, updatedAtSeconds: t);
    await insertCart(
      'cart-deleted',
      'T1',
      deletedAtSeconds: t,
      updatedAtSeconds: t,
    );
    // Other tables and a NULL-table cart stay untouched.
    await insertCart('cart-solo-t2', 'T2', updatedAtSeconds: t);
    await insertCart('cart-solo-t3', 'T3', updatedAtSeconds: t);
    await insertCart('cart-no-table', null, updatedAtSeconds: t);

    await legacyDb.customStatement('PRAGMA user_version = 32');
    await legacyDb.close();

    final upgraded = AppDatabase.forTesting(NativeDatabase(dbFile));
    // Opening triggers the 32 -> current onUpgrade chain, including the
    // v33 table-integrity step under test here.
    await upgraded.customSelect('SELECT 1').get();
    return (db: upgraded, dbFile: dbFile);
  }

  test('v32 database upgrades to v33 keeping only the latest active cart '
      'per table', () async {
    final harness = await createV32DatabaseWithDuplicates(
      'v33_upgrade_dedup.db',
    );
    final db = harness.db;

    try {
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 35);

      // Exactly one active cart still points at T1 — the most recent one.
      final activeOnT1 = await db
          .customSelect(
            'SELECT id FROM draft_carts '
            "WHERE table_id = 'T1' AND is_archived = 0 AND deleted_at IS NULL",
          )
          .get();
      expect(activeOnT1.map((r) => r.read<String>('id')), ['cart-keep']);

      // Losers kept their data but lost their table binding.
      final unlinked = await db
          .customSelect(
            'SELECT id FROM draft_carts '
            'WHERE table_id IS NULL ORDER BY id',
          )
          .get();
      expect(unlinked.map((r) => r.read<String>('id')), [
        'cart-no-table',
        'cart-old1',
        'cart-old2',
      ]);

      // Archived and soft-deleted carts were NOT unlinked.
      final inactiveBindings = await db
          .customSelect(
            'SELECT id FROM draft_carts '
            "WHERE table_id = 'T1' AND (is_archived = 1 OR deleted_at IS NOT NULL) "
            'ORDER BY id',
          )
          .get();
      expect(inactiveBindings.map((r) => r.read<String>('id')), [
        'cart-archived',
        'cart-deleted',
      ]);

      // No data was destroyed — all eight carts survived.
      final total = await db
          .customSelect('SELECT COUNT(*) AS c FROM draft_carts')
          .getSingle();
      expect(total.read<int>('c'), 8);

      // Both indexes were recreated by the migration.
      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name IN ('idx_draft_carts_table_id_unique', "
            "'idx_sales_table_id') ORDER BY name",
          )
          .get();
      expect(indexes.map((r) => r.read<String>('name')), [
        'idx_draft_carts_table_id_unique',
        'idx_sales_table_id',
      ]);
    } finally {
      await db.close();
      await harness.dbFile.parent.delete(recursive: true);
    }
  });

  test(
    'tie-break: equal updatedAt keeps the cart with the highest rowid',
    () async {
      final harness = await createV32DatabaseWithDuplicates(
        'v33_upgrade_tiebreak.db',
      );
      final db = harness.db;

      try {
        // Seed two active carts with equal updated_at on T2. This database has
        // already been migrated, so drop the unique index while seeding — the
        // assertion at the end proves the dedup re-enables creating it.
        await db.customStatement(
          'DROP INDEX IF EXISTS idx_draft_carts_table_id_unique',
        );
        await db.customStatement(
          "UPDATE draft_carts SET table_id = NULL WHERE id = 'cart-solo-t2'",
        );
        await db.customStatement(
          'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
          "VALUES ('tie-a', 'T2', $t, ${t + 500})",
        );
        await db.customStatement(
          'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
          "VALUES ('tie-b', 'T2', $t, ${t + 500})",
        );
        // Replay the dedup statement exactly as the upgrade runs it.
        await db.customStatement('''
UPDATE draft_carts
SET table_id = NULL
WHERE table_id IS NOT NULL
  AND is_archived = 0
  AND deleted_at IS NULL
  AND rowid != (
    SELECT keeper.rowid FROM draft_carts keeper
    WHERE keeper.table_id = draft_carts.table_id
      AND keeper.is_archived = 0
      AND keeper.deleted_at IS NULL
    ORDER BY keeper.updated_at DESC, keeper.rowid DESC
    LIMIT 1
  )
''');

        final activeOnT2 = await db
            .customSelect(
              'SELECT id FROM draft_carts '
              "WHERE table_id = 'T2' AND is_archived = 0 AND deleted_at IS NULL",
            )
            .get();
        expect(activeOnT2.map((r) => r.read<String>('id')), ['tie-b']);

        // Dedup resolved every conflict, so the unique index can be recreated
        // without violation — the invariant the real upgrade relies on.
        await db.customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_draft_carts_table_id_unique '
          'ON draft_carts (table_id) '
          'WHERE table_id IS NOT NULL AND is_archived = 0 AND deleted_at IS NULL',
        );
      } finally {
        await db.close();
        await harness.dbFile.parent.delete(recursive: true);
      }
    },
  );

  test('unique index blocks a second active cart on the same table', () async {
    final harness = await createV32DatabaseWithDuplicates('v33_unique.db');
    final db = harness.db;

    try {
      // Positive control: a free table accepts a new active cart.
      await db.customStatement(
        'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
        "VALUES ('cart-free', 'T9', $t, $t)",
      );

      // T1 is held by 'cart-keep' — a second ACTIVE cart must be rejected.
      await expectLater(
        db.customStatement(
          'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
          "VALUES ('cart-double', 'T1', $t, $t)",
        ),
        throwsA(anything),
      );

      // Archived carts may still reference T1 — they do not occupy it.
      await db.customStatement(
        'INSERT INTO draft_carts '
        '(id, table_id, is_archived, created_at, updated_at) '
        "VALUES ('cart-arch-new', 'T1', 1, $t, $t)",
      );
      final archRow = await db
          .customSelect(
            "SELECT table_id FROM draft_carts WHERE id = 'cart-arch-new'",
          )
          .getSingle();
      expect(archRow.read<String>('table_id'), 'T1');
    } finally {
      await db.close();
      await harness.dbFile.parent.delete(recursive: true);
    }
  });

  test('archiving or soft-deleting frees the table for a new cart', () async {
    final harness = await createV32DatabaseWithDuplicates('v33_frees.db');
    final db = harness.db;

    try {
      // Archive the current holder of T1…
      await db.customStatement(
        "UPDATE draft_carts SET is_archived = 1 WHERE id = 'cart-keep'",
      );
      // …the table now accepts a fresh active cart.
      await db.customStatement(
        'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
        "VALUES ('cart-next', 'T1', $t, $t)",
      );
      var activeOnT1 = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM draft_carts '
            "WHERE table_id = 'T1' AND is_archived = 0 AND deleted_at IS NULL",
          )
          .getSingle();
      expect(activeOnT1.read<int>('c'), 1);

      // Soft-deleting likewise releases the table.
      await db.customStatement(
        "UPDATE draft_carts SET deleted_at = $t WHERE id = 'cart-next'",
      );
      await db.customStatement(
        'INSERT INTO draft_carts (id, table_id, created_at, updated_at) '
        "VALUES ('cart-latest', 'T1', $t, $t)",
      );
      activeOnT1 = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM draft_carts '
            "WHERE table_id = 'T1' AND is_archived = 0 AND deleted_at IS NULL",
          )
          .getSingle();
      expect(activeOnT1.read<int>('c'), 1);
    } finally {
      await db.close();
      await harness.dbFile.parent.delete(recursive: true);
    }
  });

  test('fresh install creates both v33 indexes via onCreate', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.customSelect('SELECT 1').get();

    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name IN ('idx_draft_carts_table_id_unique', "
          "'idx_sales_table_id') ORDER BY name",
        )
        .get();
    expect(indexes.map((r) => r.read<String>('name')), [
      'idx_draft_carts_table_id_unique',
      'idx_sales_table_id',
    ]);
  });
}
