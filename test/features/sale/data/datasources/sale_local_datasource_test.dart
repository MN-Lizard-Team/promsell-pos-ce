import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/customer/data/datasources/customer_datasource.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDatasource;
  late ProductLocalDatasourceImpl productDatasource;
  late CustomerDatasourceImpl customerDatasource;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    saleDatasource = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
    productDatasource = ProductLocalDatasourceImpl(
      db,
      ProductOptionDatasourceImpl(db),
    );
    customerDatasource = CustomerDatasourceImpl(db);
  });

  tearDown(() => db.close());

  Future<Product> seedProduct({
    String name = 'Test Product',
    double price = 100.0,
    int stock = 50,
  }) async {
    final id = IdGenerator.newId();
    await productDatasource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: name,
        price: price,
        stock: Value(stock),
      ),
    );
    return (await productDatasource.getProductById(id))!;
  }

  group('SaleLocalDatasourceImpl', () {
    test(
      'insertSaleWithItems creates sale with items and deducts stock',
      () async {
        final product = await seedProduct(stock: 50);
        final cartItem = CartItem(product: product, qty: 3);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(500),
          changeAmount: Money.fromDouble(200),
          note: 'test',
        );

        expect(sale.id, isNotEmpty);
        expect(sale.totalAmount.value, 300.0);
        expect(sale.paymentMethod, 'cash');
        expect(sale.items.length, 1);
        expect(sale.items.first.productName, 'Test Product');
        expect(sale.items.first.qty, 3);
        expect(sale.items.first.subtotal.value, 300.0);

        final stored = await db
            .customSelect(
              'SELECT total_amount_satang, amount_received_satang, '
              'change_amount_satang FROM sales WHERE id = ?',
              variables: [Variable<String>(sale.id)],
            )
            .getSingle();
        expect(stored.read<int>('total_amount_satang'), 30000);
        expect(stored.read<int>('amount_received_satang'), 50000);
        expect(stored.read<int>('change_amount_satang'), 20000);

        final updatedProduct = await productDatasource.getProductById(
          product.id,
        );
        expect(updatedProduct!.stock, 47);
        expect(sale.payments.length, 1);
        expect(sale.payments.first.method, 'cash');
        expect(sale.payments.first.amount.value, 300.0);
      },
    );

    test('sale reader prefers satang and falls back to legacy baht', () async {
      final product = await seedProduct(stock: 5, price: 100);
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await db.customStatement(
        'UPDATE sales SET total_amount = 999.99 WHERE id = \'${sale.id}\'',
      );
      final satangRead = await saleDatasource.querySaleById(sale.id);
      expect(satangRead!.totalAmount, const Money.fromSatang(10000));

      await db.customStatement(
        'UPDATE sales SET total_amount = 123.45, total_amount_satang = NULL '
        "WHERE id = '${sale.id}'",
      );
      final legacyRead = await saleDatasource.querySaleById(sale.id);
      expect(legacyRead!.totalAmount, Money.fromDouble(123.45));
    });

    test('insertSaleWithItems multi-tender stores payment lines', () async {
      final product = await seedProduct(stock: 10, price: 100);
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'mixed',
        vatMode: 'NONE',
        vatRate: 0,
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(40)),
          SalePayment(
            method: 'promptpay',
            amount: Money.fromDouble(60),
            reference: 'pp-ref',
          ),
        ],
        amountReceived: Money.fromDouble(40),
        changeAmount: Money.zero,
      );

      expect(sale.paymentMethod, 'mixed');
      expect(sale.payments.length, 2);
      expect(sale.payments[0].method, 'cash');
      expect(sale.payments[0].amount.value, 40);
      expect(sale.payments[1].method, 'promptpay');
      expect(sale.payments[1].amount.value, 60);
      expect(sale.payments[1].reference, 'pp-ref');

      final fetched = await saleDatasource.querySaleById(sale.id);
      expect(fetched!.payments.length, 2);
      expect(fetched.payments.map((p) => p.method).toList(), [
        'cash',
        'promptpay',
      ]);
    });

    test(
      'Wave P2: multi-tender change recomputed from cash leg ignores client',
      () async {
        final product = await seedProduct(stock: 10, price: 100);
        // Client sends full-bill style change (wrong); writer uses received-cash.
        final sale = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'mixed',
          vatMode: 'NONE',
          vatRate: 0,
          payments: [
            SalePayment(method: 'cash', amount: Money.fromDouble(40)),
            SalePayment(method: 'promptpay', amount: Money.fromDouble(60)),
          ],
          amountReceived: Money.fromDouble(50),
          changeAmount: Money.fromDouble(999),
        );

        expect(sale.amountReceived?.value, 50);
        // change = 50 − 40 cash leg = 10 (not 999, not 50−100).
        expect(sale.changeAmount?.value, 10);
      },
    );

    test('insertSaleWithItems rejects tender sum mismatch', () async {
      final product = await seedProduct(stock: 10, price: 100);
      await expectLater(
        () => saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'mixed',
          vatMode: 'NONE',
          vatRate: 0,
          payments: [
            SalePayment(method: 'cash', amount: Money.fromDouble(10)),
            SalePayment(method: 'promptpay', amount: Money.fromDouble(10)),
          ],
        ),
        throwsA(isA<BusinessRuleError>()),
      );
    });

    test(
      'insertSaleWithItems rejects inactive / missing / expired promotion',
      () async {
        final product = await seedProduct(stock: 10, price: 100);
        final now = DateTime.now();

        Future<void> insertPromo({
          required String id,
          required bool isActive,
          DateTime? start,
          DateTime? end,
        }) {
          return db
              .into(db.promotions)
              .insert(
                PromotionsCompanion.insert(
                  id: id,
                  name: 'Promo $id',
                  isActive: Value(isActive),
                  startDate: Value(
                    start ?? now.subtract(const Duration(days: 1)),
                  ),
                  endDate: Value(end),
                ),
              );
        }

        await insertPromo(id: 'promo-inactive', isActive: false);
        await insertPromo(
          id: 'promo-future',
          isActive: true,
          start: now.add(const Duration(days: 2)),
        );
        await insertPromo(
          id: 'promo-expired',
          isActive: true,
          start: now.subtract(const Duration(days: 10)),
          end: now.subtract(const Duration(days: 1)),
        );

        for (final promoId in [
          'promo-missing',
          'promo-inactive',
          'promo-future',
          'promo-expired',
        ]) {
          final stockBefore = (await productDatasource.getProductById(
            product.id,
          ))!.stock;
          await expectLater(
            () => saleDatasource.insertSaleWithItems(
              items: [CartItem(product: product, qty: 1)],
              paymentMethod: 'cash',
              vatMode: 'NONE',
              vatRate: 0,
              promotionId: promoId,
              promotionDiscountAmount: Money.fromDouble(5),
            ),
            throwsA(isA<NotFoundError>()),
            reason: promoId,
          );
          final stockAfter = (await productDatasource.getProductById(
            product.id,
          ))!.stock;
          expect(stockAfter, stockBefore, reason: 'stock unchanged: $promoId');
        }
      },
    );

    test('insertSaleWithItems accepts active promotion in window', () async {
      final product = await seedProduct(stock: 10, price: 100);
      final now = DateTime.now();
      await db
          .into(db.promotions)
          .insert(
            PromotionsCompanion.insert(
              id: 'promo-ok',
              name: 'Active promo',
              isActive: const Value(true),
              startDate: Value(now.subtract(const Duration(days: 1))),
              endDate: Value(now.add(const Duration(days: 7))),
            ),
          );

      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        promotionId: 'promo-ok',
        promotionDiscountAmount: Money.fromDouble(10),
      );
      expect(sale.promotionId, 'promo-ok');
      expect(sale.promotionDiscountAmount, Money.fromDouble(10));
      expect((await productDatasource.getProductById(product.id))!.stock, 9);
    });

    test('insertSaleWithItems rejects one-satang tender mismatch', () async {
      final product = await seedProduct(stock: 10, price: 100);
      await expectLater(
        () => saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'mixed',
          vatMode: 'NONE',
          vatRate: 0,
          payments: [
            SalePayment(method: 'cash', amount: Money.fromDouble(40)),
            SalePayment(method: 'transfer', amount: Money.fromDouble(59.99)),
          ],
        ),
        throwsA(isA<BusinessRuleError>()),
      );
    });

    test('insertSaleWithItems accepts exact tender sum in satang', () async {
      final product = await seedProduct(stock: 10, price: 100);
      // 40.005 + 59.995 would need Money precision; use exact 40+60.
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'mixed',
        vatMode: 'NONE',
        vatRate: 0,
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(40)),
          SalePayment(method: 'transfer', amount: Money.fromDouble(60)),
        ],
      );
      expect(sale.payments.length, 2);
      expect(
        sale.payments.fold<double>(0, (s, p) => s + p.amount.value),
        closeTo(100, 0.001),
      );
    });

    test('legacy single method still materializes one payment line', () async {
      final product = await seedProduct(stock: 5, price: 50);
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'transfer',
        vatMode: 'NONE',
        vatRate: 0,
      );
      expect(sale.paymentMethod, 'transfer');
      expect(sale.payments, hasLength(1));
      expect(sale.payments.first.method, 'transfer');
      expect(sale.payments.first.amount.value, 100);
    });

    test('querySales returns sales within date range', () async {
      final product = await seedProduct();
      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final allSales = await saleDatasource.querySales();
      expect(allSales.length, 1);

      final futureSales = await saleDatasource.querySales(
        from: DateTime.now().add(const Duration(days: 1)),
      );
      expect(futureSales, isEmpty);
    });

    test('querySaleById returns correct sale', () async {
      final product = await seedProduct();
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'transfer',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final fetched = await saleDatasource.querySaleById(sale.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, sale.id);
      expect(fetched.paymentMethod, 'transfer');
      expect(fetched.items.length, 1);
    });

    test('querySaleById returns null for non-existent id', () async {
      final result = await saleDatasource.querySaleById('non-existent-uuid');
      expect(result, isNull);
    });

    test('watchRecentSales emits updates', () async {
      final product = await seedProduct();
      final stream = saleDatasource.watchRecentSales(limit: 5);

      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'card',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await expectLater(
        stream,
        emitsThrough(predicate<List>((list) => list.isNotEmpty)),
      );
    });

    test('watchSales emits updates', () async {
      final product = await seedProduct();
      final stream = saleDatasource.watchSales();

      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await expectLater(
        stream,
        emitsThrough(predicate<List>((list) => list.isNotEmpty)),
      );
    });

    test('insertSaleWithItems preserves discount fields', () async {
      final product = await seedProduct(price: 200.0, stock: 50);
      final cartItem = CartItem(
        product: product,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10.0,
      );

      final sale = await saleDatasource.insertSaleWithItems(
        items: [cartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 20.0,
        cartDiscountAmount: Money.fromDouble(20.0),
      );

      expect(sale.discountType, 'AMOUNT');
      expect(sale.discountValue, 20.0);
      expect(sale.discountAmount.value, 20.0);
      expect(sale.items.first.discountAmount.value, greaterThan(0));
    });

    test(
      'insertSaleWithItems with EXCLUSIVE VAT stores total with VAT',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final cartItem = CartItem(product: product, qty: 1);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
        );

        expect(sale.totalAmount.value, closeTo(107.0, 0.01));
        expect(sale.subtotalAmount.value, 100.0);
        expect(sale.vatAmount.value, closeTo(7.0, 0.01));
        expect(sale.vatMode, 'EXCLUSIVE');
      },
    );

    test(
      'insertSaleWithItems includes service charge in totalAmount (NONE VAT)',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final cartItem = CartItem(product: product, qty: 1);
        final sc = Money.fromDouble(10.0);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          serviceChargeRate: 10.0,
          serviceChargeAmount: sc,
        );

        // 100 + SC 10 = 110
        expect(sale.totalAmount.value, closeTo(110.0, 0.01));
        expect(sale.serviceChargeAmount.value, closeTo(10.0, 0.01));
        expect(sale.serviceChargeRate, 10.0);
      },
    );

    test(
      'insertSaleWithItems SC + EXCLUSIVE VAT matches checkout payable',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final cartItem = CartItem(product: product, qty: 1);
        final sc = Money.fromDouble(10.0);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
          serviceChargeRate: 10.0,
          serviceChargeAmount: sc,
        );

        // preTax = 100 + 10 = 110; VAT 7% = 7.7; total = 117.7
        expect(sale.totalAmount.value, closeTo(117.7, 0.01));
        expect(sale.subtotalAmount.value, closeTo(110.0, 0.01));
        expect(sale.vatAmount.value, closeTo(7.7, 0.01));
        expect(sale.serviceChargeAmount.value, closeTo(10.0, 0.01));
      },
    );

    test(
      'insertSaleWithItems SC + INCLUSIVE VAT keeps total as preTax',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final cartItem = CartItem(product: product, qty: 1);
        final sc = Money.fromDouble(10.0);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'INCLUSIVE',
          vatRate: 7.0,
          serviceChargeRate: 10.0,
          serviceChargeAmount: sc,
        );

        // preTax = 110 inclusive of VAT
        expect(sale.totalAmount.value, closeTo(110.0, 0.01));
        expect(sale.serviceChargeAmount.value, closeTo(10.0, 0.01));
        expect(sale.vatAmount.value, greaterThan(0));
      },
    );
  });

  group('customer aggregation', () {
    Future<String> seedCustomer({String name = 'Alice'}) async {
      final id = IdGenerator.newId();
      await customerDatasource.insert(
        CustomersCompanion.insert(id: id, name: name),
      );
      return id;
    }

    test(
      'insertSaleWithItems updates customer totalSpent and visitCount',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final customerId = await seedCustomer();

        await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 2)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          customerId: customerId,
        );

        final customer = await customerDatasource.getById(customerId);
        expect(customer!.totalSpent.value, 200.0);
        expect(customer.visitCount, 1);
        final stored = await db
            .customSelect(
              'SELECT total_spent_satang FROM customers WHERE id = ?',
              variables: [Variable<String>(customerId)],
            )
            .getSingle();
        expect(stored.read<int>('total_spent_satang'), 20000);
      },
    );

    test(
      'multiple sales accumulate customer totals and void reverses them',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final customerId = await seedCustomer();

        final sale1 = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          customerId: customerId,
        );
        final sale2 = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 3)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          customerId: customerId,
        );

        var customer = await customerDatasource.getById(customerId);
        expect(customer!.totalSpent.value, 400.0);
        expect(customer.visitCount, 2);
        var stored = await db
            .customSelect(
              'SELECT total_spent_satang FROM customers WHERE id = ?',
              variables: [Variable<String>(customerId)],
            )
            .getSingle();
        expect(stored.read<int>('total_spent_satang'), 40000);

        await saleDatasource.voidSale(sale2.id);

        var afterVoid = await customerDatasource.getById(customerId);
        expect(afterVoid!.totalSpent.value, 100.0);
        expect(afterVoid.visitCount, 1);
        stored = await db
            .customSelect(
              'SELECT total_spent_satang FROM customers WHERE id = ?',
              variables: [Variable<String>(customerId)],
            )
            .getSingle();
        expect(stored.read<int>('total_spent_satang'), 10000);

        // Void remaining sale brings totals back to zero.
        await saleDatasource.voidSale(sale1.id);
        final finalCustomer = await customerDatasource.getById(customerId);
        expect(finalCustomer!.totalSpent.value, 0.0);
        expect(finalCustomer.visitCount, 0);
      },
    );

    test('sale without customerId does not touch customer totals', () async {
      final product = await seedProduct(price: 100.0, stock: 50);
      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final allCustomers = await customerDatasource.getAll();
      expect(allCustomers, isEmpty);
    });

    test(
      'insertSaleWithItems throws InsufficientStock when oversell off',
      () async {
        fakeSettingsRepo.allowOversell = false;
        final product = await seedProduct(stock: 2);

        expect(
          () => saleDatasource.insertSaleWithItems(
            items: [CartItem(product: product, qty: 5)],
            paymentMethod: 'cash',
            vatMode: 'NONE',
            vatRate: 0,
          ),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              'InsufficientStock',
            ),
          ),
        );

        final unchanged = await productDatasource.getProductById(product.id);
        expect(unchanged!.stock, 2);
      },
    );

    test(
      'insertSaleWithItems allows oversell when allowOversell is true',
      () async {
        fakeSettingsRepo.allowOversell = true;
        final product = await seedProduct(stock: 2);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 5)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        expect(sale.items.first.qty, 5);
        final updated = await productDatasource.getProductById(product.id);
        expect(updated!.stock, -3);
      },
    );

    test(
      'insertSaleWithItems aggregates multi-line qty for same product',
      () async {
        fakeSettingsRepo.allowOversell = false;
        final product = await seedProduct(stock: 5);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [
            CartItem(product: product, qty: 2),
            CartItem(product: product, qty: 3),
          ],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        expect(sale.items.length, 2);
        final updated = await productDatasource.getProductById(product.id);
        expect(updated!.stock, 0);
      },
    );

    test(
      'insertSaleWithItems multi-line over stock fails when oversell off',
      () async {
        fakeSettingsRepo.allowOversell = false;
        final product = await seedProduct(stock: 4);

        expect(
          () => saleDatasource.insertSaleWithItems(
            items: [
              CartItem(product: product, qty: 2),
              CartItem(product: product, qty: 3),
            ],
            paymentMethod: 'cash',
            vatMode: 'NONE',
            vatRate: 0,
          ),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              'InsufficientStock',
            ),
          ),
        );
      },
    );
  });

  /// C4 — concurrent / race characterization for atomic stock deduct.
  ///
  /// SQLite serializes writers on one connection; these tests still prove the
  /// CAS-style `stock = stock - ? AND stock >= ?` path never leaves negative
  /// stock when [allowOversell] is false, and never "loses" units under races.
  group('concurrent stock / double-sale (C4)', () {
    Future<Object> trySale({required Product product, required int qty}) async {
      try {
        final sale = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: qty)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );
        return sale;
      } catch (e) {
        return e;
      }
    }

    test(
      'parallel double-sale of full stock: at most one wins; stock never negative',
      () async {
        fakeSettingsRepo.allowOversell = false;
        const initial = 5;
        final product = await seedProduct(stock: initial);

        // Both try to take the entire shelf at once.
        final results = await Future.wait([
          trySale(product: product, qty: initial),
          trySale(product: product, qty: initial),
        ]);

        final successes = results.whereType<Sale>().toList();
        final failures = results.whereType<BusinessRuleError>().toList();

        expect(successes.length + failures.length, 2);
        // Exactly one sale should commit when oversell is off.
        expect(successes, hasLength(1));
        expect(failures, hasLength(1));
        expect(failures.single.rule, 'InsufficientStock');
        expect(successes.single.items.first.qty, initial);

        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, 0);
        expect(after.stock, greaterThanOrEqualTo(0));

        final soldQty = successes.fold<int>(
          0,
          (s, sale) => s + sale.items.fold(0, (a, i) => a + i.qty),
        );
        expect(soldQty + after.stock, initial);
      },
    );

    test(
      'parallel overlapping partial sales preserve stock conservation',
      () async {
        fakeSettingsRepo.allowOversell = false;
        const initial = 10;
        final product = await seedProduct(stock: initial);

        // Three concurrent sales of 4 units each (12 > 10) — at most two can win.
        final results = await Future.wait([
          trySale(product: product, qty: 4),
          trySale(product: product, qty: 4),
          trySale(product: product, qty: 4),
        ]);

        final successes = results.whereType<Sale>().toList();
        final failures = results.whereType<BusinessRuleError>().toList();

        expect(successes.length + failures.length, 3);
        expect(successes.length, lessThanOrEqualTo(2));
        expect(failures.every((e) => e.rule == 'InsufficientStock'), isTrue);

        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, greaterThanOrEqualTo(0));

        final soldQty = successes.fold<int>(
          0,
          (s, sale) => s + sale.items.fold(0, (a, i) => a + i.qty),
        );
        expect(soldQty + after.stock, initial);
        expect(soldQty, lessThanOrEqualTo(initial));
      },
    );

    test(
      'sequential back-to-back sales cannot oversell remaining stock',
      () async {
        fakeSettingsRepo.allowOversell = false;
        final product = await seedProduct(stock: 5);

        final first = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 3)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );
        expect(first.items.first.qty, 3);

        // Second sale still uses stale Product.stock=5 in the cart snapshot,
        // but SQL CAS must fail for qty 3 when only 2 remain.
        expect(
          () => saleDatasource.insertSaleWithItems(
            items: [CartItem(product: product, qty: 3)],
            paymentMethod: 'cash',
            vatMode: 'NONE',
            vatRate: 0,
          ),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              'InsufficientStock',
            ),
          ),
        );

        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, 2);
      },
    );

    test(
      'sale then void then concurrent re-sale restores stock for next buyer',
      () async {
        fakeSettingsRepo.allowOversell = false;
        final product = await seedProduct(stock: 3);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 3)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );
        await saleDatasource.voidSale(sale.id);

        final mid = await productDatasource.getProductById(product.id);
        expect(mid!.stock, 3);

        final results = await Future.wait([
          trySale(product: product, qty: 2),
          trySale(product: product, qty: 2),
        ]);
        final successes = results.whereType<Sale>().toList();
        final failures = results.whereType<BusinessRuleError>().toList();

        expect(successes, hasLength(1));
        expect(failures, hasLength(1));
        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, 1);
        expect(successes.single.items.first.qty + after.stock, 3);
      },
    );
  });

  group('soft-delete filtering', () {
    test('querySales excludes soft-deleted sales', () async {
      final product = await seedProduct();
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await (db.update(db.sales)..where((s) => s.id.equals(sale.id))).write(
        SalesCompanion(deletedAt: Value(DateTime.now())),
      );

      expect(await saleDatasource.querySales(), isEmpty);
      expect(await saleDatasource.querySaleById(sale.id), isNull);
    });
  });
}
