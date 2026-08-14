import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/draft_naming.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_bill_switch_guard.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_list_query.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

void main() {
  group('DraftBillSwitchGuard', () {
    test('blocks when paymentLocked', () {
      expect(
        DraftBillSwitchGuard.isBlocked(
          paymentLocked: true,
          checkoutStatus: CheckoutStatus.idle,
        ),
        isTrue,
      );
    });

    test('blocks waitingPayment and processing', () {
      expect(
        DraftBillSwitchGuard.isBlocked(
          paymentLocked: false,
          checkoutStatus: CheckoutStatus.waitingPayment,
        ),
        isTrue,
      );
      expect(
        DraftBillSwitchGuard.isBlocked(
          paymentLocked: false,
          checkoutStatus: CheckoutStatus.processing,
        ),
        isTrue,
      );
    });

    test('allows idle unlocked', () {
      expect(
        DraftBillSwitchGuard.isBlocked(
          paymentLocked: false,
          checkoutStatus: CheckoutStatus.idle,
        ),
        isFalse,
      );
    });
  });

  group('DraftNaming', () {
    test('uses tableId when set', () {
      expect(DraftNaming.autoName(tableId: 'T-5', itemCount: 0), 'T-5');
    });

    test('uses time and item count without table', () {
      final name = DraftNaming.autoName(
        tableId: null,
        itemCount: 2,
        now: DateTime(2026, 1, 1, 9, 5),
      );
      expect(name, 'B-0905 · 2');
    });

    test('empty cart auto is B-HHmm without qty suffix', () {
      expect(
        DraftNaming.forNewEmptyBill(now: DateTime(2026, 1, 1, 9, 5)),
        'B-0905',
      );
    });
  });

  group('DraftListQuery', () {
    final now = DateTime(2026, 1, 2);

    // itemCount 0 drafts only kept if active — seed with fake item counts via
    // empty lists means only active survives filter unless we add products.
    test('pins active and filters by tableId', () {
      final product = Product(
        id: 'p1',
        name: 'Rice',
        price: Money.fromDouble(20),
        stock: 5,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final withItems = [
        DraftCart(
          id: 'a',
          name: 'Active',
          items: [CartItem(product: product, qty: 1)],
          updatedAt: now,
        ),
        DraftCart(
          id: 'b',
          name: null,
          tableId: 'โต๊ะ 3',
          items: [CartItem(product: product, qty: 1)],
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      ];
      final sorted = DraftListQuery.filterAndSort(
        withItems,
        activeId: 'a',
        query: 'โต๊ะ',
        settings: const Settings(),
      );
      expect(sorted.map((d) => d.id), ['b']);
    });

    test('matches note and product name', () {
      final product = Product(
        id: 'p1',
        name: 'Somtum',
        price: Money.fromDouble(50),
        stock: 5,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final d = DraftCart(
        id: 'c',
        name: 'X',
        note: 'no onion',
        items: [CartItem(product: product, qty: 1)],
        updatedAt: now,
      );
      expect(DraftListQuery.matchesQuery(d, 'onion'), isTrue);
      expect(DraftListQuery.matchesQuery(d, 'somtum'), isTrue);
      expect(DraftListQuery.matchesQuery(d, 'zzz'), isFalse);
    });
  });
}
