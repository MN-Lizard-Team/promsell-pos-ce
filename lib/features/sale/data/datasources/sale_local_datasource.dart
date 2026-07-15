import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

abstract class SaleLocalDatasource {
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    Money? cartDiscountAmount,
    Money? amountReceived,
    Money? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
    List<SalePayment>? payments,
    String orderType = 'delivery',
    String orderChannel = 'walkin',
    String? externalOrderRef,
    String? tableId,
    double serviceChargeRate = 0.0,
    Money serviceChargeAmount = Money.zero,
    String? customerId,
    String? promotionId,
    Money promotionDiscountAmount = Money.zero,
  });

  Future<List<Sale>> querySales({DateTime? from, DateTime? to});
  Future<Sale?> querySaleById(String id);
  Stream<List<Sale>> watchRecentSales({int limit});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
  Future<void> voidSale(String saleId, {String? reason});
}

@LazySingleton(as: SaleLocalDatasource)
class SaleLocalDatasourceImpl implements SaleLocalDatasource {
  SaleLocalDatasourceImpl(
    this._db, {
    required this.receiptNumberService,
    required this.inventoryLogService,
    required this.settingsRepo,
  });
  final AppDatabase _db;
  final ReceiptNumberService receiptNumberService;
  final InventoryLogService inventoryLogService;
  final SettingsRepository settingsRepo;

  String? _cachedDeviceId;
  Future<String> _getDeviceId() async {
    return _cachedDeviceId ??=
        (await settingsRepo.load()).deviceConfig.deviceId;
  }

  Sale _buildSale(
    SaleData s,
    List<SaleItemData> items, {
    List<SalePaymentData> paymentRows = const [],
  }) => Sale(
    id: s.id,
    receiptNumber: s.receiptNumber,
    status: s.status,
    subtotalAmount: Money.fromDouble(s.subtotalAmount),
    discountType: s.discountType,
    discountValue: s.discountValue,
    discountAmount: Money.fromDouble(s.discountAmount),
    vatMode: s.vatMode,
    vatRate: s.vatRate,
    vatAmount: Money.fromDouble(s.vatAmount),
    orderType: s.orderType,
    orderChannel: s.orderChannel,
    externalOrderRef: s.externalOrderRef,
    tableId: s.tableId,
    serviceChargeRate: s.serviceChargeRate,
    serviceChargeAmount: Money.fromDouble(s.serviceChargeAmount),
    customerId: s.customerId,
    promotionId: s.promotionId,
    promotionDiscountAmount: Money.fromDouble(s.promotionDiscountAmount),
    totalAmount: Money.fromDouble(s.totalAmount),
    paymentMethod: s.paymentMethod,
    amountReceived: s.amountReceived != null
        ? Money.fromDouble(s.amountReceived!)
        : null,
    changeAmount: s.changeAmount != null
        ? Money.fromDouble(s.changeAmount!)
        : null,
    note: s.note,
    paymentReference: s.paymentReference,
    sendingBankCode: s.sendingBankCode,
    voidedAt: s.voidedAt,
    voidReason: s.voidReason,
    createdAt: s.createdAt,
    payments: [
      for (final p in paymentRows)
        SalePayment(
          id: p.id,
          saleId: p.saleId,
          method: p.method,
          amount: Money.fromDouble(p.amount),
          reference: p.reference,
          sendingBankCode: p.sendingBankCode,
          sortOrder: p.sortOrder,
        ),
    ],
    items: items
        .map(
          (i) => SaleItem(
            id: i.id,
            saleId: i.saleId,
            productId: i.productId,
            productName: i.productName,
            price: Money.fromDouble(i.price),
            qty: i.qty,
            subtotal: Money.fromDouble(i.subtotal),
            discountAmount: Money.fromDouble(i.discountAmount),
            vatAmount: Money.fromDouble(i.vatAmount),
            note: i.note,
            selectedOptions: _parseSelectedOptions(i.productOptionsJson),
            updatedAt: i.updatedAt,
            deletedAt: i.deletedAt,
            version: i.version,
            deviceId: i.deviceId,
          ),
        )
        .toList(),
  );

