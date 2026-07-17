const fs = require('fs');
const full = fs
  .readFileSync('lib/features/sale/presentation/bloc/cart_bloc.dart', 'utf8')
  .replace(/\r\n/g, '\n');

function between(start, end) {
  const s = full.indexOf(start);
  if (s < 0) throw new Error('no start ' + start.slice(0, 50));
  const e = end ? full.indexOf(end, s + 1) : full.lastIndexOf('\n}');
  if (e < 0) throw new Error('no end ' + String(end).slice(0, 50));
  return full.slice(s, e);
}

// Rewrite private field/method access for mixins on Bloc (not on CartBloc).
function rewriteForMixin(body) {
  return body
    .replace(/_productRepo/g, 'productRepo')
    .replace(/_settingsRepo/g, 'settingsRepo')
    .replace(/_promotionRepo/g, 'promotionRepo')
    .replace(/_rejectIfPaymentLocked/g, 'rejectIfPaymentLocked')
    .replace(/_qtyInCart/g, 'qtyInCart')
    .replace(/_schedulePromoRecompute/g, 'schedulePromoRecompute')
    .replace(/_promoBase/g, 'promoBase')
    .replace(/_clampDiscount/g, 'clampDiscount')
    .replace(/_barcodeDebounce/g, 'barcodeDebounce')
    .replace(/_lastScannedBarcode/g, 'lastScannedBarcode')
    .replace(/_lastScannedAt/g, 'lastScannedAt')
    .replace(/_onProductAdded/g, 'onProductAdded')
    .replace(/_onProductRemoved/g, 'onProductRemoved')
    .replace(/_onQtyChanged/g, 'onQtyChanged')
    .replace(/_onCartCleared/g, 'onCartCleared')
    .replace(/_onCartRestored/g, 'onCartRestored')
    .replace(/_onCartItemRestored/g, 'onCartItemRestored')
    .replace(/_onCartItemDuplicated/g, 'onCartItemDuplicated')
    .replace(/_onItemDiscountChanged/g, 'onItemDiscountChanged')
    .replace(/_onItemDiscountCleared/g, 'onItemDiscountCleared')
    .replace(/_onCartDiscountChanged/g, 'onCartDiscountChanged')
    .replace(/_onCartDiscountCleared/g, 'onCartDiscountCleared')
    .replace(/_onNoteChanged/g, 'onNoteChanged')
    .replace(/_onProductsRefreshed/g, 'onProductsRefreshed')
    .replace(/_onBarcodeScanned/g, 'onBarcodeScanned')
    .replace(/_onBulkItemsRemoved/g, 'onBulkItemsRemoved')
    .replace(/_onBulkItemDiscountsCleared/g, 'onBulkItemDiscountsCleared')
    .replace(/_onCartItemsReordered/g, 'onCartItemsReordered')
    .replace(/_onItemNoteChanged/g, 'onItemNoteChanged')
    .replace(/_onTableAssigned/g, 'onTableAssigned')
    .replace(/_onCustomerSet/g, 'onCustomerSet')
    .replace(/_onPromotionSet/g, 'onPromotionSet')
    .replace(/_onPromotionRecompute/g, 'onPromotionRecompute')
    .replace(/_onOrderTypeChanged/g, 'onOrderTypeChanged')
    .replace(/_onOrderChannelChanged/g, 'onOrderChannelChanged')
    .replace(/_onExternalOrderRefChanged/g, 'onExternalOrderRefChanged')
    .replace(/_onServiceChargeRateChanged/g, 'onServiceChargeRateChanged')
    .replace(/_onPaymentLockChanged/g, 'onPaymentLockChanged');
}

let discountSection = between(
  '  Future<void> _onItemDiscountChanged',
  '  void _onNoteChanged',
);
discountSection = discountSection.replace(
  /Future<\(String, double\)\?> _clampDiscount\(\{[\s\S]*?\n  \}\n\n  void _onCartDiscountCleared/,
  `Future<(String, double)?> clampDiscount({
    required String type,
    required double value,
  }) async {
    try {
      final settings = await settingsRepo.load();
      return CartDiscountPolicy.clamp(
        settings: settings,
        type: type,
        value: value,
      );
    } catch (e, stack) {
      return CartDiscountPolicy.clampOrRaw(
        settings: null,
        type: type,
        value: value,
        loadError: e,
        stack: stack,
      );
    }
  }

  void _onCartDiscountCleared`,
);

const lineSection =
  between('  void _onProductAdded', '  Future<void> _onItemDiscountChanged') +
  between('  void _onProductsRefreshed', '  static const _barcodeDebounce') +
  between('  void _onBulkItemsRemoved', '  void _onTableAssigned');

const barcodeSection = between(
  '  static const _barcodeDebounce',
  '  void _onBulkItemsRemoved',
);

const promoSection = between(
  '  Future<void> _onPromotionSet',
  '  void _onOrderTypeChanged',
);

const metaSection =
  between('  void _onPaymentLockChanged', '  int _qtyInCart') +
  between('  void _onNoteChanged', '  void _onProductsRefreshed') +
  between('  void _onTableAssigned', '  Future<void> _onPromotionSet') +
  between('  void _onOrderTypeChanged', null).replace(/\n\}\s*$/, '\n');

