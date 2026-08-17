# Feature Modules API Reference

> **Scope note (v0.9.2):** This file documents a **subset** of APIs. Full feature list (13): `customer`, `daily_close`, `history`, `home`, `inventory`, `onboarding`, `product`, `promotion`, `receipt`, `report`, `restaurant_table`, `sale`, `settings` under `lib/features/`.


Public APIs for feature-level domain models, repositories, and use cases.

---

## Product Module

**Location:** `lib/features/product/`

### Product Entity

**Path:** `lib/features/product/domain/entities/product.dart`

#### Core Properties

```dart
class Product extends Equatable {
  final String id;                    // UUIDv4
  final String name;                  // Required
  final String? sku;                  // Stock Keeping Unit
  final String? barcode;              // EAN-13/8, UPC-A, Code 128
  final Money price;                  // Selling price (required)
  final Money cost;                   // Purchase cost (defaults to Money.zero)
  final int stock;                    // Current inventory level
  final String? categoryId;           // Foreign key to categories
  final String? imageUrl;             // Product image URL
  final String? imagePath;            // Product image path
  final String? imageThumbnailPath;   // 200x200 thumbnail
  final String? barcodeImagePath;     // Generated barcode PNG
  final String? description;          // Product description (v0.8.9+)
  final String? brand;                // Brand name
  final String? unit;                 // Unit of measure
  final String? supplier;             // Supplier name
  final bool isRecommended;           // Recommended flag
  final bool isActive;                // Soft delete flag
  final bool trackStock;              // Enable stock tracking
  final List<ProductOptionGroup> optionGroups;  // Modifier groups
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;                  // Optimistic locking version
}
```

#### Computed Properties

```dart
// In-stock check (non-tracking products always in stock)
bool get isInStock => !trackStock || stock > 0;

// Deprecated alias for categoryId
String? get category => categoryId;
```

### ProductRepository

**Path:** `lib/features/product/domain/repositories/product_repository.dart`

#### Interface

```dart
abstract class ProductRepository {
  // Queries
  Stream<List<Product>> watchAllProducts({int? limit});
  Future<List<Product>> getActiveProducts();
  Future<List<Product>> getAllProducts();   // active + inactive
  Future<int> getProductCount();            // non-deleted count
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<bool> barcodeExists(String barcode, {String? excludeId});
  Future<bool> skuExists(String sku, {String? excludeId});
  
  // Mutations
  Future<String> addProduct({
    required String name,
    String? sku,
    String? barcode,
    required double price,
    double? cost,
    required int stock,
    String? categoryId,
    String? imageUrl,
    String? imagePath,
    String? imageThumbnailPath,
    bool trackStock = true,
    bool isActive = true,
    String? description,
    String? brand,
    String? unit,
    String? supplier,
    bool isRecommended = false,
    List<ProductOptionGroup> optionGroups = const [],
  });
  Future<void> updateProduct(Product product, {List<ProductOptionGroup>? optionGroups});
  Future<void> bulkUpdateBarcodes(List<({String id, String barcode})> updates);
  Future<void> deleteProduct(String id);
  Future<void> restoreProduct(String id);   // Undo soft delete
}
```

#### Usage Example

```dart
// Watch products (reactive)
final products$ = repository.watchAllProducts(limit: 100);
await for (final products in products$) {
  print('Product count: ${products.length}');
}

// Get single product
final product = await repository.getProductById('abc-123');
if (product != null) {
  print('Price: ${product.price}');
}

// Check barcode uniqueness
final exists = await repository.barcodeExists(
  '2001234567890',
  excludeId: currentProductId,  // Exclude self when editing
);
```

### Use Cases

#### AddProduct

**Path:** `lib/features/product/domain/usecases/add_product.dart`

