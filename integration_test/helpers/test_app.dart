import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
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

    // Create in-memory database
    _database = AppDatabase.forTesting(NativeDatabase.memory());

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
    await _database?.close();
    _database = null;
    _isConfigured = false;
    
    // Reset GetIt
    await sl.reset();
  }

  /// Configure dependencies with test database
  static Future<void> _configureDependenciesForTesting() async {
    // Reset GetIt if already configured
    if (sl.isRegistered<AppDatabase>()) {
      await sl.reset();
    }

    // Register test database
    sl.registerSingleton<AppDatabase>(_database!);

    // Let the app configure other dependencies
    configureDependencies();
  }

  /// Pump the full app for integration testing
  static Future<void> pumpApp(WidgetTester tester) async {
    await initialize();
    app.runPromsellApp();
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Restart the app (for testing persistence scenarios)
  static Future<void> restartApp(WidgetTester tester) async {
    // Clear widget tree
    await tester.pumpWidget(Container());
    await tester.pump();

    // Restart app
    app.runPromsellApp();
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}