function wrap(name, comment, body) {
  const rewritten = rewriteForMixin(body);
  return (
    "part of 'cart_bloc.dart';\n\n" +
    `/// ${comment}\n` +
    `mixin ${name} on Bloc<CartEvent, CartState> {\n` +
    '  ProductRepository get productRepo;\n' +
    '  SettingsRepository get settingsRepo;\n' +
    '  PromotionRepository get promotionRepo;\n\n' +
    '  bool rejectIfPaymentLocked(Emitter<CartState> emit);\n' +
    '  int qtyInCart(String productId, {String? excludeLineId});\n' +
    '  void schedulePromoRecompute();\n' +
    '  Money promoBase(CartState s);\n\n' +
    rewritten.replace(/\n$/, '') +
    '\n}\n'
  );
}

// Discount mixin needs clampDiscount only on itself; barcode needs scan state fields.
function wrapBarcode(body) {
  const rewritten = rewriteForMixin(body);
  return (
    "part of 'cart_bloc.dart';\n\n" +
    '/// Barcode scan with debounce.\n' +
    'mixin CartBlocBarcodeHandlers on Bloc<CartEvent, CartState> {\n' +
    '  ProductRepository get productRepo;\n' +
    '  SettingsRepository get settingsRepo;\n\n' +
    '  bool rejectIfPaymentLocked(Emitter<CartState> emit);\n' +
    '  int qtyInCart(String productId, {String? excludeLineId});\n\n' +
    '  static const barcodeDebounce = Duration(milliseconds: 1000);\n' +
    '  String? lastScannedBarcode;\n' +
    '  DateTime? lastScannedAt;\n\n' +
    rewritten
      .replace(/static const barcodeDebounce = Duration\(milliseconds: 1000\);\n  String\? lastScannedBarcode;\n  DateTime\? lastScannedAt;\n\n/, '')
      .replace(/\n$/, '') +
    '\n}\n'
  );
}

function wrapDiscount(body) {
  const rewritten = rewriteForMixin(body);
  return (
    "part of 'cart_bloc.dart';\n\n" +
    '/// Item/cart discounts via CartDiscountPolicy.\n' +
    'mixin CartBlocDiscountHandlers on Bloc<CartEvent, CartState> {\n' +
    '  SettingsRepository get settingsRepo;\n\n' +
    '  bool rejectIfPaymentLocked(Emitter<CartState> emit);\n' +
    '  void schedulePromoRecompute();\n\n' +
    rewritten.replace(/\n$/, '') +
    '\n}\n'
  );
}

function wrapPromo(body) {
  const rewritten = rewriteForMixin(body);
  return (
    "part of 'cart_bloc.dart';\n\n" +
    '/// Promotion set / recompute.\n' +
    'mixin CartBlocPromoHandlers on Bloc<CartEvent, CartState> {\n' +
    '  PromotionRepository get promotionRepo;\n\n' +
    '  bool rejectIfPaymentLocked(Emitter<CartState> emit);\n' +
    '  Money promoBase(CartState s);\n\n' +
    rewritten.replace(/\n$/, '') +
    '\n}\n'
  );
}

function wrapMeta(body) {
  const rewritten = rewriteForMixin(body);
  return (
    "part of 'cart_bloc.dart';\n\n" +
    '/// Payment lock, notes, restaurant meta, customer.\n' +
    'mixin CartBlocMetaHandlers on Bloc<CartEvent, CartState> {\n' +
    '  bool rejectIfPaymentLocked(Emitter<CartState> emit);\n\n' +
    rewritten.replace(/\n$/, '') +
    '\n}\n'
  );
}

function wrapLine(body) {
  const rewritten = rewriteForMixin(body);
  return (
    "part of 'cart_bloc.dart';\n\n" +
    '/// Line CRUD, restore, bulk, reorder, catalog refresh.\n' +
    'mixin CartBlocLineHandlers on Bloc<CartEvent, CartState> {\n' +
    '  bool rejectIfPaymentLocked(Emitter<CartState> emit);\n' +
    '  int qtyInCart(String productId, {String? excludeLineId});\n' +
    '  void schedulePromoRecompute();\n\n' +
    rewritten.replace(/\n$/, '') +
    '\n}\n'
  );
}