```dart
@injectable
class AddProduct {
  AddProduct(this._repository, this._imageService);
  
  final ProductRepository _repository;
  final ProductImageService _imageService;
  
  Future<String> call({
    required String name,
    required Money price,
    String? sku,
    String? barcode,
    String? categoryId,
    Money? cost,
    int stock = 0,
    bool trackStock = true,
    String? localImagePath,
    String? description,
    String? brand,
    String? unit,
    String? supplier,
    bool isRecommended = false,
  }) async {
    // Validate barcode uniqueness
    if (barcode != null && barcode.isNotEmpty) {
      final exists = await _repository.barcodeExists(barcode);
      if (exists) {
        throw DuplicateBarcodeException(barcode);
      }
    }
    
    // Process image if provided
    String? savedImagePath;
    String? thumbnailPath;
    if (localImagePath != null) {
      savedImagePath = await _imageService.saveProductImage(localImagePath);
      thumbnailPath = await _imageService.generateThumbnail(savedImagePath);
    }
    
    // Delegate to repository (returns generated ID)
    return _repository.addProduct(
      name: name,
      price: price.value,
      cost: cost?.value,
      sku: sku,
      barcode: barcode,
      categoryId: categoryId,
      stock: stock,
      trackStock: trackStock,
      isActive: true,
      imagePath: savedImagePath,
      imageThumbnailPath: thumbnailPath,
      description: description,
      brand: brand,
      unit: unit,
      supplier: supplier,
      isRecommended: isRecommended,
    );
  }
}
```

#### UpdateProduct

Similar to `AddProduct` but updates existing product and checks barcode uniqueness excluding self.

#### AdjustStock

**Path:** `lib/features/inventory/domain/usecases/adjust_stock.dart`

```dart
@injectable
class AdjustStock {
  AdjustStock(this._inventoryRepository);
  
  final InventoryRepository _inventoryRepository;
  
  Future<void> call({
    required String productId,
    required double adjustmentQty,  // Positive = in, Negative = out
    required String reason,
    String? notes,
  }) async {
    await _inventoryRepository.adjustStock(
      productId: productId,
      adjustmentQty: adjustmentQty,
      type: adjustmentQty > 0 ? 'in' : 'out',
      reason: reason,
      notes: notes,
    );
  }
}
```

---

## Sale Module

**Location:** `lib/features/sale/`

### Sale Entity

**Path:** `lib/features/sale/domain/entities/sale.dart`

#### Core Properties

```dart
class Sale extends Equatable {
  final String id;
  final String? receiptNumber;        // Nullable receipt number
  final String status;                // 'COMPLETED', 'VOIDED', etc.
  final Money subtotalAmount;         // Sum of all items
  final String? discountType;         // 'PERCENT' or flat amount type
  final double? discountValue;        // % or flat amount; amount storage also has satang
  final Money discountAmount;         // Calculated discount amount
  final String vatMode;               // 'NONE', 'EXCLUSIVE', 'INCLUSIVE'
  final double vatRate;               // VAT rate % (stays double)
  final Money vatAmount;              // Calculated VAT amount
  final Money totalAmount;            // Subtotal - discount + VAT + service
  final String paymentMethod;         // cash, card, promptpay, etc.
  final Money? amountReceived;        // Cash received (for change calc)
  final Money? changeAmount;          // Change due
  final String? note;                 // Sale-level note
  final String? paymentReference;     // Payment reference (e.g., biller ID)
  final String? sendingBankCode;      // PromptPay sending bank code
  final String orderType;             // dine-in, takeaway, delivery (default 'delivery')
  final String orderChannel;          // walkin, phone, online (default 'walkin')
  final String? externalOrderRef;     // External order reference
  final String? tableId;              // Restaurant table reference
  final double serviceChargeRate;     // Service charge % (stays double)
  final Money serviceChargeAmount;    // Calculated service charge
  final String? customerId;           // Optional customer reference
  final String? promotionId;          // Optional promotion applied
  final Money promotionDiscountAmount;// Discount from promotion
  final DateTime? voidedAt;           // Soft delete for voided sales
  final String? voidReason;           // Reason for voiding
  final DateTime createdAt;
  final List<SaleItem> items;         // Line items
  final List<SalePayment> payments;   // Multi-tender payment lines
}
```

#### Computed Properties

```dart
// Is this sale voided?
bool get isVoided => status == 'VOIDED';

// Single-tender: first payment method; multi may use header [paymentMethod]
String get primaryPaymentMethod =>
    payments.length == 1 ? payments.first.method : paymentMethod;
```

