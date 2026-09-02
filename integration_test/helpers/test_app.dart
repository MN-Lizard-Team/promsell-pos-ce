import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:promsell_pos_ce/main.dart' as app;

/// Test app wrapper that provides isolated in-memory database
/// and proper dependency injection for E2E tests
class TestApp {
  TestApp._();

  static AppDatabase? _database;
  static bool _isConfigured = false;

  /// Initialize the test app with fresh in-memory database
  static Future<void> initialize() async {
    if (_isConfigured) {
      await reset();
      return;
    }

    if (Platform.isAndroid) {
      sqlite3_open.open.overrideFor(
        sqlite3_open.OperatingSystem.android,
        openCipherOnAndroid,
      );
    }

    _database = AppDatabase.forTesting(NativeDatabase.memory());
    await _database!
        .into(_database!.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'onboardingCompleted',
            value: 'true',
          ),
        );

    // Configure DI with test database
    await _configureDependenciesForTesting();

    _isConfigured = true;
  }

  /// Reset database state between tests
  static Future<void> reset() async {
    if (_database != null) {
      // Clear all tables
      await _database!.delete(_database!.products).go();
      await _database!.delete(_database!.categories).go();
      await _database!.delete(_database!.sales).go();
      await _database!.delete(_database!.saleItems).go();
      await _database!.delete(_database!.draftCarts).go();
      await _database!.delete(_database!.draftCartItems).go();
      await _database!.delete(_database!.inventoryLogs).go();
      await _database!.delete(_database!.restaurantTables).go();
      await _database!.delete(_database!.promotions).go();
      await _database!.delete(_database!.customers).go();
      await _database!.delete(_database!.productOptionGroups).go();
      await _database!.delete(_database!.productOptions).go();
    }
  }

  /// Get the test database instance
  static AppDatabase get database {
    if (_database == null) {
      throw StateError('TestApp not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Clean up resources
  static Future<void> dispose() async {
    // Close singleton blocs BEFORE closing the database: their pending
    // timers (draft autosave debounce, search debounce) would otherwise fire
    // after the DB is closed, throw an unhandled async error, and poison
    // every subsequent journey in the aggregate suite.
    Future<void> closeBloc<T extends BlocBase<Object?>>() async {
      try {
        if (sl.isRegistered<T>()) await sl<T>().close();
      } catch (_) {
        // Bloc may already be closed — safe to ignore during teardown.
      }
    }

    await closeBloc<DraftBloc>();
    await closeBloc<CartBloc>();
    await closeBloc<CheckoutBloc>();
    await closeBloc<ProductBloc>();
    await closeBloc<CategoryBloc>();
    await closeBloc<HistoryBloc>();

    await _database?.close();
    _database = null;
    _isConfigured = false;

    // Reset GetIt
    await sl.reset();
  }

  /// Configure dependencies with test database
  static Future<void> _configureDependenciesForTesting() async {
    // Start from a clean container, then replace the generated database
    // registration with the isolated in-memory test database.
    await sl.reset();
    configureDependencies();
    await sl.unregister<AppDatabase>();
    sl.registerSingleton<AppDatabase>(_database!);
  }

  /// Pump the full app for integration testing.
  ///
  /// Uses `pump` (not `pumpAndSettle`) because the app has continuous timers
  /// (clock, auto-refresh streams) that never settle — `pumpAndSettle` would
  /// block for the 10s default timeout on every call.
  ///
  /// Skips [initialize] if already configured — callers that seed data in
  /// `setUp` must call `initialize()` + `seedAll()` themselves, then call
  /// `pumpApp()` which will NOT wipe the seeded rows.
  static Future<void> pumpApp(WidgetTester tester) async {
    if (!_isConfigured) await initialize();
    await app.runPromsellApp(configure: false);
    await tester.pump(const Duration(seconds: 3));
  }

  /// Restart the app (for testing persistence scenarios)
  ///
  /// Uses `pump` (not `pumpAndSettle`) — same rationale as [pumpApp]:
  /// the app has continuous timers (clock, auto-refresh streams) that
  /// never settle, so `pumpAndSettle` would block for the 10s timeout.
  static Future<void> restartApp(WidgetTester tester) async {
    // Clear widget tree
    await tester.pumpWidget(Container());
    await tester.pump();

    // Restart app
    await app.runPromsellApp(configure: false);
    await tester.pump(const Duration(seconds: 3));
  }
}