const dir = 'lib/features/sale/presentation/bloc/';
fs.writeFileSync(dir + 'cart_bloc_line_handlers.dart', wrapLine(lineSection));
fs.writeFileSync(
  dir + 'cart_bloc_discount_handlers.dart',
  wrapDiscount(discountSection),
);
fs.writeFileSync(
  dir + 'cart_bloc_barcode_handlers.dart',
  wrapBarcode(barcodeSection),
);
fs.writeFileSync(dir + 'cart_bloc_promo_handlers.dart', wrapPromo(promoSection));
fs.writeFileSync(dir + 'cart_bloc_meta_handlers.dart', wrapMeta(metaSection));

const main = `import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_discount_policy.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

part 'cart_bloc_line_handlers.dart';
part 'cart_bloc_discount_handlers.dart';
part 'cart_bloc_barcode_handlers.dart';
part 'cart_bloc_promo_handlers.dart';
part 'cart_bloc_meta_handlers.dart';

/// Cart state machine. Handlers split into sibling mixins (D2.1); event API unchanged.
@lazySingleton
class CartBloc extends Bloc<CartEvent, CartState>
    with
        CartBlocLineHandlers,
        CartBlocDiscountHandlers,
        CartBlocBarcodeHandlers,
        CartBlocPromoHandlers,
        CartBlocMetaHandlers {
  CartBloc({
    required ProductRepository productRepo,
    required SettingsRepository settingsRepo,
    required PromotionRepository promotionRepo,
  }) : productRepo = productRepo,
       settingsRepo = settingsRepo,
       promotionRepo = promotionRepo,
       super(const CartState()) {
    on<CartProductAdded>(onProductAdded);
    on<CartProductRemoved>(onProductRemoved);
    on<CartItemQtyChanged>(onQtyChanged);
    on<CartCleared>(onCartCleared);
    on<CartRestored>(onCartRestored);
    on<CartItemRestored>(onCartItemRestored);
    on<CartItemDuplicated>(onCartItemDuplicated);
    on<CartItemDiscountChanged>(onItemDiscountChanged);
    on<CartItemDiscountCleared>(onItemDiscountCleared);
    on<CartDiscountChanged>(onCartDiscountChanged);
    on<CartDiscountCleared>(onCartDiscountCleared);
    on<CartNoteChanged>(onNoteChanged);
    on<CartProductsRefreshed>(onProductsRefreshed);
    // Async paths: run sequentially to avoid lost updates after await.
    on<CartBarcodeScanned>(onBarcodeScanned, transformer: sequential());
    on<CartBulkItemsRemoved>(onBulkItemsRemoved);
    on<CartBulkItemDiscountsCleared>(onBulkItemDiscountsCleared);
    on<CartItemsReordered>(onCartItemsReordered);
    on<CartItemNoteChanged>(onItemNoteChanged);
    on<CartTableAssigned>(onTableAssigned);
    on<CartCustomerSet>(onCustomerSet);
    on<CartPromotionSet>(onPromotionSet, transformer: sequential());
    on<CartPromotionRecompute>(
      onPromotionRecompute,
      transformer: sequential(),
    );
    on<CartOrderTypeChanged>(onOrderTypeChanged);
    on<CartOrderChannelChanged>(onOrderChannelChanged);
    on<CartExternalOrderRefChanged>(onExternalOrderRefChanged);
    on<CartServiceChargeRateChanged>(onServiceChargeRateChanged);
    on<CartPaymentLockChanged>(onPaymentLockChanged);
  }

  @override
  final ProductRepository productRepo;
  @override
  final SettingsRepository settingsRepo;
  @override
  final PromotionRepository promotionRepo;

  @override
  void schedulePromoRecompute() {
    if (state.promotionId != null) {
      add(const CartPromotionRecompute());
    }
  }

  @override
  Money promoBase(CartState s) =>
      (s.itemsSubtotal - s.cartDiscountAmount).clampToZero();

  bool get isPaymentLocked => state.paymentLocked;

  /// Mutations blocked while checkout is waitingPayment/processing.
  @override
  bool rejectIfPaymentLocked(Emitter<CartState> emit) {
    if (!state.paymentLocked) return false;
    emit(
      state.copyWith(
        errorMessage: 'paymentInProgress',
        errorNonce: state.errorNonce + 1,
      ),
    );
    return true;
  }

  @override
  int qtyInCart(String productId, {String? excludeLineId}) {
    var sum = 0;
    for (final i in state.items) {
      if (i.product.id != productId) continue;
      if (excludeLineId != null && i.lineId == excludeLineId) continue;
      sum += i.qty;
    }
    return sum;
  }
}
`;

fs.writeFileSync(dir + 'cart_bloc.dart', main);
console.log('split ok');