  List<SelectedProductOption> _parseSelectedOptions(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => SelectedProductOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  String? _serializeSelectedOptions(List<SelectedProductOption> options) {
    if (options.isEmpty) return null;
    return jsonEncode(options.map((o) => o.toJson()).toList());
  }

  Future<List<SaleItemData>> _itemsForSale(String saleId) => (_db.select(
    _db.saleItems,
  )..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())).get();

  Future<List<SalePaymentData>> _paymentsForSale(String saleId) =>
      (_db.select(_db.salePayments)
            ..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  @override
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    Money? cartDiscountAmount,
    Money? amountReceived,
    Money? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
    List<SalePayment>? payments,
    String orderType = 'delivery',
    String orderChannel = 'walkin',
    String? externalOrderRef,
    String? tableId,
    double serviceChargeRate = 0.0,
    Money serviceChargeAmount = Money.zero,
    String? customerId,
    String? promotionId,
    Money promotionDiscountAmount = Money.zero,
  }) async {
    final itemsSubtotal = items.fold(Money.zero, (sum, i) => sum + i.subtotal);
    final effectiveCartDiscount = cartDiscountAmount ?? Money.zero;
    final effectivePromoDiscount = promotionDiscountAmount.clampToZero();
    final totals = SalePayableCalculator.computeWithServiceChargeAmount(
      SalePayableInput(
        itemsSubtotal: itemsSubtotal,
        cartDiscountAmount: effectiveCartDiscount,
        promotionDiscountAmount: effectivePromoDiscount,
        serviceChargeRate: serviceChargeRate,
        vatMode: vatMode,
        vatRate: vatRate,
      ),
      serviceChargeAmount: serviceChargeAmount,
    );
    final subtotal = totals.netOfVat;
    final vatAmount = totals.vatAmount;
    final finalTotal = totals.payableTotal;

    // Multi-tender lines or single legacy method as one line.
    final List<SalePayment> tenderLines;
    if (payments != null && payments.isNotEmpty) {
      tenderLines = [
        for (var i = 0; i < payments.length; i++)
          SalePayment(
            method: payments[i].method.trim().toLowerCase(),
            amount: payments[i].amount,
            reference: payments[i].reference,
            sendingBankCode: payments[i].sendingBankCode,
            sortOrder: payments[i].sortOrder != 0 ? payments[i].sortOrder : i,
          ),
      ];
    } else {
      tenderLines = [
        SalePayment(
          method: paymentMethod.trim().toLowerCase(),
          amount: finalTotal,
          reference: paymentReference,
          sendingBankCode: sendingBankCode,
        ),
      ];
    }
    final tenderSum = tenderLines.fold(Money.zero, (s, p) => s + p.amount);
    final mismatch = tenderSum.subtractUnclamped(finalTotal);
    if (mismatch.value.abs() > 0.009) {
      throw BusinessRuleError(
        'PaymentMismatch',
        details: 'Tender sum ${tenderSum.value} != payable ${finalTotal.value}',
      );
    }
    final headerMethod = tenderLines.length == 1
        ? tenderLines.first.method
        : 'mixed';
    final cashTender = tenderLines
        .where((p) => p.method == 'cash')
        .fold(Money.zero, (s, p) => s + p.amount);
    final Money? effectiveReceived;
    final Money? effectiveChange;
    if (cashTender > Money.zero) {
      effectiveReceived = amountReceived ?? cashTender;
      final change = effectiveReceived - cashTender;
      effectiveChange =
          changeAmount ?? (change > Money.zero ? change : Money.zero);
    } else if (headerMethod != 'cash' && amountReceived != null) {
      effectiveReceived = finalTotal;
      effectiveChange = Money.zero;
    } else {
      effectiveReceived = amountReceived;
      effectiveChange = changeAmount;
    }
    if (promotionId != null) {
      await _assertPromotionActive(promotionId);
    }

    final saleId = IdGenerator.newId();
    final deviceId = await _getDeviceId();
    late SaleData saleData;
    await _db.transaction(() async {
      // Receipt # with unique index: retry on rare race / reseed lag.
      const maxReceiptAttempts = 3;
      Object? lastReceiptError;
      for (var attempt = 0; attempt < maxReceiptAttempts; attempt++) {
        final receiptNumber = await receiptNumberService.nextReceiptNumber();
        try {
          await _db
              .into(_db.sales)
              .insert(
                SalesCompanion.insert(
                  id: saleId,
                  receiptNumber: Value(receiptNumber),
                  totalAmount: finalTotal.value,
                  subtotalAmount: Value(subtotal.value),
                  discountType: Value(cartDiscountType),
                  discountValue: Value(cartDiscountValue),
                  discountAmount: Value(effectiveCartDiscount.value),
                  vatMode: Value(vatMode),
                  vatRate: Value(vatRate),
                  vatAmount: Value(vatAmount.value),
                  orderType: Value(orderType),
                  orderChannel: Value(orderChannel),
                  externalOrderRef: Value(externalOrderRef),
                  tableId: Value(tableId),
                  serviceChargeRate: Value(serviceChargeRate),
                  serviceChargeAmount: Value(serviceChargeAmount.value),
                  customerId: Value(customerId),
                  promotionId: Value(promotionId),
                  promotionDiscountAmount: Value(promotionDiscountAmount.value),
                  paymentMethod: headerMethod,
                  amountReceived: Value(effectiveReceived?.value),
                  changeAmount: Value(effectiveChange?.value),
                  note: Value(note),
                  paymentReference: Value(
                    paymentReference ??
                        (tenderLines.length == 1
                            ? tenderLines.first.reference
                            : null),
                  ),
                  sendingBankCode: Value(
                    sendingBankCode ??
                        (tenderLines.length == 1
                            ? tenderLines.first.sendingBankCode
                            : null),
                  ),
                  deviceId: Value(deviceId),
                ),
              );
          lastReceiptError = null;
          break;
        } catch (e) {
          lastReceiptError = e;
          final msg = e.toString().toLowerCase();
          final uniqueHit =
              msg.contains('unique') || msg.contains('constraint');
          if (!uniqueHit || attempt == maxReceiptAttempts - 1) {
            rethrow;
          }
        }
      }
      if (lastReceiptError != null) {
        throw lastReceiptError;
      }
      saleData = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      for (final pay in tenderLines) {
        await _db
            .into(_db.salePayments)
            .insert(
              SalePaymentsCompanion.insert(
                id: IdGenerator.newId(),
                saleId: saleId,
                method: pay.method,
                amount: pay.amount.value,
                reference: Value(pay.reference),
                sendingBankCode: Value(pay.sendingBankCode),
                sortOrder: Value(pay.sortOrder),
                deviceId: Value(deviceId),
              ),
            );
      }

      // Load oversell policy once per sale (stock integrity).
      final allowOversell = (await settingsRepo.load()).allowOversell;

      // Aggregate qty per product (option lines share product id).
      final quantitiesByProduct = <String, int>{};
      for (final item in items) {
        quantitiesByProduct.update(
          item.product.id,
          (quantity) => quantity + item.qty,
          ifAbsent: () => item.qty,
        );
      }
      final productIds = quantitiesByProduct.keys.toList();
      final productRows = await (_db.select(
        _db.products,
      )..where((p) => p.id.isIn(productIds))).get();
      final productMap = {
        for (final product in productRows) product.id: product,
      };

      // Fail closed if catalog row missing/inactive; pre-check stock when needed.
      for (final item in items) {
        final product = productMap[item.product.id];
        if (product == null) {
          throw NotFoundError('Product', id: item.product.id);
        }
        if (!product.isActive) {
          throw BusinessRuleError(
            'ProductInactive',
            details: '"${product.name}" is inactive and cannot be sold.',
          );
        }
      }
      if (!allowOversell) {
        for (final entry in quantitiesByProduct.entries) {
          final product = productMap[entry.key]!;
          if (!product.trackStock) continue;
          if (product.stock < entry.value) {
            throw BusinessRuleError(
              'InsufficientStock',
              details:
                  'Insufficient stock for "${product.name}": available ${product.stock}, requested ${entry.value}',
            );
          }
        }
      }

      // Snapshot sale lines (price/name/options) with allocated line VAT.
      final lineVats = _allocateLineVat(
        items: items,
        headerVat: vatAmount,
        vatMode: vatMode,
        vatRate: vatRate,
      );
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final itemVatAmount = lineVats[i];
        await _db
            .into(_db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                id: IdGenerator.newId(),
                saleId: saleId,
                productId: item.product.id,
                productName: item.product.name,
                price: item.product.price.value,
                qty: item.qty,
                subtotal: item.subtotal.value,
                discountAmount: Value(item.discountAmount.value),
                vatAmount: Value(itemVatAmount.value),
                note: Value(item.note),
                productOptionsJson: Value(
                  _serializeSelectedOptions(item.selectedOptions),
                ),
                deviceId: Value(deviceId),
              ),
            );
      }

      // Atomic stock deduct after line snapshots succeed.
      for (final entry in quantitiesByProduct.entries) {
        final product = productMap[entry.key]!;
        if (!product.trackStock) continue;
        final qty = entry.value;
        final now = DateTime.now();
        if (!allowOversell) {
          // Atomic: stock = stock - qty only when still sufficient.
          final rows = await _db.customUpdate(
            'UPDATE products SET stock = stock - ?, updated_at = ? '
            'WHERE id = ? AND track_stock = 1 AND stock >= ?',
            variables: [
              Variable.withInt(qty),
              Variable.withDateTime(now),
              Variable.withString(product.id),
              Variable.withInt(qty),
            ],
            updates: {_db.products},
          );
          if (rows == 0) {
            throw BusinessRuleError(
              'InsufficientStock',
              details:
                  'Insufficient stock for "${product.name}": available ${product.stock}, requested $qty',
            );
          }
          final balRow =
              await (_db.select(_db.products)
                    ..where((p) => p.id.equals(product.id)))
                  .getSingle();
          await inventoryLogService.logSale(
            productId: product.id,
            qty: qty,
            saleId: saleId,
            balanceAfter: balRow.stock,
          );
        } else {
          // Atomic allow-negative: stock = stock - qty
          await _db.customUpdate(
            'UPDATE products SET stock = stock - ?, updated_at = ? '
            'WHERE id = ? AND track_stock = 1',
            variables: [
              Variable.withInt(qty),
              Variable.withDateTime(now),
              Variable.withString(product.id),
            ],
            updates: {_db.products},
          );
          final balRow =
              await (_db.select(_db.products)
                    ..where((p) => p.id.equals(product.id)))
                  .getSingle();
          await inventoryLogService.logSale(
            productId: product.id,
            qty: qty,
            saleId: saleId,
            balanceAfter: balRow.stock,
          );
        }
      }

      // Roll up customer totals so loyalty/reporting stays correct.
      if (customerId != null) {
        await _applyCustomerSpentDelta(
          customerId: customerId,
          delta: finalTotal,
          visitDelta: 1,
          requireActive: true,
        );
      }
    });
    final saleItems = await _itemsForSale(saleData.id);
    final paymentRows = await _paymentsForSale(saleId);
    return _buildSale(saleData, saleItems, paymentRows: paymentRows);
  }

  /// Distribute [headerVat] across lines by subtotal weight; last line gets residual.
  List<Money> _allocateLineVat({
    required List<CartItem> items,
    required Money headerVat,
    required String vatMode,
    required double vatRate,
  }) {
    if (items.isEmpty || headerVat <= Money.zero || vatRate <= 0) {
      return List<Money>.filled(items.length, Money.zero);
    }
    final weights = items.map((i) => i.subtotal).toList();
    final weightSum = weights.fold(Money.zero, (a, b) => a + b);
    if (weightSum <= Money.zero) {
      return List<Money>.filled(items.length, Money.zero);
    }
    final allocated = <Money>[];
    var remaining = headerVat;
    for (var i = 0; i < items.length; i++) {
      if (i == items.length - 1) {
        allocated.add(remaining.clampToZero());
        break;
      }
      // Proportional share in satang (integer math).
      final shareSatang =
          (headerVat.satang * weights[i].satang) ~/ weightSum.satang;
      final share = Money.fromDouble(shareSatang / 100.0);
      allocated.add(share);
      remaining = remaining - share;
    }
    return allocated;
  }

  /// Fail closed when a sale references a missing, deleted, or inactive promo.
  Future<void> _assertPromotionActive(String promotionId) async {
    final now = DateTime.now();
    final row =
        await (_db.select(_db.promotions)
              ..where((p) => p.id.equals(promotionId))
              ..where((p) => p.deletedAt.isNull())
              ..where((p) => p.isActive.equals(true)))
            .getSingleOrNull();
    if (row == null) {
      throw NotFoundError('Promotion', id: promotionId);
    }
    if (now.isBefore(row.startDate)) {
      throw NotFoundError('Promotion', id: promotionId);
    }
    if (row.endDate != null && now.isAfter(row.endDate!)) {
      throw NotFoundError('Promotion', id: promotionId);
    }
  }

  /// Updates a customer's lifetime [totalSpent] and [visitCount] by absolute
  /// deltas, re-reading the current row inside the caller's transaction.
  ///
  /// When [requireActive] is true (sale create), missing/soft-deleted customers
  /// fail closed. Void reversal keeps soft-deleted rows so history can unwind.
  Future<void> _applyCustomerSpentDelta({
    required String customerId,
    required Money delta,
    required int visitDelta,
    bool requireActive = false,
  }) async {
    final query = _db.select(_db.customers)
      ..where((c) => c.id.equals(customerId));
    if (requireActive) {
      query.where((c) => c.deletedAt.isNull());
    }
    final customer = await query.getSingleOrNull();
    if (customer == null) {
      if (requireActive) {
        throw NotFoundError('Customer', id: customerId);
      }
      return;
    }
    final currentSpent = Money.fromDouble(customer.totalSpent);
    final newTotalSpent = (currentSpent + delta).clampToZero();
    final newVisitCount = (customer.visitCount + visitDelta).clamp(0, 1 << 31);
    await (_db.update(
      _db.customers,
    )..where((c) => c.id.equals(customerId))).write(
      CustomersCompanion(
        totalSpent: Value(newTotalSpent.value),
        visitCount: Value(newVisitCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<Sale>> querySales({DateTime? from, DateTime? to}) async {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final salesData = await query.get();
    if (salesData.isEmpty) return [];
    final saleIds = salesData.map((s) => s.id).toList();
    final allItems = await (_db.select(
      _db.saleItems,
    )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
    final itemsBySaleId = <String, List<SaleItemData>>{};
    for (final item in allItems) {
      (itemsBySaleId[item.saleId] ??= []).add(item);
    }
    final allPays = await (_db.select(
      _db.salePayments,
    )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
    final paysBySaleId = <String, List<SalePaymentData>>{};
    for (final pay in allPays) {
      (paysBySaleId[pay.saleId] ??= []).add(pay);
    }
    return salesData
        .map(
          (s) => _buildSale(
            s,
            itemsBySaleId[s.id] ?? [],
            paymentRows: paysBySaleId[s.id] ?? const [],
          ),
        )
        .toList();
  }

  @override
  Future<Sale?> querySaleById(String id) async {
    final s =
        await (_db.select(_db.sales)
              ..where((t) => t.id.equals(id))
              ..where((t) => t.deletedAt.isNull()))
            .getSingleOrNull();
    if (s == null) return null;
    final items = await _itemsForSale(id);
    final paymentRows = await _paymentsForSale(id);
    return _buildSale(s, items, paymentRows: paymentRows);
  }

  @override
  Stream<List<Sale>> watchRecentSales({int limit = 20}) {
    final query = _db.select(_db.sales)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit);
    return query.watch().asyncMap((salesData) async {
      if (salesData.isEmpty) return [];
      final saleIds = salesData.map((s) => s.id).toList();
      final allItems = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
      final itemsBySaleId = <String, List<SaleItemData>>{};
      for (final item in allItems) {
        (itemsBySaleId[item.saleId] ??= []).add(item);
      }
      final allPays = await (_db.select(
        _db.salePayments,
      )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
      final paysBySaleId = <String, List<SalePaymentData>>{};
      for (final pay in allPays) {
        (paysBySaleId[pay.saleId] ??= []).add(pay);
      }
      return salesData
          .map(
            (s) => _buildSale(
              s,
              itemsBySaleId[s.id] ?? [],
              paymentRows: paysBySaleId[s.id] ?? const [],
            ),
          )
          .toList();
    });
  }

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch().asyncMap((salesData) async {
      if (salesData.isEmpty) return [];
      final saleIds = salesData.map((s) => s.id).toList();
      final allItems = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
      final itemsBySaleId = <String, List<SaleItemData>>{};
      for (final item in allItems) {
        (itemsBySaleId[item.saleId] ??= []).add(item);
      }
      final allPays = await (_db.select(
        _db.salePayments,
      )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
      final paysBySaleId = <String, List<SalePaymentData>>{};
      for (final pay in allPays) {
        (paysBySaleId[pay.saleId] ??= []).add(pay);
      }
      return salesData
          .map(
            (s) => _buildSale(
              s,
              itemsBySaleId[s.id] ?? [],
              paymentRows: paysBySaleId[s.id] ?? const [],
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> voidSale(String saleId, {String? reason}) async {
    await _db.transaction(() async {
      final sale =
          await (_db.select(_db.sales)
                ..where((s) => s.id.equals(saleId))
                ..where((s) => s.deletedAt.isNull()))
              .getSingleOrNull();
      if (sale == null) {
        throw NotFoundError('Sale', id: saleId);
      }
      if (sale.status == 'VOIDED') {
        throw const BusinessRuleError('SaleAlreadyVoided');
      }

      final now = DateTime.now();
      await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          status: const Value('VOIDED'),
          voidedAt: Value(now),
          voidReason: Value(reason),
          updatedAt: Value(now),
          version: Value(sale.version + 1),
        ),
      );

      final items = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())).get();

      final productIds = items.map((i) => i.productId).toSet().toList();
      final productRows = productIds.isEmpty
          ? <ProductData>[]
          : await (_db.select(
              _db.products,
            )..where((p) => p.id.isIn(productIds))).get();
      final productMap = {for (final p in productRows) p.id: p};

      final quantitiesByProduct = <String, int>{};
      for (final item in items) {
        quantitiesByProduct.update(
          item.productId,
          (quantity) => quantity + item.qty,
          ifAbsent: () => item.qty,
        );
      }

      for (final entry in quantitiesByProduct.entries) {
        final product = productMap[entry.key];

        if (product == null) {
          // Product deleted — still log reversal but skip stock restore.
          await inventoryLogService.logVoidReversal(
            productId: entry.key,
            qty: entry.value,
            saleId: saleId,
            balanceAfter: -1,
            reason: 'Product deleted since sale',
          );
          continue;
        }

        if (!product.trackStock) {
          await inventoryLogService.logVoidReversal(
            productId: product.id,
            qty: entry.value,
            saleId: saleId,
            balanceAfter: product.stock,
          );
          continue;
        }

        // Atomic restore: stock = stock + qty
        await _db.customUpdate(
          'UPDATE products SET stock = stock + ?, updated_at = ? '
          'WHERE id = ? AND track_stock = 1',
          variables: [
            Variable.withInt(entry.value),
            Variable.withDateTime(now),
            Variable.withString(product.id),
          ],
          updates: {_db.products},
        );
        final balRow =
            await (_db.select(_db.products)
                  ..where((p) => p.id.equals(product.id)))
                .getSingle();
        await inventoryLogService.logVoidReversal(
          productId: product.id,
          qty: entry.value,
          saleId: saleId,
          balanceAfter: balRow.stock,
        );
      }

      // Reverse customer totals so reporting reflects the void.
      // sale here is SaleData (raw DB row) — totalAmount is still double.
      if (sale.customerId != null) {
        await _applyCustomerSpentDelta(
          customerId: sale.customerId!,
          delta: -Money.fromDouble(sale.totalAmount),
          visitDelta: -1,
        );
      }
    });
  }
}