### SaleItem Entity

```dart
class SaleItem extends Equatable {
  final String id;
  final String saleId;                // Parent sale reference
  final String productId;
  final String productName;           // Snapshot for history
  final Money price;                  // Price at time of sale
  final int qty;                      // Quantity sold
  final Money subtotal;               // qty * price
  final Money discountAmount;         // Line-level discount (defaults to zero)
  final Money vatAmount;              // Line-level VAT (defaults to zero)
  final String? note;                 // Special instructions
  final List<SelectedProductOption> selectedOptions;  // Selected modifiers
  final DateTime? updatedAt;
  final DateTime? deletedAt;          // Soft delete
  final int version;                  // Optimistic locking version
  final String? deviceId;             // Device that created the line
}
```

### CartState

**Path:** `lib/features/sale/presentation/bloc/cart_state.dart`

#### State Properties

```dart
class CartState extends Equatable {
  final List<CartItem> items;
  final String note;                  // Cart-level note
  final String? cartDiscountType;     // 'PERCENT' or flat amount type
  final double? cartDiscountValue;    // % or flat amount
  final String orderType;             // dine-in, takeaway, delivery (default 'delivery')
  final String orderChannel;          // walkin, phone, online (default 'walkin')
  final String? externalOrderRef;     // External order reference
  final String? tableId;              // Restaurant table reference
  final double? serviceChargeRate;    // From settings (restaurant mode)
  final String? customerId;
  final String? promotionId;
  final double promotionDiscountAmount;  // Promotion discount (double baht)
  final String? stockWarning;         // Low stock warnings
  final String? errorMessage;         // Error message (not AppError)
  final String? lastFailedBarcode;    // Barcode that failed lookup
  final int errorNonce;               // Error increment counter
  final bool paymentLocked;           // Lock cart during payment

  // Private cached computed values (populated by copyWith)
  final Money? _cachedItemsSubtotal;
  final Money? _cachedCartDiscountAmount;
  final Money? _cachedTotal;
  final Money? _cachedServiceChargeAmount;

  // Computed getters (use cache if available, else compute on the fly)
  Money get itemsSubtotal => _cachedItemsSubtotal ?? _computeItemsSubtotal();
  Money get cartDiscountAmount => _cachedCartDiscountAmount ?? _computeCartDiscountAmount();
  Money get total => _cachedTotal ?? _computeTotal();
  Money get serviceChargeAmount => _cachedServiceChargeAmount ?? _computeServiceChargeAmount();

  // Payable SSOT (SC default + VAT) for display and checkout alignment
  SalePayableTotals payableTotals(Settings settings);
}
```

> **Note (v0.9.2):** `grandTotal` was removed — use `payableTotals(settings)` as the SSOT for payable calculations. Tender equality is exact integer satang at sale creation.

#### Cart Events

```dart
// Add product to cart
CartProductAdded(String productId, {int quantity = 1})

// Remove product from cart
CartProductRemoved(String productId, {String? lineId})

// Update quantity
CartItemQtyChanged(String productId, int newQty, {String? lineId})

// Update item note
CartItemNoteChanged(String lineId, String? note)

// Apply a cart discount
CartDiscountChanged(
  discountType: 'AMOUNT',
  discountValue: 10.0,
)

// Set customer
CartCustomerSet(String? customerId)

// Attach or clear a promotion; discount is resolved by the cart domain
CartPromotionSet('promo-id')

// Set restaurant fields
CartOrderTypeChanged(String? orderType)
CartTableSelected(String? tableId)

// Clear cart
CartCleared()
```

### SaleRepository

**Path:** `lib/features/sale/domain/repositories/sale_repository.dart`

```dart
abstract class SaleRepository {
  // Mutations
  Future<Sale> createSale({
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

  // Queries
  Future<List<Sale>> getSales({DateTime? from, DateTime? to});
  Future<Sale?> getSaleById(String id);
  Stream<List<Sale>> watchRecentSales({int limit = 20});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});

  // Void
  Future<void> voidSale(String saleId, {String? reason});  // Soft delete
}
```

### Use Cases

#### CreateSale

**Path:** `lib/features/sale/domain/usecases/create_sale.dart`

