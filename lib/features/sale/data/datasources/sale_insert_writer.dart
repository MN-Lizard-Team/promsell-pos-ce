import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_day_guard.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_helpers.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_side_effects.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

/// Create-sale pipeline (payable → tender → single DB transaction → hydrate).
class SaleInsertWriter {
  SaleInsertWriter(
    this._db, {
    required this.receiptNumberService,
    required this.inventoryLogService,
    required this.settingsRepo,
    required SaleQueryLocalDatasource query,
    required SaleWriteSideEffects sideEffects,
    required Future<String> Function() deviceId,
  }) : _query = query,
       _sideEffects = sideEffects,
       _deviceId = deviceId;

  final AppDatabase _db;
  final ReceiptNumberService receiptNumberService;
  final InventoryLogService inventoryLogService;
  final SettingsRepository settingsRepo;
  final SaleQueryLocalDatasource _query;
  final SaleWriteSideEffects _sideEffects;
  final Future<String> Function() _deviceId;

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
    // Wave P2: cash change SSOT = max(0, received − cashTender). Do not trust
    // client changeAmount (UI may have used full-bill formula).
    if (cashTender > Money.zero) {
      effectiveReceived = amountReceived ?? cashTender;
      final change = effectiveReceived - cashTender;
      effectiveChange = change > Money.zero ? change : Money.zero;
    } else if (headerMethod != 'cash' && amountReceived != null) {
      effectiveReceived = finalTotal;
      effectiveChange = Money.zero;
    } else {
      effectiveReceived = amountReceived;
      effectiveChange = changeAmount;
    }
    if (promotionId != null) {
      await _sideEffects.assertPromotionActive(promotionId);
    }

    final saleId = IdGenerator.newId();
    final deviceId = await _deviceId();
    late SaleData saleData;
    await _db.transaction(() async {
      await SaleDayGuard.assertCreateAllowed(_db);

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
      )..where((p) => p.id.isIn(productIds) & p.deletedAt.isNull())).get();
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
      final lineVats = SaleWriteHelpers.allocateLineVat(
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
                  SaleWriteHelpers.serializeSelectedOptions(
                    item.selectedOptions,
                  ),
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
          final balRow = await (_db.select(
            _db.products,
          )..where((p) => p.id.equals(product.id))).getSingle();
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
          final balRow = await (_db.select(
            _db.products,
          )..where((p) => p.id.equals(product.id))).getSingle();
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
        await _sideEffects.applyCustomerSpentDelta(
          customerId: customerId,
          delta: finalTotal,
          visitDelta: 1,
          requireActive: true,
        );
      }
    });
    final saleItems = await _query.itemsForSale(saleData.id);
    final paymentRows = await _query.paymentsForSale(saleId);
    return _query.buildSale(saleData, saleItems, paymentRows: paymentRows);
  }
}
