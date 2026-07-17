import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Test data fixtures for E2E tests
/// Pre-seeds database with realistic test data
class TestFixtures {
  TestFixtures._();

  static const _uuid = Uuid();
  static final DateTime now = DateTime(2026, 7, 10, 14, 30);

  /// Seed all test data to database
  static Future<void> seedAll(AppDatabase db) async {
    await seedCategories(db);
    await seedProducts(db);
    await seedTables(db);
    await seedPromotions(db);
    await seedCustomers(db);
  }

  /// Seed 5 product categories
  static Future<void> seedCategories(AppDatabase db) async {
    final categories = [
      CategoriesCompanion.insert(
        id: 'cat-drinks',
        name: 'Drinks',
        color: const Value('#2196F3'),
      ),
      CategoriesCompanion.insert(
        id: 'cat-food',
        name: 'Food',
        color: const Value('#FF9800'),
      ),
      CategoriesCompanion.insert(
        id: 'cat-dessert',
        name: 'Desserts',
        color: const Value('#E91E63'),
      ),
      CategoriesCompanion.insert(
        id: 'cat-snacks',
        name: 'Snacks',
        color: const Value('#4CAF50'),
      ),
      CategoriesCompanion.insert(
        id: 'cat-services',
        name: 'Services',
        color: const Value('#9C27B0'),
      ),
    ];

    for (final cat in categories) {
      await db.into(db.categories).insert(cat);
    }
  }

  /// Seed 20 products with varied prices, stock, and categories
  static Future<void> seedProducts(AppDatabase db) async {
    final products = [
      // Drinks (5 items)
      _product('Coffee', 45.0, 100, 'cat-drinks', '8850123456001'),
      _product('Green Tea', 40.0, 80, 'cat-drinks', '8850123456002'),
      _product('Orange Juice', 55.0, 50, 'cat-drinks', '8850123456003'),
      _product('Smoothie', 75.0, 30, 'cat-drinks'),
      _product('Iced Latte', 60.0, 60, 'cat-drinks'),

      // Food (7 items)
      _product('Burger', 120.0, 40, 'cat-food', '8850123456011'),
      _product('Pizza Slice', 95.0, 25, 'cat-food'),
      _product('Fried Rice', 80.0, 35, 'cat-food', '8850123456013'),
      _product('Pad Thai', 85.0, 30, 'cat-food'),
      _product('Green Curry', 110.0, 20, 'cat-food'),
      _product('Tom Yum Soup', 90.0, 25, 'cat-food'),
      _product('Spring Rolls', 65.0, 40, 'cat-food'),

      // Desserts (4 items)
      _product('Ice Cream', 50.0, 60, 'cat-dessert'),
      _product('Brownie', 55.0, 30, 'cat-dessert', '8850123456021'),
      _product('Cheesecake', 70.0, 20, 'cat-dessert'),
      _product('Mango Sticky Rice', 65.0, 15, 'cat-dessert'),

      // Snacks (3 items)
      _product('Chips', 25.0, 100, 'cat-snacks', '8850123456031'),
      _product('Popcorn', 30.0, 80, 'cat-snacks'),
      _product('Cookies', 35.0, 70, 'cat-snacks'),

      // Service (1 item - no stock tracking)
      ProductsCompanion.insert(
        id: _uuid.v4(),
        name: 'Service Charge',
        price: 50.0,
        stock: const Value(0),
        trackStock: const Value(false),
        categoryId: const Value('cat-services'),
        isActive: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    ];

    for (final product in products) {
      await db.into(db.products).insert(product);
    }
  }

  /// Seed 3 restaurant tables
  static Future<void> seedTables(AppDatabase db) async {
    final tables = [
      RestaurantTablesCompanion.insert(
        id: 'table-001',
        name: 'Table 1',
        seats: const Value(4),
        status: const Value('AVAILABLE'),
        createdAt: Value(now),
      ),
      RestaurantTablesCompanion.insert(
        id: 'table-005',
        name: 'Table 5',
        seats: const Value(6),
        status: const Value('AVAILABLE'),
        createdAt: Value(now),
      ),
      RestaurantTablesCompanion.insert(
        id: 'table-010',
        name: 'Table 10',
        seats: const Value(2),
        status: const Value('AVAILABLE'),
        createdAt: Value(now),
      ),
    ];

    for (final table in tables) {
      await db.into(db.restaurantTables).insert(table);
    }
  }

  /// Seed 2 active promotions
  static Future<void> seedPromotions(AppDatabase db) async {
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    final promotions = [
      PromotionsCompanion.insert(
        id: 'promo-percent-15',
        name: '15% Discount',
        type: const Value('PERCENT'),
        value: const Value(15.0),
        startDate: Value(yesterday),
        endDate: Value(tomorrow),
        isActive: const Value(true),
        createdAt: Value(now),
      ),
      PromotionsCompanion.insert(
        id: 'promo-fixed-50',
        name: '50 THB Off',
        type: const Value('FIXED'),
        value: const Value(50.0),
        startDate: Value(yesterday),
        endDate: Value(tomorrow),
        isActive: const Value(true),
        createdAt: Value(now),
      ),
    ];

    for (final promo in promotions) {
      await db.into(db.promotions).insert(promo);
    }
  }

  /// Seed 3 customers
  static Future<void> seedCustomers(AppDatabase db) async {
    final customers = [
      CustomersCompanion.insert(
        id: 'cust-001',
        name: 'John Doe',
        phone: const Value('0812345678'),
        createdAt: Value(now),
      ),
      CustomersCompanion.insert(
        id: 'cust-002',
        name: 'Jane Smith',
        phone: const Value('0823456789'),
        email: const Value('jane@example.com'),
        createdAt: Value(now),
      ),
      CustomersCompanion.insert(
        id: 'cust-003',
        name: 'Bob Wilson',
        createdAt: Value(now),
      ),
    ];

    for (final customer in customers) {
      await db.into(db.customers).insert(customer);
    }
  }

  /// Helper to create product companion
  static ProductsCompanion _product(
    String name,
    double price,
    int stock,
    String categoryId, [
    String? barcode,
  ]) {
    return ProductsCompanion.insert(
      id: _uuid.v4(),
      name: name,
      price: price,
      stock: Value(stock),
      trackStock: const Value(true),
      categoryId: Value(categoryId),
      barcode: Value(barcode),
      isActive: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  /// Find product by name (for test assertions)
  static Future<ProductData?> findProductByName(
    AppDatabase db,
    String name,
  ) async {
    final query = db.select(db.products)
      ..where((p) => p.name.equals(name));
    return query.getSingleOrNull();
  }

  /// Find category by name
  static Future<CategoryData?> findCategoryByName(
    AppDatabase db,
    String name,
  ) async {
    final query = db.select(db.categories)
      ..where((c) => c.name.equals(name));
    return query.getSingleOrNull();
  }

  /// Find table by name
  static Future<RestaurantTableData?> findTableByName(
    AppDatabase db,
    String name,
  ) async {
    final query = db.select(db.restaurantTables)
      ..where((t) => t.name.equals(name));
    return query.getSingleOrNull();
  }

  /// Find promotion by name
  static Future<PromotionData?> findPromotionByName(
    AppDatabase db,
    String name,
  ) async {
    final query = db.select(db.promotions)
      ..where((p) => p.name.equals(name));
    return query.getSingleOrNull();
  }
}