```dart
@injectable
class CreateSale {
  const CreateSale(this._repository, this._settingsRepo);

  final SaleRepository _repository;
  final SettingsRepository _settingsRepo;

  Future<Sale> call({
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
    // Validate cart + items
    Validators.nonEmptyCart(items);
    for (final item in items) {
      Validators.qty(item.qty);
      Validators.price(item.product.price.value);
    }

    // Sales-day lock check
    final settings = await _settingsRepo.load();
    if (SalesDayLock.isCreateBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
    )) {
      throw const BusinessRuleError(SalesDayLock.ruleDayClosed);
    }

    // Fiscal policy: clamp VAT rate and cart discount against settings
    final safeVatRate = vatRate.clamp(0.0, 100.0);
    // ... clamp cart discount type/value against settings limits ...

    // Recompute money from lines + clamped type/value (Wave D / AH-2.3)
    final itemsSubtotal = items.fold(Money.zero, (sum, i) => sum + i.subtotal);
    final recomputedCartDiscount = CartDiscountMath.amountFromTypeValue(
      type: safeCartDiscountType,
      value: safeCartDiscountValue,
      itemsSubtotal: itemsSubtotal,
    );
    final recomputedPromo = CartDiscountMath.clampPromotionToBase(
      itemsSubtotal: itemsSubtotal,
      cartDiscountAmount: recomputedCartDiscount,
      promotionDiscount: promotionDiscountAmount,
    );
    final recomputedServiceCharge = CartDiscountMath.serviceChargeFromRate(
      itemsSubtotal: itemsSubtotal,
      cartDiscountAmount: recomputedCartDiscount,
      promotionDiscountAmount: recomputedPromo,
      serviceChargeRate: safeServiceChargeRate,
    );

    // Delegate to repository (creates sale + items + payments, decrements stock)
    return _repository.createSale(
      items: items,
      paymentMethod: paymentMethod,
      vatMode: vatMode,
      vatRate: safeVatRate,
      cartDiscountType: safeCartDiscountType,
      cartDiscountValue: safeCartDiscountValue,
      cartDiscountAmount: recomputedCartDiscount,
      amountReceived: amountReceived,
      changeAmount: changeAmount,
      note: note,
      paymentReference: paymentReference,
      sendingBankCode: sendingBankCode,
      payments: payments,
      orderType: orderType,
      orderChannel: orderChannel,
      externalOrderRef: externalOrderRef,
      tableId: tableId,
      serviceChargeRate: safeServiceChargeRate,
      serviceChargeAmount: recomputedServiceCharge,
      customerId: customerId,
      promotionId: promotionId,
      promotionDiscountAmount: recomputedPromo,
    );
  }
}
```

#### VoidSale

```dart
@injectable
class VoidSale {
  VoidSale(this._saleRepository, this._productRepository);
  
  Future<void> call(String saleId) async {
    final sale = await _saleRepository.getSaleById(saleId);
    if (sale == null) {
      throw NotFoundError('Sale', id: saleId);
    }
    
    if (sale.isVoided) {
      throw BusinessRuleError('SaleAlreadyVoided');
    }
    
    // Void sale (triggers inventory reversal in repository)
    await _saleRepository.voidSale(saleId);
  }
}
```

---

## Customer Module (v0.8.9+)

**Location:** `lib/features/customer/`

### Customer Entity

