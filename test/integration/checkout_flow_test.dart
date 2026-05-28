import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late ProductRepositoryImpl productRepo;
  late SaleRepositoryImpl saleRepo;

  setUp(() {
    db = createInMemoryDatabase();
    productDs = ProductLocalDatasourceImpl(db);
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(db),
    );
    productRepo = ProductRepositoryImpl(productDs);
    saleRepo = SaleRepositoryImpl(saleDs);
  });

  tearDown(() => db.close());

  group('Checkout flow (end-to-end data layer)', () {
    test(
      'full checkout: add products → create sale → verify stock deducted',
      () async {
        // 1. Add products
        final waterId = IdGenerator.newId();
        await productDs.insertProduct(
          ProductsCompanion.insert(
            id: waterId,
            name: 'Water',
            price: 10.0,
            stock: const Value(50),
          ),
        );
        final cokeId = IdGenerator.newId();
        await productDs.insertProduct(
          ProductsCompanion.insert(
            id: cokeId,
            name: 'Coke',
            price: 25.0,
            stock: const Value(30),
          ),
        );

        // 2. Fetch products via repo
        final products = await productRepo.getActiveProducts();
        expect(products.length, 2);

        final water = products.firstWhere((p) => p.name == 'Water');
        final coke = products.firstWhere((p) => p.name == 'Coke');
        expect(water.stock, 50);
        expect(coke.stock, 30);

        // 3. Create a sale (3x Water, 2x Coke)
        final cart = [
          CartItem(product: water, qty: 3),
          CartItem(product: coke, qty: 2),
        ];
        final expectedTotal = (3 * 10.0) + (2 * 25.0); // 80.0

        final sale = await saleRepo.createSale(
          items: cart,
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: 100,
          changeAmount: 20,
          note: 'Integration test',
        );

        // 4. Verify sale
        expect(sale.totalAmount, expectedTotal);
        expect(sale.paymentMethod, 'cash');
        expect(sale.items.length, 2);
        expect(sale.items.where((i) => i.productName == 'Water').first.qty, 3);
        expect(sale.items.where((i) => i.productName == 'Coke').first.qty, 2);

        // 5. Verify stock deducted
        final updatedWater = await productDs.getProductById(waterId);
        final updatedCoke = await productDs.getProductById(cokeId);
        expect(updatedWater!.stock, 47); // 50 - 3
        expect(updatedCoke!.stock, 28); // 30 - 2

        // 6. Verify sale appears in history
        final sales = await saleDs.querySales();
        expect(sales.length, 1);
        expect(sales.first.id, sale.id);
      },
    );

    test('multiple sales deduct stock cumulatively', () async {
      final id = IdGenerator.newId();
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: id,
          name: 'Juice',
          price: 15.0,
          stock: const Value(20),
        ),
      );

      final product = (await productDs.getProductById(id))!;

      // Sale 1: buy 5
      await saleRepo.createSale(
        items: [CartItem(product: product, qty: 5)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      // Sale 2: buy 3 (use refreshed product)
      final updated1 = (await productDs.getProductById(id))!;
      expect(updated1.stock, 15);

      await saleRepo.createSale(
        items: [CartItem(product: updated1, qty: 3)],
        paymentMethod: 'transfer',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final updated2 = (await productDs.getProductById(id))!;
      expect(updated2.stock, 12); // 20 - 5 - 3

      // Verify 2 sales total
      final allSales = await saleDs.querySales();
      expect(allSales.length, 2);
    });

    test('sale with note persists correctly', () async {
      final id = IdGenerator.newId();
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: id,
          name: 'Snack',
          price: 5.0,
          stock: const Value(100),
        ),
      );
      final product = (await productDs.getProductById(id))!;

      final sale = await saleRepo.createSale(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'card',
        vatMode: 'NONE',
        vatRate: 0,
        note: 'VIP customer',
      );

      final fetched = await saleDs.querySaleById(sale.id);
      expect(fetched, isNotNull);
      expect(fetched!.note, 'VIP customer');
      expect(fetched.paymentMethod, 'card');
    });
  });
}