```dart
class Customer extends Equatable {
  final String id;
  final String name;                  // Required
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;                // For VAT invoices
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### CustomerRepository

```dart
abstract class CustomerRepository {
  Stream<List<Customer>> watchAllCustomers();
  Stream<Customer?> watchCustomerById(String id);
  Future<Customer?> getById(String id);
  Future<void> insertCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
```

---

## Promotion Module (v0.8.9+)

**Location:** `lib/features/promotion/`

### Promotion Entity

```dart
enum PromotionType { percent, fixed }

class Promotion extends Equatable {
  final String id;
  final String name;                  // Display name
  final String? description;
  final PromotionType type;           // percent or fixed
  final double value;                 // % (0-100) or fixed amount
  final DateTime? startDate;          // Activation date
  final DateTime? endDate;            // Expiry date
  final bool isActive;                // Manual enable/disable
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Computed Properties

```dart
// Is promotion currently valid?
bool get isValid {
  if (!isActive) return false;
  
  final now = DateTime.now();
  if (startDate != null && now.isBefore(startDate!)) return false;
  if (endDate != null && now.isAfter(endDate!)) return false;
  
  return true;
}

// Calculate discount amount
Money calculateDiscount(Money subtotal) {
  if (type == PromotionType.percent) {
    return subtotal * (value / 100);
  } else {
    return Money.fromDouble(value);
  }
}
```

### PromotionRepository

```dart
abstract class PromotionRepository {
  Stream<List<Promotion>> watchAllPromotions();
  Stream<List<Promotion>> watchActivePromotions();
  Future<Promotion?> getById(String id);
  Future<void> insertPromotion(Promotion promotion);
  Future<void> updatePromotion(Promotion promotion);
  Future<void> deletePromotion(String id);
}
```

---

## Settings Module

**Location:** `lib/features/settings/`

### Settings Aggregate

**Path:** `lib/features/settings/domain/entities/settings.dart`

Settings is split into 14 typed group entities (v0.9.2):

```dart
class Settings extends Equatable {
  final ShopInfo shopInfo;
  final ReceiptConfig receiptConfig;
  final TaxConfig taxConfig;
  final DiscountConfig discountConfig;
  final StockConfig stockConfig;
  final ImageConfig imageConfig;
  final PaymentConfig paymentConfig;
  final DeviceConfig deviceConfig;
  final UiConfig uiConfig;
  final DailyCloseConfig dailyCloseConfig;
  final BackupConfig backupConfig;
  final DraftConfig draftConfig;
  final BarcodeConfig barcodeConfig;
  final BusinessConfig businessConfig;
  final bool onboardingCompleted;
  final int skuLastCounter;
  final String skuAutoGeneratePrefix;
}
```

### Example: UiConfig

```dart
class UiConfig extends Equatable {
  final String locale;                // 'th' or 'en'
  final String themeMode;             // 'light', 'dark', 'system'
  final String dateFormat;            // Date format string
  final bool ultraCompactMode;        // Ultra-compact cart UI
  final bool accessibilityMode;       // Accessibility mode
}
```

### SettingsRepository

```dart
abstract class SettingsRepository {
  Future<Settings> load();
  Future<void> save(Settings settings);
  Future<void> reset();
}
```

### SettingsCubit

**Path:** `lib/features/settings/presentation/cubit/settings_cubit.dart`

```dart
@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._service);
  
  final SettingsRepository _repository;
  final SettingsPersistenceService _service;
  
  // Load settings on app start
  Future<void> load() async { ... }
  
  // Update specific group
  Future<void> updateShopInfo(ShopInfo shopInfo) async { ... }
  Future<void> updateReceiptConfig(ReceiptConfig receiptConfig) async { ... }
  
  // Auto-save with debounce (500ms)
  void scheduleAutoSave(Settings settings) { ... }
}
```

---

## Repository Pattern

All feature repositories follow this structure:

```
lib/features/<feature>/
├── domain/
│   └── repositories/
│       └── <feature>_repository.dart      # Abstract interface
└── data/
    └── repositories/
        └── <feature>_repository_impl.dart # Implementation
```

### Why Abstract Interfaces?

**Domain independence:** Domain layer has zero external dependencies (no Flutter, no Drift, no packages).

**Testability:** Mock repositories in unit tests without database.

**Flexibility:** Swap datasource (SQLite → cloud) without changing domain logic.

### Dependency Injection

```dart
// Domain interface (abstract)
abstract class ProductRepository {
  Future<Product?> getProductById(String id);
}

// Data implementation (concrete)
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._localDatasource);
  
  final ProductLocalDatasource _localDatasource;
  
  @override
  Future<Product?> getProductById(String id) async {
    final data = await _localDatasource.getProductById(id);
    if (data == null) return null;
    return Product.fromData(data);  // Map database model to domain entity
  }
}
```

---

<sub>Promsell POS CE · v0.9.2 · Feature Modules API</sub>
